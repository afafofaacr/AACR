trigger ContactAppStatus on contact_last_accessed_step__c (after insert,after update) {
     if(trigger.isAfter && trigger.isInsert) {
        ContactApplicationStatusTriggerHelper.setContactApplicationStatus(trigger.new);
    }else if(Trigger.isUpdate && Trigger.isAfter){
        ContactApplicationStatusTriggerHelper.setContactApplicationStatus(Trigger.new);
    }
}