/**
 * Created by afaf.awad on 3/9/2021.
 */

@IsTest
public without sharing class EC_AccountInfoControllerTest {

    @testSetup public static void setup() {

        Account account = LiveTestDataFactory.buildAccount('Test Account');
        insert account;
        Contact contact = LiveTestDataFactory.buildContact(account.Id);
        insert contact;
        User user = TestDataFactory.buildUser(contact.Id);
        insert user;

        EC_Exhibitor_Setting__c ecSetting = new EC_Exhibitor_Setting__c(Company__c = account.Id);
        insert ecSetting;

    }

    @IsTest
    public static void test_getExhibitorSettings(){
        Contact con = [SELECT Id, AccountId FROM Contact WHERE Account.Name = 'Test Account' LIMIT 1];
        User user = [SELECT Id, ContactId FROM User WHERE ContactId =: con.Id];
        String ecSettingID = [SELECT Id FROM EC_Exhibitor_Setting__c LIMIT 1].Id;

        System.debug('Contact = ' + con);
        EC_AccountInfoController.ExhibitorSetting ecSetting;
        Test.startTest();
        system.runAs(user) {
            ecSetting = EC_AccountInfoController.getExhibitorSettings();// without cv
        }

//        EC_AccountInfoController.uploadLogoImage(ecSettingID,'', 'Logo Image File', EncodingUtil.base64Encode(Blob.valueOf('Testing 123..')), 'text/plain', 'Exhibitor Logo Image', '');
        
        system.runAs(user){
        ecSetting = EC_AccountInfoController.getExhibitorSettings(); //with cv
        }
        System.assertEquals(ecSettingID, ecSetting.exSet.Id);
        Test.stopTest();
    }

    @IsTest
    public static void test_verifyExhibitorEmail(){
        Contact con = [SELECT Id, AccountId FROM Contact LIMIT 1];
        User user = [SELECT Id, ContactId FROM User WHERE ContactId =: con.Id];
        EC_Exhibitor_Setting__c ecSetting = [SELECT Id FROM EC_Exhibitor_Setting__c LIMIT 1];
        system.runAs(user) {
            Boolean success = EC_AccountInfoController.verifyExhibitorEmail('testclass@aacr.org', ecSetting.Id);
            System.assertEquals(true, success);
        }
    }

//    @IsTest
//    public static void test_UploadLogoImage(){
//        EC_Exhibitor_Setting__c ecSetting = [SELECT Id FROM EC_Exhibitor_Setting__c LIMIT 1];
//
//        Test.startTest();
//        EC_AccountInfoController.uploadLogoImage(ecSetting.Id,'', 'Logo Image File', EncodingUtil.base64Encode(Blob.valueOf('Testing 123..')), 'text/plain', 'Exhibitor Logo Image', '');
//        EC_AccountInfoController.uploadLogoImage(ecSetting.Id,'', 'Logo Image File', EncodingUtil.base64Encode(Blob.valueOf('Testing 123..')), 'text/plain', 'Exhibitor Logo Image', '');
//        EC_AccountInfoController.removeFile('Logo Image File', ecSetting.Id);
//        Test.stopTest();
//    }

    @IsTest
    public static void test_updateExhibitorSigs(){
        EC_Exhibitor_Setting__c ecSetting = [SELECT Id FROM EC_Exhibitor_Setting__c LIMIT 1];

        Test.startTest();
        Boolean resp = EC_AccountInfoController.updateExhibitorSigs(ecSetting.Id, 'TEST UPDATE', 'Test Sig 1', 'Test Sig 2', 'Test Sig 3', 'Test Sig 4', 'Test Sig 5', 'Test Sig 6');
        System.assertEquals(true, resp);
        Test.stopTest();
    }



}