/**
 * Created by afaf.awad on 7/7/2021.
 */

@IsTest
private class ExportHelper_AccountTest {
    @IsTest
    public static void test_exportTagsAccount() {

        Account acc = TestDataFactory.buildAccount('Test Account');
        insert acc;

        Dimension_Tags__mdt DMT = [SELECT Id FROM Dimension_Tags__mdt WHERE Object__c = 'Account' AND Visibility__c = 'Public' LIMIT 1];
        SObject publicObj = DimensionTagHelper.createTagRecord(DMT.Id,  acc.Id);
        insert publicObj;

        ExportHelper_Account.AccountExport ae = ExportHelper_Account.queryAccounts(DMT.Id);

        System.assertEquals(1, ae.Accounts.size());
    }
}