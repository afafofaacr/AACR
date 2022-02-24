/**
 *@Purpose      : batch class for creating committee object from the sales order line
 *@Created Date : 11-19-2018 - 11-20-2018
 */
global class DW_CommitteeAutomationTriggerBatch implements Database.Batchable<sObject> {
public List<OrderApi__Sales_Order_Line__c> salesOrderList = new List<OrderApi__Sales_Order_Line__c>();
public String dmlOperation;
global DW_CommitteeAutomationTriggerBatch(List<OrderApi__Sales_Order_Line__c> sol, String operation) {
    this.salesOrderList = sol;
    this.dmlOperation = operation;
}
global Database.QueryLocator start(Database.BatchableContext BC) {
    return DataBase.getQueryLocator([SELECT Id, OrderApi__Item__c, OrderApi__Item__r.Name, 
                                                                 OrderApi__Item__r.OrderApi__Item_Class__r.Name,OrderApi__Contact__c,
                                                                 OrderApi__Item_Class__r.Name, OrderApi__Sales_Order__c,OrderApi__Activation_Date__c,OrderApi__End_Date__c
                                                          FROM OrderApi__Sales_Order_Line__c
                                                          WHERE Id IN : salesOrderList
                                                          ]);
}
global void execute(Database.BatchableContext BC,List<OrderApi__Sales_Order_Line__c> salesOrderLst) {
    if(dmlOperation == 'insert') {
        DW_CommitteeAutomationTriggerHandler.createCommiteeAfterLICreate(salesOrderLst);
    } 
    if(dmlOperation == 'delete') {
        DW_CommitteeAutomationTriggerHandler.updateCommiteeAfterLIDelete(salesOrderLst);
    }
}
global void finish(Database.BatchableContext BC) {

}

}