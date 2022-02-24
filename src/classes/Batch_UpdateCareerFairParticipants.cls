/**
 * Created by lauren.lezberg on 3/17/2021.
 */

//NEEDS TO BE RUN IN BATCH SIZES OF 10 BECAUSE OF CALLOUT LIMITATIONS
public with sharing class Batch_UpdateCareerFairParticipants implements Database.Batchable<sObject>, Database.AllowsCallouts{
    public String eventId;

    public Batch_UpdateCareerFairParticipants(String eventId){
        this.eventId = eventId;
    }

    public Database.Querylocator start(Database.BatchableContext bc){
        String queryString = 'SELECT Id FROM BR_Participation__c WHERE BR_Event__c=:eventId AND External_Attendee_Id__c!=null';
        return Database.getQueryLocator(queryString);
    }

    public void execute(Database.BatchableContext BC, List<BR_Participation__c> scope) {
        for(BR_Participation__c p : scope){
            vFairsHelper.updateAttendee(p.Id);
        }
    }

    public void finish(Database.BatchableContext BC) {
    }


}