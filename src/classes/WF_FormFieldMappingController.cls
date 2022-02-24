/**
 * Created by afaf.awad on 10/20/2021.
 */

public with sharing class WF_FormFieldMappingController {

    @AuraEnabled
    public static List<FieldMappingInfo> getSurveyQuestionInfo(String surveyId){

        //query sq records from survey id
        List<Survey_Question__c> sqRecords = [SELECT Id, Label__c, MetaTypeId__c, Survey__r.Form_Type__c, Overwrite__c
                                                FROM Survey_Question__c
                                                WHERE Field_Category__c = 'Body'
                                                AND Survey__c =: surveyId
                                                ORDER BY OrderNumber__c];
        List<String> metaTypeIds = new List<String>();
        for(Survey_Question__c sq: sqRecords){
            metaTypeIds.add(sq.MetaTypeId__c);
        }

        //query metadata from list of sq records
        Map<Id, Form_Field__mdt> formFields = new Map<Id, Form_Field__mdt>([SELECT Id, Label, API_Name__c, Field_Category__c From Form_Field__mdt WHERE Id IN: metaTypeIds]);

        List<FieldMappingInfo> fieldMappingList = new List<FieldMappingInfo>();
        for(Survey_Question__c sq: sqRecords){
            FieldMappingInfo fmi = new FieldMappingInfo();
            fmi.sqRecord = sq;
            fmi.formField = formFields.get(sq.MetaTypeId__c);
            fieldMappingList.add(fmi);
        }

        return fieldMappingList;

    }

    @AuraEnabled
    public static void saveFieldMapping(String sqRecordsJSON){
        List<SurveyQuestionMapping> jsonParse = (List<SurveyQuestionMapping>) System.JSON.deserialize(sqRecordsJSON, List<SurveyQuestionMapping>.class);
        List<Survey_Question__c> surveyQuestions = new List<Survey_Question__c>();
        for(SurveyQuestionMapping sqObj : jsonParse){
            System.debug('object == ' + sqObj);
            Survey_Question__c sq = new Survey_Question__c();
            sq.Id = sqObj.Id;
            sq.Overwrite__c = Boolean.valueOf(sqObj.Overwrite);
            surveyQuestions.add(sq);
        }
        update surveyQuestions;
    }

    public class FieldMappingInfo{
        @AuraEnabled
        public Survey_Question__c sqRecord;
        @AuraEnabled
        public Form_Field__mdt formField;
    }

    public class SurveyQuestionMapping {
        public String Id;
        public String Overwrite;
    }

}