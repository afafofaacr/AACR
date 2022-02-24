/**
 * Created by afaf.awad on 7/7/2021.
 */

@IsTest
private class DimensionTagDetailsControllerTest {
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

        Dimension_Tags__mdt contactDT = [SELECT Id FROM Dimension_Tags__mdt WHERE Object__c = 'Contact' AND Visibility__c = 'Public' LIMIT 1];
        SObject contactObj = DimensionTagHelper.createTagRecord(contactDT.Id,  con.Id);
        insert contactObj;

        Dimension_Tags__mdt accountDT = [SELECT Id FROM Dimension_Tags__mdt WHERE Object__c = 'Account' AND Visibility__c = 'Public' LIMIT 1];
        SObject accountObj = DimensionTagHelper.createTagRecord(accountDT.Id,  acc.Id);
        insert accountObj;

        Dimension_Tags__mdt leadDT = [SELECT Id FROM Dimension_Tags__mdt WHERE Object__c = 'Lead' AND Visibility__c = 'Public' LIMIT 1];
        SObject leadObj = DimensionTagHelper.createTagRecord(leadDT.Id,  lead.Id);
        leadObj.put('Conversion_Tag__c', contactObj.get('Id'));
        insert leadObj;

        contactObj.put('Conversion_Tag__c', leadObj.get('Id'));
        update contactObj;

        Dimension_Tags__mdt opportunityDT = [SELECT Id FROM Dimension_Tags__mdt WHERE Object__c = 'Opportunity' AND Visibility__c = 'Public' LIMIT 1];
        SObject opportunityObj = DimensionTagHelper.createTagRecord(opportunityDT.Id,  opp.Id);
        insert opportunityObj;

    }

    @IsTest
    public static void test_getDimTagDetails_Contact() {
        List<Contact_Dimension_Tag__c> contactTags = [SELECT Id, Dim_Tag_Id__c, Object_Lookup__c FROM Contact_Dimension_Tag__c WHERE Visibility__c = 'Public' LIMIT 1];

        DimensionTagDetailsController.DimTagDetails dtd = DimensionTagDetailsController.getDimTagDetails(contactTags[0].Dim_Tag_Id__c, 50, 1);
        System.assertEquals(1, dtd.unionTags.size());
    }

    @IsTest
    public static void test_getDimTagDetails_Lead() {
        List<Lead_Dimension_Tag__c> LeadTags = [SELECT Id, Dim_Tag_Id__c, Object_Lookup__c FROM Lead_Dimension_Tag__c WHERE Visibility__c = 'Public' LIMIT 1];

        DimensionTagDetailsController.DimTagDetails dtd = DimensionTagDetailsController.getDimTagDetails(LeadTags[0].Dim_Tag_Id__c, 50, 1);
        System.assertEquals(1, dtd.unionTags.size());
    }

    @IsTest
    public static void test_exportTagsContact() {

        Dimension_Tags__mdt contactDT = [SELECT Id FROM Dimension_Tags__mdt WHERE Object__c = 'Contact' AND Visibility__c = 'Public' LIMIT 1];

        DimensionTagDetailsController.ObjectExport objExportFull = DimensionTagDetailsController.exportTags('Contact', 'full', contactDT.Id );
        System.assertEquals(1, objExportFull.objectList.size());
        System.assertEquals(true, objExportFull.headers.size() > 5);

        DimensionTagDetailsController.ObjectExport objExportMarket = DimensionTagDetailsController.exportTags('Contact', 'market', contactDT.Id );
        System.assertEquals(1, objExportMarket.objectList.size());
        System.assertEquals(5, objExportMarket.headers.size());
    }

    @IsTest
    public static void test_exportTagsAccount() {

        Dimension_Tags__mdt accountDT = [SELECT Id FROM Dimension_Tags__mdt WHERE Object__c = 'Account' AND Visibility__c = 'Public' LIMIT 1];
        DimensionTagDetailsController.ObjectExport objExport = DimensionTagDetailsController.exportTags('Account', null, accountDT.Id);

        System.assertEquals(1, objExport.objectList.size());

    }


    @IsTest
    public static void test_exportTagsLead() {

        Dimension_Tags__mdt leadDT = [SELECT Id FROM Dimension_Tags__mdt WHERE Object__c = 'Lead' AND Visibility__c = 'Public' LIMIT 1];
        DimensionTagDetailsController.ObjectExport objExport = DimensionTagDetailsController.exportTags('Lead', null, leadDT.Id);

        System.assertEquals(1, objExport.objectList.size());
    }

    @IsTest
    public static void test_exportTagsOpportunity() {

        Dimension_Tags__mdt opportunityDT = [SELECT Id FROM Dimension_Tags__mdt WHERE Object__c = 'Opportunity' AND Visibility__c = 'Public' LIMIT 1];
        DimensionTagDetailsController.ObjectExport objExport = DimensionTagDetailsController.exportTags('Opportunity',null, opportunityDT.Id);
        System.debug('ObjectExport == ' + objExport);
        System.assertEquals(1, objExport.objectList.size());
    }

    @IsTest
    public static void test_logDownload(){

        Profile profile = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
        User user = TestDataFactory.buildTestUser(profile.Id, 'TestFirstName', 'TestLastName');
        insert user;

        DimensionTagDetailsController.logDownload('Contact', 'Test Tag Label', 'TestFimeName.csv', user.Id , 'ME');
        List<DTM_Activity_Log__c> dtmlog = [SELECT Id FROM DTM_Activity_Log__c];

        System.assertEquals(1, dtmlog.size());

    }
}