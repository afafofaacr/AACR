/**
 * Created by afaf.awad on 5/13/2020.
 */

global class Batch_AddAttendeesToEvent implements Database.Batchable<sObject>, Database.AllowsCallouts, Database.Stateful {

    String pastEvent { get; set; }
    String newEvent { get; set; }
    Boolean setBusinessFlag { get; set; }

    global Batch_AddAttendeesToEvent( String pastEventId, String newEventId, Boolean setFlag) {
        pastEvent = pastEventId;
        newEvent = newEventId;
        setBusinessFlag = setFlag;
    }

    global Database.QueryLocator start(Database.BatchableContext BC) {
        String query = 'SELECT Id, Title, AACR_Id__c, Salutation, FirstName, LastName, OrderApi__Preferred_Email__c FROM Contact WHERE Id IN (SELECT EventApi__Contact__c FROM EventApi__Attendee__c WHERE EventApi__Event__c =: newEvent)';
        System.debug('queryString: ' + query);
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<Contact> scope) {
        System.debug('Execute method running...');

        Set<Id> newEventSet = new Set<Id>();
        for (Contact c : scope) {
            newEventSet.add(c.Id);
        }

        List<EventApi__Attendee__c> oldAttendees = [SELECT EventApi__Contact__c FROM EventApi__Attendee__c WHERE EventApi__Event__c =: pastEvent AND EventApi__Contact__c IN: newEventSet];

        Set<Id> pastEventSet = new Set<Id>();
        for (EventApi__Attendee__c a : oldAttendees) {
            pastEventSet.add(a.EventApi__Contact__c);
        }

        List<Contact> conList = new List<Contact>();
        List<EventApi__Attendee__c> newAtt = new List<EventApi__Attendee__c>();

        for (Contact con : scope) {
            if ( !pastEventSet.contains(con.Id) ) {
                EventApi__Attendee__c a = new EventApi__Attendee__c();

                a.EventApi__Contact__c = con.Id;
                a.EventApi__Event__c = pastEvent;
                a.EventApi__Status__c ='Registered';
                newAtt.add(a);

                conList.add(con);
            }
        }

        System.debug('New attendees to insert: ' + newAtt.size());
        System.debug('Count of contact to send to freeman = ' + conList.size());

        try {
            System.debug('Sending ' + conList.size() + ' contacts to Freeman...');

            for (Contact con : conList) {
                FreemanIntegrationController.createFreemanAttendee(con, setBusinessFlag);
            }

            insert newAtt;
        } catch (Exception e) {
            System.debug('Error sending Contact to Freeman: ' + e.getMessage());
        }

//        try {
//            insert newAtt;
//        } catch (Exception e) {
//            System.debug('Error Message: ' + e.getMessage());
//        }

    }

    global void finish(Database.BatchableContext BC) {

    }
}