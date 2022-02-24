/**
 * Created by lauren.lezberg on 4/1/2020.
 */

public with sharing class ObjectFieldSelectorController {

    @AuraEnabled
    public static List<List<UserSegmentHelper.FieldValuePair>> getFields(String objectName, String segmentId){
        System.debug('getFields: ' + objectName + ' segmentId: ' + segmentId);
        List<List<UserSegmentHelper.FieldValuePair>> toReturn = new List<List<UserSegmentHelper.FieldValuePair>>();

        List<UserSegmentHelper.FieldValuePair> selectedFields = new List<UserSegmentHelper.FieldValuePair>();
        List<UserSegmentHelper.FieldValuePair> allAvailableFields = UserSegmentHelper.getAvailableSegmentFields(objectName);

        List<UserSegmentHelper.FieldValuePair> availableFields = new List<UserSegmentHelper.FieldValuePair>();

        System.debug('availableFields: ' + allAvailableFields);
        if(segmentId!=null){
            AC_User_Segment__c segment = [SELECT Query__c FROM AC_User_Segment__c WHERE Id=:segmentId];
            Map<String, UserSegmentHelper.FieldValuePair> fieldValueMap = UserSegmentHelper.parseSegmentQuery(segment.Query__c, objectName);
            System.debug('fieldValueMap: ' + fieldValueMap);
            Set<String> mapKeyset = fieldValueMap.keySet();
            System.debug('keyset: ' + mapKeyset);


            for(Integer i = 0;i<allAvailableFields.size();i++){
                if(mapKeyset.contains(allAvailableFields[i].fieldName)){
                    //add to selected
                    UserSegmentHelper.FieldValuePair selectedField = fieldValueMap.get(allAvailableFields[i].fieldName);
                    selectedField.fieldType = allAvailableFields[i].fieldType;
                    selectedField.fieldLabel = allAvailableFields[i].fieldLabel;
                    selectedFields.add(selectedField);

                } else {
                    availableFields.add(allAvailableFields[i]);
                }
            }

        } else {
            availableFields.addAll(allAvailableFields);
        }

        System.debug('selectedFields: ' + selectedFields);
        SYstem.debug('availableFields: ' + availableFields);
        toReturn.add(availableFields);
        toReturn.add(selectedFields);

        return toReturn;
    }

//    @AuraEnabled
//    public static List<UserSegmentHelper.FieldValuePair> getFields(String objectName){
////        return UserSegmentHelper.getObjectFields(objectName);
//        return UserSegmentHelper.getAvailableSegmentFields(objectName);
//    }


}