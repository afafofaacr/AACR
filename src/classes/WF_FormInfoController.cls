/**
 * Created by afaf.awad on 9/28/2021.
 */

public without sharing class WF_FormInfoController {

    @AuraEnabled
    public static void getSurveyInfo(Id surveyId, Id stepId){
        JP_Helper.upsertLastAccessedStep(stepId);
    }

    @AuraEnabled
    public static void createSystemTag(String tagName, String surveyId){

    }

    @AuraEnabled
    public static void createEmbeddedCode(Id surveyId){

        Site site = [SELECT Id FROM Site WHERE Subdomain = 'aacr' LIMIT 1];
        String communityUrl = [SELECT SecureURL FROM SiteDetail WHERE DurableId =: site.Id].SecureUrl;
        System.debug('Community url: ' + communityUrl);

       String url = communityUrl + 'WF_Survey?c__survey=' + surveyId;

        String iframe = '<iframe src="' + url + '" frameborder="0"/>';

        Survey__c survey = new Survey__c(Id = surveyId, Embed_Code__c = iframe);

        update survey;
    }

}