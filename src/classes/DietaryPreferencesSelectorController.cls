/**
 * Created by lauren.lezberg on 12/10/2019.
 */

public with sharing class DietaryPreferencesSelectorController {

    /**
     * @purpose Get participation fields sets based on event Id
     *
     * @param eventId
     *
     * @return Map of field set and fields
     */
    @AuraEnabled
    public static Map<String,List<String>> getFieldSets(Id eventId){
        String sObjName = 'BR_Participation__c';
        SYstem.debug('sObjName: ' + sObjName);
//        Map<String, Schema.FieldSet> FsMap = Schema.getGlobalDescribe().get(sObjName).getDescribe().fieldSets.getMap();
        Map<String, Schema.FieldSet> FsMap = Schema.SObjectType.BR_Participation__c.fieldSets.getMap();
        Map<String, List<String>> fieldMap = new Map<String, List<String>>();
        for(String key : FsMap.keySet()){
            System.debug(key + ' ' + FsMap.get(key));
            List<String> fieldNames = new List<String>();
            for(Schema.FieldSetMember fsm : FsMap.get(key).getFields()){
                fieldNames.add(fsm.getLabel());
            }
            fieldMap.put(FsMap.get(key).getName(), fieldNames);
        }

//        BR_Event__c evt = [SELECT Id, Event_Preferences_Form_Fieldset__c FROM BR_Event__c WHERE Id=: eventId];

        return fieldMap;
    }

//    public class DietaryPreferenceInfo{

//        @AuraEnabled
//        public String selectedFieldset;

//        @AuraEnabled
//        public Map<String,List<String>> fieldSetMap;
//
//        public DietaryPreferenceInfo(Map<String,List<String>> fieldSetMap){
//            this.selectedFieldset = selectedFieldset;
//            this.fieldSetMap = fieldSetMap;
//        }
//    }
}