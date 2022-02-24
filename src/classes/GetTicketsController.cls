/**
 * Created by lauren.lezberg on 10/7/2019.
 */

public with sharing class GetTicketsController {

    /**
     * @purpose Checks if user has access to the back office ticketing system
     *
     * @return True or False
     */
    @AuraEnabled
    public static Boolean checkAccess(){
        System.debug('checkAccess: ' + FeatureManagement.checkPermission('Ticketing') );
        return FeatureManagement.checkPermission('Ticketing');
    }

    /**
     * @purpose Creates a sales order and retrieves correct join id
     *
     * @param contactId
     *
     * @return Instance of TicketingInfo class
     */
    @AuraEnabled
    public static TicketingInfo createBackOfficeTicketSO(Id contactId){
        OrderApi__Sales_Order__c SO = new OrderApi__Sales_Order__c(OrderApi__Contact__c=contactId);
        try {
            insert SO;
            List<Join_Process__mdt> joinProcesses = [SELECT Id FROM Join_Process__mdt WHERE DeveloperName = 'Back_Office_Ticketing' LIMIT 1];
            return new TicketingInfo(SO.Id, joinProcesses[0].Id);
        } catch(Exception e){
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