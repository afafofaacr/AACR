/**
 * Created by afaf.awad on 5/13/2020.
 */

global class BatchAttendeeHelper implements Database.Batchable<sObject>, Database.AllowsCallouts, Database.Stateful {

    String pastEvent { get; set; }
    String newEvent { get; set; }
    Set<String> pastEventSet { get; set; }

    global BatchAttendeeHelper(String pastEventId, String newEventId) {
        pastEvent = pastEventId;
        newEvent = newEventId;
    }

    global Database.QueryLocator start(Database.BatchableContext BC) {
        String query = 'SELECT EventApi__Contact__c FROM EventApi__Attendee__c WHERE EventApi__Event__c = :pastEvent';
        System.debug('queryString: ' + query);
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<EventApi__Attendee__c> scope) {

        pastEventSet = new Set<String>();

        if(!scope.isEmpty()) {
            for (EventApi__Attendee__c a : scope) {
                pastEventSet.add(a.EventApi__Contact__c);
            }
        }
    }

    global void finish(Database.BatchableContext BC) {

        System.debug('Count of Attendees in Set: ' + pastEventSet.size());

        database.executeBatch(new Batch_AddAttendeesToEvent(pastEventSet, pastEvent, newEvent, true),1);

    }

    //    public static Set<String> setOfAttendees(String eventId) {
//
//        Set<String> attSet = new Set<String>();
//
//        Database.QueryLocator q = Database.getQueryLocator(
//        [SELECT EventApi__Contact__c FROM EventApi__Attendee__c WHERE EventApi__Event__c = :eventId]);
//
////        for(Database.QueryLocator a : q ){
////            attSet.add(a.EventApi__Contact__c);
////        }
//
//        Database.QueryLocatorIterator it = q.iterator();
//
//        while (it.hasNext()) {
//            EventApi__Attendee__c a = (EventApi__Attendee__c) it.next();
//             attSet.add(a.EventApi__Contact__c);
//        }


//        List<EventApi__Attendee__c> attList = [SELECT EventApi__Contact__c FROM EventApi__Attendee__c WHERE EventApi__Event__c =: eventId];
//
//        Set<String> attSet = new Set<String>();
//
//        if ( !attList.isEmpty()) {
//            for (EventApi__Attendee__c a : attList) {
//                attSet.add(a.EventApi__Contact__c);
//            }
//        }
//
//        return attSet;
//    }


}