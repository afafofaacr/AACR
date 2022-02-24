/**
 * Created by lauren.lezberg on 6/3/2019.
 */

public with sharing class JP_RequiredDocumentationController {


    @AuraEnabled
    public static RequiredDocumentation getRequiredDocuments(Id salesOrderId, Id stepId){
        if(stepId!=null){JP_Helper.upsertLastAccessedStep(stepId);}
        Id contactId = ECRMUtils.getCurrentLoginUserContactId();
        String itemName;
        if(salesOrderId!=null){
            itemName = getMembershipItemName(salesOrderId);
        } else {
            itemName = [SELECT Process__r.Item__c FROM Process_Steps__mdt WHERE Id=: stepId LIMIT 1].Process__r.Item__c;
        }

        set<Id> setDocumentIds = new set<Id>();
        List<ContentDocumentLink> cdls = [SELECT ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId =: contactId];
        for(ContentDocumentLink cdl: cdls){
            setDocumentIds.add(cdl.ContentDocumentId);
        }
        List<ContentVersion> cvs = [SELECT Id, Title, ContentDocumentId, ContentModifiedDate, LastModifiedDate FROM ContentVersion WHERE IsLatest=true AND ContentDocumentId IN: setDocumentIds AND Description LIKE: '%JoinProcess%' ORDER BY CreatedDate DESC];
        return new RequiredDocumentation(contactId, cvs, itemName);
    }

    public static String getMembershipItemName(Id salesOrderId){
        List<OrderApi__Sales_Order_Line__c> soLines = [SELECT Id, OrderApi__Item__r.Name FROM OrderApi__Sales_Order_Line__c WHERE OrderApi__Sales_Order__c=: salesOrderId AND OrderApi__Item_Class__r.Name='Individual Memberships'];
        if(soLines!=null && soLines.size()==1){
            return soLines[0].OrderApi__Item__r.Name;
        }
        return null;
    }

    public class RequiredDocumentation{
        @AuraEnabled
        public Id contactId;

        @AuraEnabled
        public List<ContentVersion> attachments = new List<ContentVersion>();

        @AuraEnabled
        public String itemName;

        public RequiredDocumentation(Id contactId, List<ContentVersion> attachments, String itemName){
            this.contactId = contactId;
            this.attachments = new List<ContentVersion>();
            this.attachments.addAll(attachments);
            this.itemName = itemName;
        }
    }
}