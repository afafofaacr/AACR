/**
 * Created by lauren.lezberg on 3/10/2021.
 */

public class Batch_DeleteFreemanAttendees implements Database.Batchable<FreemanAttendee>, Database.AllowsCallouts, Database.Stateful {
    List<FreemanAttendee> attendees= new List<FreemanAttendee>();
    public String externalEventId;

    public Batch_DeleteFreemanAttendees(String eventId){
        this.externalEventId = eventId;

        Http h;
        HttpRequest reqAuth;
        HttpResponse resAuth;
        Fuzion_Session__c fSession = Fuzion_Session__c.getOrgDefaults();


        Long timestamp = datetime.now().getTime();

        h = new Http();

        String apiURL = 'https://fuzionapi.com/v1/attendees';
        System.debug('apiURL: ' + apiURL);

        reqAuth = new HttpRequest();
        reqAuth.setEndpoint(apiURL);
        reqAuth.setMethod('GET');
        reqAuth.setHeader('Content-Type', 'application/json');
        reqAuth.setHeader('partner_app_key', fSession.Client_Id__c);
        reqAuth.setHeader('fuzion_event_id', this.externalEventId);
        reqAuth.setHeader('request_timestamp', String.valueOf(timestamp));
        reqAuth.setHeader('partner_app_signature', V_FreemanIntegration.buildPartnerAppSignature(fSession, 'GET', timestamp, '/v1/attendees'));


        try {
            resAuth = h.send(reqAuth);
            System.debug('Response body received = ' + resAuth.getBody());

            if (resAuth.getStatusCode() == 200) {
                System.debug('success!');

                String resBody = resAuth.getBody();

                Object fuzionAtt = (Object)JSON.deserializeUntyped(resBody);
                System.debug('fuzionAtt: ' + fuzionAtt);
                Map<String,Object> mp_StrObj = (Map<string,Object>)fuzionAtt;
                SYstem.debug('map: ' + mp_StrObj);

                String payloadStr = JSON.serialize(mp_StrObj.get('payload'));
                List<FreemanAttendee> fAttendees = (List<FreemanAttendee>)JSON.deserialize(payloadStr, List<FreemanAttendee>.class);
                for(FreemanAttendee a : fAttendees){
                    attendees.add(a);
                }

                System.debug('attendeeIds: ' + attendees.size());

            }
        } catch (Exception e) {
            System.debug('Error: ' + e.getMessage());
            ErrorHelper.sendExceptionEmail('Event Registration', e.getMessage(), e.getStackTraceString());
        }
    }

   public List<FreemanAttendee> start(Database.BatchableContext bc){
        return attendees;
    }

    public void execute(Database.BatchableContext bc, List<FreemanAttendee> scope) {
       for(FreemanAttendee s : scope){
           Http h;
           HttpRequest reqAuth;
           HttpResponse resAuth;
           Fuzion_Session__c fSession = Fuzion_Session__c.getOrgDefaults();


           Long timestamp = datetime.now().getTime();

           h = new Http();

           String apiURL = 'https://fuzionapi.com/v1/attendees/' + s.fuzion_attendee_id;
           System.debug('apiURL: ' + apiURL);

           reqAuth = new HttpRequest();
           reqAuth.setEndpoint(apiURL);
           reqAuth.setMethod('DELETE');
           reqAuth.setHeader('Content-Type', 'application/json');
           reqAuth.setHeader('partner_app_key', fSession.Client_Id__c);
           reqAuth.setHeader('fuzion_event_id', this.externalEventId);
           reqAuth.setHeader('request_timestamp', String.valueOf(timestamp));
           reqAuth.setHeader('partner_app_signature', V_FreemanIntegration.buildPartnerAppSignature(fSession, 'DELETE', timestamp, '/v1/attendees/' + s.fuzion_attendee_id));


           try {
               resAuth = h.send(reqAuth);
               System.debug('Response body received = ' + resAuth.getBody());

               if (resAuth.getStatusCode() == 200) {
                   System.debug('success!');

               }
           } catch (Exception e) {
               System.debug('Error: ' + e.getMessage());
           }
       }

    }

    public void finish(Database.BatchableContext BC){
        AsyncApexJob a = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed,
                TotalJobItems, CreatedBy.Email
        FROM AsyncApexJob WHERE Id =
                :BC.getJobId()];
        System.debug('job summary: ' + a);
    }

    public class FreemanAttendee{
        public String fuzion_attendee_id;
    }
}