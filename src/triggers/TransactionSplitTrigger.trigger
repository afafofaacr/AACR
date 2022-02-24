/**
 * Created by lauren.lezberg on 9/23/2019.
 */

trigger TransactionSplitTrigger on OrderApi__Transaction__c (after update) {

    System.debug('transactionSplitTrigger...');
    List<OrderApi__Transaction__c> transactions = [SELECT Id, OrderApi__Receipt_Type__c, OrderApi__Receipt__c, OrderApi__Batch__c, GP_Batch_Number__c, OrderApi__Num_Lines__c FROM OrderApi__Transaction__c WHERE Id IN: Trigger.new];
    if(Fon_TransactionService.runOnce() && transactions[0].GP_Batch_Number__c==null){
        Fon_TransactionService.splitRevenue(Trigger.new,Trigger.oldMap);
    } 
}