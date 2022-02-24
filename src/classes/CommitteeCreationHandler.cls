/**
 * Created by afaf.awad on 9/28/2020.
 */

public with sharing class CommitteeCreationHandler {

    public static void createWGCommittees(List<OrderApi__Receipt__c> receipts){

        List<String> saleOrderIds = new List<String>();
        for(OrderApi__Receipt__c r : receipts){
            saleOrderIds.add(r.OrderApi__Sales_Order__c);
        }
        

        List<OrderApi__Sales_Order_Line__c> salesOrderItems = [
                SELECT Id, OrderApi__Item__c, OrderApi__Item__r.Name, OrderApi__Item__r.OrderApi__Item_Class__r.Name,
                        OrderApi__Contact__c, OrderApi__Sales_Order__c,OrderApi__Activation_Date__c,OrderApi__End_Date__c
                FROM OrderApi__Sales_Order_Line__c
                WHERE OrderApi__Sales_Order__c IN: saleOrderIds
                AND OrderApi__Item_Class__r.Name = 'Working Groups'
        ];

        List<Committees__c> committees = new List<Committees__c>();
        for(OrderApi__Sales_Order_Line__c salesOrderLI : salesOrderItems){

            Committees__c com = new Committees__c();
            com.Name = salesOrderLI.OrderApi__Item__r.Name;
            com.Committee_Related_To__c = salesOrderLI.OrderApi__Item__c;
            com.Committees__c = salesOrderLI.OrderApi__Contact__c;
            com.Date_From__c = salesOrderLI.OrderApi__Activation_Date__c;
            com.Date_Through__c = salesOrderLI.OrderApi__End_Date__c;
            committees.add(com);
        }

        if(!committees.isEmpty()){
            try{
                System.debug('committeeToInsertList==>'+ committees);
                insert committees;
            }catch(Exception exp){
                System.debug('Exception while creating committee==>'+exp.getMessage());
            }


        }
    }

}