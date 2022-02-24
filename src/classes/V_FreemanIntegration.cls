/**
 * Created by lauren.lezberg on 9/25/2020.
 */

public without sharing class V_FreemanIntegration implements Callable, VirtualEventIntegration{

    /** EXAMPLE CALL **/
//    Callable extension = (Callable) Type.forName(className).newInstance();
//    Decimal result = (Decimal) extension.call(methodName, new Map<String, Object> { 'decimalValue' => decimalTestValue });

    public Object call(String action, Map<String, Object> args){
        switch on action {
            when 'sendAttendee' {
                return this.sendAttendee((String)args.get('contactId'), (String)args.get('externalEventId'), (Boolean)args.get('flag'));
//                return null;
            }
            when 'asyncSendAttendee' {
                V_FreemanIntegration.asyncSendAttendee((String)args.get('contactId'), (String)args.get('externalEventId'), (Boolean)args.get('flag'));
                return null;
            }
            when 'updateAttendee' {
               V_FreemanIntegration.updateAttendee((String)args.get('participantId'));
                return null;
            }
            when 'deleteAttendee' {
                V_FreemanIntegration.deleteAttendee((String)args.get('fuzionAttendeeId'), (String)args.get('fuzionEventId'));
                return null;
            }
            when 'goToVenue' {
                return this.goToVenue((String)args.get('contactId'), (String)args.get('SFEventId'));
            }
            when else {
                throw new AACRCustomException('Failure to execute action: ' + action, 'V_FreemanIntegration.call()', 'FreemanIntegration');
            }
        }
    }


    public String sendAttendee(String contactId, String externalEventId, Boolean flag){

        if(flag==null){
            flag = false;
        }
//        String contactString = JSON.serialize([SELECT FirstName, LastName, Id, AACR_ID__c, Salutation, Title, OrderApi__Preferred_Email__c FROM COntact WHERE Id=: contactId]);
        Http h;
        HttpRequest reqAuth;
        HttpResponse resAuth;

        Virtual_Event_Details__c ved = [SELECT Id, Event__c FROM Virtual_Event_Details__c WHERE External_Event_Id__c =: externalEventId];
//        Contact con = (Contact)JSON.deserialize(contactString, Contact.class);
        BR_Participation__c participant = [SELECT Id, AC_User_Segment__r.Name, COMP_Code__c, Fon_Sales_Order__r.OrderApi__Source_Code__c, Fon_Sales_Order__r.OrderApi__Source_Code__r.Name, User__c, User__r.Email, Is_Booth_Staff__c, Exhibitor_Id__c, Contact__r.AACR_ID__c, Contact__r.Account.Name, Contact__r.Salutation,
                                            Contact__r.FirstName, Contact__r.LastName, Contact__r.MiddleName, Contact__r.Suffix_Text__c,
                                            Contact__r.Title, Contact__r.Email, Contact__r.OrderApi__Work_Phone__c, Contact__r.MailingCountry,
                                            Contact__r.MailingStreet, Contact__r.MailingCity, Contact__r.MailingState, Contact__r.MailingPostalCode,
                                            Contact__r.Primary_Research_Area_of_Expertise__c, Contact__r.Major_Focus__c, Contact__r.Organ_Sites__c,
                                            Contact__r.RecordType.Name, Contact__r.Highest_Degree__c, Contact__r.OrderApi__Preferred_Phone__c
                                            FROM BR_Participation__c
                                            WHERE Contact__c=:contactId AND BR_Event__c=: ved.Event__c AND Participate__c='Yes' ];
        Contact con = [SELECT FirstName, LastName, Id, AACR_ID__c, Salutation, Title, OrderApi__Preferred_Email__c FROM COntact WHERE Id=: contactId];


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
        reqAuth.setHeader('fuzion_event_id', externalEventId);
        reqAuth.setHeader('request_timestamp', String.valueOf(timestamp));
        reqAuth.setHeader('partner_app_signature', buildPartnerAppSignature(fSession, 'POST', timestamp, '/v1/attendees'));

        String body = createFuzionAttendeeJSON(participant);
        System.debug('body: ' + body);

        reqAuth.setBody(body);

        try {
            resAuth = h.send(reqAuth);

            System.debug('Response body received = ' + resAuth.getBody());

            System.debug('Response status received = ' + resAuth.getStatus());
            System.debug('Response status code = ' + resAuth.getStatusCode());
            if (resAuth.getStatusCode() == 200) {
                System.debug('success!');
                String resBody = resAuth.getBody();

                Object fuzionAtt = (Object)JSON.deserializeUntyped(resBody);
                System.debug('fuzionAtt: ' + fuzionAtt);
                Map<String,Object> mp_StrObj = (Map<string,Object>)fuzionAtt;
                SYstem.debug('map: ' + mp_StrObj);

                String payloadStr = JSON.serialize(mp_StrObj.get('payload'));
                System.debug('payloadStr: ' + payloadStr);
                Object payload = (Object)JSON.deserializeUntyped(payloadStr);
                Map<String,Object> mp_payload = (Map<string,Object>)payload;

                return (String)mp_payload.get('fuzion_attendee_id');
            } else {
                ErrorHelper.sendExceptionEmail('Event Registration', 'Freeman Callout Failure: ' + resAuth.getStatus(), resAuth.getBody());
                return null;
            }

        } catch (Exception e) {
            System.debug('Error: ' + e.getMessage());
            ErrorHelper.sendExceptionEmail('Event Registration', e.getMessage(), e.getStackTraceString());
            return null;
        }
    }

    @future (callout=true)
    public static void deleteAttendee(String fuzionAttendeeId, String fuzionEventId){
        Http h;
        HttpRequest reqAuth;
        HttpResponse resAuth;


        Fuzion_Session__c fSession = Fuzion_Session__c.getOrgDefaults();

        Long timestamp = datetime.now().getTime();

        h = new Http();

        String fuzionPath = '/v1/attendees/' + fuzionAttendeeId;
        String method = 'DELETE';
        String apiURL = 'https://fuzionapi.com' + fuzionPath;
        System.debug('apiURL: ' + apiURL);

        reqAuth = new HttpRequest();
        reqAuth.setEndpoint(apiURL);
        reqAuth.setMethod(method);
        reqAuth.setHeader('Content-Type', 'application/json');
        reqAuth.setHeader('partner_app_key', fSession.Client_Id__c);
        reqAuth.setHeader('fuzion_event_id', fuzionEventId);
        reqAuth.setHeader('request_timestamp', String.valueOf(timestamp));
        reqAuth.setHeader('partner_app_signature', buildPartnerAppSignature(fSession, method, timestamp, fuzionPath));

        try {
            resAuth = h.send(reqAuth);
            System.debug('Response body received = ' + resAuth.getBody());

            if (resAuth.getStatusCode() == 200) {
                System.debug('success!');

            } else {
                ErrorHelper.sendExceptionEmail('Fuzion Attendee DELETE', 'Freeman Callout Failure: ' + resAuth.getStatus(), resAuth.getBody());
            }
        } catch (Exception e) {
            System.debug('Error: ' + e.getMessage());
            ErrorHelper.sendExceptionEmail('Fuzion Attendee DELETE', e.getMessage(), e.getStackTraceString());
        }
    }

    public static void updateAttendee(String participantId){
        Http h;
        HttpRequest reqAuth;
        HttpResponse resAuth;

        BR_Participation__c participant = [SELECT Id, AC_User_Segment__r.Name, COMP_Code__c,Fon_Sales_Order__r.OrderApi__Source_Code__c, Fon_Sales_Order__r.OrderApi__Source_Code__r.Name, User__c,User__r.Email, Is_Booth_Staff__c, Exhibitor_Id__c, Contact__r.AACR_ID__c, Contact__r.Account.Name, Contact__r.Salutation,
                Contact__r.FirstName, Contact__r.LastName, Contact__r.MiddleName, Contact__r.Suffix_Text__c,Contact__r.OrderApi__Preferred_Phone__c,
                Contact__r.Title, Contact__r.Email, Contact__r.OrderApi__Work_Phone__c, Contact__r.MailingCountry,
                Contact__r.MailingStreet, Contact__r.MailingCity, Contact__r.MailingState, Contact__r.MailingPostalCode,
                Contact__r.Primary_Research_Area_of_Expertise__c, Contact__r.Major_Focus__c, Contact__r.Organ_Sites__c,
                Contact__r.RecordType.Name, Contact__r.Highest_Degree__c, BR_Event__c,External_Attendee_Id__c
        FROM BR_Participation__c
        WHERE Id=:participantId];

        Virtual_Event_Details__c ved = [SELECT Id, External_Event_Id__c FROM Virtual_Event_Details__c WHERE Event__c=:participant.BR_Event__c];

        Fuzion_Session__c fSession = Fuzion_Session__c.getOrgDefaults();


        Long timestamp = datetime.now().getTime();

        h = new Http();

        String fuzionPath = '/v1/attendees/' + participant.External_Attendee_Id__c;
        String method = 'PUT';
        String apiURL = 'https://fuzionapi.com' + fuzionPath;
        System.debug('apiURL: ' + apiURL);

        reqAuth = new HttpRequest();
        reqAuth.setEndpoint(apiURL);
        reqAuth.setMethod(method);
        reqAuth.setHeader('Content-Type', 'application/json');
        reqAuth.setHeader('partner_app_key', fSession.Client_Id__c);
        reqAuth.setHeader('fuzion_event_id', ved.External_Event_Id__c);
        reqAuth.setHeader('request_timestamp', String.valueOf(timestamp));
        reqAuth.setHeader('partner_app_signature', buildPartnerAppSignature(fSession, method, timestamp, fuzionPath));

        String body = createFuzionAttendeeJSON(participant);
        System.debug('body: ' + body);

        reqAuth.setBody(body);

        try {
            resAuth = h.send(reqAuth);
            System.debug('Response body received = ' + resAuth.getBody());

            if (resAuth.getStatusCode() == 200) {
                System.debug('success!');

            } else {
                ErrorHelper.sendExceptionEmail('Fuzion Attendee UPDATE', 'Freeman Callout Failure: ' + resAuth.getStatus(), resAuth.getBody());
            }
        } catch (Exception e) {
            System.debug('Error: ' + e.getMessage());
            ErrorHelper.sendExceptionEmail('Fuzion Attendee UPDATE', e.getMessage(), e.getStackTraceString());
        }



    }

    @Future(callout=true)
    public static void asyncSendAttendee(String contactId, String externalEventId, Boolean flag){
        Http h;
        HttpRequest reqAuth;
        HttpResponse resAuth;

        Virtual_Event_Details__c ved = [SELECT Id, Event__c FROM Virtual_Event_Details__c WHERE External_Event_Id__c =: externalEventId];
//        Contact con = (Contact)JSON.deserialize(contactString, Contact.class);
        BR_Participation__c participant = [SELECT Id,AC_User_Segment__r.Name, COMP_Code__c,Fon_Sales_Order__r.OrderApi__Source_Code__c, Fon_Sales_Order__r.OrderApi__Source_Code__r.Name, User__c,User__r.Email, Is_Booth_Staff__c, Exhibitor_Id__c, Contact__r.AACR_ID__c, Contact__r.Account.Name, Contact__r.Salutation,
                Contact__r.FirstName, Contact__r.LastName, Contact__r.MiddleName, Contact__r.Suffix_Text__c,Contact__r.OrderApi__Preferred_Phone__c,
                Contact__r.Title, Contact__r.Email, Contact__r.OrderApi__Work_Phone__c, Contact__r.MailingCountry,
                Contact__r.MailingStreet, Contact__r.MailingCity, Contact__r.MailingState, Contact__r.MailingPostalCode,
                Contact__r.Primary_Research_Area_of_Expertise__c, Contact__r.Major_Focus__c, Contact__r.Organ_Sites__c,
                Contact__r.RecordType.Name, Contact__r.Highest_Degree__c
        FROM BR_Participation__c
        WHERE Contact__c=:contactId AND BR_Event__c=: ved.Event__c AND Participate__c = 'Yes'];
        Contact con = [SELECT FirstName, LastName, Id, AACR_ID__c, Salutation, Title, OrderApi__Preferred_Email__c FROM COntact WHERE Id=: contactId];

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
        reqAuth.setHeader('fuzion_event_id', externalEventId);
        reqAuth.setHeader('request_timestamp', String.valueOf(timestamp));
        reqAuth.setHeader('partner_app_signature', buildPartnerAppSignature(fSession, 'POST', timestamp, '/v1/attendees'));

        String body = createFuzionAttendeeJSON(participant);
        System.debug('body: ' + body);

        reqAuth.setBody(body);

        try {
            resAuth = h.send(reqAuth);
            System.debug('Response body received = ' + resAuth.getBody());

            System.debug('Response status received = ' + resAuth.getStatus());
            System.debug('Response status code = ' + resAuth.getStatusCode());
            if (resAuth.getStatusCode() == 200) {
                System.debug('success!');

                String resBody = resAuth.getBody();

                Object fuzionAtt = (Object)JSON.deserializeUntyped(resBody);
                System.debug('fuzionAtt: ' + fuzionAtt);
                Map<String,Object> mp_StrObj = (Map<string,Object>)fuzionAtt;
                SYstem.debug('map: ' + mp_StrObj);

                String payloadStr = JSON.serialize(mp_StrObj.get('payload'));
                System.debug('payloadStr: ' + payloadStr);
                Object payload = (Object)JSON.deserializeUntyped(payloadStr);
                Map<String,Object> mp_payload = (Map<string,Object>)payload;

                //update participation record because you can't return string from future method
                String attendeeId = (String)mp_payload.get('fuzion_attendee_id');
                BR_Participation__c p = [SELECT Id, External_Attendee_Id__c FROM BR_Participation__c WHERE Contact__c =: contactId AND BR_Event__c IN (SELECT Event__c FROM VIrtual_Event_Details__c WHERE External_Event_Id__c =:externalEventId)];
                p.External_Attendee_Id__c = attendeeId;
                update p;

            } else {
                ErrorHelper.sendExceptionEmail('Event Registration', 'Freeman Callout Failure: ' + resAuth.getStatus(), resAuth.getBody());
            }
        } catch (Exception e) {
            System.debug('Error: ' + e.getMessage());
            ErrorHelper.sendExceptionEmail('Event Registration', e.getMessage(), e.getStackTraceString());
        }
    }

    public String goToVenue(String contactId, String SFEventId){
        BR_Event__c evt = [SELECT Id, Virtual_Venue__r.Base_URL__c FROM BR_Event__c WHERE Id=: SFEventId];

        Virtual_Event_Details__c ved = [SELECT External_Event_Id__c FROM Virtual_Event_Details__c WHERE Event__c=: SFEventId];

        String retURL = evt.Virtual_Venue__r.Base_URL__c;

        return retURL;
    }

    public static String buildPartnerAppSignature(Fuzion_Session__c fuzion_session, String method, Long timestamp, String path) {
        String secretKey = fuzion_session.Client_Secret__c;

        String host = 'fuzionapi.com';
//        String path = '/v1/attendees';

        SYstem.debug('timestamp: ' + timestamp);
        String fuzionAppKey = fuzion_session.Client_Id__c;
        String signatureParts = host + path + '|' + method + '|' + timestamp + '|' + fuzionAppKey;
        System.debug('signatureParts: ' + signatureParts);


        Blob hmacData = crypto.generateMac('HmacSHA256',
                Blob.valueOf(signatureParts), Blob.valueOf(secretKey));

        System.debug('hmacData: ' + EncodingUtil.base64Encode(hmacData));

        return EncodingUtil.base64Encode(hmacData);
    }


    public static String createFuzionAttendeeJSON(BR_Participation__c participant) {
        System.debug('creating fuzionAttendeeJSON: ' + participant);

        List<Poster_Presenter__c> presenters = [SELECT GRIP_Primary_Filter__c, GRIP_Secondary_Filter__c FROM Poster_Presenter__c WHERE Presenter_Email__c=: participant.Contact__r.Email];

        FuzionAttendee fAtt = new FuzionAttendee();
        fAtt.attendee_type_flag = participant.AC_User_Segment__r.Name!=null?participant.AC_User_Segment__r.Name:'Default';
        fAtt.registration_number = participant.User__c;


        fAtt.booth_staff_flag = participant.Is_Booth_Staff__c?1:0;
        if(participant.Exhibitor_Id__c!=null) {
            fAtt.exhibitor_company_id = participant.Exhibitor_Id__c;
        }

        fAtt.custom_attributes = '[{\"AACR_ID\": \"' + participant.Contact__r.AACR_ID__c + '\"}';
        if(participant.COMP_Code__c!=null){
            fAtt.custom_attributes += ',{\"CompCode\":\"' + participant.COMP_Code__c + '\"}';
        }
        if(participant.Contact__r.Primary_Research_Area_of_Expertise__c!=null){
            fAtt.custom_attributes += ',{\"Research_Area_of_Expertise\":\"' + participant.Contact__r.Primary_Research_Area_of_Expertise__c + '\"}';
        }
        if(participant.Contact__r.Major_Focus__c!=null){
            fAtt.custom_attributes += ',{\"Major_Focus\":\"' + participant.Contact__r.Major_Focus__c + '\"}';
        }
        if(participant.Contact__r.Organ_Sites__c!=null){
            fAtt.custom_attributes += ',{\"Organ_Sites\":\"' + participant.Contact__r.Organ_Sites__c + '\"}';
        }
        if(participant.Contact__r.Highest_Degree__c!=null){
            fAtt.custom_attributes += ',{\"Highest_Degree\":\"' + participant.Contact__r.Highest_Degree__c + '\"}';
        }


        //POSTER PRESENTERS
        if(!presenters.isEmpty()){
            fAtt.custom_attributes += ',{\"IsPoster\":\"Poster Presenters\"}';
            if(presenters.size()<=5) {
                for (Integer i = 0; i < presenters.size(); i++) {
                    fAtt.custom_attributes += ',{\"Grip_Filter_' + String.valueOf(i + 1) + '\":\"' + presenters[i].GRIP_Secondary_Filter__c + '\"}';
                }
            } else if(presenters.size() > 5){
                for (Integer i = 0; i < 5; i++) {
                    fAtt.custom_attributes += ',{\"Grip_Filter_' + String.valueOf(i + 1) + '\":\"' + presenters[i].GRIP_Secondary_Filter__c + '\"}';
                }
            }
        }

        fAtt.custom_attributes += ']';

        FuzionContact fCon = new FuzionContact();

        fCon.name_prefix = participant.Contact__r.Salutation != null ? participant.Contact__r.Salutation : null;
        fCon.title = participant.Contact__r.Title != null ? participant.Contact__r.Title : null;
        fCon.first_name = participant.Contact__r.FirstName;
        fCon.middle_name = participant.Contact__r.MiddleName!=null?participant.Contact__r.MiddleName:null;
        fCon.last_name = participant.Contact__r.LastName;
        fCon.email = participant.User__r.Email;
        fCon.company = !participant.Contact__r.Account.Name.contains('Household')?participant.Contact__r.Account.Name:null;
        fCon.name_suffix = participant.Contact__r.Suffix_Text__c!=null?participant.Contact__r.Suffix_Text__c:null;
        fCon.phone_number = participant.Contact__r.OrderApi__Preferred_Phone__c!=null? participant.Contact__r.OrderApi__Preferred_Phone__c:null;
        fCon.contact_type = participant.Contact__r.RecordType.Name;

        fAtt.contact = fCon;


        FuzionAddress fAdd = new FuzionAddress();
        fAdd.country = participant.Contact__r.MailingCountry!=null?participant.Contact__r.MailingCountry:null;
        fAdd.address_line_one = participant.Contact__r.MailingStreet!=null?participant.Contact__r.MailingStreet:null;
        fAdd.city = participant.Contact__r.MailingCity!=null?participant.Contact__r.MailingCity:null;
        fAdd.state_province = participant.Contact__r.MailingState!=null?participant.Contact__r.MailingState:null;
        fAdd.postal_code = participant.Contact__r.MailingPostalCode!=null?participant.Contact__r.MailingPostalCode:null;


        fAtt.address = fAdd;

        String attendeeString = JSON.serialize(fAtt, true);
        System.debug('string: ' + attendeeString);

        return attendeeString;
    }


    public class FuzionAttendee {
        public String registration_number;
        public Integer booth_staff_flag;
        public String exhibitor_company_id;
        public String attendee_type_flag;
        public String custom_attributes;
        public FuzionContact contact;
        public FuzionAddress address;

    }

    public class FuzionContact {
        public String contact_type;
        public String name_prefix;
        public String first_name;
        public String last_name;
        public String email;
        public String title;
        public String company;
        public String middle_name;
        public String name_suffix;
        public String phone_number;
    }

    public class FuzionAddress {
        public String address_line_one;
        public String postal_code;
        public String city;
        public String state_province;
        public String country;
    }

}