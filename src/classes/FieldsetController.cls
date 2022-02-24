/**
 * Created by lauren.lezberg on 6/23/2020.
 */

public without sharing class FieldsetController {
 
    @AuraEnabled
    public static Map<String, String> getStateList(String countryVal){

        return ECRMUtils.getDependentPicklistValues('Contact', 'MailingCountryCode', 'MailingStateCode', countryVal);
    }

    @AuraEnabled
    public static FieldsetInfo getFieldsInFieldset(String objectAPIName, String fieldsetName){
        Map<String, Schema.SObjectType> GlobalDescribeMap = Schema.getGlobalDescribe();
        Schema.SObjectType SObjectTypeObj = GlobalDescribeMap.get(objectAPIName);
        Schema.DescribeSObjectResult DescribeSObjectResultObj = SObjectTypeObj.getDescribe();

        //system.debug('====>' + DescribeSObjectResultObj.FieldSets.getMap().get(fieldSetName));

        Schema.FieldSet fieldSetObj = DescribeSObjectResultObj.FieldSets.getMap().get(fieldSetName);

        List<Schema.FieldSetMember> fieldSetMemberList =  fieldSetObj.getFields();
        system.debug('fieldSetMemberList ====>' + fieldSetMemberList);

        List<String> fields = new List<String>();
        for(Schema.FieldSetMember fieldSetMemberObj : fieldSetMemberList) {
            fields.add(fieldSetMemberObj.getFieldPath());
        }

        return new FieldsetInfo(fields);
    }

    public class FieldsetInfo{
        @AuraEnabled
        public Map<String, String> countryList;

        @AuraEnabled
        public List<String> fields;

        public FieldsetInfo(List<String> fieldsetFields){
            this.countryList = ECRMUtils.getCountryPicklistValues();
            this.fields = fieldsetFields;
        }
    }

}