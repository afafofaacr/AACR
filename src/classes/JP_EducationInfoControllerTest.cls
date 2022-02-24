/**
 * Created by lauren.lezberg on 2/8/2019.
 */
@isTest
private with sharing class JP_EducationInfoControllerTest {
 
    @testSetup static void setup(){
        Account acc = TestDataFactory.buildAccount('Test Account');
        insert acc;
        Contact testContact = TestDataFactory.buildContactMemberCurrent(acc.Id);
        testContact.Salutation = 'Mr.';
        insert testContact;
        OrderApi__Item_Class__c itemClass = TestDataFactory.buildItemClass('Individual Memberships');
        insert itemClass;
        OrderApi__Item__c item = TestDataFactory.buildItem(itemClass.Id, 'Active Membership');
        insert item;

    }

    @IsTest
    public static void test_deferAndTransfer(){
        Contact testContact = [SELECT Id, AccountId FROM Contact LIMIT 1];

        OrderApi__Sales_Order__c so = TestDataFactory.buildOpenSalesOrder(testContact.AccountId, testContact.Id);
        insert so;

        Test.startTest();

        JP_EducationInfoController.deferAndTransfer(so.Id);

        Test.stopTest();

        so = [SELECT OrderApi__Status__c FROM OrderApi__Sales_Order__c WHERE Id=:so.Id];
        System.assertEquals('Cancelled', so.OrderApi__Status__c);

    }

    @IsTest
    public static void test_deferMember(){
        Contact testContact = [SELECT Id, AccountId FROM Contact LIMIT 1];

        Test.startTest();

        JP_EducationInfoController.deferMember(testContact.Id);

        Test.stopTest();
    }


    @isTest
    public static void testGetEducationData(){
        Contact testContact = [SELECT Id FROM Contact LIMIT 1];
        User u = TestDataFactory.buildUser(testContact.Id);
        insert u;
        Education__c educationRecord = new Education__c();
        educationRecord.Education_Related_to_Contact__c = testContact.Id;
        educationRecord.Current_Education_Status__c = 'Undergraduate';
        educationRecord.Degree__c = 'BS';
        educationRecord.Degree_Completion_Year__c = '2019';
        educationRecord.Name='Test Education';
        insert educationRecord;
        System.assertNotEquals(null, educationRecord);

        Join_Process__mdt jp = [SELECT Id FROM Join_Process__mdt WHERE Item__c LIKE: '%Active Membership%' AND Is_Renewal__c = false];
        Process_Steps__mdt step = [SELECT Id FROM Process_Steps__mdt WHERE Process__c =: jp.Id AND Join_Step__r.DeveloperName ='Journal_Selections'];

        System.runAs(u) {
            JP_EducationInfoController.EducationData eData = JP_EducationInfoController.getEducationData(step.Id);

            System.assertNotEquals(null, eData);
            System.assertEquals(testContact.Id, eData.contactId);

            JP_EducationInfoController.deleteEducation(educationRecord);
            Integer records = [SELECT COUNT() FROM Education__c WHERE Education_Related_to_Contact__c =: testContact.Id];
            System.assertEquals(0, records);
        }
    }

}