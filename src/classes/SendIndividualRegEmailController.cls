/**
 * Created by lauren.lezberg on 4/21/2020.
 */

public with sharing class SendIndividualRegEmailController {
    public static List<Virtual_Meeting_Links__mdt> virtualMeetings = new List<Virtual_Meeting_Links__mdt>();

    @AuraEnabled
    public static Boolean sendRegistrationEmail(String eventId, String contactId, String attendeeId){
        List<Id> attendeeIds = new List<Id>();
        if(attendeeId==null) {
            List<EventApi__Attendee__c> attendees = [SELECT Id FROM EventApi__Attendee__c WHERE EventApi__Contact__c = :contactId AND EventApi__Event__c = :eventId];
            attendeeIds.add(attendees[0].Id);
        } else {
            attendeeIds.add(attendeeId);
        }

        try {
            VirtualRegistrationTriggerHandler.sendRegistrationEmails(attendeeIds);
            return true;
        } catch(Exception e){
            System.debug('Could not send email: ' + e.getMessage());
            return false;
        }

    }

    @AuraEnabled
    public static String getEventId(String attendeeId){
        if(FeatureManagement.checkPermission('Send_Reg_Emails')) {
            EventApi__Attendee__c att = [SELECT EventApi__Event__c FROM EventApi__Attendee__c WHERE Id = :attendeeId];
            if (att.EventApi__Event__c != null) {
                String eventId = att.EventApi__Event__c;

                List<Virtual_Meeting_Links__mdt> meetings = new List<Virtual_Meeting_Links__mdt>();
                if(Test.isRunningTest()){
                    System.debug('running test: ' + virtualMeetings);
                    meetings = virtualMeetings;
                } else{
                    meetings = [SELECT Id FROM Virtual_Meeting_Links__mdt WHERE Event_Id__c = :eventId];
                }
                if (meetings.size() > 0) {
                    return eventId;
                }
            }
        }

        return null;
    }

}