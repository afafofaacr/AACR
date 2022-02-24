/**
 * Created by lauren.lezberg on 4/1/2020.
 */

public without sharing class UserSegmentHelper {
    public static final Set<String> validTypes = new Set<String>{'STRING', 'DATE', 'DATETIME', 'PHONE', 'EMAIL', 'URL', 'INTEGER', 'DOUBLE', 'BOOLEAN', 'PICKLIST'};
    public static List<User_Segment_Fields__mdt> segFields = new List<User_Segment_Fields__mdt>();
    /**
     * @purpose Get all available segment fields for specified object
     * @param sObjectName
     *
     * @return List of available field value pairs
     */
    public static List<FieldValuePair> getAvailableSegmentFields(String sObjectName){
        List<FieldValuePair> fields = new List<FieldValuePair>();
        SObjectType accountType = Schema.getGlobalDescribe().get(sObjectName);
        Map<String,Schema.SObjectField> mfields = accountType.getDescribe().fields.getMap();
        List<User_Segment_Fields__mdt> segmentFields = [SELECT API_Name__c FROM User_Segment_Fields__mdt WHERE Object_Type__c=:sObjectName];
        if(Test.isRunningTest()){
            segmentFields = segFields;
        }
        for(User_Segment_Fields__mdt f: segmentFields){
            if(validTypes.contains(String.valueOf(mfields.get(f.API_Name__c).getDescribe().getType()))) {
                fields.add(new FieldValuePair(mFields.get(f.API_Name__c).getDescribe()));
            }
        }
        System.debug('fields: ' + fields);
        return fields;
    }

    /**
     * @purpose Parse user segment query to get individual specified object fields
     * @param queryString
     * @param objName
     *
     * @return Map of fields
     */
    public static Map<String,FieldValuePair> parseSegmentQuery(String queryString, String objName){
        Integer conStart = queryString.indexOf('(');
        Integer conEnd = queryString.indexOf(')');

        String conQuery = queryString.substring(conStart + 1, conEnd);
        String whereQuery = conQuery.substringAfter('WHERE');

        List<String> statements = whereQuery.split('AND');
        Map<String, FieldValuePair> fieldValueMap = new Map<String, FieldValuePair>();

        for(String s : statements){
            FieldValuePair fvp = new FieldValuePair();
            String fieldName, fieldValue = '';
            if(s.contains('>')){
                if(s.contains('>=')){
                    fvp.operator = '>=';
                    fieldName = s.split('>=')[0].trim();
                    fieldValue = s.split('>=')[1].remove('\'').trim();
                } else{
                    fvp.operator = '>';
                    fieldName = s.split('>')[0].trim();
                    fieldValue = s.split('>')[1].remove('\'').trim();
                }
            } else if(s.contains('<')){
                if(s.contains('<=')){
                    fvp.operator = '<=';
                    fieldName = s.split('<=')[0].trim();
                    fieldValue = s.split('<=')[1].remove('\'').trim();
                } else {
                    fvp.operator = '<';
                    fieldName = s.split('<')[0].trim();
                    fieldValue = s.split('<')[1].remove('\'').trim();
                }
            } else if(s.contains('=')){
                if(s.contains('!=')){
                    fvp.operator = '!=';
                    fieldName = s.split('!=')[0].trim();
                    fieldValue = s.split('!=')[1].remove('\'').trim();
                } else {
                    fvp.operator = '=';
                    fieldName = s.split('=')[0].trim();
                    fieldValue = s.split('=')[1].remove('\'').trim();
                }
            }
            fvp.fieldName = fieldName;
            fvp.fieldValue = fieldValue;

            if(objName=='Account'){
                if(fieldName.contains('.')){
                    fvp.fieldName = fieldName.substringAfter('.');
                    fieldValueMap.put(fieldName.substringAfter('.'),fvp);
                }
            } else {
                if(!fieldName.contains('.')) {
                    fieldValueMap.put(fieldName, fvp);
                }
            }

        }

        System.debug('returning fieldValueMap in userSegmentHelper: ' + fieldValueMap);

        return fieldValueMap;
    }


    /**
     * @purpose create user segment query from contact and account fields
     * @param contactJSON
     * @param accountJSON
     *
     * @return User segment query
     */
    public static String buildSegmentQueryString(String contactJSON, String accountJSON){
        System.debug('buildSegmentQueryString with contactJSON: ' + contactJSON + ' and accountJSON: ' + accountJSON);
        List<FieldValuePair> contactFields = (List<FieldValuePair>)JSON.deserialize(contactJSON, List<FieldValuePair>.class);
        List<FieldValuePair> accountFields = (List<FieldValuePair>)JSON.deserialize(accountJSON, List<FieldValuePair>.class);

        String querystring = 'SELECT Id FROM User WHERE IsActive = true';
        if(contactFields.size()>0) {
            querystring += ' AND ContactId IN (SELECT Id FROM Contact WHERE ';

            for (FieldValuePair fvp : contactFields) {
                queryString += fvp.fieldName + fvp.operator;
                if (fvp.fieldType == '' || fvp.fieldType == null || fvp.fieldType == 'email' || fvp.fieldType == 'tel' || fvp.fieldType == 'url') {
                    queryString += '\'' + fvp.fieldValue + +'\'';
                } else {
                    querystring += fvp.fieldValue;
                }

                if (fvp != contactFields[contactFields.size() - 1]) {
                    queryString += ' AND ';
                }
            }
        }


        if(accountFields.size()>0){
            for (FieldValuePair accfvp : accountFields) {
                System.debug('fieldName: ' + accfvp.fieldName);
                if(accfvp == accountFields[0]){
                    if(contactFields.size()==0){
                        querystring += ' AND ContactId IN (SELECT Id FROM Contact WHERE Account.' + accfvp.fieldName  + accfvp.operator;
                    } else {
                        querystring += ' AND Account.' + accfvp.fieldName  + accfvp.operator;

                    }
                }


                if (accfvp.fieldType == '' || accfvp.fieldType == null || accfvp.fieldType == 'email' || accfvp.fieldType == 'tel' || accfvp.fieldType == 'url') {
                    queryString += '\'' + accfvp.fieldValue + +'\'';
                } else {
                    querystring += accfvp.fieldValue;
                }
            }
        }


        queryString += ')';

        System.debug('queryString: ' + queryString);

        return queryString;
    }


    public class FieldValuePair{
        @AuraEnabled
        public String fieldLabel;

        @AuraEnabled
        public String fieldName;

        @AuraEnabled
        public String fieldType;

        @AuraEnabled
        public String fieldValue;

        @AuraEnabled
        public String operator;

        public FieldValuePair(){}

        public FieldValuePair(DescribeFieldResult f){
            this.fieldLabel = f.getLabel();
            this.fieldName = f.getName();
            this.fieldType = convertType(f.getType());
            this.fieldValue = null;
            this.operator = null;
        }

        private String convertType(Schema.DisplayType type){
            String displayType = String.valueOf(type);

            if(displayType.equalsIgnoreCase('Phone')){
                displayType = 'tel';
            } else if (displayType.equalsIgnoreCase('Double') || displayType.equalsIgnoreCase('Integer')){
                displayType = 'number';
            } else if (displayType.equalsIgnoreCase('String')|| displayType.equalsIgnoreCase('Picklist')){
                displayType = '';
            }

            return displayType.toLowerCase();
        }



    }

}