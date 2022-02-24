/**
 * Created by lauren.lezberg on 6/29/2020.
 */

public with sharing class SegmentFieldSelectorController {

    @AuraEnabled
    public static List<List<UserSegmentHelper.FieldValuePair>> getFields(String objectName){
        List<List<UserSegmentHelper.FieldValuePair>> toReturn = new List<List<UserSegmentHelper.FieldValuePair>>();

        //selected fields
        Map<String, UserSegmentHelper.FieldValuePair> selectedMap = new Map<String, UserSegmentHelper.FieldValuePair>();
        List<UserSegmentHelper.FieldValuePair> selectedFields = new List<UserSegmentHelper.FieldValuePair>();
        for(User_Segment_Fields__mdt f: [SELECT Id, MasterLabel, API_Name__c, Object_Type__c FROM User_Segment_Fields__mdt WHERE Object_Type__c = :objectName]){
            UserSegmentHelper.FieldValuePair fvp = new UserSegmentHelper.FieldValuePair();
            fvp.fieldLabel = f.MasterLabel;
            fvp.fieldName = f.API_Name__c;
            selectedMap.put(f.API_Name__c, fvp);
        }


        List<UserSegmentHelper.FieldValuePair> availableFields = new List<UserSegmentHelper.FieldValuePair>();

        Map <String, Schema.SObjectField> fieldMap = Schema.getGlobalDescribe().get(objectName).getDescribe().fields.getMap();
            for(Schema.SObjectField sfield : fieldMap.Values()) {
            schema.describefieldresult dfield = sfield.getDescribe();
            if(!selectedMap.keySet().contains(dfield.getName()) && dfield.getType()!=Schema.DisplayType.REFERENCE){
                UserSegmentHelper.FieldValuePair fvp = new UserSegmentHelper.FieldValuePair();
                fvp.fieldLabel = dfield.getLabel();
                fvp.fieldName = dfield.getName();
                availableFields.add(fvp);
            }
        }



        System.debug('selectedFields: ' + selectedMap.values());
        SYstem.debug('availableFields: ' + availableFields);
        toReturn.add(availableFields);
        toReturn.add(selectedMap.values());

        return toReturn;
    }


    @AuraEnabled
    public static void saveSegmentFields(String objectName, String selectedJSON) {
        System.debug('selectedJSON: ' + selectedJSON);
        List<UserSegmentHelper.FieldValuePair> selectedList = (List<UserSegmentHelper.FieldValuePair>) JSON.deserialize(selectedJSON, List<UserSegmentHelper.FieldValuePair>.class);

        //TODO: create new metadata records
        AACRAdminUtils.createSegmentFields(selectedList, objectName);
    }

}