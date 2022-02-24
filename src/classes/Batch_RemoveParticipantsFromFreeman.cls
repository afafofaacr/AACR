/**
 * Created by lauren.lezberg on 3/17/2021.
 */

public with sharing class Batch_RemoveParticipantsFromFreeman implements Database.Batchable<sObject>, Database.AllowsCallouts, Database.Stateful{
    public String externalEventId;
    public String eventId;
    public List<String> participantErrors;
    public List<BR_Participation__c> toUpdate;

    public Batch_RemoveParticipantsFromFreeman(String eventId, String externalId) {
        this.eventId = eventId;
        this.externalEventId = externalId;
        this.participantErrors = new List<String>();
        this.toUpdate = new List<BR_Participation__c>();
    }

    public Database.Querylocator start(Database.BatchableContext bc){
        System.debug('start....');
        String query = 'SELECT Id, External_Attendee_Id__c FROM BR_Participation__c WHERE BR_Event__c =: eventId AND External_Attendee_Id__c!=null';

        System.debug('query: ' + query);
        System.debug('result: ' + Database.query(query));
        return Database.getQuerylocator(query);
    }

    public void execute(Database.BatchableContext bc, List<BR_Participation__c> scope) {
        for (BR_Participation__c p : scope) {
            Http h;
            HttpRequest reqAuth;
            HttpResponse resAuth;
            Fuzion_Session__c fSession = Fuzion_Session__c.getOrgDefaults();


            Long timestamp = datetime.now().getTime();

            h = new Http();

            String apiURL = 'https://fuzionapi.com/v1/attendees/' + p.External_Attendee_Id__c;
            System.debug('apiURL: ' + apiURL);

            reqAuth = new HttpRequest();
            reqAuth.setEndpoint(apiURL);
            reqAuth.setMethod('DELETE');
            reqAuth.setHeader('Content-Type', 'application/json');
            reqAuth.setHeader('partner_app_key', fSession.Client_Id__c);
            reqAuth.setHeader('fuzion_event_id', this.externalEventId);
            reqAuth.setHeader('request_timestamp', String.valueOf(timestamp));
            reqAuth.setHeader('partner_app_signature', V_FreemanIntegration.buildPartnerAppSignature(fSession, 'DELETE', timestamp, '/v1/attendees/' + p.External_Attendee_Id__c));


            try {
                resAuth = h.send(reqAuth);
                System.debug('Response body received = ' + resAuth.getBody());

                if (resAuth.getStatusCode() == 200) {
                    System.debug('success!');
                    p.External_Attendee_Id__c = null;
                    toUpdate.add(p);
                } else {
                    participantErrors.add(p.Id);
                }
            } catch (Exception e) {
                System.debug('Error: ' + e.getMessage());
            }
        }

    }


    public void finish(Database.BatchableContext BC) {
        update toUpdate;

        AsyncApexJob a = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed,
                TotalJobItems, CreatedBy.Email
        FROM AsyncApexJob WHERE Id =
                :BC.getJobId()];
        System.debug('job summary: ' + a);

        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        String[] toAddresses = new String[] {a.CreatedBy.Email};
        mail.setToAddresses(toAddresses);
        mail.setSubject('Batch_RemoveParticipantsFromFreeman ' + a.Status);
        string body = 'Records processed ' + a.TotalJobItems +
                'with '+ a.NumberOfErrors + ' failures.';
        body += '\n Records with Errors: ' + participantErrors;
        mail.setPlainTextBody(body);

        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }
}