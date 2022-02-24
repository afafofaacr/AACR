/**
 * Created by lauren.lezberg on 3/29/2021.
 */

public with sharing class VerifyORCIDController {
    public static String redirectURL {get;set;}
    public static Boolean hasError {get;set;}
    public static String msg {get;set;}


    @AuraEnabled
    public static Boolean checkORCID(){
        User u =[SELECT Id, ORCID__c FROM User WHERE Id=:UserInfo.getUserId()];
        if(u.ORCID__c!=null){
            return true;
        }

        return false;
    }

    @AuraEnabled
    public static String getVerifyURL(String redirectURI){
        return ORCIDHelper.getORCIDAuthURL(redirectURI);
    }

    public static PageReference goBack(){
        return new PageReference('/MemberProfile');
    }

    public static PageReference verify(){

        String code = ApexPages.currentPage().getParameters().get('code');
        System.debug('code: ' + code);

        if(code!=null) {
            String retURL;
            if (redirectURL == null) {
                retURL = ApexPages.currentPage().getParameters().get('ret_URL');
                System.debug('retURL: ' + retURL);
                Blob retBlob = EncodingUtil.base64Decode(retURL);
                string s = retBlob.tostring();
                retURL = EncodingUtil.base64Decode(EncodingUtil.base64Encode(retBlob)).toString();
                System.debug('retURL: ' + retURL);
            } else {
                retURL = redirectURL;
            }

            if (code != null) {
                Boolean success = ORCIDHelper.verifyORCID(code, retURL);
                if (success) {
                    msg = 'ORCID has been linked successfully. You may close this window at any time.';
//                    return new PageReference(retURL);
                } else {
                    hasError = true;
                    msg = 'Could not verify ORCID. You may try again or close this window at any time.';
                }
            } else {
                hasError = true;
                msg = 'ORCID was not verified. You may try again or close this window at any time.';
            }
        } else { //initial hit of page to authenticate
            User u = [SELECT ORCID__c FROM User WHERE Id=:UserInfo.getUserId() LIMIT 1];
            if(u.ORCID__c==null){
                String redirectURI = Page.VerifyORCID.getUrl();
                return new PageReference(ORCIDHelper.getORCIDAuthURL(redirectURI));
            } else {
                msg = 'Your ORCID has already been linked. You may close this window.';
            }
        }

        return null;
    }

}