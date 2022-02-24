/**
 * Created by lauren.lezberg on 1/30/2020.
 */

public with sharing class ModifyMembershipController {

    /**
     * @purpose Determine if Modify Membership button should appear on contact record based on contact subscriptions and current users permissions
     *
     * @param contactId
     *
     * @return True or False
     */
    @AuraEnabled
    public static Boolean getShowModify(String contactId){
        if(FeatureManagement.checkPermission('Modify_Membership')) {
            List<OrderApi__Subscription__c> memberships = RenewalUtils.getIndividualMembershipSubscription(contactId);
            if (!memberships.isEmpty()) {
                if (memberships[0].OrderApi__Paid_Through_Date__c.year() >= System.now().year() && memberships[0].OrderApi__Is_Active__c){
                    return true;
                }
            }
        }

        return false;

    }

    /**
     * @purpose Create an empty sales order and retrieve modify membership join process id
     *
     * @param contactId
     *
     * @return Map of sales order id and join process id for url construction
     */
    @AuraEnabled
    public static Map<String, String> createModifySalesOrder(String contactId){
        Map<String, String> toReturn = new Map<String, String>();
        //create sales order
        OrderApi__Sales_Order__c SO = new OrderApi__Sales_Order__c(OrderApi__Contact__c=contactId);
        insert SO;

        //get modify membership join process id
        Id jpRecordId = [SELECT Id FROM Join_Process__mdt WHERE DeveloperName='Modify_Membership' LIMIT 1].Id;
        toReturn.put(SO.Id, jpRecordId);

        return toReturn;
    }

    /**
     * @purpose Removes membership item from sales order so a new subscription doesn't get created
     * (**Fonteva workaround - needed to be added to sales order to fire correct price rules for any subscription additions)
     *
     * @param salesOrderId
     */
    @AuraEnabled
    public static void removeMembershipFromSO(String salesOrderId){
        List<OrderApi__Sales_Order_Line__c> linesToDelete = new List<OrderApi__Sales_Order_Line__c>();
        List<OrderApi__Sales_Order_Line__c> linesToUpdate = new List<OrderApi__Sales_Order_Line__c>();
        List<OrderApi__Sales_Order_Line__c> soLines = [SELECT Id, OrderApi__Item__c, OrderApi__Item_Class__r.Name FROM OrderApi__Sales_Order_Line__c WHERE OrderApi__Sales_Order__c=: salesOrderId];
        for(OrderApi__Sales_Order_Line__c line : soLines){
            System.debug('line: ' + line);
            if(line.OrderApi__Item_Class__r.Name == 'Individual Memberships'){
                linesToDelete.add(line);
//                soLines = OrderEntryFormController.removeItem(line.OrderApi__Item__c, salesOrderId);
            } else {
                line.OrderApi__Price_Override__c = true;
                linesToUpdate.add(line);
            }
        }

        delete linesToDelete;
        update linesToUpdate;
    }



    /**
    * @purpose Adds a selected to item to a specified sales order with the specified subscription plan and activation date. Based on the subscription plan and activation date, the correct GL will be used.
    *
    * @param itemId
    * @param subPlanId
    * @param futureEndDate
    * @param salesOrderId
    *
    * @return List of all sales order lines including added line
    */
    @AuraEnabled
    public static List<OrderApi__Sales_Order_Line__c> addSelectedItemToSO(String itemId, String subPlanId, String salesOrderId){
        System.debug('adding selected item: ' + itemId );

        if(itemId!=null) {

            //add sales order line with added item with price override set to true -- when we remove membership item during payment we want the correct price rules to stay applied
            OrderApi__Sales_Order_Line__c newLine = new OrderApi__Sales_Order_Line__c(OrderApi__Item__c = itemId, OrderApi__Sales_Order__c = salesOrderId);
            if(subPlanId!=null) {
                newLine.OrderApi__Subscription_Plan__c = subPlanId;
            }
            newLine.OrderApi__Activation_Date__c = Date.newInstance(System.now().year(), 1, 1);

            insert newLine;

        }

        return ECRMUtils.getAllSalesOrderLines(salesOrderId);
    }

    /**
     * @purpose Removes selected item from sales order by deleting sales order line
     *
     * @param itemId
     * @param salesOrderId
     *
     * @return
     */
    @AuraEnabled
    public static List<OrderApi__Sales_Order_Line__c> removeSelectedItemFromSO(String itemId, String salesOrderId ){
        return OrderEntryFormController.removeItem(itemId, salesOrderId);
    }


    /**
     * @purpose Retrieve basic info for modifying membership - existing sales order lines, current subscriptions and subscription plan based on renewal setting
     *
     * @param salesOrderId
     *
     * @return ModifyInfo instance
     */
    @AuraEnabled
    public static ModifyInfo getModifyInfo(String salesOrderId){
        Id contactId = [SELECT OrderApi__Contact__c FROM OrderApi__Sales_Order__c WHERE Id=: salesOrderId].OrderApi__Contact__c;
        List<OrderApi__Subscription__c> currentSubs = new List<OrderApi__Subscription__c>();

        //get most recent membership subscription
        List<OrderApi__Subscription__c> memSubs = RenewalUtils.getIndividualMembershipSubscription(contactId);
        if(!memSubs.isEmpty()){
            String subscriptionPlanId;
            if(memSubs[0].OrderApi__Item__r.Managed__c) {
                //get subscription plan based on whether renewals are on or off
                Renewal_Settings__c renewalProcess = Renewal_Settings__c.getInstance();
                if (renewalProcess.Is_Active__c) { // if renewals are ON
                    if (memSubs[0].OrderApi__Paid_Through_Date__c.year() == System.now().year()) {
                        OrderApi__Item_Subscription_Plan__c isp = [SELECT OrderApi__Subscription_Plan__c FROM OrderApi__Item_Subscription_Plan__c WHERE OrderApi__Item__c = :memSubs[0].OrderApi__Item__c AND OrderApi__Is_Default__c = true];
                        subscriptionPlanId = isp.OrderApi__Subscription_Plan__c;
                    } else {
                        subscriptionPlanId = [SELECT Id FROM OrderApi__Subscription_Plan__c WHERE OrderApi__Is_Active__c = true AND Show_In_Portal__c = false AND OrderApi__Advanced_Calendar_Days__c = 365 AND OrderApi__Type__c = 'Calendar'].Id;
                        //for 2 YR sub plan, sales order needs to reflect the is2yr checkbox
                        OrderApi__Sales_Order__c SO = [SELECT id FROM OrderApi__Sales_Order__c WHERE Id = :salesOrderId];
                        SO.Is2YR__c = true;
                        update SO;
                    }
                } else { // if renewals are OFF - default to 1yr sub plan
                    OrderApi__Item_Subscription_Plan__c isp = [SELECT OrderApi__Subscription_Plan__c FROM OrderApi__Item_Subscription_Plan__c WHERE OrderApi__Item__c = :memSubs[0].OrderApi__Item__c AND OrderApi__Is_Default__c = true];
                    subscriptionPlanId = isp.OrderApi__Subscription_Plan__c;
                }
            } else {
                if(!memSubs[0].OrderApi__Item__r.Name.contains('Emeritus') && !memSubs[0].OrderApi__Item__r.Name.contains('Honorary')) {
                    OrderApi__Item_Subscription_Plan__c isp = [SELECT OrderApi__Subscription_Plan__c FROM OrderApi__Item_Subscription_Plan__c WHERE OrderApi__Item__c = :memSubs[0].OrderApi__Item__c AND OrderApi__Is_Default__c = true];
                    subscriptionPlanId = isp.OrderApi__Subscription_Plan__c;
                }
            }

            //get existing sales order lines & if membership item is not present, add it
            List<OrderApi__Sales_Order_Line__c> lines = ECRMUtils.getAllSalesOrderLines(salesOrderId);
            Boolean hasMembershipItem = false;
            for(OrderApi__Sales_Order_Line__c line : lines){
                if(line.OrderApi__Item_Class__r.Name == 'Individual Memberships'){
                    hasMembershipItem = true;
                }
            }

            //if there is no membership line -- add one based on their most recent membership subscription and set price override to $0
            if(!hasMembershipItem){
                OrderApi__Sales_Order_Line__c sol = new OrderApi__Sales_Order_Line__c(OrderApi__Item__c= memSubs[0].OrderApi__Item__c, OrderApi__Sales_Order__c=salesOrderId, OrderApi__Price_Override__c = true, OrderApi__Sale_Price__c=0.0);
                insert sol;

                lines = ECRMUtils.getAllSalesOrderLines(salesOrderId);
            }

            return new ModifyInfo(subscriptionPlanId, lines, contactId);

        }

        return null;
    }


    public class ModifyInfo {
        @AuraEnabled
        public Id contactId;

        @AuraEnabled
        public List<OrderApi__Sales_Order_Line__c> soLines;

        @AuraEnabled
        public Id subPlanId;

        public ModifyInfo(Id subPlanId, List<OrderApi__Sales_Order_Line__c> lines, Id contactId){
            this.subPlanId = subPlanId;
            this.soLines = lines;
            this.contactId = contactId;
        }
    }



}