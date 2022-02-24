/**
 * Created by afaf.awad on 6/18/2020.
 */

global class Batch_CallFreeman implements Database.Batchable<sObject>, Database.AllowsCallouts {
    public static List<Virtual_Meeting_Links__mdt> virtualMeetings = new List<Virtual_Meeting_Links__mdt>();

    String freemanEventId{get;set;}
    String eventId {get;set;}
    List<Id> contacts {get;set;}
    Boolean setBusinessFlag{get;set;}
    Boolean isMassReg {get;set;}
    List<EventApi__Attendee__c> attendees = new List<EventApi__Attendee__c>();


    global Batch_CallFreeman(String event, Boolean setFlag, String contactIds ,String freemanEvent, Boolean massReg){
        eventId = event;
        setBusinessFlag = setFlag;
        contacts = (List<String>) System.JSON.deserialize(contactIds, List<String>.class);
        freemanEventId = freemanEvent;
        isMassReg = massReg;
        System.debug('contactIds = ' + contacts);
    }

    global Database.QueryLocator start(Database.BatchableContext BC){
        String query = 'SELECT Id, Title, AACR_Id__c, Salutation, FirstName, LastName, OrderApi__Preferred_Email__c FROM Contact WHERE Id IN: contacts';
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<Contact> scope){
        System.debug('executing batch with ' + scope.size() + ' records.');

        for (Contact con : scope) {
            try {
                if ( String.isNotBlank(freemanEventId) ) {
                    FreemanIntegrationController.createFreemanAttendee(JSON.serialize(con), freemanEventId, setBusinessFlag);
                }
            }catch(Exception e){
                System.debug('Error Message : ' + e.getMessage());
//                throw new AACRCustomException(e.getMessage(),  e.getStackTraceString() , 'Mass Registration');
            }

            EventApi__Attendee__c att = new EventApi__Attendee__c();
            att.EventApi__Contact__c = con.Id;
            att.EventApi__Event__c = eventId;
            att.EventApi__Status__c = 'Registered';
            att.EventApi__Registration_Date__c = Date.today();
            attendees.add(att);
        }

        try {
            if ( isMassReg ) {
                insert attendees;
            }
        }catch(Exception e){
            System.debug('Error Message : ' + e.getMessage());
//            throw new AACRCustomException(e.getMessage(),  e.getStackTraceString() , 'Mass Registration');
        }
    }

    global void finish(Database.BatchableContext BC){

    }
}