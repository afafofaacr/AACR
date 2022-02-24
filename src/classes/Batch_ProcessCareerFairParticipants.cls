/**
 * Created by lauren.lezberg on 3/4/2021.
 */

global class Batch_ProcessCareerFairParticipants implements Database.Batchable<sObject>, Database.AllowsCallouts{
    public string eventId;

    public Batch_ProcessCareerFairParticipants(String eventId){
        this.eventId = eventId;
    }

    global Database.Querylocator start(Database.BatchableContext bc){
        System.debug('start....');
        String query = 'SELECT Id, External_Attendee_Id__c FROM BR_Participation__c WHERE External_Attendee_Id__c=null AND Participate__c= \'Yes\' AND BR_Event__c=: eventId';

        System.debug('query: ' + query);
        System.debug('result: ' + Database.query(query));
        return Database.getQuerylocator(query);
    }

    global void execute(Database.BatchableContext bc, List<BR_Participation__c> scope){
        List<BR_Participation__c> toUpdate = new List<BR_Participation__c>();

        for(BR_Participation__c p : scope){
            if(p.External_Attendee_Id__c==null) {
                System.debug('p: ' + p);
                String attId = vFairsHelper.synchronousInsertAttendee(p.Id);
                vFairsHelper.uploadResume(p.Id, attId);
                p.External_Attendee_Id__c = attId;
                toUpdate.add(p);
            }
        }

        update toUpdate;

    }

    global void finish(Database.BatchableContext BC){

        AsyncApexJob a = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed,
                TotalJobItems, CreatedBy.Email
        FROM AsyncApexJob WHERE Id =
                :BC.getJobId()];
        System.debug('job summary: ' + a);
    }
}