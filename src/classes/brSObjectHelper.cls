/**
 * Created by mitfity on 23.07.2019.
 */

public with sharing class brSObjectHelper {

    /**
     * Retrieves field set options for specified SObjectType.
     *
     * @param objectType
     *
     * @return
     */
    public static List<Map<String, String>> getFieldSetOptions(SObjectType objectType) {
        List<Map<String, String>> options = new List<Map<String, String>>();

//        if (Test.isRunningTest()) {
//            return options;
//        }

        Map<String, FieldSet> fieldSetMap = objectType.getDescribe().fieldSets.getMap();

        for (String fieldSetName : fieldSetMap.keySet()) {
            FieldSet currentFieldSet = fieldSetMap.get(fieldSetName);
            Map<String, String> option = new Map<String, String>();

            option.put('value', currentFieldSet.getName());
            option.put('label', currentFieldSet.getLabel());
            options.add(option);
        }

        return options;
    }
}