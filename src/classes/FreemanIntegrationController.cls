/**
 * Created by lauren.lezberg on 4/22/2020.
 */

public without sharing class FreemanIntegrationController {
    public static Virtual_Meeting_Links__mdt virtualMeeting = new Virtual_Meeting_Links__mdt();


    public static void createFreemanAttendee(String contactString, String eventId, Boolean setBusinessFlag){ 
        Http h;
        HttpRequest reqAuth;
        HttpResponse resAuth;

        Contact con = (Contact)JSON.deserialize(contactString, Contact.class);

        Fuzion_Session__c fSession = Fuzion_Session__c.getOrgDefaults();


        Long timestamp = datetime.now().getTime();

        h = new Http();

        String apiURL = 'https://fuzionapi.com/v1/attendees';
        System.debug('apiURL: ' + apiURL);

        reqAuth = new HttpRequest();
        reqAuth.setEndpoint(apiURL);
        reqAuth.setMethod('POST');
        reqAuth.setHeader('Content-Type', 'application/json');
        reqAuth.setHeader('partner_app_key', fSession.Client_Id__c);
        reqAuth.setHeader('fuzion_event_id', eventId);
        reqAuth.setHeader('request_timestamp', String.valueOf(timestamp));
        reqAuth.setHeader('partner_app_signature', buildPartnerAppSignature(fSession, 'POST', timestamp));

        String body = createFuzionAttendeeJSON(con, setBusinessFlag);
        System.debug('body: ' + body);

        reqAuth.setBody(body);

        try {
            resAuth = h.send(reqAuth);
            System.debug('Response body received = ' + resAuth.getBody());

            System.debug('Response status received = ' + resAuth.getStatus());
            System.debug('Response status code = ' + resAuth.getStatusCode());
            if (resAuth.getStatusCode() == 200) {
                System.debug('success!');
//                Virtual_Meeting_Links__mdt vml = new Virtual_Meeting_Links__mdt();
//                if (Test.isRunningTest()) {
//                    System.debug('running test: ' + virtualMeeting);
//                    vml = virtualMeeting;
//                } else {
//                    vml = [SELECT View_Link__c FROM Virtual_Meeting_Links__mdt WHERE Freeman_Event_Id__c = :eventId];
//                }
//                return vml.View_Link__c;
            } else {
                ErrorHelper.sendExceptionEmail('Event Registration', 'Freeman Callout Failure', resAuth.getStatus());
            }

        } catch (Exception e) {
            System.debug('Error: ' + e.getMessage());
            ErrorHelper.sendExceptionEmail('Event Registration', e.getMessage(), e.getStackTraceString());
//            return null;
        }

//        return null;

    }

    @Future(callout=true)
    public static void asyncCreateFreemanAttendee(String contactString, String eventId, Boolean setBusinessFlag){
        Http h;
        HttpRequest reqAuth;
        HttpResponse resAuth;

        Contact con = (Contact)JSON.deserialize(contactString, Contact.class);

        Fuzion_Session__c fSession = Fuzion_Session__c.getOrgDefaults();


        Long timestamp = datetime.now().getTime();

        h = new Http();

        String apiURL = 'https://fuzionapi.com/v1/attendees';
        System.debug('apiURL: ' + apiURL);

        reqAuth = new HttpRequest();
        reqAuth.setEndpoint(apiURL);
        reqAuth.setMethod('POST');
        reqAuth.setHeader('Content-Type', 'application/json');
        reqAuth.setHeader('partner_app_key', fSession.Client_Id__c);
        reqAuth.setHeader('fuzion_event_id', eventId);
        reqAuth.setHeader('request_timestamp', String.valueOf(timestamp));
        reqAuth.setHeader('partner_app_signature', buildPartnerAppSignature(fSession, 'POST', timestamp));

        String body = createFuzionAttendeeJSON(con, setBusinessFlag);
        System.debug('body: ' + body);

        reqAuth.setBody(body);

        try {
            resAuth = h.send(reqAuth);
            System.debug('Response body received = ' + resAuth.getBody());

            System.debug('Response status received = ' + resAuth.getStatus());
            System.debug('Response status code = ' + resAuth.getStatusCode());
            if (resAuth.getStatusCode() == 200) {
                System.debug('success!');
            } else {
                ErrorHelper.sendExceptionEmail('Event Registration', 'Freeman Callout Failure: ' + resAuth.getStatus(), resAuth.getBody());
            }
        } catch (Exception e) {
            System.debug('Error: ' + e.getMessage());
            ErrorHelper.sendExceptionEmail('Event Registration', e.getMessage(), e.getStackTraceString());

        }


    }

    public static String createFreemanAttendee(Contact con, Boolean setBusinessFlag) {

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
        reqAuth.setMethod('POST');
        reqAuth.setHeader('Content-Type', 'application/json');
        reqAuth.setHeader('partner_app_key', fSession.Client_Id__c);
        reqAuth.setHeader('fuzion_event_id', fSession.Event_Id__c);
        reqAuth.setHeader('request_timestamp', String.valueOf(timestamp));
        reqAuth.setHeader('partner_app_signature', buildPartnerAppSignature(fSession, 'POST', timestamp));

        String body = createFuzionAttendeeJSON(con, setBusinessFlag);
        System.debug('body: ' + body);

        reqAuth.setBody(body);

        try {
            resAuth = h.send(reqAuth);
            System.debug('Response body received = ' + resAuth.getBody());

            System.debug('Response status received = ' + resAuth.getStatus());
            System.debug('Response status code = ' + resAuth.getStatusCode());
            if (resAuth.getStatusCode() == 200) {
                Virtual_Meeting_Links__mdt vml = new Virtual_Meeting_Links__mdt();
                if (Test.isRunningTest()) {
                    System.debug('running test: ' + virtualMeeting);
                    vml = virtualMeeting;
                } else {
                    vml = [SELECT View_Link__c FROM Virtual_Meeting_Links__mdt WHERE Freeman_Event_Id__c = :fSession.Event_Id__c];
                }
                return vml.View_Link__c;
            }else {
                ErrorHelper.sendExceptionEmail('Event Registration', 'Freeman Callout Failure', resAuth.getStatus());
            }

        } catch (Exception e) {
            System.debug('Error: ' + e.getMessage());
            return null;
        }

        return null;

    }

    private static String buildPartnerAppSignature(Fuzion_Session__c fuzion_session, String method, Long timestamp) {
        String secretKey = fuzion_session.Client_Secret__c;

        String host = 'fuzionapi.com';
        String path = '/v1/attendees';

        SYstem.debug('timestamp: ' + timestamp);
        String fuzionAppKey = fuzion_session.Client_Id__c;
        String signatureParts = host + path + '|' + method + '|' + timestamp + '|' + fuzionAppKey;
        System.debug('signatureParts: ' + signatureParts);


        Blob hmacData = crypto.generateMac('HmacSHA256',
                Blob.valueOf(signatureParts), Blob.valueOf(secretKey));

        System.debug('hmacData: ' + EncodingUtil.base64Encode(hmacData));

        return EncodingUtil.base64Encode(hmacData);
    }

    public static String createFuzionAttendeeJSON(Contact con, Boolean setBusinessFlag) {
        System.debug('creating fuzionAttendeeJSON: ' + con);

        FuzionAttendee fAtt = new FuzionAttendee();
        fAtt.attendee_type_flag = '0';
        fAtt.registration_number = con.Id;

        fAtt.custom_attributes = '[{\"AACR_ID\": \"' + con.AACR_ID__c + '\"}';
        if(setBusinessFlag){
            fAtt.custom_attributes += ',{\"BusinessMeeting\":' + 1 + '}';
        }
        fAtt.custom_attributes += ']';

        FuzionContact fCon = new FuzionContact();

        fCon.name_prefix = con.Salutation != null ? con.Salutation : 'Dr.';
        if(con.Title!=null) {
            fCon.title = con.Title != null ? con.Title : 'empty';
        }
        fCon.first_name = con.FirstName;
        fCon.last_name = con.LastName;
        fCon.email = con.OrderApi__Preferred_Email__c;

        fAtt.contact = fCon;


        FuzionAddress fAdd = new FuzionAddress();
//        if(con.Preferred_Address__c == 'Business') {
//            fAdd.address_line_one = con.MailingStreet!=null?con.MailingStreet:null;
//            fAdd.city = con.MailingCity!=null?con.MailingCity:null;
//            fAdd.state_province = con.MailingState!=null?con.MailingState:null;
//            fAdd.country = con.MailingCountry!=null?con.MailingCountry:null;
//        } else {
//            fAdd.address_line_one = con.OtherStreet!=null?con.OtherStreet:null;
//            fAdd.city = con.OtherCity!=null?con.OtherCity:null;
//            fAdd.state_province = con.OtherState!=null?con.OtherState:null;
//            fAdd.country = con.OtherCountry!=null?con.OtherCountry:null;
//        }

        fAtt.address = fAdd;

        String attendeeString = JSON.serialize(fAtt, true);
        System.debug('string: ' + attendeeString);

        return attendeeString;
    }


    public class FuzionAttendee {
        public String registration_number;
        public String attendee_type_flag;
        public String custom_attributes;
        public FuzionContact contact;
        public FuzionAddress address;

    }

    public class FuzionContact {

        public String name_prefix;
        public String first_name;
        public String last_name;
        public String email;
        public String title;
    }

    public class FuzionAddress {
        public String address_line_one;
        public String address_line_two;
        public STring address_line_three;
        public String city;
        public String state_province;
        public String country;
    }

//    public static String createFreemanAttendee(Contact con){
//
//        Http h;
//        HttpRequest reqAuth;
//        HttpResponse resAuth;
//
//        Fuzion_Session__c fSession = Fuzion_Session__c.getOrgDefaults();
//
//        Long timestamp = datetime.now().getTime();
//
//        h = new Http();
//
//        String apiURL = 'https://fuzionapi.com/v1/attendees';
//        System.debug('apiURL: ' + apiURL);
//
//        reqAuth = new HttpRequest();
//        reqAuth.setEndpoint(apiURL);
//        reqAuth.setMethod('POST');
//        reqAuth.setHeader('Content-Type', 'application/json');
//        reqAuth.setHeader('partner_app_key', fSession.Client_Id__c);
//        reqAuth.setHeader('fuzion_event_id', fSession.Event_Id__c);
//        reqAuth.setHeader('request_timestamp', String.valueOf(timestamp));
//        reqAuth.setHeader('partner_app_signature', buildPartnerAppSignature(fSession, 'POST', timestamp));
//
//        String body = createFuzionAttendeeJSON(con);
//        System.debug('body: ' + body);
//
//        reqAuth.setBody(body);
//
//        try{
//            resAuth= h.send(reqAuth);
//            System.debug('Response body received = ' + resAuth.getBody());
//
//            System.debug('Response status received = ' + resAuth.getStatus());
//            System.debug('Response status code = ' + resAuth.getStatusCode());
//            if (resAuth.getStatusCode() == 200){
//                Virtual_Meeting_Links__mdt vml = new Virtual_Meeting_Links__mdt();
//                if(Test.isRunningTest()){
//                    System.debug('running test: ' + virtualMeeting);
//                    vml = virtualMeeting;
//                } else{
//                    vml = [SELECT View_Link__c FROM Virtual_Meeting_Links__mdt WHERE Freeman_Event_Id__c =: fSession.Event_Id__c];
//                }
//                return vml.View_Link__c;
//            }
//            if (resAuth.getStatusCode() == 401 && resAuth.getStatus() == 'Unauthorized') {
//                System.debug('Response: Unauthorized.');
//            }
//        } catch(Exception e){
//            System.debug('Error: ' + e.getMessage());
//            return null;
//        }
//
//        return null;
//
//    }


}