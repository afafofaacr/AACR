trigger BrParticipationTrigger on BR_Participation__c (after insert, after update, before insert, before update, before delete) {
    BrParticipationTriggerHandler handler = new BrParticipationTriggerHandler();

    if (Trigger.isAfter) {
        if (Trigger.isInsert) {
            handler.onAfterInsert(Trigger.newMap);
        }

        if (Trigger.isUpdate) {
            handler.onAfterUpdate(Trigger.new, Trigger.oldMap);
        }
    } else if (Trigger.isBefore){
        if(Trigger.isDelete){
            handler.onBeforeDelete(Trigger.oldMap);
        } else {
            handler.setRegistrationDate(Trigger.new);
        }
    }

}