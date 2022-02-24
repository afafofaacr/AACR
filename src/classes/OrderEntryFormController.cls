/**
 * Created by lauren.lezberg on 10/24/2019.
 */

public with sharing class OrderEntryFormController {

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
    public static List<OrderApi__Sales_Order_Line__c> addSelectedItem(String itemId, String subPlanId, Boolean futureEndDate, String salesOrderId) {
        System.debug('adding selected item: ' + itemId);
        System.debug('subPlanId: ' + subPlanId);
        System.debug('futureEndDate: ' + futureEndDate);

        Renewal_Settings__c renewalProcess = Renewal_Settings__c.getInstance();
        List<OrderApi__Sales_Order_Line__c> linesToInsert = new List<OrderApi__Sales_Order_Line__c>();

        if (itemId != null) {
            //get item
            List<OrderApi__Item__c> items = [
                    SELECT Id, Name, OrderApi__Is_Subscription__c, OrderApi__Item_Class__c,
                            OrderApi__Item_Class__r.Name, Future_Income_Account__c, OrderApi__Income_Account__c, Managed__c
                    FROM OrderApi__Item__c
                    WHERE Id = :itemId
            ];
            OrderApi__Subscription_Plan__c subPlan;
            OrderApi__Subscription_Plan__c lifetimeSubPlan;

            /** create initial sales order line**/
            OrderApi__Sales_Order_Line__c newLine = new OrderApi__Sales_Order_Line__c(OrderApi__Item__c = itemId, OrderApi__Sales_Order__c = salesOrderId);

            /** only do logic for subscription items **/
            if (items[0].OrderApi__Is_Subscription__c) {
                /** if sub plan is provided  **/
                if (subPlanId != null) {
                    /** set sub plan **/
                    newLine.OrderApi__Subscription_Plan__c = subPlanId;
                    /** if future end date - set future gl and future activation date **/
                    if (futureEndDate) {
                        newLine.OrderApi__Auto_Calculate_Activation_Date__c = false;
                        if(items[0].Managed__c) {
                            newLine.OrderApi__Activation_Date__c = Date.newInstance((Integer) renewalProcess.Term_Year__c, 1, 1);
                        } else {
                            newLine.OrderApi__Activation_Date__c = Date.newInstance(System.now().year() + 1, 1, 1);
                        }
                        newLine.OrderApi__GL_Account__c = items[0].Future_Income_Account__c != null ? items[0].Future_Income_Account__c : items[0].OrderApi__Income_Account__c;
                    }

                }
                /** no subscription plan id provided **/
                else {
                    /** handle emeritus & honorary exception **/
                    if (items[0].OrderApi__Item_Class__r.Name == 'Individual Memberships' && (items[0].Name == 'Emeritus Membership' || items[0].Name == 'Honorary Membership')) {
                        lifetimeSubPlan = [SELECT Id FROM OrderApi__Subscription_Plan__c WHERE OrderApi__Type__c = 'Lifetime' AND OrderApi__Is_Active__c = true];
                        newLine.OrderApi__Subscription_Plan__c = lifetimeSubPlan.Id;
                        newLine.OrderApi__Activation_Date__c = Date.newInstance(System.now().year(), 1, 1);
                    }
                    /** handle all other items **/
                    else {
                        /** get default sub plan from item **/
                        OrderApi__Item_Subscription_Plan__c isp = [SELECT OrderApi__Subscription_Plan__c FROM OrderApi__Item_Subscription_Plan__c WHERE OrderApi__Item__c = :itemId AND OrderApi__Is_Default__c = true];
                        subPlan = [SELECT Id, OrderApi__Advanced_Calendar_Days__c FROM OrderApi__Subscription_Plan__c WHERE Id = :isp.OrderApi__Subscription_Plan__c];
                        subPlanId = subPlan.Id;
                        /** set sub plan **/
                        newLine.OrderApi__Subscription_Plan__c = subPlanId;
                        /** if future end date - set future gl and future activation date **/
                        if (futureEndDate) {
                            newLine.OrderApi__Auto_Calculate_Activation_Date__c = false;
                            if(items[0].Managed__c) {
                                newLine.OrderApi__Activation_Date__c = Date.newInstance((Integer) renewalProcess.Term_Year__c, 1, 1);
                            } else {
                                newLine.OrderApi__Activation_Date__c = Date.newInstance(System.now().year()+1, 1, 1);
                            }
                            newLine.OrderApi__GL_Account__c = items[0].Future_Income_Account__c != null ? items[0].Future_Income_Account__c : items[0].OrderApi__Income_Account__c;
                        }
                    }
                }
            }

            linesToInsert.add(newLine);

            /** if item is a membership, automatically add blood cancer journal **/
            if (items[0].OrderApi__Item_Class__r.Name == 'Individual Memberships') {
                OrderApi__Item__c bloodCancerJournal = [SELECT Id, OrderApi__Income_Account__c, Future_Income_Account__c FROM OrderApi__Item__c WHERE Name = 'Blood Cancer Discovery - Online' LIMIT 1];
                OrderApi__Sales_Order_Line__c additionalLine = new OrderApi__Sales_Order_Line__c(OrderApi__Item__c = bloodCancerJournal.Id, OrderApi__Sales_Order__c = salesOrderId);

                if(subPlanId!=null){
                    additionalLine.OrderApi__Subscription_Plan__c = subPlanId;
                }

                if(futureEndDate){
                        newLine.OrderApi__Auto_Calculate_Activation_Date__c = false;
                        newLine.OrderApi__Activation_Date__c = Date.newInstance((Integer) renewalProcess.Term_Year__c, 1, 1);
                        newLine.OrderApi__GL_Account__c = items[0].Future_Income_Account__c != null ? items[0].Future_Income_Account__c : items[0].OrderApi__Income_Account__c;
                }

                linesToInsert.add(additionalLine);
            }

            upsert linesToInsert;


        }
        return ECRMUtils.getAllSalesOrderLines(salesOrderId);
    }


    /**
     * @purpose Removes a sales order line from the specified sales order based on the item
     *
     * @param itemId
     * @param salesOrderId
     *
     * @return List of all remaining sales order lines
     */
    @AuraEnabled
    public static List<OrderApi__Sales_Order_Line__c> removeItem(String itemId, String salesOrderId) {
        List<OrderApi__Sales_Order_Line__c> linesToDelete = new List<OrderApi__Sales_Order_Line__c>();
        OrderApi__Sales_Order_Line__c newLine = [SELECT Id, OrderApi__Item_Class__r.Name, OrderApi__Item_Class__c FROM OrderApi__Sales_Order_Line__c WHERE OrderApi__Sales_Order__c = :salesOrderId AND OrderApi__Item__c = :itemId LIMIT 1];
        linesToDelete.add(newLine);
        if (newLine.OrderApi__Item_Class__r.Name == 'Individual Memberships') {
//            List<OrderApi__Sales_Order_Line__c> bloodCancerLines = [SELECT Id FROM OrderApi__Sales_Order_Line__c WHERE OrderApi__Sales_Order__c = :salesOrderId AND OrderApi__Item__r.Name = 'Blood Cancer Discovery - Online'];
//            if (bloodCancerLines.size() > 0) {
//                linesToDelete.addAll(bloodCancerLines);
//            }
            //delete all sales order lines if item removed is membership --> because of complications with term selector
            linesToDelete = [SELECT Id FROM OrderApi__Sales_Order_Line__c WHERE OrderApi__Sales_Order__c=:salesOrderId];
        }
        delete linesToDelete;

        return ECRMUtils.getAllSalesOrderLines(salesOrderId);
    }
}