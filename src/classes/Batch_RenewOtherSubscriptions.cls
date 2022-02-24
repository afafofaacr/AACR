/**
 * Created by afaf.awad on 12/7/2020.
 */

public class Batch_RenewOtherSubscriptions implements Database.Batchable<sObject>, Database.Stateful {

    Map<Id,OrderApi__Sales_Order_Line__c> solMap = new Map<Id,OrderApi__Sales_Order_Line__c>();
    Set<String> aacrIds = new Set<String>();
    Id itemClass;
    Date ptd;

    public Batch_RenewOtherSubscriptions(Set<String> aIds, Date paidThruDate, Map<Id,OrderApi__Sales_Order_Line__c> solMemMap, Id itemClassId) {
        this.aacrIds = aIds;
        this.ptd = paidThruDate;
        this.solMap = solMemMap;
        this.itemClass = itemClassId;
    }

    public Database.QueryLocator start(Database.BatchableContext BC) {
        String query = 'SELECT Id, OrderApi__Contact__c, OrderApi__Subscription_Plan__r.Name, OrderApi__Account__c, OrderApi__Item_Class__c, OrderApi__Item__r.Future_Income_Account__c, OrderApi__Item__r.OrderApi__Income_Account__c, OrderApi__Business_Group__c,OrderApi__Item__c, OrderApi__Entity__c, OrderApi__Item__r.Name, OrderApi__Item_Class__r.Name, OrderApi__Is_Active__c, OrderApi__Subscription_Plan__c, OrderApi__Enable_Auto_Renew__c \n' +
                'FROM OrderApi__Subscription__c \n' +
                'WHERE OrderApi__Contact__r.AACR_ID__c IN: aacrIds ' +
                'AND OrderApi__Paid_Through_Date__c =: ptd ' +
                'AND OrderApi__Item__r.OrderApi__Is_Active__c = true \n' +
                'AND OrderApi__Subscription_Plan__r.OrderApi__Is_Active__c = true \n' +
                'AND OrderApi__Is_Cancelled__c = false \n' +
                'AND OrderApi__Item_Class__c !=: itemClass';
        System.debug('Query: ' + query);
        return Database.getQueryLocator(query);

    }

    public void execute(Database.BatchableContext BC, List<OrderApi__Subscription__c> scope) {

        List<OrderApi__Sales_Order_Line__c> salesOrderLines = new List<OrderApi__Sales_Order_Line__c>();
        List<OrderApi__Sales_Order__c> salesOrders = new List<OrderApi__Sales_Order__c>();

//        System.debug('MemSalesOrderLines= ' + solMap);

        for (OrderApi__Subscription__c sub : scope) {
//            System.debug('Sub Contact to compare with: ' + sub.OrderApi__Contact__c);
//            for (OrderApi__Sales_Order_Line__c sol : solMap) {
//                System.debug('SOL Contact to compare with: ' + sol.OrderApi__Contact__c);
//                if ( sub.OrderApi__Contact__c == sol.OrderApi__Contact__c ) {
                    salesOrderLines.add(new OrderApi__Sales_Order_Line__c(
                            OrderApi__Sales_Order__c = solMap.get(sub.OrderApi__Contact__c).OrderApi__Sales_Order__c,
                            OrderApi__Is_Renewal__c = true,
                            OrderApi__Item__c = sub.OrderApi__Item__c,
                            OrderApi__Item_Class__c = sub.OrderApi__Item_Class__c,
                            OrderApi__Subscription__c = sub.Id,
                            OrderApi__Business_Group__c = sub.OrderApi__Business_Group__c,
                            OrderApi__Entity__c = sub.OrderApi__Entity__c,
                            OrderApi__Enable_Auto_Renew__c = sub.OrderApi__Enable_Auto_Renew__c,
                            OrderApi__Subscription_Plan__c = solMap.get(sub.OrderApi__Contact__c).OrderApi__Subscription_Plan__c
                    ));
//                }
//            }
        }

        System.debug(' Non-Membership SalesOrderLines to Insert = ' + salesOrderLines.size());

        for(OrderApi__Sales_Order_Line__c sol : solMap.values()){
            salesOrders.add(new OrderApi__Sales_Order__c(Id = sol.OrderApi__Sales_Order__c,
                    OrderApi__Status__c = 'Closed',
                    OrderApi__Posting_Status__c = 'Posted'));
        }

        try {
            insert salesOrderLines;
            update salesOrders;
        } catch (Exception exp) {
            System.debug('Exception Occurred While inserting Sales Order Lines :::' + exp.getMessage() + '\t' + exp.getStackTraceString());
        }
    }

    public void finish(Database.BatchableContext BC) {
        System.debug('finishing Batch_RenewOtherSubscriptions...');
        //Call next batch
    }
}