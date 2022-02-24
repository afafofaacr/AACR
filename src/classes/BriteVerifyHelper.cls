/**
 * Created by lauren.lezberg on 2/23/2021.
 */

public without sharing class BriteVerifyHelper {

    /**
         * @purpose Retrieve stripe secret key from custom setting - for API
         * @return stripe secret key
         */
    private static String getValidityAPIKey() {
        Validity_Session__c vSession = Validity_Session__c.getOrgDefaults();
        return vSession.API_Key__c;
    }

    public static Boolean verifyEmail(String email){
        Boolean isVerified = true;

        Http h = new Http();
        HttpResponse res = new HttpResponse();
        HttpRequest req = new HttpRequest();
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/json');
        String endpoint = 'https://bpi.briteverify.com/api/v1/fullverify?apikey=' + getValidityAPIKey();
        req.setEndpoint(endpoint);

        String payload = '{"email" : "' + email + '"}';

        System.debug('payload: ' + payload);
        req.setBody(payload);
        req.setTimeout(20000);
        res = h.send(req);
        Object jsonParse = (Object) JSON.deserializeUntyped(res.getBody());
        Map<String, Object> mp_StrObj = (Map<string, Object>) jsonParse;
        System.debug('objectMap: ' + mp_StrObj);
        if (res.getStatusCode() == 200) {
            Object emailObj = mp_StrObj.get('email');
            Map<String, Object> mp_emailObj = (Map<string, Object>) emailObj;
            if(String.valueOf(mp_emailObj.get('status'))=='invalid'){
                isVerified = false;
            }
        }


        return isVerified;
    }

}