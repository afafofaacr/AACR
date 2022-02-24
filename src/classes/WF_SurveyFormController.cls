/**
 * Created by afaf.awad on 11/5/2021.
 */

public without sharing class WF_SurveyFormController {

    @AuraEnabled
    public static FormData getFormInfo(Id surveyId){
        Survey__c survey = [SELECT Id, Name, Form_Type__c, Additional_Confirmation_Text__c FROM Survey__c WHERE Id=: surveyId];

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
        fd.siteUrl = getSiteDomain();

        return fd;
    }

    @AuraEnabled
    public static String getSiteDomain(){
        Site site = [SELECT Id FROM Site WHERE Subdomain = 'aacr' LIMIT 1];

        String communityUrl = [SELECT SecureURL FROM SiteDetail WHERE DurableId =: site.Id].SecureUrl;

        System.debug('Community url: ' + communityUrl);

        return communityUrl;
    }
    @AuraEnabled
    public static String getSurveyFormImage(Id recordId, String imageId) {
        String imageUrl;
        ContentVersion cv = [select id, ContentDocumentId, Title from contentversion where Id = :imageId];
        System.debug('cv == ' + cv);
        List<ContentDocumentLink> chatterFiles = [
                SELECT ContentDocument.LatestPublishedVersionId
                FROM ContentDocumentLink
                WHERE ContentDocumentId = :cv.ContentDocumentId
        ];

            System.debug('chatterFiles == ' + chatterFiles);
        if (chatterFiles.size() > 0) {
            List<ContentDistribution> distributions = [Select Id, ContentDocumentId, ContentDownloadUrl, ContentVersion.Title from ContentDistribution WHERE ContentVersionId =: chatterFiles[0].ContentDocument.LatestPublishedVersionId ];

            if(distributions.size()>0){
                imageUrl = distributions[0].ContentDownloadUrl;
            }
        }

        System.debug('imageUrl == ' + imageUrl);

        return imageUrl;
    }

    @AuraEnabled
    public static void saveFormResponses(String surveyId, String inputListJSON){
        system.debug('saving form responses');
        //Parse JSON
        System.debug('fieldListJSON == ' + inputListJSON.replace('__c',''));
        List<SurveyFormParse> jsonParse = (List<SurveyFormParse>) System.JSON.deserialize(inputListJSON.replace('__c',''), List<SurveyFormParse>.class);

        SurveyTaker__c taker = createSurveyTaker(jsonParse, surveyId);
        List<SurveyQuestionResponse__c> qResponses = new List<SurveyQuestionResponse__c>();
        for(SurveyFormParse sfp : jsonParse) {
            SurveyQuestionResponse__c response = new SurveyQuestionResponse__c();
            response.SurveyTaker__c = taker.Id;
            response.Survey__c = surveyId;
            response.Survey_Question__c = sfp.Id;
            response.Response__c = sfp.input;
            qResponses.add(response);
        }

        insert qResponses;
    }

    public static Map<Id,Id> findContact(String email){
        List<Contact> contact = [SELECT Id FROM Contact WHERE Email =: email OR OrderApi__Personal_Email__c =: email OR OrderApi__Work_Email__c =: email];
        Map<Id, Id> conUserMap = new Map<Id, Id>();
        if(contact.size() == 1){
            List<User> user = [SELECT Id FROM User WHERE ContactId =: contact[0].Id];
            conUserMap.put(contact[0].Id, !user.isEmpty() ? user[0].Id : null);
        }
        System.debug('contact == ' + conUserMap);
        return conUserMap;
    }

    public static Lead upsertSurveyLead(List<SurveyFormParse> surveyFormParse, String leadId){
        Map<String, String> sfpMap = createMapOfMetaFields(surveyFormParse);
        Lead lead = new Lead();
        if(String.isNotBlank(leadId)){
            lead.Id = leadId;
        }
        lead.Email = sfpMap.get('Email');
        lead.FirstName = sfpMap.containsKey('FirstName') == null ? sfpMap.get('FirstName') : 'Not Provided' ;
        lead.LastName = sfpMap.containsKey('LastName') == null  ? sfpMap.get('LastName') : 'Not Provided';
        lead.Company = sfpMap.containsKey('Organization') == null ? sfpMap.get('Organization') : 'Not Provided';
        lead.Status = 'Open - Not Contacted';

        System.debug('Upsert Lead == ' + lead);
        upsert lead;
        return lead;
    }

    public static Map<String,String> createMapOfMetaFields(List<SurveyFormParse> surveyFormParse){
        Map<String,String> formResponseMap = new Map<String, String>();
        Map<String, String> formFieldsMap = new Map<String,String>();
        //Map formFields from Metadata to get the ID and API Name
        List<Form_Field__mdt> formFields = [SELECT Id, API_Name__c FROM Form_Field__mdt];
        for(Form_Field__mdt ff : formFields){
            formFieldsMap.put(ff.Id, ff.API_Name__c);
        }
        //Map responses to get MetadataId and response
        Map<String, String> sfpMap = new Map<String, String>();
        for(SurveyFormParse sfp : surveyFormParse){
            sfpMap.put(sfp.MetaTypeId, sfp.input);
        }
        //Final map get APIName from MAP1 and response from MAP2
        for(Id metaId : sfpMap.keySet()){
            formResponseMap.put(formFieldsMap.get(metaId), sfpMap.get(metaId));
        }
        System.debug('FormResponseMap == ' + formResponseMap);
        return formResponseMap;

    }

    public static SurveyTaker__c createSurveyTaker(List<SurveyFormParse> surveyFormParse, String surveyId){
        SurveyTaker__c taker = new SurveyTaker__c();
        for(SurveyFormParse sfp : surveyFormParse){
            if(sfp.Label == 'Email'){
                System.debug('email == ' + sfp.input);
                Map<Id,Id> conUserMap = findContact(sfp.input);
                if(conUserMap.size() == 1){
                    for(Id key : conUserMap.keySet()) {
                        taker.Contact__c = key;
                        taker.User__c = conUserMap.get(key);
                    }
                }else{
                    List<Lead> leads = [SELECT Id FROM Lead WHERE Email =: sfp.input ORDER BY CreatedDate];
                    String leadId = leads.isEmpty() ? '' : leads[0].Id;
                    taker.Lead__c = upsertSurveyLead(surveyFormParse, leadId).Id;
                }
                taker.Survey__c = surveyId;
                taker.Completed__c = true;
            }
        }

        insert taker;
        return taker;
    }


    public class FormData{
        @AuraEnabled
        public Survey__c survey;
        @AuraEnabled
        public List<Survey_Question__c> bodyFields;
        @AuraEnabled
        public String siteUrl;

    }

    public class SurveyFormParse{
        public String Id;
        public String Label;
        public String Input;
        public String MetaTypeId;
    }


}