/**
 *@Purpose      : Committee automation after Sales Order Line Items are create/edit/delete
 *@Created Date : 14-08-2018
 *@Modified Date: 
 */
trigger DW_CommitteeAutomationTrigger on OrderApi__Sales_Order_Line__c (after insert, after delete) {
//    // check if Trigger is called after DML operation.
//       if(Trigger.isAfter && Trigger.isInsert){
//           System.debug('insert');
//           Database.executeBatch(new DW_CommitteeAutomationTriggerBatch(Trigger.new, 'insert'));
//           System.debug('Trigger.new:::::::: '+Trigger.new);
//           //DW_CommitteeAutomationTriggerHandler.createCommiteeAfterLICreate(Trigger.new);
//       }
//
//       // Check if Trigger is called after delete operation
//       if(Trigger.isDelete){
//           //DW_CommitteeAutomationTriggerHandler.updateCommiteeAfterLIDelete(Trigger.old);
//          Database.executeBatch(new DW_CommitteeAutomationTriggerBatch(Trigger.old, 'delete'));
//       }
}