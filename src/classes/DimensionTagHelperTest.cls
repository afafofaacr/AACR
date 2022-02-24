/**
 * Created by afaf.awad on 7/7/2021.
 */

@IsTest
private class DimensionTagHelperTest {
    @TestSetup
    public static void setup(){
        Account acc = TestDataFactory.buildAccount('Test Account');
        insert acc;

        Contact con = TestDataFactory.buildContact(acc.Id);
        insert con;

        Lead lead = TestDataFactory.buildLead();
        insert lead;

        Appeal_Code__c appealCode = new Appeal_Code__c(Name = 'Test Appeal Code');
        insert appealCode;

        OrderApi__GL_Account__c glAccount = TestDataFactory.buildGLAccount();
        glAccount.Distribution_Code__c = true;
        insert glAccount;

        Opportunity opp = TestDataFactory.buildOpportunity(acc.Id, con.Id, appealCode.Id, glAccount.Id);
        insert opp;

        Dimension_Tags__mdt publicDT = [SELECT Id FROM Dimension_Tags__mdt WHERE Object__c = 'Contact' AND Visibility__c = 'Public' LIMIT 1];
        SObject publicObj = DimensionTagHelper.createTagRecord(publicDT.Id,  con.Id);
        insert publicObj;

        Dimension_Tags__mdt privateDT = [SELECT Id FROM Dimension_Tags__mdt WHERE Object__c = 'Contact' AND Visibility__c = 'Private' LIMIT 1];
        SObject privateObj = DimensionTagHelper.createTagRecord(privateDT.Id,  con.Id);
        insert privateObj;

        Dimension_Tags__mdt leadDT = [SELECT Id FROM Dimension_Tags__mdt WHERE Object__c = 'Lead' AND Visibility__c = 'Public' LIMIT 1];
        SObject leadObj = DimensionTagHelper.createTagRecord(leadDT.Id,  lead.Id);
        leadObj.put('Conversion_Tag__c', publicObj.get('Id'));
        insert leadObj;

        publicObj.put('Conversion_Tag__c', leadObj.get('Id'));
        update publicObj;

    }

    @IsTest
    public static void test_getRecordTags(){
        Contact con = [SELECT Id FROM Contact LIMIT 1];
        Contact_Dimension_Tag__c contactTag = [SELECT Id, Dim_Tag_Id__c, Object_Lookup__c FROM Contact_Dimension_Tag__c WHERE Visibility__c = 'Public' LIMIT 1];

        List<SObject> tagRecords = DimensionTagHelper.getRecordTags(con.Id, 'Contact_Dimension_Tag__c', null);
        System.assertEquals(2,tagRecords.size());

        List<SObject> tagRecordsFilter = DimensionTagHelper.getRecordTags(con.Id, 'Contact_Dimension_Tag__c', 'Dim_Tag_Id__c = \'' + contactTag.Dim_Tag_Id__c + '\'');
        System.assertEquals(1,tagRecordsFilter.size());

        List<SObject> tagRecordsNullId = DimensionTagHelper.getRecordTags(null, 'Contact_Dimension_Tag__c', 'Dim_Tag_Id__c = \'' + contactTag.Dim_Tag_Id__c + '\'');
        System.assertEquals(1,tagRecordsNullId.size());
    }

    @IsTest
    public static void test_getConvertedFromTags() {
        Contact con = [SELECT Id FROM Contact LIMIT 1];
        List<Contact_Dimension_Tag__c> contactTag = [SELECT Id, Dim_Tag_Id__c, Object_Lookup__c, Conversion_Tag__c FROM Contact_Dimension_Tag__c WHERE Visibility__c = 'Public'];
        Map<Id, Id> cTagMap = new Map<Id, Id>();

        for (Contact_Dimension_Tag__c obj : contactTag) {
            if (String.isNotEmpty((String) obj.get('Conversion_Tag__c'))) {
                cTagMap.put((String) obj.get('Id'), (String) obj.get('Conversion_Tag__c'));
            }
        }
        Map<String, Dimension_Tags__mdt> cMetaTagMap = DimensionTagHelper.getConvertedFromTags(cTagMap.values());

        System.assertEquals(1, cMetaTagMap.size());

    }

    @IsTest
    public static void test_getConvertedToTags() {
        Lead lead = [SELECT Id FROM Lead LIMIT 1];
        List<Lead_Dimension_Tag__c> LeadTag = [SELECT Id, Dim_Tag_Id__c, Object_Lookup__c, Conversion_Tag__c FROM Lead_Dimension_Tag__c WHERE Visibility__c = 'Public'];
        Map<Id, Id> cTagMap = new Map<Id, Id>();

        for (Lead_Dimension_Tag__c obj : LeadTag) {
            if (String.isNotEmpty((String) obj.get('Conversion_Tag__c'))) {
                cTagMap.put((String) obj.get('Id'), (String) obj.get('Conversion_Tag__c'));
            }
        }
        Map<String, Dimension_Tags__mdt> cMetaTagMap = DimensionTagHelper.getConvertedToTags(cTagMap.values());

        System.assertEquals(1, cMetaTagMap.size());

    }


        @IsTest
    public static void test_getRecordTagsWithPaging(){
        Contact con = [SELECT Id FROM Contact LIMIT 1];
        Contact_Dimension_Tag__c contactTag = [SELECT Id, Dim_Tag_Id__c, Object_Lookup__c FROM Contact_Dimension_Tag__c WHERE Visibility__c = 'Public' LIMIT 1];

        List<SObject> tagRecords = DimensionTagHelper.getRecordTags(con.Id, 'Contact_Dimension_Tag__c', null, 50, 1);
        System.assertEquals(2,tagRecords.size());

        List<SObject> tagRecordsFilter = DimensionTagHelper.getRecordTags(con.Id, 'Contact_Dimension_Tag__c', 'Dim_Tag_Id__c = \'' + contactTag.Dim_Tag_Id__c + '\'', 50, 1);
        System.assertEquals(1,tagRecordsFilter.size());

        List<SObject> tagRecordsNullId = DimensionTagHelper.getRecordTags(null, 'Contact_Dimension_Tag__c', 'Dim_Tag_Id__c = \'' + contactTag.Dim_Tag_Id__c + '\'', 50, 1);
        System.assertEquals(1,tagRecordsNullId.size());
    }

    @IsTest
    public static void test_getPublicMdtTags(){

        List<Dimension_Tags__mdt> dimTags = [
                SELECT Id, DeveloperName, Label, Status__c, Visibility__c
                FROM Dimension_Tags__mdt
                WHERE Object__c = 'Contact'
                AND Status__c = 'Active'
                AND Visibility__c IN ('Public','System')
        ];

        List<Id> dimTagIds = new List<Id>();
        for(Dimension_Tags__mdt dt : dimTags){
            dimTagIds.add(dt.Id);
        }

        List<Dimension_Tags__mdt> dimTagsReturned = DimensionTagHelper.getPublicMdtTags(dimTagIds, 'Contact');
        System.assertEquals(dimTags.size(), dimTagsReturned.size());
    }

    @IsTest
    public static void test_getPrivateMdtTags() {

        List<Dimension_Tags__mdt> dimTags = [
                SELECT Id, DeveloperName, Label, Status__c, Visibility__c
                FROM Dimension_Tags__mdt
                WHERE Object__c = 'Contact'
                AND Status__c = 'Active'
                AND Visibility__c = 'Private'
                AND Owner_Id__c =: UserInfo.getUserId()
        ];

        List<Id> dimTagIds = new List<Id>();
        for (Dimension_Tags__mdt dt : dimTags) {
            dimTagIds.add(dt.Id);
        }

        List<Dimension_Tags__mdt> dimTagsReturned = DimensionTagHelper.getPrivateMdtTags(dimTagIds, 'Contact');
        System.debug('dimTagsReturned : ' + dimTagsReturned);
        System.assertEquals(dimTags.size(), dimTagsReturned.size());
    }

    @IsTest
    public static void test_getDimTagRecord(){
        Dimension_Tags__mdt dimTag = [SELECT Id FROM Dimension_Tags__mdt LIMIT 1];

        Dimension_Tags__mdt returnedTag = DimensionTagHelper.getDimTagRecord(dimTag.Id);
        System.assertEquals(dimTag.Id, returnedTag.Id);
    }

    @IsTest
    public static void test_createDimTagMetadata(){

        Map<String, String> dimTagMap = DimensionTagHelper.createDimTagMetadata('Test Dim Tag', 'Contact', 'Private');
        System.assertEquals(UserInfo.getUserId(), dimTagMap.get('Owner_Id__c'));

    }

    @IsTest
    public static void test_CreateTagRecord(){
        Contact con = [SELECT Id FROM Contact LIMIT 1];
        Dimension_Tags__mdt dimTag = [SELECT Id FROM Dimension_Tags__mdt WHERE Object__c = 'Contact' AND Visibility__c = 'Public' LIMIT 1];
        SObject returnedTag = DimensionTagHelper.createTagRecord(dimTag.Id,  con.Id);
        System.assertEquals(con.Id, returnedTag.get('Object_Lookup__c'));
    }

    @IsTest
    public static void test_deleteTagRecord(){
        Contact_Dimension_Tag__c contactTagPre = [SELECT Id, Dim_Tag_Id__c, Object_Lookup__c FROM Contact_Dimension_Tag__c WHERE Visibility__c = 'Private' LIMIT 1];
        DimensionTagHelper.deleteTagRecord(contactTagPre.Id);

        List<Contact_Dimension_Tag__c> contactTagPost = [SELECT Id, Dim_Tag_Id__c, Object_Lookup__c FROM Contact_Dimension_Tag__c WHERE Visibility__c = 'Private'];
        System.assertEquals(0, contactTagPost.size());

    }

    @IsTest
    public static void test_removeRequestTagRecord(){
        Contact_Dimension_Tag__c contactTagPre = [SELECT Id, Dim_Tag_Id__c, Object_Lookup__c FROM Contact_Dimension_Tag__c WHERE Visibility__c = 'Public' LIMIT 1];
        DimensionTagHelper.removeRequestTagRecord(contactTagPre.Id);

        Contact_Dimension_Tag__c contactTagPost = [SELECT Id, Request_for_Removal__c FROM Contact_Dimension_Tag__c WHERE Visibility__c = 'Public' LIMIT 1];
        System.assertEquals(true, contactTagPost.Request_for_Removal__c);

    }

    @IsTest
    public static void test_bulkCreateTagRecord(){

        Dimension_Tags__mdt dimTag = [SELECT Id, DeveloperName, Visibility__c FROM Dimension_Tags__mdt WHERE Object__c = 'Contact' AND Visibility__c = 'Public' LIMIT 1];
        List<Contact> contacts = [SELECT Id FROM Contact];

        SObject sobj = DimensionTagHelper.bulkCreateTagRecord(dimTag, contacts[0].Id,'Contact_Dimension_Tag__c');
        System.assertEquals(true, sobj != null);
    }


}