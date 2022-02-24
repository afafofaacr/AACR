/**
 * Created by lauren.lezberg on 8/8/2019.
 */

public with sharing class NewApplicationController {


    /**
     * @purpose Determines whether to show the new application button
     * Criteria: Does current user have custom permission & does contact have any subscriptions
     *
     * @param contactId
     *
     * @return True or False
     */
    @AuraEnabled
    public static Boolean showNewApplicationButton(String contactId){

        if(FeatureManagement.checkPermission('New_Application')) {
//            List<OrderApi__Subscription__c> individualMemSubList = RenewalUtils.getIndividualMembershipSubscription(contactId);
//            if (individualMemSubList.isEmpty()) {
            //check for any membership subscriptions that ever existed regardless of status
            Integer subCount = [SELECT COUNT() FROM OrderApi__Subscription__c WHERE OrderApi__Item_Class__r.Name='Individual Memberships' AND OrderApi__Contact__c=: contactId];
            if(subCount==0){ //if user never had any membership subscription
                return true;
            } else {
                return false;
            }
        }
        return false;
    }

    /**
     * @purpose Creates an empty sales order for back order processing and find correct join process for new application
     *
     * @param contactId
     *
     * @return Instance of NewApplicationInfo class
     */
    @AuraEnabled
    public static NewApplicationInfo createBackOfficeSO(Id contactId){
        OrderApi__Sales_Order__c SO = new OrderApi__Sales_Order__c(OrderApi__Contact__c=contactId);
        try {
            insert SO;
            List<Join_Process__mdt> joinProcesses = [SELECT Id FROM Join_Process__mdt WHERE DeveloperName = 'Back_Office_Order' LIMIT 1];
            return new NewApplicationInfo(SO.Id, joinProcesses[0].Id);
        } catch(Exception e){
            System.debug('Could not create sales order: ' + e.getMessage());
        }
        return null;
    }

    public class NewApplicationInfo{
        @AuraEnabled
        public String salesOrderId;

        @AuraEnabled
        public String joinId;


        public NewApplicationInfo(String soId, String jId){
            this.salesOrderId = soId;
            this.joinId = jId;
        }

    }
}