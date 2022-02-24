/**
 * Created by afaf.awad on 5/25/2021.
 */

public without sharing class MDTHelper{

//    public static String createMetadata(String metaDataTypeName, String label, Map<String, String> fieldDataMap){
//
//        try {
////            //Create CustomMeta record
//                Metadata.CustomMetadata customMetadata =  new Metadata.CustomMetadata();
//                customMetadata.label = label;
//                customMetadata.fullName = metaDataTypeName.replace('__mdt','')+'.'+label.replace(' ', '_');
////                //Create Custom Fields for record
//            for(String item : fieldDataMap.keySet()) {
//                Metadata.CustomMetadataValue field = new Metadata.CustomMetadataValue();
//                field.field = item;
//                field.value = fieldDataMap.get(item);
//                customMetadata.values.add(field); //add custom fields to CustomMeta record
//            }
//////          Add new CustomMeta record to deployment container
//            Metadata.DeployContainer mdContainer = new Metadata.DeployContainer();
//            mdContainer.addMetadata(customMetadata);
//            MetadataCallback callback = new MetadataCallback();
//            Id jobId = Metadata.Operations.enqueueDeployment(mdContainer, callback);
//
//            system.debug('Container>>'+mdContainer);
//            system.debug('Id>>'+jobId);
//            return jobId;
//
//        }
//        catch(Exception ex){
//            system.debug('Error on insert');
//            system.debug('Error:'+ex.getMessage());
//            return null;
//        }
//    }

    public static Metadata.DeployContainer createMetadataContainer(String metaDataTypeName, String label, Map<String, String> fieldDataMap){

//            //Create CustomMeta record
            Metadata.CustomMetadata customMetadata =  new Metadata.CustomMetadata();
            customMetadata.label = label;
            customMetadata.fullName = metaDataTypeName.replace('__mdt','')+'.'+label.replaceAll('[^a-zA-Z0-9\\s+]', '').replace(' ', '_');
//                //Create Custom Fields for record
            for(String item : fieldDataMap.keySet()) {
                Metadata.CustomMetadataValue field = new Metadata.CustomMetadataValue();
                field.field = item;
                field.value = fieldDataMap.get(item);
                customMetadata.values.add(field); //add custom fields to CustomMeta record
            }
////          Add new CustomMeta record to return container
            Metadata.DeployContainer mdContainer = new Metadata.DeployContainer();
            mdContainer.addMetadata(customMetadata);
            return mdContainer;
    }
}