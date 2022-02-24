/**
 * Created by afaf.awad on 10/29/2021.
 */

public without sharing class WF_FormPreviewController {

    @AuraEnabled
    public static FormData getFormInfo(Id surveyId){
        Survey__c survey = [SELECT Id, Form_Type__c FROM Survey__c WHERE Id=: surveyId];

        List<Survey_Question__c> sqRecords = [SELECT Id, Label__c, MetaTypeId__c, ImageId__c, isRequired__c, Custom_Text__c, isBold__c,
                                                Question_Responses__c, Question_Type__c, Field_Category__c, Field_Type__c, Output_Field__c
                                                FROM Survey_Question__c WHERE Survey__c =: surveyId ORDER BY OrderNumber__c];

        List<Form_Field__mdt> formFields = [SELECT Id, Label, API_Name__c, Field_Category__c, Layout_Section__c, isLocked__c,
                isUnique__c, Field_Type__c, Default_Text__c, Output_Field__c
        From Form_Field__mdt];

        List<Survey_Question__c> bodyFields = new List<Survey_Question__c>();
        List<Survey_Question__c> footerFields = new List<Survey_Question__c>();
        List<Survey_Question__c> headerFields = new List<Survey_Question__c>();

        for(Survey_Question__c sq: sqRecords){
            switch on sq.Field_Category__c{
                when 'Body'{
                    bodyFields.add(sq);
                }
                when 'Header'{
                    headerFields.add(sq);
                }
                when 'Footer'{
                    footerFields.add(sq);
                }
            }
        }

        FormData fd = new FormData();
        fd.bodyFields = sqRecords;
        fd.survey = survey;

        return fd;

    }

    public static Map<Id,Survey_Question__c> getSurveyQuestionMapRecords(Id surveyId){

        Map<Id,Survey_Question__c> sqRecords = new Map<Id, Survey_Question__c>([SELECT Id, Label__c, MetaTypeId__c, ImageId__c, isRequired__c,
                Question_Responses__c, Question_Type__c
        FROM Survey_Question__c WHERE Survey__c =: surveyId]);

        return sqRecords;
    }

    @AuraEnabled
    public static String getPreviousStep(String stepId) {
        List<Process_Steps__mdt> currentStep = [
                SELECT Id, Step_Order__c, Step_Title__c, Description__c,
                        Join_Step__r.Component_Name__c, Join_Step__r.MasterLabel, Process__r.Is_Renewal__c, Process__c
                FROM Process_Steps__mdt
                WHERE Id = :stepId
                LIMIT 1
        ];

        Integer previousStep = currentStep[0].Step_Order__c.intValue() - 1;

        List<Process_Steps__mdt> newStep = [
                SELECT Id, Step_Order__c, Step_Title__c, Description__c, Join_Step__r.Component_Name__c,
                        Join_Step__r.MasterLabel, Process__r.Is_Renewal__c, Process__c
                FROM Process_Steps__mdt
                WHERE Step_Order__c = :previousStep and Process__r.DeveloperName = 'WebForm_Create'
                LIMIT 1
        ];

        return newStep[0].Id ;
    }

    @AuraEnabled
    public static String getSiteDomain(){
        Site site = [SELECT Id FROM Site WHERE Subdomain = 'aacr' LIMIT 1];

        String communityUrl = [SELECT SecureURL FROM SiteDetail WHERE DurableId =: site.Id].SecureUrl;

        System.debug('Community url: ' + communityUrl);

        return communityUrl;
    }


    @AuraEnabled
    public static String getForceSiteDomain() {

        List<Site> siteList = [
                SELECT GuestUserId, Name,MasterLabel, Subdomain,
                        OptionsRequireHttps, UrlPathPrefix
                FROM Site
                WHERE Status = 'Active' AND Name = 'AACR_Community'
                LIMIT 1];

        List<String> siteFullUrlList = new List<String>();
        Organization org = [SELECT InstanceName,Name, IsSandbox, OrganizationType FROM Organization];
        if ( siteList != null && siteList.size() != 0 ) {
            for (Site s : siteList) {
                if ( s.Subdomain != null ) {
//                    String httpStr = 'http://';
//                    if ( s.OptionsRequireHttps == true ) {
//                        httpStr = 'https://';
//                    }
                    String siteFullUrl='';
                    if(org.IsSandbox == true) {
                        siteFullUrl = UserInfo.getUserName().substringAfterLast('.')+'-';
                    }
                    siteFullUrl += s.Subdomain + '.';
                    siteFullUrl += (org.IsSandbox ? (org.InstanceName.toLowerCase() + '.') : '');
                    siteFullUrl += org.IsSandbox ? 'force.com' : 'secure.force.com';
                    if ( s.UrlPathPrefix != null ) {
                        siteFullUrl += '/' + s.UrlPathPrefix;
                    }
                    System.debug(siteFullUrl);
                    siteFullUrlList.add(siteFullUrl);
                }
            }

        }

        return siteFullUrlList[0];
    }

    /**
     * Returns site key for recaptcha
     *
     * @return Site key
     */
    @AuraEnabled
    public static String getSiteKey() {
        String siteKey = '';

        BrEvents_Settings__c setting = BrEvents_Settings__c.getValues('recaptcha_key');

        if ( setting != null ) {
            siteKey = setting.Value__c;

        }

        if ( Test.isRunningTest() ) {
            return '1234';
        } else {
            return siteKey;
        }
    }


    public class FormData{
        @AuraEnabled
        public Survey__c survey;
        @AuraEnabled
        public List<Survey_Question__c> bodyFields;
    }

}