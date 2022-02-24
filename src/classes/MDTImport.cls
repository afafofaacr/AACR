/**
 * Created by afaf.awad on 11/4/2020.
 */

public with sharing class MDTImport {

    public static void insertMetadata(String metaDataTypeName, String jsonString){

        try {
            Integer count = 1;
            Metadata.DeployContainer mdContainer = new Metadata.DeployContainer();
            JSONCsvTemplate csv = (JSONCsvTemplate)JSON.deserialize(jsonStringMdt(jsonString), JSONCsvTemplate.class);
            for(mdtRecords item : csv.data.mdtRecordsList){
                //Sets the custom metadata type you'll insert your records on
                //If you're using namespaces on your org set it here
                String nameSpacePrefix ='';
                Metadata.CustomMetadata rec =  new Metadata.CustomMetadata();
                rec.label = item.country;
                rec.fullName = metaDataTypeName.replace('__mdt','')+'.'+item.country.replace(' ','_').replace('(','').replace(')','').replace('-','');
                //Sets the custom metadata custom fields to be inserted

                /*
                * Use the template below to setup any fields you want to:
                *
                Metadata.CustomMetadataValue fieldX = new Metadata.CustomMetadataValue();     //New instance
                fieldX.field = 'Custom_Field_Name__c'; //Custom Metadata Field you want to fill
                field1.value = item.JSON_Matching_Key_Value; //The matching key value on the wrapper
                rec.values.add(fieldX); //adds the value and the matching field
                *
                */

                Metadata.CustomMetadataValue field1 = new Metadata.CustomMetadataValue();
                field1.field = 'Region__c';
                field1.value = item.region;
                rec.values.add(field1);
                Metadata.CustomMetadataValue field2 = new Metadata.CustomMetadataValue();
                field2.field = 'Country_Code__c';
                field2.value = item.countryCode;
                rec.values.add(field2);
                Metadata.CustomMetadataValue field3 = new Metadata.CustomMetadataValue();
                field3.field = 'Income_Level__c';
                field3.value = item.incomeLevel;
                rec.values.add(field3);
                Metadata.CustomMetadataValue field4 = new Metadata.CustomMetadataValue();
                field4.field = 'Abbreviation__c';
                field4.value = item.abbreviation;
                rec.values.add(field4);
                Metadata.CustomMetadataValue field5 = new Metadata.CustomMetadataValue();
                field5.field = 'WB_Country__c';
                field5.value = item.wbCountry;
                rec.values.add(field5);

                mdContainer.addMetadata(rec);
                count++;
            }
            Id jobId = Metadata.Operations.enqueueDeployment(mdContainer, null);
            system.debug('Container>>'+mdContainer);
            system.debug('Id>>'+jobId);
            return;
        }
        catch(Exception ex){
            system.debug('Error on insert');
            system.debug('Error:'+ex.getMessage());
        }
    }

    private static String jsonStringMdt(String jsonString){
        String resultJson = '{"data":{"mdtRecordsList":'+jsonString+'}}';
        return resultJson;
    }

    private class JSONCsvTemplate{

        private Data data;
    }

    private class Data{
        private List<mdtRecords> mdtRecordsList;
    }

    private class mdtRecords{
        private String country;
        private String wbCountry;
        private String countryCode;
        private String incomeLevel;
        private String region;
        private String abbreviation;
    }

}