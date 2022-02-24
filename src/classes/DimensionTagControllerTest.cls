/**
 * Created by afaf.awad on 7/6/2021.
 */

@IsTest
private class DimensionTagControllerTest {

    @TestSetup
    public static void setup(){
        Account acc = TestDataFactory.buildAccount('Test Account');
        insert acc;

        Contact con = TestDataFactory.buildContact(acc.Id);
        insert con;

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

    }

    @IsTest
    public static void test_getDimTags(){

        List<Contact_Dimension_Tag__c> cdt = [SELECT Id FROM Contact_Dimension_Tag__c];
        Contact con = [SELECT Id FROM Contact WHERE AccountId IN (SELECT Id FROM Account WHERE Name = 'Test Account') LIMIT 1];
        System.debug('contact Tags = ' + cdt);
        List<DimensionTagController.DimTagInfo> dimTagInfo = DimensionTagController.getDimTags(con.Id);
        System.debug('DimTagInfo TEST = ' + dimTagInfo);
        System.assertEquals(2,dimTagInfo.size());

    }

    @IsTest
    public static void test_searchTags(){
        List<Contact_Dimension_Tag__c> contactTags = [SELECT Id, Dim_Tag_Id__c, Object_Lookup__c  FROM Contact_Dimension_Tag__c WHERE Visibility__c='Public' LIMIT 1];
        Dimension_Tags__mdt dt = [SELECT Id, Label FROM Dimension_Tags__mdt WHERE Id !=: contactTags[0].Dim_Tag_Id__c AND Object__c = 'Contact' AND Visibility__c='Public' LIMIT 1];
        System.debug('dt to test == ' + dt);
        List<Dimension_Tags__mdt> dimTags = DimensionTagController.searchTags(dt.Label, 'Contact', contactTags[0].Object_Lookup__c);

        System.assertEquals(1, dimTags.size());

    }

    @IsTest
    public static void test_createTagRecord() {
        Account acc = [SELECT Id FROM Account LIMIT 1];

        List<Dimension_Tags__mdt> dt = [SELECT Id FROM Dimension_Tags__mdt WHERE Object__c = 'Account' AND Visibility__c = 'Public' LIMIT 1];

        SObject obj = DimensionTagController.createTagRecord(dt[0].Id,  acc.Id);

        System.assertEquals(acc.Id, obj.get('Object_Lookup__c'));

    }

    @IsTest
    public static void test_removeTagRecord(){

        List<Contact_Dimension_Tag__c> contactTagsPre = [SELECT Id, Dim_Tag_Id__c, Object_Lookup__c, Visibility__c  FROM Contact_Dimension_Tag__c];

        for(Contact_Dimension_Tag__c cdt : contactTagsPre) {
            DimensionTagController.removeTagRecord(cdt.Dim_Tag_Id__c, cdt.Object_Lookup__c, cdt.Visibility__c);
        }

        List<Contact_Dimension_Tag__c> contactTagsPost = [SELECT Id, Dim_Tag_Id__c, Object_Lookup__c, Visibility__c  FROM Contact_Dimension_Tag__c];
        System.assertEquals(1, contactTagsPost.size());

    }

    @IsTest
    public static void test_getReportURL(){

        Dimension_Tags__mdt dt = [SELECT Id FROM Dimension_Tags__mdt WHERE Object__c = 'Contact' LIMIT 1];

        String url = DimensionTagController.getReportURL(dt.Id, 'Contact');

        System.assertEquals(true, url.contains(dt.Id));

    }

}