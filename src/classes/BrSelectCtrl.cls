/**
 * Created by lovandos on 2019-03-27.
 */

public with sharing class BrSelectCtrl {

    @AuraEnabled
    public static List<Map<String,String>> getPicklistOptions(String picklistField) {
        List<Map<String,String>> options = new List<Map<String,String>>();

        Schema.DescribeSObjectResult dsr = Contact.SObjectType.getDescribe();

        Map<String, Schema.SObjectField> field_map = dsr.fields.getMap();
        List<Schema.PicklistEntry> ple = field_map.get(picklistField).getDescribe().getPicklistValues();

        for(Schema.PicklistEntry f : ple) {
            Map<String,String> optionMap = new Map<String,String>();
            optionMap.put('name', f.getValue());
            optionMap.put('label', f.getLabel());
            options.add(optionMap);
        }

        return options;
    }
}