/**
 * Created by lauren.lezberg on 9/1/2020.
 */

public with sharing class AttendeeToParticipantTriggerHandler {
    public static List<Virtual_Meeting_Links__mdt> links {get;set;}



    public static void createMatchingParticipants(List<EventApi__Attendee__c> attendees){

        Map<Id, Id> eventIdMap = new Map<Id, Id>();
        List<Virtual_Meeting_Links__mdt> mtdMeetings = new List<Virtual_Meeting_Links__mdt>();
        if(Test.isRunningTest()){
            mtdMeetings = links;
        } else {
            mtdMeetings = [SELECT Id, Live_Event_Id__c,Event_Id__c FROM Virtual_Meeting_Links__mdt WHERE Live_Event_Id__c !=NULL AND Event_Id__c!=NULL];
        }
        for(Virtual_Meeting_Links__mdt m : mtdMeetings){
            eventIdMap.put(m.Event_Id__c, m.Live_Event_Id__c);
        }


        //get all attendee records that have an evt mtd record with a matching live event
        List<EventApi__Attendee__c> validAttendees = [SELECT EventApi__Contact__c, EventApi__Event__c FROM EventApi__Attendee__c WHERE Id IN: attendees AND EventApi__Event__c IN: eventIdMap.keySet()];
        if(!validAttendees.isEmpty()) {
            Set<Id> contactIds = new Set<Id>();
            for (EventApi__Attendee__c att : validAttendees) {
                contactIds.add(att.EventApi__Contact__c);
            }

            //get contact user map
            List<User> users = [SELECT ContactId, Id FROM User WHERE ContactId IN:contactIds];
            Map<Id, Id> contactUserMap = new Map<Id, Id>();
            for (User u : users) {
                contactUserMap.put(u.ContactId, u.Id);
            }

            List<BR_Participation__c> participations = new List<BR_Participation__c>();
            for (EventApi__Attendee__c att : validAttendees) {
                BR_Participation__c p = new BR_Participation__c();
                p.Contact__c = att.EventApi__Contact__c;
                p.Participate__c = 'Yes';
                p.Bypass_Confirmation__c = true;
                p.BR_Event__c = eventIdMap.get(att.EventApi__Event__c);
                p.User__c = contactUserMap.get(att.EventApi__Contact__c);
                participations.add(p);
            }

            try {
                insert participations;

            } catch (Exception e) {
                new AACRCustomException(e.getMessage(), e.getStackTraceString(), 'Attendee/Participation Conversion');
            }
        }
    }

}