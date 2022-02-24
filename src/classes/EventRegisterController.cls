/**
 * Created by lauren.lezberg on 7/9/2020.
 */

public without sharing class EventRegisterController {


    @AuraEnabled
    public static RegistrationInfo getRegistrationFieldset(String eventId, String salesOrderId) {
        System.debug('getRegistrationFieldset with eventId: ' + eventId + ' and salesOrderId: ' + salesOrderId);
        String contactId = ECRMUtils.getCurrentLoginUserContactId();
        List<BR_Participation__c> tickets = [SELECT Id FROM BR_Participation__c WHERE Participate__c = 'Yes' AND BR_Event__c = :eventId AND Contact__c = :contactId];
        if (tickets.size() == 0) {

            String regURL = null;
            if (salesOrderId == null) {
                regURL = brPurchaseTicketController.getTicketPurchaseUrl(eventId);
                System.debug('regURL: ' + regURL);
                regURL = regURL.substringAfter('&salesOrder=');
                salesOrderId = regURL.substringBefore('&eventId');

            } else {
                //if empty sales order - i.e. OFFER - create new line
                List<OrderApi__Sales_Order_Line__c> lines = [SELECT Id FROM OrderApi__Sales_Order_Line__c WHERE OrderApi__Sales_Order__c = :salesOrderId];
                if (lines.isEmpty()) {
                    OrderApi__Item__c ticketItem = [SELECT Id FROM OrderApi__Item__c WHERE AC_Event__c = :eventId];
                    OrderApi__Sales_Order_Line__c line = new OrderApi__Sales_Order_Line__c(OrderApi__Item__c = ticketItem.Id, OrderApi__Sales_Order__c = salesOrderId, OrderApi__Price_Override__c = true);
                    insert line;
                    updateTicket(eventId, salesOrderId);
                }
            }

            List<BR_Event__c> evts = [SELECT Registration_Form_Fieldset__c,Show_Joint_Fields__c, Advocate__c, Show_Workshop_Fields__c, Show_Pre_Post_Doc__c FROM BR_Event__c WHERE Id = :eventId];
            if (!evts.isEmpty()) {
                return new RegistrationInfo(evts[0].Registration_Form_Fieldset__c, salesOrderId, evts[0].Advocate__c, evts[0].Show_Workshop_Fields__c, evts[0].Show_Pre_Post_Doc__c, evts[0].Show_Joint_Fields__c);
            }
        }


        return null;
    }

    @AuraEnabled
    public static String getParticipantFromSO(String salesOrderId) {
        List<BR_Participation__c> tickets = [SELECT Id FROM BR_Participation__c WHERE Fon_Sales_Order__c = :salesOrderId];
        if (!tickets.isEmpty()) {
            return tickets[0].Id;
        }
        return null;
    }

    @AuraEnabled
    public static String getJointInstitutionName(String participantId){
        List<BR_Participation__c> tickets = [SELECT Id, BR_Event__r.Joint_Providership_Institution__r.Name FROM BR_Participation__c WHERE Id =:participantId];
        if (!tickets.isEmpty()) {
            return tickets[0].BR_Event__r.Joint_Providership_Institution__r.Name;
        }
        return null;
    }

    @AuraEnabled
    public static ContentVersion getPrePostDocCertification(String contactId){
        set<Id> setDocumentIds = new set<Id>();
        List<ContentDocumentLink> cdls = [SELECT ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId =: contactId];
        if(!cdls.isEmpty()) {
            for (ContentDocumentLink cdl : cdls) {
                setDocumentIds.add(cdl.ContentDocumentId);
            }
            List<ContentVersion> cvs = [SELECT Id, Title, ContentDocumentId, ContentModifiedDate, LastModifiedDate FROM ContentVersion WHERE IsLatest = true AND ContentDocumentId IN:setDocumentIds AND Description LIKE:'Pre/Post Doc%' ORDER BY CreatedDate DESC];
            if (!cvs.isEmpty()) {
                return cvs[0];
            }
        }

        return null;
    }

    @AuraEnabled
    public static void updateTicket(String eventId, String salesOrderId) {
        String contactId = ECRMUtils.getCurrentLoginUserContactId();

        List<BR_Participation__c> tickets = [SELECT Id FROM BR_Participation__c WHERE BR_Event__c = :eventId AND Contact__c = :contactId];

        List<OrderApi__Sales_Order_Line__c> lines = [SELECT Id, OrderApi__Sales_Order__r.OrderApi__Source_Code__c FROM OrderApi__Sales_Order_Line__c WHERE OrderApi__Sales_Order__c = :salesOrderId];
        if (!lines.isEmpty()) {

            Map<String, AC_Event_User_Segment__c> priceMap = brEventParticipationManager.getTicketPrice(eventId, UserInfo.getUserId());
            AC_Event_User_Segment__c uSegment = null;
            for (String key : priceMap.keySet()) {
                if (priceMap.get(key).Early_Bird_Price__c != null && Datetime.now() < priceMap.get(key).Early_Bird_Price_Deadline__c) {
                    lines[0].OrderApi__Sale_Price__c = priceMap.get(key).Early_Bird_Price__c;
                } else if (priceMap.get(key).On_Demand_Price__c != null && Datetime.now() >= priceMap.get(key).On_Demand_Start_Date__c) {
                    lines[0].OrderApi__Sale_Price__c = priceMap.get(key).On_Demand_Price__c;
                } else {
                    lines[0].OrderApi__Sale_Price__c = priceMap.get(key).Price__c;
                }
                uSegment = priceMap.get(key);
            }
            
            if (lines[0].OrderApi__Sales_Order__r.OrderApi__Source_Code__c != null) { //source code applied
                lines[0].OrderApi__Sale_Price__c = 0.0;
            }

            tickets[0].AC_User_Segment__c = uSegment.AC_User_Segment__c;
            tickets[0].Fon_Sales_Order__c = salesOrderId;
            lines[0].AC_User_Segment__c = uSegment.AC_User_Segment__c;
        } else {
            //if empty sales order - i.e. OFFER - create new line
            if (lines.isEmpty()) {
                OrderApi__Item__c ticketItem = [SELECT Id FROM OrderApi__Item__c WHERE AC_Event__c = :eventId];
                OrderApi__Sales_Order_Line__c line = new OrderApi__Sales_Order_Line__c(OrderApi__Item__c = ticketItem.Id, OrderApi__Sales_Order__c = salesOrderId, OrderApi__Price_Override__c = true);
                insert line;
                updateTicket(eventId, salesOrderId);
            }
        }

        try {
            update lines[0];

            update tickets[0];

        } catch (Exception e) {
            System.debug('exception: ' + e.getMessage());
        }
    }

    public class RegistrationInfo {
        @AuraEnabled
        public String contactId;

        @AuraEnabled
        public String fieldsetName;

        @AuraEnabled
        public String salesOrderId;

        @AuraEnabled
        public Boolean advocate;

        @AuraEnabled
        public Boolean showWorkshopFields;

        @AuraEnabled
        public Boolean showPrePostDoc;

        @AuraEnabled
        public Boolean showJointFields;


        public RegistrationInfo(String fsName, String SOID, Boolean advocate, Boolean workshop, Boolean prePostDoc, Boolean joint) {
            this.fieldsetName = fsName;
            this.contactId = ECRMUtils.getCurrentLoginUserContactId();
            this.salesOrderId = SOID;
            this.advocate = advocate;
            this.showWorkshopFields = workshop;
            this.showPrePostDoc = prePostDoc;
            this.showJointFields = joint;

        }
    }

}