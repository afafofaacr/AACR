/**
 * Created by afaf.awad on 10/19/2021.
 */

public with sharing class WF_FormFieldsContainerController {

    @AuraEnabled
    public static FormFieldData getFormFieldInfo(Id surveyId, Id stepId){
        JP_Helper.upsertLastAccessedStep(stepId);

        Survey__c survey = [SELECT Id, Form_Type__c FROM Survey__c WHERE Id=: surveyId];
        List<Form_Field__mdt> formFields = [SELECT Id, Label, API_Name__c, Field_Category__c, Layout_Section__c, isLocked__c,
                isUnique__c, Field_Type__c, Default_Text__c, Output_Field__c, Default_Order__c, Default_Bold__c, DragNotAllowed__c
        From Form_Field__mdt ORDER BY Default_Order__c];

        List<Form_Field__mdt> piFields = new List<Form_Field__mdt>();
        List<Form_Field__mdt> sciFields = new List<Form_Field__mdt>();
        List<Form_Field__mdt> customFields = new List<Form_Field__mdt>();
        List<Form_Field__mdt> footerFields = new List<Form_Field__mdt>();
        List<Form_Field__mdt> headerFields = new List<Form_Field__mdt>();

        for(Form_Field__mdt ff: formFields){
            switch on ff.Layout_Section__c{
                when 'PerInfo'{
                    piFields.add(ff);
                }
                when 'SciInt'{
                    sciFields.add(ff);
                }
                when 'Custom'{
                    customFields.add(ff);
                }
                when 'Header'{
                    headerFields.add(ff);
                }
                when 'Footer'{
                    footerFields.add(ff);
                }
            }
        }

        FormFieldData ffd = new FormFieldData();
        ffd.piFields = piFields;
        ffd.sciFields = sciFields;
        ffd.customFields = customFields;
        ffd.headerFields = headerFields;
        ffd.footerFields = footerFields;
        ffd.survey = survey;
        ffd.sqMetadataMap = buildSQAndMetadataMap(survey.Id, formFields);
        ffd.sqRecordsMap = getSurveyQuestionMapRecords(survey.Id);

        return ffd;

    }

    public static Map<Id,Form_Field__mdt> buildSQAndMetadataMap(Id surveyId, List<Form_Field__mdt> formFields){

        List<Survey_Question__c> surveyQuestions = [SELECT Id, MetaTypeId__c FROM Survey_Question__c WHERE Survey__c =: surveyId];
        Map<Id,Form_Field__mdt> sqMap = new Map<Id, Form_Field__mdt>();
        if(!surveyQuestions.isEmpty()) {
            for (Survey_Question__c sq : surveyQuestions) {
                System.debug('sq== ' + sq);
                for (Form_Field__mdt ff : formFields) {
                    if (sq.MetaTypeId__c == ff.Id) {
                        sqMap.put(sq.Id, ff);
                    }
                }
            }
        }

        return sqMap;

    }

    public static Map<Id,Survey_Question__c> getSurveyQuestionMapRecords(Id surveyId){

        Map<Id,Survey_Question__c> sqRecords = new Map<Id, Survey_Question__c>([SELECT Id, Label__c, MetaTypeId__c, ImageId__c, isRequired__c, isBold__c, OrderNumber__c,
                                                                                        Question_Responses__c, Question_Type__c, Field_Type__c, Output_Field__c
                                                                                FROM Survey_Question__c WHERE Survey__c =: surveyId
                                                                                ORDER BY OrderNumber__c]);

        return sqRecords;
    }


    @AuraEnabled
    public static void saveSurveyQuestions(String fieldListJSON, String surveyId){
        System.debug('fieldListJSON == ' + fieldListJSON.replace('__c',''));
        List<SurveyQuestionParse> jsonParse = (List<SurveyQuestionParse>) System.JSON.deserialize(fieldListJSON.replace('__c',''), List<SurveyQuestionParse>.class);
        List<Survey_Question__c> surveyQuestions = new List<Survey_Question__c>();
        for(SurveyQuestionParse sqObj : jsonParse){
            Survey_Question__c sq = new Survey_Question__c();
            System.debug('object == ' + sqObj);
            if(String.isNotBlank(sqObj.sqId)) {
                sq.Id = sqObj.sqId;
            }else{
                System.debug('Default Text = ' + sqObj.Default_Text);
                System.debug('Field_type = ' + sqObj.Field_Type);
                System.debug('Field-Category = ' + sqObj.Field_Category);
                System.debug('Label = ' + sqObj.Label);
                sq.Label__c = String.isBlank(sqObj.Default_Text) ?  sqObj.Label : sqObj.Default_Text;
                sq.MetaTypeId__c = sqObj.Id;
                sq.Survey__c = surveyId;
                sq.Field_Type__c = sqObj.Field_Type;
                sq.Field_Category__c = sqObj.Field_Category;
                sq.Output_Field__c = sqObj.Output_Field;
            }
            sq.OrderNumber__c = Integer.valueOf(sqObj.orderNumber);
            surveyQuestions.add(sq);
        }

        upsert surveyQuestions;

    }

    public class FormFieldData{
        @AuraEnabled
        public Survey__c survey;
        @AuraEnabled
        public List<Form_Field__mdt> piFields;
        @AuraEnabled
        public List<Form_Field__mdt> sciFields;
        @AuraEnabled
        public List<Form_Field__mdt> customFields;
        @AuraEnabled
        public List<Form_Field__mdt> footerFields;
        @AuraEnabled
        public List<Form_Field__mdt> headerFields;
        @AuraEnabled
        public Map<Id,Form_Field__mdt> sqMetadataMap;
        @AuraEnabled
        public Map<Id,Survey_Question__c> sqRecordsMap;
    }


    public class SurveyQuestionParse {

        public String Id;
        public String Label;
        public String API_Name;
        public String Field_Category;
        public String Layout_Section;
        public Boolean isLocked;
        public Boolean isUnique;
        public String Field_Type;
        public Boolean Output_Field;
        public String dragId;
        public String orderNumber;
        public String sqId;
        public String Default_Text;

    }

}