/**
 * Created by lauren.lezberg on 12/12/2018.
 */

public with sharing class AuraHelper {

//    public class membershipData{
//
//        @AuraEnabled
//        public List<RecordType> recordTypes;
//
//        @AuraEnabled
//        public List<OrderApi__Item__c> items;
//
//        public membershipData(List<RecordType> recordTypes, List<OrderApi__Item__c> membershipTypes){
//            this.recordTypes = recordTypes;
//            this.items = membershipTypes;
//        }
//    }
//
//    @AuraEnabled
//    public static membershipData getMembershipTypes(){
//        List<RecordType> recordTypes = getRecordTypes('Contact');
//        List<OrderApi__Item__c> items = [SELECT Name, Id FROM OrderApi__Item__c WHERE OrderApi__Item_Class__r.Name = 'Individual Memberships' AND OrderApi__Is_Active__c = true];
//        if(items.size()>0 && recordTypes.size()>0){
//            return new membershipData(recordTypes, items);
//        }
//        return null;
//    }
//
//
//    @AuraEnabled
//    public static Boolean createContactRecord(String lastName, Id recordTypeId, String membershipStatus, Boolean yopify, String memberType, Boolean nonMember ){
//        System.debug('createContactRecord was just called with lastname: ' + lastName + ' recordTypeId: ' + recordTypeId + ' membershipStatus: ' + membershipStatus + ' yopify: ' + yopify + ' memberType: ' + memberType + ' nonMember: ' + nonMember);
//
//        Account acct = [SELECT Id FROM Account WHERE Name='AACR Test Accounts' LIMIT 1];
//        Contact newContact = new Contact();
//        if(!nonMember){
//            newContact.FirstName = 'TEST';
//            newContact.LastName = lastName;
//            newContact.RecordTypeId = recordTypeId;
//            newContact.AccountId = acct.Id;
//            newContact.Email = lastName + '@yopmail.com';
//            newContact.Phone = '555-555-5555';
//            newContact.Initial_Join_Date__c = Date.newInstance(System.now().year()-6, 01, 03);
//        } else {
//            newContact.Member_Type__c = memberType;
//        }
//
//        OrderApi__Item__c item = [SELECT Id FROM OrderApi__Item__c WHERE Name=: memberType];
//        OrderApi__Subscription_Plan__c subPlan = [SELECT Id FROM OrderApi__Subscription_Plan__c ORDER BY CreatedDate LIMIT 1];
//
//        OrderApi__Subscription__c sub = new OrderApi__Subscription__c();
//        sub.OrderApi__Account__c = acct.Id;
//        sub.OrderApi__Contact__c = newContact.Id;
//        sub.OrderApi__Entity__c = 'Contact';
//        sub.OrderApi__Subscription_Plan__c = subPlan.Id;
//        sub.OrderApi__Item__c = item.Id;
//        if(membershipStatus == null && !nonMember){
//            newContact.Membership_Status__c = 'Current';
//            newContact.Paid_thru_date__c = Date.newInstance(System.now().year(), 12, 31);
//            sub.OrderApi__Current_Term_Start_Date__c = Date.newInstance(System.now().year(), 01, 01);
//            sub.OrderApi__Current_Term_End_Date__c = Date.newInstance(System.now().year(), 12, 31);
//            sub.OrderApi__Grace_Period_End_Date__c = Date.newInstance(System.now().year() + 1 , 01, 30);
//        } else{
//            newContact.Membership_Status__c = membershipStatus;
//            if(membershipStatus == '1-YR Suspended') {
//                newContact.Paid_thru_date__c = Date.newInstance(System.now().year()-1, 12, 31);
//                sub.OrderApi__Current_Term_Start_Date__c = Date.newInstance(System.now().year()-1, 01, 01);
//                sub.OrderApi__Current_Term_End_Date__c = Date.newInstance(System.now().year()-1, 12, 31);
//                sub.OrderApi__Grace_Period_End_Date__c = Date.newInstance(System.now().year(), 01, 30);
//            } else if(membershipStatus== '2-YR Suspended'){
//                newContact.Paid_thru_date__c = Date.newInstance(System.now().year()-2, 12, 31);
//                sub.OrderApi__Current_Term_Start_Date__c = Date.newInstance(System.now().year()-2, 01, 01);
//                sub.OrderApi__Current_Term_End_Date__c = Date.newInstance(System.now().year()-2, 12, 31);
//                sub.OrderApi__Grace_Period_End_Date__c = Date.newInstance(System.now().year()-1, 01, 30);
//            } else if(membershipStatus == 'Suspended(Delinquent)'){
//                newContact.Paid_thru_date__c = Date.newInstance(System.now().year()-3, 12, 31);
//                sub.OrderApi__Current_Term_Start_Date__c = Date.newInstance(System.now().year()-3, 01, 01);
//                sub.OrderApi__Current_Term_End_Date__c = Date.newInstance(System.now().year()-3, 12, 31);
//                sub.OrderApi__Grace_Period_End_Date__c = Date.newInstance(System.now().year()-2, 01, 30);
//            } else if (membershipStatus == 'Suspended(Resigned)'){
//                newContact.Paid_thru_date__c = Date.newInstance(System.now().year()-5, 12, 31);
//                sub.OrderApi__Current_Term_Start_Date__c = Date.newInstance(System.now().year()-5, 01, 01);
//                sub.OrderApi__Current_Term_End_Date__c = Date.newInstance(System.now().year()-5, 12, 31);
//                sub.OrderApi__Grace_Period_End_Date__c = Date.newInstance(System.now().year()-4, 01, 30);
//            }
//        }
//
//        try{
//            insert newContact;
//            insert sub;
//            return true;
//        } catch(DmlException e){
//            System.debug('Error: ' + e.getMessage());
//            return false;
//        }
//
//    }


    @AuraEnabled
    public static List<RecordType> getRecordTypes(String sObjectType){
        return [SELECT Id, Name FROM RecordType WHERE SobjectType =: sObjectType AND IsActive = true ORDER BY Name];
    }

//    @AuraEnabled
//    public static List<Maintenance_Mode_Config__mdt> getSiteConfigs(){
//        return [SELECT Id, Is_Active__c, Maintenance_Message__c,Page_API_Name__c, Label, DeveloperName, MasterLabel, Description__c FROM Maintenance_Mode_Config__mdt ORDER BY Is_Active__c DESC];
//    }
//
//    @AuraEnabled
//    public static void saveMdtConfig(Maintenance_Mode_Config__mdt record){
//
//        Metadata.CustomMetadata customMetadata =  new Metadata.CustomMetadata();
//        customMetadata.fullName = 'Maintenance_Mode_Config__mdt.' + record.DeveloperName;
//        customMetadata.label = record.MasterLabel;
//
//        Metadata.CustomMetadataValue isActive = new Metadata.CustomMetadataValue();
//        isActive.field = 'Is_Active__c';
//        isActive.value = record.Is_Active__c;
//        customMetadata.values.add(isActive);
//
//        Metadata.CustomMetadataValue message = new Metadata.CustomMetadataValue();
//        message.field = 'Maintenance_Message__c';
//        message.value = record.Maintenance_Message__c;
//        customMetadata.values.add(message);
//
//        Metadata.CustomMetadataValue pageName = new Metadata.CustomMetadataValue();
//        pageName.field = 'Page_API_Name__c';
//        pageName.value = record.Page_API_Name__c;
//        customMetadata.values.add(pageName);
//
//        Metadata.DeployContainer mdContainer = new Metadata.DeployContainer();
//        mdContainer.addMetadata(customMetadata);
//
//        MetadataCallback callback = new MetadataCallback();
//
//        Id jobId = Test.isRunningTest() ? '7074F00000TFipCQAT' : Metadata.Operations.enqueueDeployment(mdContainer, callback);
//        System.debug('jobId: ' + jobId);
//
//    }

}