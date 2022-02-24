/**
 * Created by lauren.lezberg on 2/4/2019.
 */
@isTest 
private with sharing class JP_ScientificInterestsControllerTest {


    @testSetup static void setup() {
        Account acc = TestDataFactory.buildAccount('Test Account');
        insert acc;
        Contact testContact = TestDataFactory.buildContactMemberCurrent(acc.Id);
        insert testContact;
        User u = TestDataFactory.buildUser(testContact.Id);
        insert u;
        OrderApi__Item_Class__c itemClass = TestDataFactory.buildItemClass('Individual Memberships');
        insert itemClass;
        OrderApi__Item__c item = TestDataFactory.buildItem(itemClass.Id, 'Active Membership');
        insert item;

    }

    @isTest
    public static void testInitialize(){

        Test.startTest();
        JP_ScientificInterestsController controller = new JP_ScientificInterestsController();
        Test.stopTest();

        System.assertNotEquals(controller, null);

    }

    @isTest
    public static void testGetScientificInterestData(){
        Join_Process__mdt jp = [SELECT Id FROM Join_Process__mdt WHERE Item__c LIKE: '%Active Membership%' AND Is_Renewal__c = false];
        Process_Steps__mdt step = [SELECT Id, Step_Order__c FROM Process_Steps__mdt WHERE Process__c =: jp.Id AND Join_Step__r.DeveloperName ='Scientific_Interest'];

        Test.startTest();
        JP_ScientificInterestsController.scientificInterestData scientificInterestData = JP_ScientificInterestsController.getScientificInterestData(step.Id);
        Test.stopTest();

        System.assertNotEquals(null, scientificInterestData);
    }


    @isTest
    public static void testUpsertContact(){
        Contact testContact = [SELECT Id FROM Contact LIMIT 1];
        Join_Process__mdt jp = [SELECT Id FROM Join_Process__mdt WHERE Item__c LIKE: '%Active Membership%' AND Is_Renewal__c = false];
        Process_Steps__mdt step = [SELECT Id, Step_Order__c FROM Process_Steps__mdt WHERE Process__c =: jp.Id AND Join_Step__r.DeveloperName ='Scientific_Interest'];

        User u = [SELECT Id FROM User WHERE ContactId =: testContact.Id];

        Test.startTest();
        System.runAs(u){
            testContact.Major_Focus__c = 'Basic Research';
            Boolean updateComplete = JP_ScientificInterestsController.updateContactRecord(testContact);

            Contact updatedCon = [SELECT Major_Focus__c FROM Contact WHERE Id=: testContact.Id];

            System.assertEquals(updateComplete, true);
            System.assertEquals(updatedCon.Major_Focus__c, 'Basic Research');
        }
        Test.stopTest();
    }
}