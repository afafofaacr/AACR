/**
 * Created by lauren.lezberg on 4/10/2020.
 */

public with sharing class UserPasswordResetTriggerHandler {
    public static List<Virtual_Meeting_Links__mdt> virtualMeetings = new List<Virtual_Meeting_Links__mdt>();

    public static void checkForVirtualAttendeeRecords(List<Id> userIds){

        //get all virtual meeting records
        List<Virtual_Meeting_Links__mdt> meetings = new List<Virtual_Meeting_Links__mdt>();
        if(Test.isRunningTest()){
            System.debug('running test: ' + virtualMeetings);
            meetings = virtualMeetings;
        } else{
            meetings = [SELECT Event_Id__c FROM Virtual_Meeting_Links__mdt];
        }
        Set<Id> eventIds = new Set<Id>();
        //get all events with virtual meetings
        for(Virtual_Meeting_Links__mdt vml : meetings){
            eventIds.add(vml.Event_Id__c);
        }


        if(!eventIds.isEmpty()) {
            List<EventApi__Attendee__c> attendees = [
                    SELECT EventApi__Contact__c
                    FROM EventApi__Attendee__c
                    WHERE EventApi__Contact__c IN (SELECT ContactId FROM User WHERE Id IN:userIds)
                    AND EventApi__Event__c IN:eventIds
            ];

            // get set of attendee contactIds
            Set<Id> contactIds = new Set<Id>();
            for (EventApi__Attendee__c attendee : attendees) {
                if(!contactIds.contains(attendee.EventApi__Contact__c)) {
                    contactIds.add(attendee.EventApi__Contact__c);
                }
            }

            //check if users have matching attendee record for virtual meeting & send password reset
//            database.executeBatch(new Batch_ResetUserPassword(userIds),100);
            for (User u : [SELECT ContactId FROM User WHERE Id IN:userIds]) {
                if (contactIds.contains(u.ContactId)) {
                    sendResetPasswordEmail(u.Id);
                }
            }
        }
    }


    private static void sendResetPasswordEmail(Id userId){
        System.resetPassword(userId, true);
    }
}