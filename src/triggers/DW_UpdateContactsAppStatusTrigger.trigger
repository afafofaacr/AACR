/**
 *@Purpose      : Update contacts application status when sales order gets created or updated
 *@Created Date : 29-10-2018
 *@Modified Date: 29-10-2018
 */
trigger DW_UpdateContactsAppStatusTrigger on OrderApi__Sales_Order__c (after insert, after update) {
    // check if Trigger is called after DML operation.
    if(Trigger.isAfter){
        // Check if Trigger is called after insert operation
        if(Trigger.isInsert){
            DW_UpdateContactsAppStatusController.updateContactsAppStatus(Trigger.new);
        }
        
        // Check if Trigger is called after update operation
        if(Trigger.isUpdate){
            DW_UpdateContactsAppStatusController.onafterUpdateSO(Trigger.new,Trigger.oldMap);
        }
    }
}