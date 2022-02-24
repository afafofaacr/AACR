/**
 * Created by afaf.awad on 7/7/2021.
 */

@IsTest
private class DimensionTagModalControllerTest {
    @TestSetup
    public static void setup(){
        Account acc = TestDataFactory.buildAccount('Test Account');
        insert acc;

        Contact con = TestDataFactory.buildContact(acc.Id);
        insert con;

    }

    @IsTest
    public static void test_createDimTag(){
        Contact con = [SELECT Id FROM Contact LIMIT 1];
        DimensionTagModalController.createDimTag('Test Tag', 'Test tag description', 'Contact', 'Public', con.Id);
    }

    @IsTest
    public static void test_CreateTagRecord(){
        Contact con = [SELECT Id FROM Contact LIMIT 1];
        Dimension_Tags__mdt dimTag = [SELECT Id FROM Dimension_Tags__mdt WHERE Object__c = 'Contact' AND Visibility__c = 'Public' LIMIT 1];
        DimensionTagModalController.createTagRecord(dimTag.Id,  con.Id);

        List<Contact_Dimension_Tag__c> contactTags = [SELECT Id FROM Contact_Dimension_Tag__c WHERE Visibility__c = 'Public'];
        System.assertEquals(1, contactTags.size());
    }

    @IsTest
    public static void test_validateTagName(){
        Dimension_Tags__mdt dimTag = [SELECT Label, Id FROM Dimension_Tags__mdt WHERE Object__c = 'Contact' AND Visibility__c = 'Public' LIMIT 1];

        Boolean validateFalse = DimensionTagModalController.validateTagName(dimTag.Label);
        Boolean validateTrue = DimensionTagModalController.validateTagName('Test Tag');

        System.assertEquals(false, validateFalse);
        System.assertEquals(true, validateTrue);

    }
}