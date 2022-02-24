/**
 * Created by lauren.lezberg on 4/1/2021.
 */

public with sharing class ModifyAACRGroupsController {

    @AuraEnabled
    public static String buildAACRGroupsSO(){
        String contactId = ECRMUtils.getCurrentLoginUserContactId();

        //get active aacr group subscriptions
        List<OrderApi__Subscription__c> aacrGroups = [SELECT Id, OrderApi__Item__c FROM OrderApi__Subscription__c WHERE OrderApi__Contact__c=:contactId AND OrderApi__Is_Active__c = true AND OrderApi__Status__c='Active' AND (OrderApi__Item_Class__r.Name = 'Working Groups' OR OrderApi__Item_Class__r.Name='Individual Memberships')];

        //create sales order
        OrderApi__Sales_Order__c so = new OrderApi__Sales_Order__c(OrderApi__Contact__c=contactId);
        insert so;
        List<OrderApi__Sales_Order_Line__c> gLines = new List<OrderApi__Sales_Order_Line__c>();

        //add sales order line for each active aacr group
        if(!aacrGroups.isEmpty()){
            for(OrderApi__Subscription__c sub : aacrGroups) {
                gLines.add(new OrderApi__Sales_Order_Line__c(OrderApi__Sales_Order__c = so.Id, OrderApi__Item__c = sub.OrderApi__Item__c));
            }
        }

        insert gLines;

        return so.Id;

    }

    @AuraEnabled
    public static Boolean completeAACRGroupsOrder(String salesOrderId, List<Id> selectedItems){
        Set<Id> selectedIds = new Set<Id>();
        selectedIds.addAll(selectedItems);

        String contactId = ECRMUtils.getCurrentLoginUserContactId();
        OrderApi__Sales_Order__c so = [SELECT OrderApi__Posting_Status__c, OrderApi__Status__c FROM OrderApi__Sales_Order__c WHERE Id=:salesOrderId];
        so.OrderApi__Status__c = 'Closed';
        so.OrderApi__Posting_Status__c = 'Posted';

        try {
            List<OrderApi__Subscription__c> subsToCancel = new List<OrderApi__Subscription__c>();

            Map<Id, OrderApi__Subscription__c> itemSubscriptionMap = new Map<Id, OrderApi__Subscription__c>();
            //get active aacr group subscriptions
            List<OrderApi__Subscription__c> aacrGroups = [SELECT Id, OrderApi__Item__c, OrderApi__Is_Cancelled__c FROM OrderApi__Subscription__c WHERE OrderApi__Contact__c = :contactId AND OrderApi__Is_Active__c = true AND OrderApi__Item_Class__r.Name = 'Working Groups'];
            if (!aacrGroups.isEmpty()) {
                for (OrderApi__Subscription__c sub : aacrGroups) {
                    itemSubscriptionMap.put(sub.OrderApi__Item__c, sub);
                    if(!selectedIds.contains(sub.OrderApi__Item__c)){
                        sub.OrderApi__Is_Cancelled__c = true;
                        subsToCancel.add(sub);
                    }
                }

                List<OrderApi__Sales_Order_Line__c> lines = [SELECT Id, OrderApi__Item__c, OrderApi__Item_Class__r.Name FROM OrderApi__Sales_Order_Line__c WHERE OrderApi__Sales_Order__c = :salesOrderId];

                List<OrderApi__Sales_Order_Line__c> linesToDelete = new List<OrderApi__Sales_Order_Line__c>();
                for (OrderApi__Sales_Order_Line__c line : lines) {
                    if(line.OrderApi__Item_Class__r.Name == 'Individual Memberships'){
                        linesToDelete.add(line);
                    }
                    if (itemSubscriptionMap.keySet().contains(line.OrderApi__Item__c)) {
//                        OrderApi__Subscription__c sub = itemSubscriptionMap.get(line.OrderApi__Item__c);
//                        sub.OrderApi__Is_Cancelled__c = true;
//                        subsToCancel.add(sub);
                        linesToDelete.add(line);
                    }
                }

                delete linesToDelete;
                update subsToCancel;
            }

            update so;

            return true;
        } catch(Exception e){
            new AACRCustomException(salesOrderId, e.getMessage(), e.getStackTraceString(), 'Modify AACR Groups');
            return false;
        }
    }

    @AuraEnabled
    public static void deleteOrder(String salesOrderId){
        Database.delete(salesOrderId);
    }

}