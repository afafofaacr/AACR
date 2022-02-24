/**
 * Created by afaf.awad on 5/25/2021.
 */

public with sharing class DimensionTagController {

    @AuraEnabled
    public static List<DimTagInfo> getDimTags(Id recordId){
        sObject sObj = recordId.getSobjectType().newSObject(recordId);
        String objectName = String.valueOf(sObj.getSObjectType());
        system.debug('ObjectName-->' + objectName);

        //Get DimTag Records
        List<SObject> dimObj = DimensionTagHelper.getRecordTags(recordId, objectName + '_Dimension_Tag__c', null);
        System.debug('recordTags:  ' + dimObj);

        String[] tagIds = new List<String>();
        Map<String, Boolean> tagRecordMap = new Map<String, Boolean>();
        Map<Id,Id> cnvrtTagMap = new Map<Id,Id>(); //Tag's metaTag Id with Tag's converted from Id

        for(sObject obj : dimObj){
            System.debug(obj.get('Dim_Tag_Id__c'));
            tagRecordMap.put((String)obj.get('Dim_Tag_Id__c'), (Boolean)obj.get('Request_for_Removal__c')); //Build Map of DimTag records with RemoveRequest
            tagIds.add((String)obj.get('Dim_Tag_Id__c')); //List of DimTag Ids to get metadata details
            if(objectName == 'Contact') {
                if ( String.isNotEmpty((String) obj.get('Conversion_Tag__c'))){
                    cnvrtTagMap.put( (String)obj.get('Dim_Tag_Id__c'), (String) obj.get('Conversion_Tag__c'));
                }
            }

        }
        Map<String,Dimension_Tags__mdt> leadTagMap = new Map<String, Dimension_Tags__mdt>();
        if(!cnvrtTagMap.isEmpty()){
            leadTagMap = DimensionTagHelper.getConvertedFromTags(cnvrtTagMap.values());
        }

        List<Dimension_Tags__mdt> dimTags = new List<Dimension_Tags__mdt>();
        dimTags.addAll(DimensionTagHelper.getPublicMdtTags(tagIds, objectName));
        dimTags.addAll(DimensionTagHelper.getPrivateMdtTags(tagIds, objectName));

        List<DimTagInfo> dtInfo = new List<DimTagInfo>();
        for(Dimension_Tags__mdt dt: dimTags){
            dtInfo.add(new DimensionTagController.DimTagInfo( dt, tagRecordMap.get(dt.Id), leadTagMap.get(cnvrtTagMap.get(dt.Id))));
        }

            System.debug('DimTags returned: ' + dtInfo);
        return dtInfo;
    }

    @AuraEnabled
    public static List<Dimension_Tags__mdt> searchTags(String searchString, String objectName, Id recordId) {
        system.debug('ObjectName-->' + objectName);

        List<SObject> recordTags = DimensionTagHelper.getRecordTags(recordId, objectName + '_Dimension_Tag__c', null);
        String[] tagNames = new List<String>();

        for(sObject obj : recordTags){
            System.debug(obj.get('Tag__c'));
            tagNames.add((String)obj.get('Tag__c'));
        }

        String searchKey = '%' + searchString.replace(' ', '%') + '%';

        List<Dimension_Tags__mdt> dimTags = new List<Dimension_Tags__mdt>();
        dimTags.addAll(searchPublicTags(searchKey, objectName, tagNames));
        dimTags.addAll(searchPrivateTags(searchKey, objectName, tagNames));

        return dimTags;
    }

    public static List<Dimension_Tags__mdt> searchPublicTags(String searchString, String objectName, List<String> tagNames){
        return [
                SELECT Id, DeveloperName, Label
                FROM Dimension_Tags__mdt
                WHERE Label LIKE:searchString
                AND DeveloperName NOT IN: tagNames
                AND Object__c = :objectName
                AND Status__c = 'Active'
                AND Visibility__c = 'Public'
                ORDER BY DeveloperName DESC
                limit 5
        ];
    }

    public static List<Dimension_Tags__mdt> searchPrivateTags(String searchString, String objectName, List<String> tagNames){
        return [
                SELECT Id, DeveloperName, Label
                FROM Dimension_Tags__mdt
                WHERE Label LIKE:searchString
                AND DeveloperName NOT IN: tagNames
                AND Object__c = :objectName
                AND Status__c = 'Active'
                AND Visibility__c = 'Private'
                AND Owner_Id__c =: UserInfo.getUserId()
                ORDER BY DeveloperName DESC
                limit 5
        ];
    }


    @AuraEnabled
    public static SObject createTagRecord(Id dimTagId,  Id recordId){
        System.debug('inside CreateTagRecord method...');
        SObject tagRecord = DimensionTagHelper.createTagRecord(dimTagId, recordId);
        try {
            insert tagRecord;
            return tagRecord;
        }catch(Exception ex){
            System.debug('Error creating ' + tagRecord + ' Tag Record: ' + ex.getMessage());
            return null;
        }

    }

    @AuraEnabled
    public static void removeTagRecord(String tagRecordId, Id recordId, String tagLevel){
        System.debug('checking visibility before deleting...' + tagLevel);
        sObject sObj = recordId.getSobjectType().newSObject(recordId);
        String objectTag = sObj.getSObjectType() + '_Dimension_Tag__c';
        List<SObject> tagRecords = DimensionTagHelper.getRecordTags(recordId, objectTag, 'Dim_Tag_Id__c = \'' + tagRecordId + '\'' );

        switch on tagLevel{
            when 'Public'{
                DimensionTagHelper.removeRequestTagRecord(tagRecords[0].Id);
            }
            when 'Private'{
                DimensionTagHelper.deleteTagRecord(tagRecords[0].Id);
            }
//            when 'System'{
                //TBD
//            }
        }

    }

    @AuraEnabled
    public static String getReportURL(String dimTagId, String objectName){
        System.debug('dimTagId = ' + dimTagId);

        Dimension_Tag_Report__mdt dimTagReport = [SELECT Id, Report_Url__c FROM Dimension_Tag_Report__mdt WHERE Object__c =: objectName];

        String url = dimTagReport.Report_Url__c + '?fv0=' + dimTagId;

        return url;
    }


    public class DimTagInfo{
        @AuraEnabled
        public Dimension_Tags__mdt dimTag;
        @AuraEnabled
        public Boolean deleteRequest;
        @AuraEnabled
        public Dimension_Tags__mdt convertedTag;

        public DimTagInfo(Dimension_Tags__mdt dimTagObj, Boolean isDelete, Dimension_Tags__mdt conTagObject ){
            this.dimTag = dimTagObj;
            this.deleteRequest = isDelete;
            this.convertedTag = conTagObject;

        }
    }

}