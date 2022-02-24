/**
 * Created by lauren.lezberg on 7/15/2021.
 */

public with sharing class AdvocateAppReviewController {

    public class AdvocateInfoDTO{
        @AuraEnabled
        public Contact con;

        @AuraEnabled
        public List<BR_Participation__c> tickets;

        public AdvocateInfoDTO(Contact c, List<BR_Participation__c> participations){
            this.con = c;
            this.tickets = new List<BR_Participation__c>();
            this.tickets.addAll(participations);
        }
    }


    @AuraEnabled
    public static Boolean getButtonVisibility(String contactId){
        Boolean showButton = true;
        Contact con = [SELECT Advocate__c FROM Contact WHERE Id=:contactId];
        if(con.Advocate__c){
            showButton = false;
        }
        return showButton && FeatureManagement.checkPermission('Advocate Review');
    }

    @AuraEnabled
    public static AdvocateInfoDTO getAdvocateInfo(String contactId){
        Contact con = [SELECT Advocate__c, Primary_Stakeholder__c, Primary_Stakeholder_Other__c,
                        Secondary_Stakeholder__c, Secondary_Stakeholder_Other__c, Name
                        FROM Contact d
                        WHERE Id=:contactId];
        List<BR_Participation__c> participations = [SELECT Id, BR_Event__r.Name, AC_User_Segment__r.Name, Fon_Sales_Order__c, Fon_Sales_Order__r.Name, Fon_Sales_Order__r.OrderApi__Total__c
                                                FROM BR_Participation__c WHERE Participate__c = 'Pending Approval'];

        return new AdvocateInfoDTO(con, participations);

    }

    @AuraEnabled
    public static Boolean approveAdvocate(String contactId){
        //get & update contact for ticket pricing
        Contact con = [SELECT Advocate__c, Primary_Stakeholder__c, Primary_Stakeholder_Other__c,
                        Secondary_Stakeholder__c, Secondary_Stakeholder_Other__c
                        FROM Contact
                        WHERE Id=:contactId];
        con.Advocate__c = true;
        update con;

        //get user to calculate ticket price
        User u = [SELECT Id FROM User WHERE ContactId=:contactId];

        //get participation records
        List<BR_Participation__c> participations = [SELECT Id, BR_Event__c, Contact__r.Name, Contact__r.FirstName, Contact__r.LastName,
                                                    Contact__r.DonorApi__Suffix__c, Contact__r.Salutation,
                                                    BR_Event__r.Name, AC_User_Segment__r.Name, Fon_Sales_Order__c
                                                    FROM BR_Participation__c
                                                    WHERE Contact__c=:contactId AND Participate__c = 'Pending Approval'];

        if(!participations.isEmpty()) {
            List<OrderApi__Sales_Order_Line__c> linesToUpdate = new List<OrderApi__Sales_Order_Line__c>();
            //loop through participation records to update with status and price
            for (BR_Participation__c p : participations) {
                //get sales order lines to update
                List<OrderApi__Sales_Order_Line__c> lines = [
                        SELECT OrderApi__Sales_Order__c, OrderApi__Sale_Price__c,
                                AC_User_Segment__c
                        FROM OrderApi__Sales_Order_Line__c
                        WHERE OrderApi__Sales_Order__c = :p.Fon_Sales_Order__c
                ];

                //recalculate price
                Map<String, AC_Event_User_Segment__c> priceMap = brEventParticipationManager.getTicketPrice(p.BR_Event__c, u.Id);
                System.debug('priceMap: ' + priceMap);
                DOuble ticketPrice = 0.0;
                AC_Event_User_Segment__c uSegment = null;
                for (String key : priceMap.keySet()) {
                    if (priceMap.get(key).Early_Bird_Price__c != null && Datetime.now() < priceMap.get(key).Early_Bird_Price_Deadline__c) {
                        ticketPrice = priceMap.get(key).Early_Bird_Price__c;
                    } else if (priceMap.get(key).On_Demand_Price__c != null && Datetime.now() >= priceMap.get(key).On_Demand_Start_Date__c) {
                        System.debug('on demand: ' + priceMap.get(key).On_Demand_Price__c);
                        ticketPrice = priceMap.get(key).On_Demand_Price__c;
                    } else {
                        ticketPrice = priceMap.get(key).Price__c;
                    }

                    uSegment = priceMap.get(key);
                }
                //update line
                lines[0].OrderApi__Sale_Price__c = ticketPrice;
                lines[0].AC_User_Segment__c = uSegment.AC_User_Segment__c;
                linesToUpdate.add(lines[0]);

                //update participant fields
                p.Participate__c = 'Awaiting Payment';
                p.AC_User_Segment__c = uSegment.AC_User_Segment__c;
            }


            try {

                update linesToUpdate;

                update participations;

                //send approval emails
                sendAdvocateApprovalEmails(participations);
                return true;
            } catch (Exception e) {
                System.debug('Exception: ' + e);
                new AACRCustomException(contactId, e.getMessage(), e.getStackTraceString(), 'Advocate Rate Approval');
                return false;
            }
        }

        return true;

    }

    @AuraEnabled
    public static Boolean rejectAdvocate(String contactId, String rejectMsg){
       Contact con = [SELECT Advocate__c, Primary_Stakeholder__c, Primary_Stakeholder_Other__c,
                    Secondary_Stakeholder__c, Secondary_Stakeholder_Other__c
                    FROM Contact
                    WHERE Id=:contactId];

        con.Advocate__c = false;
        con.Primary_Stakeholder__c = null;
        con.Primary_Stakeholder_Other__c = null;
        con.Secondary_Stakeholder__c = null;
        con.Secondary_Stakeholder_Other__c = null;


        List<BR_Participation__c> participations = [SELECT Id, BR_Event__c, Contact__r.Name, Contact__r.FirstName,
                                                    Contact__r.LastName, Contact__r.DonorApi__Suffix__c,
                                                    Contact__r.Salutation, BR_Event__r.Name, AC_User_Segment__r.Name,
                                                    Fon_Sales_Order__c
                                                    FROM BR_Participation__c
                                                    WHERE Contact__c=:contactId AND Participate__c = 'Pending Approval'];

        for(BR_Participation__c p : participations){
            p.Participate__c = 'Incomplete';
        }

        if(!participations.isEmpty()) {
            try {
                update con;

                update participations;

                //send approval emails
                sendAdvocateRejectionEmails(participations, rejectMsg);
                return true;
            } catch (Exception e) {
                System.debug('Exception: ' + e);
                new AACRCustomException(contactId, e.getMessage(), e.getStackTraceString(), 'Advocate Rate Rejection');
                return false;
            }
        }

        return true;

    }

    private static void sendAdvocateRejectionEmails(List<BR_Participation__c> participations, String msg){
        System.debug('sendAdvocateRejectionEmails....');
        Messaging.SingleEmailMessage[] messages =   new List<Messaging.SingleEmailMessage>();
        EmailTemplate et = [SELECT Id, HtmlValue, Body FROM EmailTemplate WHERE Name='Advocate Rate Rejection'];

        String orgWideEmailId = BrEventsHelper.getConfigValue('org wide email id');

        for(BR_Participation__c participation : participations) {
            Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
            message.setTargetObjectId(participation.Contact__c);
            message.setWhatId(participation.BR_Event__c);
            message.setOrgWideEmailAddressId(orgWideEmailId);
            message.setTreatTargetObjectAsRecipient(true);


            String body = et.HtmlValue.replace('{!Contact.FirstName}', participation.Contact__c != null ? participation.Contact__r.FirstName : '')
                    .replace('{!Contact.LastName}', participation.Contact__r.LastName)
                    .replace('{!Contact.Salutation}', participation.Contact__r.Salutation!=null?participation.Contact__r.Salutation:'')
                    .replace('{!Contact.DonorApi__Suffix__c}', participation.Contact__r.DonorApi__Suffix__c!=null?participation.Contact__r.DonorApi__Suffix__c:'')
                    .replace('{!BR_Event__r.Name}', participation.BR_Event__r.Name)
                    .replace('{!SalesOrderId}', participation.Fon_Sales_Order__c)
                    .replace('{!rejectionMsg}', msg!=null?msg:'');
            message.setHtmlBody(body);
            message.setTemplateId(et.Id);

            messages.add(message);
        }

        if (!messages.isEmpty()) {
            try {
                Messaging.sendEmail(messages);
            } catch (EmailException ex) {
                new AACRCustomException(ex.getMessage(), ex.getStackTraceString(), 'Advocate Rate Rejection Email');
            }
        }
    }


    private static void sendAdvocateApprovalEmails(List<BR_Participation__c> participations){
        Messaging.SingleEmailMessage[] messages =   new List<Messaging.SingleEmailMessage>();
        EmailTemplate et = [SELECT Id, HtmlValue, Body FROM EmailTemplate WHERE Name='Advocate Rate Approval'];
        String orgWideEmailId = BrEventsHelper.getConfigValue('org wide email id');

        for(BR_Participation__c participation : participations) {
            Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
            message.setTargetObjectId(participation.Contact__c);
            message.setWhatId(participation.BR_Event__c);
            message.setOrgWideEmailAddressId(orgWideEmailId);
            message.setTreatTargetObjectAsRecipient(true);
            message.setReplyTo('advocacy@aacr.org');


            String body = et.HtmlValue.replace('{!Contact.FirstName}', participation.Contact__c != null ? participation.Contact__r.FirstName : '')
                        .replace('{!Contact.LastName}', participation.Contact__r.LastName)
                        .replace('{!Contact.Salutation}', participation.Contact__r.Salutation!=null?participation.Contact__r.Salutation:'')
                        .replace('{!SalesOrderId}', participation.Fon_Sales_Order__c);
            message.setHtmlBody(body);
            message.setTemplateId(et.Id);

            messages.add(message);
        }

        if (!messages.isEmpty()) {
            try {
                Messaging.sendEmail(messages);
            } catch (EmailException ex) {
                new AACRCustomException(ex.getMessage(), ex.getStackTraceString(), 'Advocate Rate Approval Email');
            }
        }
    }

}