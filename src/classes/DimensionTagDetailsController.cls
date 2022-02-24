/**
 * Created by afaf.awad on 6/7/2021.
 */

public with sharing class DimensionTagDetailsController {

    @AuraEnabled
    public static DimTagDetails getDimTagDetails(String dimTagId, Integer pageSize, Integer pageNumber){
//        System.debug('pagenumber == ' + pageNumber + ' and pagesize == ' + pageSize);
        Dimension_Tags__mdt dimTag = DimensionTagHelper.getDimTagRecord(dimTagId);
        List<UnionTags> unionTags = new List<UnionTags>();
        List<sObject> dtRecords = DimensionTagHelper.getRecordTags(null,dimTag.Object__c + '_Dimension_Tag__c', 'Dim_Tag_Id__c = \'' + dimTagId + '\'', pageSize, pageNumber);

        //converted tag maps
        Map<Id, Id> cnvrtTagMap = new Map<Id, Id>(); //Tag's metaTag Id with Tag's converted from Id
        Map<String, Dimension_Tags__mdt> cnvrtMetaTagMap = new Map<String, Dimension_Tags__mdt>(); //Tag's converted Id (the lead id) with the lead id's metaTag

        if(dimTag.Object__c == 'Contact') {
            for (sObject obj : dtRecords) {
                if (String.isNotEmpty((String) obj.get('Conversion_Tag__c'))) {
                    cnvrtTagMap.put((String) obj.get('Id'), (String) obj.get('Conversion_Tag__c'));
                }
            }
            if (!cnvrtTagMap.isEmpty()) {
                cnvrtMetaTagMap = DimensionTagHelper.getConvertedFromTags(cnvrtTagMap.values());
            }
        }

        if(dimTag.Object__c == 'Lead') {
            for (sObject obj : dtRecords) {
                if (String.isNotEmpty((String) obj.get('Conversion_Tag__c'))) {
                    cnvrtTagMap.put((String) obj.get('Id'), (String) obj.get('Conversion_Tag__c'));
                }
            }
            if (!cnvrtTagMap.isEmpty()) {
                cnvrtMetaTagMap = DimensionTagHelper.getConvertedToTags(cnvrtTagMap.values());
            }
        }

        System.debug('cnvrtMetaTagMap == ' + cnvrtMetaTagMap);

        for (sObject obj : dtRecords) {
            UnionTags utag = new UnionTags();
            utag.dtRecord = obj;
            utag.convertedTag = cnvrtMetaTagMap.get(cnvrtTagMap.get((String) obj.get('Id')));
            unionTags.add(utag);
        }

        DimTagDetails dtd = new DimTagDetails();
        dtd.dimTag = dimTag;
        dtd.unionTags = unionTags;

        return dtd;
    }

    @AuraEnabled
    public static ObjectExport exportTags(String objectName, String exportType, String dimTagId){
//        List<String> tagIds = (List<String>) System.JSON.deserialize(idListString, List<String>.class);
        User u = [SELECT Id,Name,Username FROM User WHERE Id =: userInfo.getUserId()];
        ObjectExport objExport = new ObjectExport();

        switch on objectName{
            when 'Account' {
                ExportHelper_Account.AccountExport ae = ExportHelper_Account.queryAccounts(dimTagId);
                objExport.objectList = ae.Accounts;
                objExport.headers = ae.headers;
                objExport.user = u;
            }
            when 'Contact' {
                if(exportType == 'full') {
                    ExportHelper_Contact.ContactExport ce = ExportHelper_Contact.queryContacts_full(dimTagId);
                    objExport.objectList = ce.Contacts;
                    objExport.headers = ce.headers;
                    objExport.user = u;
                }else{
                    ExportHelper_Contact.ContactExport ce = ExportHelper_Contact.queryContacts_market(dimTagId);
                    objExport.objectList = ce.Contacts;
                    objExport.headers = ce.headers;
                    objExport.user = u;
                }
            }
            when 'Lead' {
                ExportHelper_Lead.LeadExport le = ExportHelper_Lead.queryLeads(dimTagId);
                objExport.objectList = le.Leads;
                objExport.headers = le.headers;
                objExport.user = u;
            }
            when 'Opportunity'{
                ExportHelper_Opportunity.OpportunityExport oe = ExportHelper_Opportunity.queryOpportunities(dimTagId);
                objExport.objectList = oe.Opportunities;
                objExport.headers = oe.headers;
                objExport.user = u;
            }
        }

        return objExport;
    }

    @AuraEnabled
    public static void logDownload(String objectName, String tagLabel, String filename, String userId, String exportType){
        DTM_Activity_Log__c actlog = new DTM_Activity_Log__c(User__c = userId,
                                                            filename__c = filename,
                                                            Criteria__c = exportType + ' ' + objectName + ' Export - ' + tagLabel,
                                                            date_Time__c = System.now());

        insert actlog;
    }

    public class DimTagDetails{

        @AuraEnabled
        public Dimension_Tags__mdt dimTag;
        @AuraEnabled
        public List<UnionTags> unionTags;

//        public DimTagDetails(Dimension_Tags__mdt dimTagMdt, List<sObject> dimTagRecords, Dimension_Tags__mdt cnvtTag){
//            this.dimTag = dimTagMdt;
//            this.dtRecords = dimTagRecords;
//            this.cnvtTag = cnvtTag;
//        }
    }

    public class UnionTags{
        @AuraEnabled
        public sObject dtRecord;
        @AuraEnabled
        public Dimension_Tags__mdt convertedTag;
    }

    public class ObjectExport{
        @AuraEnabled
        public List<Object> objectList;
        @AuraEnabled
        public List<String> headers;
        @AuraEnabled
        public User user;

    }

}