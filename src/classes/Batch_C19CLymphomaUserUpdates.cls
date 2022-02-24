/**
 * Created by lauren.lezberg on 7/14/2020.
 */

public with sharing class Batch_C19CLymphomaUserUpdates implements Database.Batchable<sObject>{
    public String eventId;

    public Batch_C19CLymphomaUserUpdates(String evtId){
        eventId = evtId;
    }

    public Database.Querylocator start(Database.BatchableContext bc) {
        String queryString = 'SELECT Id, EventApi__Contact__c, EventApi__Status__c, EventApi__Event__c FROM EventApi__Attendee__c WHERE EventApi__Event__c =: eventId';
        System.debug('queryString: ' + queryString);

        return Database.getQueryLocator(queryString);
    }

    public void execute(Database.BatchableContext bc, List<EventApi__Attendee__c > scope) {
        List<Id> registeredContactIds = new List<Id>();
        List<Id> cancelledContactIds = new List<Id>();
        for(EventApi__Attendee__c att : scope){
            if (att.EventApi__Status__c == 'Registered') {
                registeredContactIds.add(att.EventApi__Contact__c);
            } else if(att.EventApi__Status__c == 'Cancelled'){
                cancelledContactIds.add(att.EventApi__Contact__c);
            }
        }

        if(eventId == C19CLymphomaTriggerHandler.lymphomaEventId){
            C19CLymphomaTriggerHandler.updateLymphomaUserRecords(registeredContactIds, cancelledContactIds);
        } else if(eventId == C19CLymphomaTriggerHandler.covidEventId){
            C19CLymphomaTriggerHandler.updateC19CUserRecords(registeredContactIds, cancelledContactIds);
        }
    }


    public void finish(Database.BatchableContext BC) {
        AsyncApexJob a = [
                SELECT Id, Status, NumberOfErrors, JobItemsProcessed,
                        TotalJobItems, CreatedBy.Email
                FROM AsyncApexJob
                WHERE Id =
                        :BC.getJobId()
        ];
        System.debug('job summary: ' + a);

    }
}