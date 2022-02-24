/**
 * Created by lauren.lezberg on 9/1/2020.
 */

trigger AttendeeToParticipantTrigger on EventApi__Attendee__c (after insert) {


    if(Trigger.isAfter && Trigger.isInsert){
        AttendeeToParticipantTriggerHandler.createMatchingParticipants(Trigger.new);
    }

}