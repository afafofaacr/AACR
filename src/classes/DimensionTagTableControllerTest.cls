/**
 * Created by afaf.awad on 7/7/2021.
 */

@IsTest
private class DimensionTagTableControllerTest {
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
    public static void test_getDimTagInfo(){
        List<String> objFilters = new List<String>{'Contact','Account', 'Lead', 'Opportunity'};

        for(String obj: objFilters) {

            Dimension_Tags__mdt publicDT = [SELECT Id, Label FROM Dimension_Tags__mdt WHERE Object__c =: obj AND Visibility__c = 'Public' LIMIT 1];
            List<DimensionTagTableController.DimTagInfo> publicDimTags = DimensionTagTableController.getDimTagInfo('Public', JSON.serialize(objFilters), publicDT.Label);
            System.assertEquals(1, publicDimTags.size());

            Dimension_Tags__mdt privateDT = [SELECT Id, Label FROM Dimension_Tags__mdt WHERE Object__c=: obj AND Visibility__c = 'Private' LIMIT 1];
            List<DimensionTagTableController.DimTagInfo> privateDimTags = DimensionTagTableController.getDimTagInfo('Private', JSON.serialize(objFilters), privateDT.Label);
//        System.assertEquals(1, privateDimTags.size());
        }

    }
}