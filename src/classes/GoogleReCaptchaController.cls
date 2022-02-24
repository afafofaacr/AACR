/**
 * Created by afaf.awad on 10/13/2021.
 */

public with sharing class GoogleReCaptchaController {

    public GoogleReCaptchaController() {

    }

    @AuraEnabled
    public static String getSiteKey(){
        String siteKey ='';
        ReCaptcha__c setting = ReCaptcha__c.getOrgDefaults();

        if ( Test.isRunningTest() ) {
            siteKey = '1234';
        } else {
            siteKey = setting.Key__c;
        }
        return siteKey;
    }


    public static String getSiteDomain(){
        Site site = [SELECT Id FROM Site WHERE Subdomain = 'aacr' LIMIT 1];

        String communityUrl = [SELECT SecureURL FROM SiteDetail WHERE DurableId =: site.Id].SecureUrl;

        System.debug('Community url: ' + communityUrl);

        return communityUrl;
    }

//    @AuraEnabled
//    public static String verifyResponse(SObject record, String recaptchaResponse){
//        //https://developers.google.com/recaptcha/docs/verify
//        Http http = new Http();
//        HttpRequest request = new HttpRequest();
//        request.setEndpoint('https://www.google.com/recaptcha/api/siteverify');
//        request.setMethod('POST');
//        request.setBody('secret=' + recaptchaSecretKey + '&response=' + recaptchaResponse);
//        HttpResponse response = http.send(request);
//
//        if (response.getStatusCode() == 200) {
//            System.debug(response.getBody());
//            Map<String, Object> result = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
//
//            if (result.containsKey('success') && result.get('success') == true) {
//                if (result.containsKey('score')) {
//                    //score logic is only needed/returned for v3 (0.0 - 1.0)
//                    //https://developers.google.com/recaptcha/docs/v3
//                    //TODO: verify action name for the request
//                    String action = (String)result.get('action');
//                    //TODO: get threshold configuration for each action
//                    Decimal threshold = .4;
//                    Decimal score = (Decimal)result.get('score');
//                    if (score > threshold) {
//                        //TODO: perform action on record
//
//                        return 'Success - v3';
//                    }
//                } else {
//                    //TODO: perform action on record
//
//                    return 'Success - v2';
//                }
//            } else {
//                return 'Invalid Verification';
//            }
//        }
//        //consider letting this through
//        return 'Invalid Verification Request';
//    }

}