/**
 * Created by lauren.lezberg on 3/14/2019.
 */
@isTest
private with sharing class JP_PersonalInfoControllerTest {

    @testSetup static void setup(){
        Account acc = TestDataFactory.buildAccount('Test Account');
        insert acc;
        Contact testContact = TestDataFactory.buildContactMemberCurrent(acc.Id);
        insert testContact;
        User u = TestDataFactory.buildUser(testContact.Id);
        insert u;
    }

    @isTest static void test_getCurrentContact(){
        Contact con = [SELECT Id, AccountId FROM Contact LIMIT 1];
        User u = [SELECT Id FROM User WHERE ContactId=: con.Id];
        System.runAs(u){
            Contact con2 = JP_PersonalInfoController.getCurrentContact();

            System.assertEquals(con.Id, con2.Id);
        }
    }


    @isTest static void test_getPersonalInfo(){
        Contact con = [SELECT Id FROM Contact LIMIT 1];
        con.Birthdate = Date.newInstance(1987, 9, 27);
        update con;
        User u = [SELECT Id FROM User WHERE ContactId=: con.Id];
        Join_Process__mdt jp = [SELECT Id FROM Join_Process__mdt WHERE DeveloperName='myAACR_Registration' LIMIT 1];
        System.runAs(u){
            JP_PersonalInfoController.PersonalInfo personalInfo = JP_PersonalInfoController.getPersonalInfo(jp.Id);
            System.assertNotEquals(null, personalInfo);
        }
    }

    @IsTest static void test_setContactAccount(){
        Contact con = [SELECT Id FROM Contact LIMIT 1];

        Test.startTest();

        JP_PersonalInfoController.setContactAccount(con.Id, null);

        Test.stopTest();
    }

    @IsTest static void test_getStates(){
        Contact con = [SELECT Id FROM Contact LIMIT 1];
        User u = [SELECT Id FROM User WHERE ContactId=: con.Id];

        System.runAs(u) {
            Test.startTest();
            Map<String, String> states = JP_PersonalInfoController.getStates('US', 'US', 'US');
            System.assertNotEquals(null, states);
            Test.stopTest();
        }
    }


}