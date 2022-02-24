/**
 * Created by lauren.lezberg on 3/18/2020.
 */

public with sharing class BackOfficeTicketPurchaseController {

    public class TicketAccess{
        @AuraEnabled
        public Boolean hasAccess;

        @AuraEnabled
        public Boolean hasDisabledAccess;
    }
    
    @AuraEnabled
    public static TicketAccess checkAccess(String contactId){
        TicketAccess ta = new TicketAccess();
        ta.hasAccess = true;
        ta.hasDisabledAccess = false;

        List<User> users = [SELECT Id FROM User WHERE ContactId=:contactId AND IsActive = true];
        if(users.isEmpty()){
            ta.hasDisabledAccess = true;
        }
        ta.hasAccess = FeatureManagement.checkPermission('Ticketing');
        System.debug('checkAccess: ' + ta );
        return ta;
    }


    @AuraEnabled
    public static TicketingInfo createBackOfficeTicketSO(Id contactId){
        OrderApi__Sales_Order__c SO = new OrderApi__Sales_Order__c(OrderApi__Contact__c=contactId);
        try {
            insert SO;
            List<Join_Process__mdt> joinProcesses = [SELECT Id FROM Join_Process__mdt WHERE DeveloperName = 'Back_Office_Live' LIMIT 1];
            return new TicketingInfo(SO.Id, joinProcesses[0].Id);
        } catch(Exception e){
            new AACRCustomException(contactId, e.getMessage(), e.getStackTraceString(), 'Back Office Ticketing'); 
            System.debug('Could not create sales order: ' + e.getMessage());
        }
        return null;
    }

    public class TicketingInfo{
        @AuraEnabled
        public String salesOrderId;

        @AuraEnabled
        public String joinId;

        public TicketingInfo(String soId, String jId){
            this.salesOrderId = soId;
            this.joinId = jId;
        }

    }
}