/**
 * Created by lauren.lezberg on 1/2/2020.
 */

public with sharing class FS_SelectorController {


    /**
     * @purpose Get field sets for specific object
     *
     * @param sObjName
     *
     * @return Map of field set name and field set label
     */
    @AuraEnabled
    public static Map<String,String> getFieldSets(String sObjName){
        System.debug('---sObjName: ' + sObjName);
        Map<String, Schema.FieldSet> FsMap = Schema.getGlobalDescribe().get(sObjName).getDescribe().fieldSets.getMap();
        Map<String, String> fieldSetMap = new Map<String, String>();
        for(String key : FsMap.keySet()){
            fieldSetMap.put(FsMap.get(key).getLabel(),FsMap.get(key).getName());
        }

        return fieldSetMap;
    }


    /**
     * @purpose Retrieve fields in particular field set
     *
     * @param sObjName
     * @param fieldsetName
     *
     * @return List of field names
     */
    @AuraEnabled
    public static List<String> getFieldsInFieldset(String sObjName, String fieldsetName){
        System.debug('---sObjName:fieldsetName ' + sObjName +':'+ fieldsetName);
        List<String> fields = new List<String>();
        Map<String, Schema.FieldSet> FsMap = Schema.getGlobalDescribe().get(sObjName).getDescribe().fieldSets.getMap();
        System.debug('---FsMap ' + FsMap);

        for(String key : FsMap.keySet()){
            if(key == fieldsetName) {
                for (Schema.FieldSetMember fsm : FsMap.get(key).getFields()) {
        System.debug('---fields.add: ' + fsm.getLabel());
                    fields.add(fsm.getLabel());
                }
            }
        }

        return fields;
    }
}