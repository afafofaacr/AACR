/**
 * Created by afaf.awad on 4/24/2020.
 */

global class Batch_SendAttendees implements Database.Batchable<sObject>, Database.AllowsCallouts, Database.Stateful{
//    public static List<Virtual_Meeting_Links__mdt> virtualMeetings = new List<Virtual_Meeting_Links__mdt>();

    String freemanEventId{get;set;}
    String eventId {get;set;}
    Boolean setBusinessFlag{get;set;}

    global Batch_SendAttendees(String event, Boolean setFlag, String fEventId){ 
        eventId = event;
        setBusinessFlag = setFlag;
        freemanEventId = fEventId;
//        if(Test.isRunningTest()){
//            freemanEventId = virtualMeetings[0].Freeman_Event_Id__c;
//        } else{
//            freemanEventId = [SELECT Freeman_Event_Id__c FROM Virtual_Meeting_Links__mdt WHERE Event_Id__c =: eventId].Freeman_Event_Id__c;
//        }
    }

    global Database.QueryLocator start(Database.BatchableContext BC){
        String query = 'SELECT Id, Title, AACR_Id__c, Salutation, FirstName, LastName, OrderApi__Preferred_Email__c FROM Contact WHERE Id IN (SELECT EventApi__Contact__c FROM EventApi__Attendee__c WHERE EventApi__Event__c =: eventId)';
        System.debug('queryString: ' + query);
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<Contact> scope){

        System.debug('executing Bath_SendAttendees with ' + scope.size() + ' records.');

            for (Contact con : scope) {
                FreemanIntegrationController.createFreemanAttendee(JSON.serialize(con), freemanEventId, setBusinessFlag);
            }
    }

    global void finish(Database.BatchableContext BC){
    }

}