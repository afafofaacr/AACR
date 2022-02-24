/**
 * Created by lauren.lezberg on 9/29/2020.
 */

public without sharing class V_ZoomIntegration implements Callable, VirtualEventIntegration {

    public Object call(String action, Map<String, Object> args) {
        switch on action {
            when 'sendAttendee' {
                return this.sendAttendee((String) args.get('contactId'), (String) args.get('externalEventId'), (Boolean) args.get('flag'));
            }
            when 'asyncSendAttendee' {
                V_ZoomIntegration.asyncSendAttendee((String) args.get('contactId'), (String) args.get('externalEventId'), (Boolean) args.get('flag'));
                return null;
            }
            when 'updateAttendee' {
                V_ZoomIntegration.updateAttendee((String)args.get('participantId'));
                return null;
            }
            when 'deleteAttendee' {
                V_ZoomIntegration.deleteAttendee((String)args.get('fuzionAttendeeId'), (String)args.get('fuzionEventId'));
                return null;
            }
            when 'goToVenue' {
                return this.goToVenue((String) args.get('contactId'), (String) args.get('SFEventId'));
            }
            when else {
                throw new AACRCustomException('Failure to execute action: ' + action, 'ZoomIntegration.call()', 'ZoomIntegration');
            }
        }
    }

    public static void deleteAttendee(String fuzionAttendeeId, String fuzionEventId){

    }

    public static void updateAttendee(String participantId){

    }

    public String sendAttendee(String contactId, String externalEventId, Boolean flag) {

        return null;
    }

    @Future(callout=true)
    public static void asyncSendAttendee(String contactId, String externalEventId, Boolean flag) {

    }

    public String goToVenue(String contactId, String SFEventId) {
        String redirectURL = '';

        BR_Event__c evt = [SELECT Id, Virtual_Venue__r.Base_URL__c FROM BR_Event__c WHERE Id = :SFEventId];

        Virtual_Event_Details__c ved = [SELECT External_Event_Id__c, Encrypted_Password__c FROM Virtual_Event_Details__c WHERE Event__c = :SFEventId];

        redirectURL = evt.Virtual_Venue__r.Base_URL__c + ved.External_Event_Id__c;
        if (ved.Encrypted_Password__c != null) {
            redirectURL += '?pwd=' + ved.Encrypted_Password__c;
        }

        return redirectURL;
    }

    private static String getZoomClientId() {
        Zoom_Session__c zSession = Zoom_Session__c.getOrgDefaults();
        return zSession.Client_Id__c;
    }

    private static String getZoomClientSecret() {
        Zoom_Session__c zSession = Zoom_Session__c.getOrgDefaults();
        return zSession.Client_Secret__c;
    }

    public static String createJWTToken() {
        System.debug('createJWTToken...');
        Datetime dt = Datetime.now().addMinutes(2);
        Long timestamp = (dt.getTime()) / 1000;

        String header = '{"alg":"HS256","typ":"JWT"}';
        String payload = '{"iss":"' + getZoomClientId() + '","exp":' + timestamp + '}';
        String key = getZoomClientSecret();

        String header64 = EncodingUtil.base64Encode(Blob.valueOf(header));
        header64 = header64.replaceAll('=', '');
        header64 = header64.replaceAll('/', '_');

        String payload64 = EncodingUtil.base64Encode(Blob.valueOf(payload));
        payload64 = payload64.replaceAll('=', '');
        payload64 = payload64.replaceAll('/', '_');

        Blob hmacData = Crypto.generateMac('hmacSHA256', Blob.valueOf(header64 + '.' + payload64), Blob.valueOf(key));

        String signature = EncodingUtil.base64Encode(hmacData);

        String token = header64 + '.' + payload64 + '.' + signature;
        token = token.replaceAll('=', '');
        token = token.replaceAll('/', '_');


        System.debug('returning token: ' + token);

        return token;

    }

    public static String createZoomMeeting(String eventId, String userId, String password, Boolean isWebinar) {
        System.debug('updateZoomMeeting with eventId: ' + eventId + ' userId: ' + userId + ' and password: ' + password);
        BR_Event__c evt = [SELECT Id, Name, Description__c, Start_Date__c, End_Date__c FROM BR_Event__c WHERE Id = :eventId];
        Http h = new Http();
        HttpRequest req = new HttpRequest();
        HttpResponse res = new HttpResponse();
        req.setMethod('POST');
        req.setHeader('Authorization', 'Bearer ' + createJWTToken());
        req.setHeader('Content-Type', 'application/json');
        String endpoint = 'https://api.zoom.us/v2/users/' + userId;
        if(isWebinar){
            endpoint += '/webinars';
        } else {
            endpoint += '/meetings';
        }
        req.setEndpoint(endpoint);

        integer intDays = evt.Start_Date__c.Date().daysBetween(evt.End_Date__c.Date());
        datetime sameDayEndDate = evt.Start_Date__c.addDays(intDays);
        decimal decMinutes = ((evt.End_Date__c.getTime()) / 1000 / 60) - ((sameDayEndDate.getTime()) / 1000 / 60);

        ZoomMeeting mtng = new ZoomMeeting();
        mtng.topic = evt.Name;
        mtng.start_time = String.valueOf(evt.Start_Date__c.format('yyyy-MM-dd\'T\'HH:mm:ss', 'America/New_York'));
        mtng.duration = Integer.valueOf(decMinutes);
        mtng.type = isWebinar?5:2;
        mtng.timezone = 'America/New_York';
//        mtng.agenda = evt.Description__c;
        mtng.agenda = '';
        mtng.password = password;
        req.setBody(JSON.serialize(mtng));
        req.setHeader('Connection', 'keep-alive');

        res = h.send(req);
        System.debug('response: ' + res);
        System.debug('status code: ' + res.getStatusCode());
        if (res.getStatusCode() == 201) {
            Object jsonParse = (Object) JSON.deserializeUntyped(res.getBody());
            Map<String, Object> mp_StrObj = (Map<string, Object>) jsonParse;
            System.debug('objectMap: ' + mp_StrObj);
            Virtual_Event_Details__c ved = [SELECT Id, External_Event_Id__c, Encrypted_Password__c FROM Virtual_Event_Details__c WHERE Event__c = :evt.Id];
            ved.External_Event_Id__c = String.valueOf(mp_StrObj.get('id'));
            if(String.valueOf(mp_StrObj.get('encrypted_password'))!=null) {
                ved.Encrypted_Password__c = String.valueOf(mp_StrObj.get('encrypted_password'));
            } else {
                String joinURL = String.valueOf(mp_StrObj.get('join_url'));
                System.debug('joinURL: ' + joinURL);
                ved.Encrypted_Password__c = joinURL.substringAfter('?pwd=');
            }
            update ved;
        }


        return null;
    }

    public static void updateZoomMeeting(String eventId, String userId, String password) {
        System.debug('updateZoomMeeting with eventId: ' + eventId + ' userId: ' + userId + ' and password: ' + password);
        BR_Event__c evt = [SELECT Id, Name, Description__c, Start_Date__c, End_Date__c FROM BR_Event__c WHERE Id = :eventId];
        Virtual_Event_Details__c ved = [SELECT Id,External_Event_Id__c, Encrypted_Password__c, Zoom_Type__c FROM Virtual_Event_Details__c WHERE Event__c = :evt.Id];
        Http h = new Http();
        HttpRequest req = new HttpRequest();
        HttpResponse res = new HttpResponse();
        req.setMethod('PATCH');
        req.setHeader('Authorization', 'Bearer ' + createJWTToken());
        req.setHeader('Content-Type', 'application/json');
        String endpoint = 'https://api.zoom.us/v2/';
        if(ved.Zoom_Type__c=='Webinar'){
            endpoint += 'webinars/';
        } else {
            endpoint += 'meetings/';
        }
        endpoint += ved.External_Event_Id__c;
        req.setEndpoint(endpoint);

        integer intDays = evt.Start_Date__c.Date().daysBetween(evt.End_Date__c.Date());
        datetime sameDayEndDate = evt.Start_Date__c.addDays(intDays);
        decimal decMinutes = ((evt.End_Date__c.getTime()) / 1000 / 60) - ((sameDayEndDate.getTime()) / 1000 / 60);

        ZoomMeeting mtng = new ZoomMeeting();
        mtng.topic = evt.Name;
        mtng.start_time = String.valueOf(evt.Start_Date__c.format('yyyy-MM-dd\'T\'HH:mm:ss', 'America/New_York'));
        mtng.duration = Integer.valueOf(decMinutes);
        mtng.type = 2;
        mtng.timezone = 'America/New_York';
        mtng.agenda = evt.Description__c;
        mtng.password = password;
        req.setBody(JSON.serialize(mtng));
        req.setHeader('Connection', 'keep-alive');

        res = h.send(req);
        System.debug('response: ' + res);
        System.debug('status code: ' + res.getStatusCode());
        if (res.getStatusCode() == 204) {
            //GET call to get encrypted password
            h = new Http();
            req = new HttpRequest();
            res = new HttpResponse();
            req.setMethod('GET');
            req.setHeader('Authorization', 'Bearer ' + createJWTToken());
            req.setHeader('Content-Type', 'application/json');
            endpoint = 'https://api.zoom.us/v2/meetings/' + ved.External_Event_Id__c;
            req.setEndpoint(endpoint);
            res = h.send(req);
            System.debug('response: ' + res);
            if (res.getStatusCode() == 200) {
                Object jsonParse = (Object) JSON.deserializeUntyped(res.getBody());
                Map<String, Object> mp_StrObj = (Map<string, Object>) jsonParse;
                System.debug('object map ' + mp_StrObj);
                ved.Encrypted_Password__c = String.valueOf(mp_StrObj.get('encrypted_password'));
                update ved;
            }
        }
    }

    public static void deleteMeeting(String meetingId, Boolean isWebinar){
        System.debug('delete meeting ' + meetingId);
        if(meetingId!=null) {
            Http h = new Http();
            HttpRequest req = new HttpRequest();
            HttpResponse res = new HttpResponse();
            req.setMethod('DELETE');
            req.setHeader('Authorization', 'Bearer ' + createJWTToken());
            req.setHeader('Content-Type', 'application/json');
            String endpoint = 'https://api.zoom.us/v2/';
            if(isWebinar){
                endpoint += 'webinars/';
            } else {
                endpoint += 'meetings/';
            }
            endpoint += meetingId;
            req.setEndpoint(endpoint);

            res = h.send(req);
            System.debug('response: ' + res);
            System.debug('status code: ' + res.getStatusCode());
            if (res.getStatusCode() == 204) {
                List<Virtual_Event_Details__c> ved = [
                        SELECT Id
                        FROM Virtual_Event_Details__c
                        WHERE External_Event_Id__c = :meetingId
                ];
                if(!ved.isEmpty()) {
                    try{
                        delete ved;
                    } catch(Exception e){
                        new AACRCustomException(e.getMessage(), e.getStackTraceString(), 'Zoom Delete');
                    }

                }
            }
        }
    }


    public class ZoomMeeting {
        public String topic;
        public Integer type;
        public String start_time;
        public Integer duration;
        public String timezone;
        public String agenda;
        public String password;
    }





}