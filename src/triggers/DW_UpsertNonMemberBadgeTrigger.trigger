/**
 *@Purpose      : Upsert non-Member Badges depeding on Contact record type
 *@Created Date : 11-10-2018
 *@Modified Date: 11-10-2018
 */
trigger DW_UpsertNonMemberBadgeTrigger on Contact (after insert, after update) {

    // check if Trigger is called after DML operation.
    if(Trigger.isAfter){
        // Check if Trigger is called after insert operation
        if(Trigger.isInsert){
           DW_UpsertNonMemberBadgeTriggerHandler.onafterInsertContact(Trigger.new);
        }
        
        // Check if Trigger is called after update operation
        if(Trigger.isUpdate){
           DW_UpsertNonMemberBadgeTriggerHandler.onafterUpdateContact(Trigger.new, Trigger.oldMap);
        }
    }
}