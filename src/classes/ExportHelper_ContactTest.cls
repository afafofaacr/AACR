/**
 * Created by afaf.awad on 7/7/2021.
 */

@IsTest
private class ExportHelper_ContactTest {

    @TestSetup
    public static void setup() {
        Account acc = TestDataFactory.buildAccount('Test Account');
        insert acc;

        Contact con = TestDataFactory.buildContact(acc.Id);
        insert con;

        OrderApi__Badge_Type__c badgeType = TestDataFactory.buildBadgeType('WICR - Women in Cancer Research');
        insert badgeType;

        OrderApi__Badge__c badge = TestDataFactory.buildBadge(badgeType.Id, con.Id);
        insert badge;

        Dimension_Tags__mdt dmt = [SELECT Id FROM Dimension_Tags__mdt WHERE Object__c = 'Contact' AND Visibility__c = 'Public' LIMIT 1];
        SObject publicObj = DimensionTagHelper.createTagRecord(dmt.Id,  con.Id);
        insert publicObj;

    }

    @IsTest
    public static void test_queryContacts_full() {

        Contact con = [SELECT Id FROM Contact LIMIT 1];
        Contact_Dimension_Tag__c cdt = [SELECT Id, Dim_Tag_Id__c FROM Contact_Dimension_Tag__c LIMIT 1];

        ExportHelper_Contact.ContactExport ce = ExportHelper_Contact.queryContacts_full(cdt.Dim_Tag_Id__c);

        System.assertEquals(1, ce.Contacts.size());
    }

    @IsTest
    public static void queryContacts_market() {
        Contact con = [SELECT Id FROM Contact LIMIT 1];
        Contact_Dimension_Tag__c cdt = [SELECT Id, Dim_Tag_Id__c FROM Contact_Dimension_Tag__c LIMIT 1];

        ExportHelper_Contact.ContactExport ce = ExportHelper_Contact.queryContacts_market(cdt.Dim_Tag_Id__c);

        System.assertEquals(1, ce.Contacts.size());
    }
}