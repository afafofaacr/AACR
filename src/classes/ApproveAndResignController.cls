/**
 * Created by lauren.lezberg on 5/15/2019.
 */

public with sharing class ApproveAndResignController {
    /**
     * @purpose Get all record types for a particular object type
     *
     * @param sObjectType
     *
     * @return List of record types
     */
    @AuraEnabled
    public static List<RecordType> getRecordTypes(String sObjectType){
        return ECRMUtils.getRecordTypes(sObjectType);
    }


    /**
     * @purpose Resign specified contact member, end any committees, subscriptions, and badges they may be a part of and disable their directory access badge
     *
     * @param contactId
     *
     * @return Success or Failure
     */
    @AuraEnabled
    public static Boolean resignMember(Id contactId){ 
        System.debug('resigning member: ' + contactId);
        /** Expire Committees **/
        List<Committee_Member__c> committeeMemberships = [SELECT Id, End_Date__c FROM Committee_Member__c WHERE Committee_Member__c=: contactId];
        System.debug('found committee memberships: ' + committeeMemberships);
        if(committeeMemberships.size()>0) {
            for (Committee_Member__c membership : committeeMemberships) {
                if(membership.End_Date__c == null) {
                    membership.End_Date__c = Date.today();
                }
            }
        }

        /** Update Contact Status and Record Type **/
        Contact con = [SELECT Id, Membership_Status__c, Initial_Join_Date__c FROM Contact WHERE Id=: contactId];

        Id priorRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Prior Member').getRecordTypeId();
        con.Membership_Status__c = 'Suspended (Resigned)';
        con.RecordTypeId = priorRecordTypeId;

        /** Cancel Subscriptions **/
        /** Get all active membership subscriptions **/
        List<OrderApi__Subscription__c> memSubs = RenewalUtils.getIndividualMembershipSubscription(con.Id);
        List<OrderApi__Subscription__c> allSubs = new List<OrderApi__Subscription__c>();
        if(!memSubs.isEmpty()) {
            allSubs = [
                    SELECT Id
                    FROM OrderApi__Subscription__c
                    WHERE OrderApi__Contact__c = :con.Id AND
                    OrderApi__Item__r.OrderApi__Is_Active__c = true AND
                    OrderApi__Subscription_Plan__r.OrderApi__Is_Active__c = true AND
                    OrderApi__Is_Cancelled__c = false AND
                    OrderApi__Is_Active__c = true
            ];

            /** Cancel all subscriptions from List **/
            for (OrderApi__Subscription__c sub : allSubs) {
                sub.OrderApi__Is_Cancelled__c = true;
                sub.OrderApi__Cancelled_Reason__c = 'Resigned';
            }
        }

            /** Cancel Badges **/
            /** Get badge to Expire (Badges with Sales Orders)**/
            List<OrderApi__Badge__c> oldBadges = [
                    SELECT Id
                    FROM OrderApi__Badge__c
                    WHERE OrderApi__Item__c != NULL
                    AND OrderApi__Is_Active__c = true
                    AND (Active_Lookup__c =: con.Id OR Inactive_Lookup__c =: con.Id)
            ];

        
            /**Remove sales order line lookup **/
            if ( !oldBadges.isEmpty() ) {
            for(OrderApi__Badge__c badge : oldBadges) {
                badge.OrderApi__Sales_Order_Line__c = null;
                badge.OrderApi__Is_Active__c = false;
                badge.OrderApi__Expired_Date__c = Date.today().addDays(-1);
                }
            }

        try{
            if(committeeMemberships.size()>0) {
                System.debug('committee membership records to update: ' + committeeMemberships);
                update committeeMemberships;
            }
            if(allSubs.size()>0) {
                update allSubs;
            }
            if(oldBadges.size()>0) {
                update oldBadges;
            }
            update con;
            return BadgeUtils.revokeDirectoryAccess(contactId);

        } catch(Exception e){
            System.debug('Error resigning member: ' + e.getMessage());
            return false;
        }

    }

    /**
     * @purpose Approve contact record by setting their Membership Status, Application Status, Record Type, Initial Join Date and removing their directory access badge
     *
     * @param contactId
     *
     * @return
     */
    @AuraEnabled
    public static Boolean approveMember(Id contactId){
        System.debug('approving member: ' + contactId);

        Contact con = [SELECT Id, Membership_Status__c, Application_Status__c, Initial_Join_Date__c FROM Contact WHERE Id=: contactId];

        if(con.Application_Status__c == 'Pending Approval') {

            Id memberRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Member').getRecordTypeId();
            con.Membership_Status__c = 'Current';
            con.Application_Status__c = null;
            con.RecordTypeId = memberRecordTypeId;

            //only update join date if it's null
            if (con.Initial_Join_Date__c == null) {
                Renewal_Settings__c renewalProcess = Renewal_Settings__c.getInstance();
                List<OrderApi__Subscription__c> memSubs = RenewalUtils.getIndividualMembershipSubscription(con.Id);
                if (memSubs[0].OrderApi__Current_Term_Start_Date__c.year() == renewalProcess.Term_Year__c && renewalProcess.Is_Active__c) {
                    con.Initial_Join_Date__c = memSubs[0].OrderApi__Current_Term_Start_Date__c;
                } else {
                    con.Initial_Join_Date__c = Date.today();
                }
            }

            update con;

            try {
                return BadgeUtils.enableDirectoryAccess(contactId);
            } catch (Exception e) {
                System.debug('Could not approve member: ' + e.getMessage());
                return false;
            }
        } else if(con.Application_Status__c == 'Pending Transfer' || con.Application_Status__c == 'Pending Reinstatement' || con.Application_Status__c == 'Pending Reinstatement-Transfer'){
            OrderApi__Sales_Order__c so = [SELECT Id, OrderApi__Total__c, Is_Transfer__c, Is_Reinstatement__c FROM OrderApi__Sales_Order__c
                                                                                    WHERE (Is_Transfer__c  = TRUE
                                                                                    OR Is_Reinstatement__c = TRUE)
                                                                                    AND OrderApi__Status__c = 'Open'
                                                                                    AND OrderApi__Contact__c =: con.Id
                                                                                    ORDER BY CreatedDate DESC LIMIT 1]; 
            if(so.Is_Transfer__c && !so.Is_Reinstatement__c) {
                //cancel old subs
                ECRMUtils.cancelAllSubscriptionsWithBadges(con.Id, 'Transfer');
            }

            if(so.OrderApi__Total__c != 0.0) { //if order requires payment
                //convert contact to awaiting payment
                con.Application_Status__c = 'Awaiting Payment';

                //send customer invoice
                CustomInvoiceController.emailReceipt(so.Id);
            } else {
                //clear status
                Id memberRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Member').getRecordTypeId();
                con.Membership_Status__c = 'Current';
                con.Application_Status__c = null;
                con.RecordTypeId = memberRecordTypeId;
                //close & post $0 order
                so.OrderApi__Status__c = 'Closed';
                so.OrderApi__Posting_Status__c = 'Posted';
                update so;

                //send customer approval
                sendApprovalEmail(con.Id);

            }
            update con;

            return true;
        }


        return false;
    }

    @AuraEnabled
    public static void sendApprovalEmail(String contactId){
        Contact con = [SELECT Id, Salutation, FirstName, LastName, DonorApi__Suffix__c, AACR_ID__c, Member_Type__c FROM Contact WHERE Id=: contactId];

        Member_Count__c memberCount  = [SELECT Count__c FROM Member_Count__c];

        // the contents of the attachment from the pdf
        Blob pdfbody;

        String orgWideEmailId = [SELECT Id FROM OrgWideEmailAddress WHERE DisplayName = 'AACR Membership'].Id;
        EmailTemplate emailTemplate = [SELECT Id, HtmlValue, Body FROM EmailTemplate WHERE DeveloperName = 'Member_Welcome_Email'];

        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        String body = emailTemplate.HtmlValue;
        body = body.replace('{!Contact.Salutation}', String.isBlank(con.Salutation) ? '' : con.Salutation)
                .replace('{!Contact.FirstName}', con.FirstName)
                .replace('{!Contact.LastName}', con.LastName)
                .replace('{!Contact.AACR_ID__c}', con.AACR_ID__c)
                .replace('{!Contact.DonorApi__Suffix__c}', String.isBlank(con.DonorApi__Suffix__c) ? '' : con.DonorApi__Suffix__c)
                .replace('{!Contact.Member_Type__c}', con.Member_Type__c)
                .replace('{!$Setup.Member_Count__c.Count__c}', memberCount.Count__c);

        mail.setTargetObjectId(con.Id);
        mail.setOrgWideEmailAddressId(orgWideEmailId);
        mail.setTreatTargetObjectAsRecipient(true);
        mail.setUseSignature(false);
        mail.setSubject('Welcome to the American Association for Cancer Research!');
        mail.setHtmlBody(body);

        try {
            Messaging.sendEmail(new Messaging.SingleEmailMessage[]{
                    mail
            });
        }catch (EmailException e){
            new AACRCustomException(con.Id, e.getMessage(), e.getStackTraceString(), 'Approval Email');
        }

    }



    public class ApproveResignData{
        @AuraEnabled
        public Boolean showApprove;

        @AuraEnabled
        public Boolean showResign;

        public ApproveResignData(Id contactId){
            showApprove = getShowApprove(contactId);
            showResign = getShowResign(contactId);
        }
    }

    /**
     * Get all approve and resign data as well as button visibility for the given contact
     *
     * @param contactId
     *
     * @return
     */
    @AuraEnabled
    public static ApproveResignData getButtonVisibility(String contactId){
        System.debug('checking button visibility for contact: ' + contactId);
        return new ApproveResignData(contactId);
    }


    /**
     * @purpose Determines whether the current user should see the approve button for a given contact record
     * Checks whether the contact membership is unapproved and if the user has the approve permission
     *
     * @param contactId
     *
     * @return Success or failure
     */
    public static Boolean getShowApprove(Id contactId){
        System.debug('getShowApprove for contact: ' + contactId);
        Boolean showApprove = false;
//        List<OrderApi__Subscription__c> memSubs = RenewalUtils.getIndividualMembershipSubscription(contactId);
//        if(memSubs!=null && !memSubs.isEmpty()){
            System.debug('Contact has subscriptions');
                Contact con = [SELECT Application_Status__c FROM Contact WHERE Id=: contactId];
                if(con.Application_Status__c!=null) {
                    if (con.Application_Status__c.contains('Pending')) {
                        showApprove = true;
                    }
                }
//        }


        return showApprove && FeatureManagement.checkPermission('Membership_Approve');
    }


    /**
     * @purpose Determines whether the current user should see the resign button for a given contact record
     * Checks whether the contact has a subscription and associated membership record
     *
     * @param contactId
     *
     * @return Success or failure
     */
    public static Boolean getShowResign(Id contactId){
        Boolean showResign = false;
        List<OrderApi__Subscription__c> memSubs = RenewalUtils.getIndividualMembershipSubscription(contactId);
        if(memSubs!=null && !memSubs.isEmpty()){
            Contact con = [SELECT RecordType.Name, Membership_Status__c FROM Contact WHERE Id=: contactId];
            if(con.RecordType.Name == 'Member' || con.RecordType.Name == 'Prior Member' && con.Membership_Status__c!='Suspended (Resigned)') {
                showResign = true;
            }
        }

        return showResign && FeatureManagement.checkPermission('Membership_Resign');
    }


}