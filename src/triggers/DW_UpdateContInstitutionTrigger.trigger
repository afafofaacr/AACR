/**
 *@Purpose      : Update Account Contact's Institution type and Minoirity institution
 *@Created Date : 11-10-2018
 *@Modified Date: 11-10-2018
 */
trigger DW_UpdateContInstitutionTrigger on Account (after update) {

    // check if Trigger is called after DML operation.
    if(Trigger.isAfter){
        
        // Check if Trigger is called after update operation
        if(Trigger.isUpdate){
            system.debug('DW_UpdateContInstitutionTriggerHandler...');
            DW_UpdateContInstitutionTriggerHandler.onafterUpdateAccount(Trigger.new, Trigger.oldMap);
        }
    }

}