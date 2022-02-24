/**
 * Created by lauren.lezberg on 3/29/2021.
 */

public with sharing class ORCIDHelper {
    public String errorMsg;


    private static ORCID_Session__c getORCIDSession(){
        return ORCID_Session__c.getOrgDefaults();
    }

    public static String getORCIDAuthURL(String redirectURI){
        ORCID_Session__c os = getORCIDSession();

        String url = os.Base_URL__c + '/oauth/authorize?client_id=' + os.Client_Id__c
                + '&response_type=code&scope=/authenticate&redirect_uri=' + os.Redirect_URI__c + '%3Fret_URL=' + EncodingUtil.urlEncode(EncodingUtil.base64Encode(Blob.valueOf(redirectURI)), 'UTF-8');
        return url;
    }

    public static Boolean verifyORCID(String code, String redirectURI){
        ORCID_Session__c os = getORCIDSession();

        Http h = new Http();
        HttpResponse res = new HttpResponse();
        HttpRequest req = new HttpRequest();
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        String endpoint = os.Base_URL__c + '/oauth/token?client_id=' + os.Client_Id__c + '&client_secret='
                + os.Client_Secret__c + '&grant_type=authorization_code&code=' + code + '&redirect_uri=' + os.Redirect_URI__c + '%3Fret_URL=' + EncodingUtil.urlEncode(EncodingUtil.base64Encode(Blob.valueOf(redirectURI)), 'UTF-8');
        req.setEndpoint(endpoint);

        res = h.send(req);
        System.debug('orcid response: ' + res);
        Object jsonParse = (Object) JSON.deserializeUntyped(res.getBody());
        Map<String, Object> mp_StrObj = (Map<string, Object>) jsonParse;
        System.debug('objectMap: ' + mp_StrObj);
        if (res.getStatusCode() == 200) {
            String userORCID = String.valueOf(mp_StrObj.get('orcid'));
            system.debug('userORCID: ' + userORCID);
            try {
                updateORCID(userORCID);
                return true;
            } catch(Exception e){
                return false;
            }
        }

        return false;
    }

    public static void updateORCID(String id){
        User u = [SELECT Id, ORCID__c FROM User WHERE Id=:UserInfo.getUserId()];
        u.ORCID__c = id;
        update u;
    }

}