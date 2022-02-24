/**
 * @purpose List of AuraEnabled methods used by CustomLookup lightning component
 * Created by lauren.lezberg on 3/21/2019.
 */
 
public without sharing class CustomLookupController {
    /**
     * @purpose Retrieves records based on search keyword from specific object type
     *
     * @param searchKeyWord
     * @param ObjectName
     *
     * @return List of records matching the search keyword
     */
    @AuraEnabled
    public static List < sObject > fetchLookUpValues(String searchKeyWord, String ObjectName, String filterString) {
        system.debug('ObjectName-->' + ObjectName);
        return ECRMUtils.fetchLookUpValues(searchKeyWord, ObjectName, filterString);
    }

    /**
     * @purpose Gets specific record based on object type and recordId
     *
     * @param ObjectName
     * @param recordId
     *
     * @return specified record or null
     */
    @AuraEnabled
    public static sObject getInitialValue(String ObjectName, String recordId){
        String sQuery =  'select id, Name from ' +ObjectName + ' where Id =\'' + recordId + '\'';
        List < sObject > lstOfRecords = Database.query(sQuery);
        if(lstOfRecords.size()==1){
            return lstOfRecords[0];
        }
        return null;
    }


    /**
     * @purpose Creates new record with specified name and record type
     *
     * @param objectApiName
     * @param recordName
     * @param recordTypeName
     *
     * @return recordId of created record or null
     */
    @AuraEnabled
    public static String createNewRecord(String objectApiName, String recordName, String recordTypeName){
        System.debug('creatingNewRecord...');
        List<RecordType> recordTypes = [SELECT Id FROM RecordType WHERE Name=: recordTypeName AND SobjectType=: objectApiName];
        System.debug('recordTypes: ' + recordTypes);
        sObject sObj = Schema.getGlobalDescribe().get(objectApiName).newSObject() ;
        sObj.put('Name',recordName);
        sObj.put('RecordTypeId', recordTypes[0].Id);
        List<siteSettings__c> siteSetting = [SELECT ownerId__c FROM siteSettings__c LIMIT 1];
        if(siteSetting.size()==1) {
            sObj.put('OwnerId', siteSetting[0].ownerId__c);
        }
        try {
            insert sObj;
            return sObj.get('Id').toString();
        } catch(Exception e){
            return null;
        }
    }

    /**
     * @purpose Creates new relationship record for assistants
     *
     * @param assistantId
     * @param contactId
     */
    @AuraEnabled
    public static void createAssistantRelationship(String assistantId, String contactId){

        System.debug('creating new assistant with ' + assistantId + ' and ' + contactId);

        npe4__Relationship__c r = new npe4__Relationship__c();

        r.npe4__RelatedContact__c = assistantId;
        r.npe4__Status__c = 'Current';
        r.npe4__Type__c = 'Assistant';
        r.npe4__Contact__c = contactId;

        Try {
            insert r;
        }catch(Exception exp){
            System.debug('Exception Occured :::'+ exp.getMessage() + '\t' + exp.getStackTraceString());
        }
    }

}