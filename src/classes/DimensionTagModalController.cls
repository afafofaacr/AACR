/**
 * Created by afaf.awad on 6/1/2021.
 */

public with sharing class DimensionTagModalController {

    @AuraEnabled
    public static void createDimTag(String recLabel, String description, String objectName, String visibility, String recordId){
        System.debug('deploying metadata dim tag record....');

        Map<String, String> mdtRecordMap = DimensionTagHelper.createDimTagMetadata(description, objectName, visibility);

        Metadata.DeployContainer mdContainer = MDTHelper.createMetadataContainer('Dimension_Tags__mdt', recLabel, mdtRecordMap);
        DimTagMetadataCallback callback = new DimTagMetadataCallback();
        callback.recordId = recordId;
        if(!Test.isRunningTest()) {
            Id jobId = Metadata.Operations.enqueueDeployment(mdContainer, callback);
            system.debug('Container>>'+mdContainer);
            system.debug('Id>>'+jobId);
        }

    }

    @AuraEnabled
    public static void createTagRecord(String dimTagId,  String recordId){
        System.debug('creating tag record....');
            try {
                insert DimensionTagHelper.createTagRecord(dimTagId, recordId);
            }catch(Exception ex){
                System.debug('Error creating Tag Record: ' + ex.getMessage());
            }
    }

    @AuraEnabled
    public static Boolean validateTagName(String tagName){
        List<Dimension_Tags__mdt> dimensionTags = [SELECT Id, DeveloperName, Label, Status__c FROM Dimension_Tags__mdt WHERE Label =: tagName];
        System.debug('dimensionTags == ' + dimensionTags);

        if(dimensionTags.size()>0){
            return false;
        }else{
            return true;
        }

    }
}