/**
 * Created by lauren.lezberg on 3/17/2021.
 */

public without sharing class V_VFairsIntegration implements Callable, VirtualEventIntegration{

    public Object call(String action, Map<String, Object> args){
        switch on action {
            when 'sendAttendee' {
                return this.sendAttendee((String)args.get('contactId'), (String)args.get('externalEventId'), (Boolean)args.get('flag'));
            }
            when 'asyncSendAttendee' {
                V_VFairsIntegration.asyncSendAttendee((String)args.get('contactId'), (String)args.get('externalEventId'), (Boolean)args.get('flag'));
                return null;
            }
            when 'updateAttendee' {
                return null;
            }
            when 'deleteAttendee' {
                return null;
            }
            when 'goToVenue' {
                return this.goToVenue((String)args.get('contactId'), (String)args.get('SFEventId'));
            }
            when else {
                throw new AACRCustomException('Failure to execute action: ' + action, 'V_VFairsIntegration.call()', 'VFairsIntegration');
            }
        }
    }

    public String goToVenue(String contactId, String SFEventId){
//        Contact con = [SELECT Id, FirstName, LastName, Email FROM Contact WHERE Id=:contactId];
//        //using user email because of bad data on contacts
//        User u = [SELECT Email FROM User WHERE ContactId=: contactId];
//
//        BR_Event__c evt = [SELECT Id, Virtual_Venue__r.Base_URL__c FROM BR_Event__c WHERE Id=: SFEventId];
//
//        String retURL = evt.Virtual_Venue__r.Base_URL__c + createVFairsJWT(con.FirstName, con.LastName, u.Email);

        String retURL = vFairsHelper.getAttendeeLoginURL(contactId, SFEventId);

        return retURL;
    }

    public String sendAttendee(String contactId, String externalEventId, Boolean flag) {
       return null;
    }

    @Future(callout=true)
    public static void asyncSendAttendee(String contactId, String externalEventId, Boolean flag) {
    }

    public void deleteAttendee(String fuzionAttendeeId, String fuzionEventId) {
    }

    public void updateAttendee(String participantId) {
    }


//    private static String createVFairsJWT(String firstName, String lastName, String email){
//        System.debug('createVFairsJWT: ' + firstName + ' ' + lastName + ' ' + email);
//        vFairs_Session__c vSession = vFairs_Session__c.getOrgDefaults();
//        String header = '{"alg":"HS256","typ":"JWT"}';
//        String payload = '{"first_name":"' + firstName + '","last_name":"' + lastName + '","email":"' + email + '"}';
//        String key = vSession.API_Key__c;
//
//        String header64 = EncodingUtil.base64Encode(Blob.valueOf(header));
//        header64 = header64.replaceAll('=', '');
//        header64 = header64.replaceAll('/', '_');
//        System.debug('header64: ' + header64);
//
//        String payload64 = EncodingUtil.base64Encode(Blob.valueOf(payload));
//        payload64 = payload64.replaceAll('=', '');
//        payload64 = payload64.replaceAll('/', '_');
//        System.debug('payload64: ' + payload64);
//
//        Blob hmacData = Crypto.generateMac('hmacSHA256', Blob.valueOf(header64 + '.' + payload64), Blob.valueOf(key));
//
//        String signature = EncodingUtil.base64Encode(hmacData);
//
//        String token = header64 + '.' + payload64 + '.' + signature;
//        token = token.replaceAll('=', '');
//        token = token.replaceAll('/', '_');
//
//        return token;
//    }
}