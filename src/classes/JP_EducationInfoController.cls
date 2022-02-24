/**
 * Created by lauren.lezberg on 1/28/2019.
 */

public without sharing class JP_EducationInfoController {

    @AuraEnabled
    public static void deferAndTransfer(String salesOrderId){
        OrderApi__Sales_Order__c so = [SELECT Id, OrderApi__Status__c, OrderApi__Contact__c FROM OrderApi__Sales_Order__c WHERE Id=: salesOrderId];
        so.OrderApi__Status__c = 'Cancelled';
        update so;

//        Contact con = [SELECT Id FROM Contact WHERE Id=: so.OrderApi__Contact__c];
//        con.Application_Status__c = 'Deferred';
//        update con;
    }

    @AuraEnabled
    public static void deferMember(String contactId){

        Messaging.SingleEmailMessage[] messages =   new List<Messaging.SingleEmailMessage>();

        String orgWideEmailId = [SELECT Id FROM OrgWideEmailAddress WHERE DisplayName = 'AACR Membership'].Id;
        EmailTemplate et = [SELECT Id, HtmlValue, Body FROM EmailTemplate WHERE Name='Membership: Ineligible' LIMIT 1];

        Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
        message.setTargetObjectId(contactId);
        message.setTreatTargetObjectAsRecipient(true);
        message.setTemplateId(et.Id);
        message.setOrgWideEmailAddressId(orgWideEmailId);
//        message.setSenderDisplayName('AACR Membership');

        messages.add(message);

        if (!messages.isEmpty()) {
            try {
                Messaging.sendEmail(messages);
            } catch (EmailException ex) {
                new AACRCustomException(ex.getMessage(), ex.getStackTraceString(), 'Ineligible Member');
            }
        }
    }
 
    /**
     * @purpose Retrieve any Education__c records for current contact
     *
     * @return EducationData wrapper object with all relevant education information
     */
    @AuraEnabled
    public static EducationData getEducationData(Id stepId){
        System.debug('getEducationData...');
        JP_Helper.upsertLastAccessedStep(stepId);
        Id contactId = ECRMUtils.getCurrentLoginUserContactId();
        System.debug('gettingEducationData for ' + contactId);
        List<Education__c> educationRecords = [SELECT Name, Current_Education_Status__c, Date_of_Expected_Graduation__c, Degree__c,
                                                Degree_Completion_Year__c,Degree_Level__c, Education_Related_to_Contact__c
                                                FROM Education__c
                                                WHERE Education_Related_to_Contact__c =: contactId];
        List<String> statusList = ECRMUtils.getPicklistValues('Education__c', 'Current_Education_Status__c');
        List<String> degrees = ECRMUtils.getPicklistValues('Education__c','Degree__c');
        return new EducationData(degrees, statusList, educationRecords, contactId);
    }

    @AuraEnabled
    public static void deleteEducation(Education__c record){
        delete record;
    }

    public class EducationData{
        @AuraEnabled
        public Id contactId;

        @AuraEnabled
        public List<String> degrees;

        @AuraEnabled
        public List<String> statusList;

        @AuraEnabled
        public List<Education__c> educations;

        public EducationData(List<String> degrees, List<String> statusList, List<Education__c> educations, Id contactId){
            this.degrees = degrees;
            this.statusList = statusList;
            this.educations  = educations;
            this.contactId = contactId;
        }

    }

}