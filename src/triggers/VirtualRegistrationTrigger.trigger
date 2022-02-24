/**
 * Created by lauren.lezberg on 4/10/2020.
 */

trigger VirtualRegistrationTrigger on EventApi__Attendee__c (after insert, after update) {

    List<Id> attendeeIds = new List<Id>();

    for(EventApi__Attendee__c att : Trigger.new){
        if (Trigger.isAfter) {
            if (Trigger.isInsert) {
                attendeeIds.add(att.Id);
            } else if (Trigger.isUpdate) {
               if(att.EventApi__Contact__c!=null && Trigger.oldMap.get(att.Id).EventApi__Contact__c==null){
                   attendeeIds.add(att.Id);
               } else if (att.EventApi__Email__c!=null && Trigger.oldMap.get(att.Id).EventApi__Email__c==null){
                   attendeeIds.add(att.Id); 
               }
            }
        }
    }

    VirtualRegistrationTriggerHandler.sendRegistrationEmails(attendeeIds);
}