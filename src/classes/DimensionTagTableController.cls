/**
 * Created by afaf.awad on 6/4/2021.
 */

public with sharing class DimensionTagTableController {

    @AuraEnabled
    public static List<DimTagInfo> getDimTagInfo(String tagLevel, String filterString, String searchString){

        String sQuery =  'SELECT Id, DeveloperName, Label, Status__c, Visibility__c, Object__c, Description__c FROM Dimension_Tags__mdt WHERE Status__c = \'Active\' AND Visibility__c =: tagLevel';

        if(filterString != '[]'){
            List<String> objFilters = (List<String>)JSON.deserialize(filterString, List<String>.class);
            sQuery += ' AND Object__c IN: objFilters';
        }

        if(tagLevel == 'Private'){
            String userId = UserInfo.getUserId();
            sQuery += ' AND Owner_Id__c =: userId';
        }

        if(String.isNotBlank(searchString)){
            String searchKey = '%' + searchString.replace(' ', '%') + '%';
            sQuery += ' AND Label LIKE \'' + searchKey +'\'';
        }

        System.debug('squery: ' + sQuery);
        List<Dimension_Tags__mdt> dimensionTags = Database.query(sQuery);

        List<String> accTags = new List<String>();
        List<String> conTags = new List<String>();
        List<String> leadTags = new List<String>();
        List<String> oppTags = new List<String>();

        for(Dimension_Tags__mdt dt : dimensionTags) {
            switch on dt.Object__c{
                when 'Account'{
                    accTags.add(dt.Id);
                }
                when 'Contact'{
                    conTags.add(dt.Id);
                }
                when 'Lead'{
                    leadTags.add(dt.Id);
                }
                when 'Opportunity'{
                    oppTags.add(dt.Id);
                }
            }
        }

        Map<Id, Integer> mapOfTagCounts = new Map<Id, Integer>();
        mapOfTagCounts.putAll(getTagCounts('Account_Dimension_Tag__c', accTags));
        mapOfTagCounts.putAll(getTagCounts('Contact_Dimension_Tag__c', conTags));
        mapOfTagCounts.putAll(getTagCounts('Lead_Dimension_Tag__c', leadTags));
        mapOfTagCounts.putAll(getTagCounts('Opportunity_Dimension_Tag__c', oppTags));

        System.debug('List of Tags = ' + mapOfTagCounts);

        List<DimTagInfo> dimTagInfo = new List<DimTagInfo>();
        for(Dimension_Tags__mdt dt : dimensionTags){
            DimTagInfo dti = new DimTagInfo();
            dti.tagName = dt.Label;
            dti.ObjectName = dt.Object__c;
            dti.tagCount = mapOfTagCounts.get(dt.Id) == null ? 0 : mapOfTagCounts.get(dt.Id);
            dti.dtId = dt.Id;
            dimTagInfo.add(dti);
        }

        System.debug('dimTagInfo:::' + dimTagInfo);

        return dimTagInfo;

    }

    public static Map<Id, Integer> getTagCounts(String objectName, List<String> dimTagIds){

        String sQuery =  'SELECT COUNT(Id) tagCount , Dim_Tag_Id__c FROM ' + objectName + ' WHERE Dim_Tag_Id__c IN:dimTagIds  GROUP BY Dim_Tag_Id__c';

        System.debug('squery: ' + sQuery);
        List<SObject> objectCounts = Database.query(sQuery);

        system.debug('objectCounts == ' + objectCounts);
        
        Map<Id, Integer> tagCountMap = new Map<Id, Integer>();
        for (SObject obj : objectCounts) {
            Id dimTagId = (Id) obj.get('Dim_Tag_Id__c');
            Integer count = (Integer) obj.get('tagCount');
            tagCountMap.put(dimTagId, count);
        }

        return tagCountMap;

    }

    public class DimTagInfo{
        @AuraEnabled
        public String tagName;
        @AuraEnabled
        public String objectName;
        @AuraEnabled
        public Integer tagCount;
        @AuraEnabled
        public Id dtId;
    }


}