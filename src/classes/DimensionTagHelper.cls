/**
 * Created by afaf.awad on 6/1/2021.
 */

public with sharing class DimensionTagHelper {


    public static List<sObject> getRecordTags(Id recordId, String objectName, String filterString){

        String sQuery =  'SELECT Id, Tag__c, Dim_Tag_Id__c, Request_for_Removal__c,Object_Lookup__r.Name, Object_Lookup__c ';
        sQuery += objectName == 'Contact_Dimension_Tag__c' ? ', Conversion_Tag__c ' : '';
        sQuery += 'FROM ' + objectName;

        if(recordId != null) {
            sQuery += ' WHERE Object_Lookup__c =: recordId';
        }
        if(filterString !=null){
            if(recordId !=null) {
                sQuery += ' AND ' + filterString;
            }else{
                sQuery += ' WHERE ' + filterString;
            }
        }

        System.debug('squery: ' + sQuery);
        return Database.query(sQuery);

    }

    public static List<sObject> getRecordTags(Id recordId, String objectName, String filterString, Integer pageSize, Integer pageNumber){

        System.debug('pagenumber == ' + pageNumber + ' and pagesize == ' + pageSize);
        Integer offset = (pageNumber - 1) * pageSize;

        String sQuery =  'SELECT Id, Tag__c, Dim_Tag_Id__c, Request_for_Removal__c,Object_Lookup__r.Name, Object_Lookup__c ';
        if(objectName == 'Contact_Dimension_Tag__c' || objectName == 'Lead_Dimension_Tag__c') {
            sQuery += ', Conversion_Tag__c ';
        }
        sQuery += 'FROM ' + objectName;

        if(recordId != null) {
            sQuery += ' WHERE Object_Lookup__c =: recordId';
        }
        if(filterString !=null){
            if(recordId !=null) {
                sQuery += ' AND ' + filterString;
            }else{
                sQuery += ' WHERE ' + filterString;
            }

        }

        sQuery += ' LIMIT ' + pageSize + ' OFFSET ' + offset;

        System.debug('squery: ' + sQuery);
        return Database.query(sQuery);

    }

    public static Map<String,Dimension_Tags__mdt> getConvertedToTags(List<String> convertedTagIds){

        System.debug('FROM : convertedTagIds == ' + convertedTagIds);

        List<Contact_Dimension_Tag__c> cdt = [SELECT Id, Dim_Tag_Id__c, Request_for_Removal__c FROM Contact_Dimension_Tag__c WHERE Id IN: convertedTagIds];
        List<String> tagIds = new List<String>();

        for(Contact_Dimension_Tag__c c : cdt){
            tagIds.add(c.Dim_Tag_Id__c  );
        }

        Map<String,Dimension_Tags__mdt> dimTagMap = new Map<String, Dimension_Tags__mdt>(DimensionTagHelper.getPublicMdtTags(tagIds, 'Contact')); //get Map of meta tag Ids with its object
        Map<String,Dimension_Tags__mdt> conTagMap = new Map<String, Dimension_Tags__mdt>();
        System.debug('FROM : dimTagMap == ' + dimTagMap);

        for(Contact_Dimension_Tag__c c : cdt){
            conTagMap.put(c.Id, dimTagMap.get(c.Dim_Tag_Id__c));
        }

        return conTagMap;

    }

    public static Map<String,Dimension_Tags__mdt> getConvertedFromTags(List<String> convertedTagIds){

        System.debug('TO : convertedTagIds == ' + convertedTagIds);

        List<Lead_Dimension_Tag__c> ldt = [SELECT Id, Dim_Tag_Id__c, Request_for_Removal__c FROM Lead_Dimension_Tag__c WHERE Id IN: convertedTagIds];
        List<String> tagIds = new List<String>();

        for(Lead_Dimension_Tag__c l : ldt){
            tagIds.add(l.Dim_Tag_Id__c  );
        }

        Map<String,Dimension_Tags__mdt> dimTagMap = new Map<String, Dimension_Tags__mdt>(DimensionTagHelper.getPublicMdtTags(tagIds, 'Lead')); //get Map of meta tag Ids with its object
        Map<String,Dimension_Tags__mdt> leadTagMap = new Map<String, Dimension_Tags__mdt>();
        System.debug('TO : dimTagMap == ' + dimTagMap);

        for(Lead_Dimension_Tag__c l : ldt){
            leadTagMap.put(l.Id, dimTagMap.get(l.Dim_Tag_Id__c));
        }

        return leadTagMap;

    }

    public static List<Dimension_Tags__mdt> getPublicMdtTags(List<String> tagIds, String objectName) {

        return [
                SELECT Id, DeveloperName, Label, Status__c, Visibility__c, Object__c
                FROM Dimension_Tags__mdt
                WHERE Id IN: tagIds
                AND Object__c = :objectName
                AND Status__c = 'Active'
                AND Visibility__c IN ('Public','System')
        ];
    }

    public static List<Dimension_Tags__mdt> getPrivateMdtTags(List<String> tagIds, String objectName) {

        return [
                SELECT Id, DeveloperName, Label, Status__c, Visibility__c, Object__c
                FROM Dimension_Tags__mdt
                WHERE Id IN: tagIds
                AND Object__c = :objectName
                AND Status__c = 'Active'
                AND Visibility__c = 'Private'
                AND Owner_Id__c =: UserInfo.getUserId()
        ];
    }

    public static Dimension_Tags__mdt getDimTagRecord(String dimTagId) {

        return [SELECT Id, DeveloperName, Label, Status__c, Visibility__c, Owner__c, Object__c, Description__c
                FROM Dimension_Tags__mdt
                WHERE Id =: dimTagId
        ];
    }


    public static Map<String, String> createDimTagMetadata(String description, String objectName, String visibility){

        Map<String, String> mdtRecordMap = new Map<String, String>();
        mdtRecordMap.put('Description__c',description);
        mdtRecordMap.put('Object__c',objectName);
        mdtRecordMap.put('Visibility__c',visibility);

        if(visibility == 'Private'){
            mdtRecordMap.put('Owner__c', UserInfo.getName());
            mdtRecordMap.put('Owner_Id__c',UserInfo.getUserId());
        }

        return mdtRecordMap;
    }

    public static SObject createTagRecord(Id dimTagId,  Id recordId){
//        System.debug('inside CreateTagRecord method...');
        Dimension_Tags__mdt dimTag = DimensionTagHelper.getDimTagRecord(dimTagId);

        sObject sObj = recordId.getSobjectType().newSObject(recordId);
        String objectTag = sObj.getSObjectType() + '_Dimension_Tag__c';
//        System.debug('objectName == ' + objectTag);

        sObject tagObj = Schema.getGlobalDescribe().get(objectTag).newSObject() ;
        tagObj.put('Tag__c',dimTag.DeveloperName);
        tagObj.put('Visibility__c',dimTag.Visibility__c);
        tagObj.put('Object_Lookup__c', recordId);
        tagObj.put('Dim_Tag_Id__c', dimTagId);

        return tagObj;

    }

    public static SObject bulkCreateTagRecord(Dimension_Tags__mdt dimTag,  Id recordId, String objectTag ){
//        System.debug('inside CreateTagRecord method...');
//        Dimension_Tags__mdt dimTag = DimensionTagHelper.getDimTagRecord(dimTagId);

//        sObject sObj = recordId.getSobjectType().newSObject(recordId);
//        String objectTag = sObj.getSObjectType() + '_Dimension_Tag__c';
//        System.debug('objectName == ' + objectTag);

        sObject tagObj = Schema.getGlobalDescribe().get(objectTag).newSObject() ;
        tagObj.put('Tag__c',dimTag.DeveloperName);
        tagObj.put('Visibility__c',dimTag.Visibility__c);
        tagObj.put('Object_Lookup__c', recordId);
        tagObj.put('Dim_Tag_Id__c', dimTag.Id);

        return tagObj;

    }

    public static void deleteTagRecord(Id recordId) {
        System.debug('Deleting tag...');
        sObject sObj = recordId.getSobjectType().newSObject(recordId);
        delete sObj;

    }

    public static void removeRequestTagRecord(Id recordId){
        System.debug('Updating tag...');
        sObject tagObj = recordId.getSobjectType().newSObject(recordId);
        tagObj.put('Request_for_Removal__c',true);
        tagObj.put('Removal_Requested_By__c', UserInfo.getUserId());
        update tagObj;
    }

}