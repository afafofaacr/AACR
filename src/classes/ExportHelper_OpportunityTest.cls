/**
 * Created by afaf.awad on 7/7/2021.
 */

@IsTest
private class ExportHelper_OpportunityTest {

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

        Dimension_Tags__mdt dmt = [SELECT Id FROM Dimension_Tags__mdt WHERE Object__c = 'Contact' AND Visibility__c = 'Public' LIMIT 1];
        SObject publicObj = DimensionTagHelper.createTagRecord(dmt.Id,  opp.Id);
        insert publicObj;

    }

    @IsTest
    public static void test_exportTagsOpportunity() {

        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
        Opportunity_Dimension_Tag__c odt = [SELECT Id, Dim_Tag_Id__c FROM Opportunity_Dimension_Tag__c LIMIT 1];

        ExportHelper_Opportunity.OpportunityExport oe = ExportHelper_Opportunity.queryOpportunities(odt.Dim_Tag_Id__c);
        System.assertEquals(1, oe.Opportunities.size());
    }
}