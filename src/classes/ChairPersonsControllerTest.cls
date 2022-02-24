/**
 * Created by lauren.lezberg on 2/21/2020.
 */
@isTest
private with sharing class ChairPersonsControllerTest {

    @testSetup public static void setup(){
        Account acc = LiveTestDataFactory.buildAccount('Test Account');
        insert acc;

        Contact con = LiveTestDataFactory.buildContact(acc.Id);
        insert con;

        BR_Event__c event = LiveTestDataFactory.buildEvent('Test Event', false, false);
        insert event;

        AACR_Session__c eventSession = LiveTestDataFactory.buildSession(event.Id, 'Test Session', Date.valueOf(event.Start_Date__c), Time.newInstance(11, 0, 0, 0), Time.newInstance(11, 30, 0, 0) );
        insert eventSession; 

        Id cpRecordTypeId = Schema.SObjectType.Session_Speaker__c.getRecordTypeInfosByName().get('Chair Person').getRecordTypeId();
        Session_Speaker__c speaker = LiveTestDataFactory.buildSessionSpeaker(eventSession.Id, 'Test Presentation', con.Id);
        speaker.Roles__c = 'Chair';
        speaker.Event__c = event.Id;
        speaker.RecordTypeId = cpRecordTypeId;
        insert speaker;
    }

    @isTest
    public static void test_getChairPersons(){
        Id cpRecordTypeId = Schema.SObjectType.Session_Speaker__c.getRecordTypeInfosByName().get('Chair Person').getRecordTypeId();
        String eventId = [SELECT Id FROM BR_Event__c LIMIT 1].Id;

        Test.startTest();
        ChairPersonsController.ChairPersonsData cpd = ChairPersonsController.getChairPersonsData(eventId);
        System.assertNotEquals(null, cpd);
        System.assertEquals(1, cpd.persons.size());
        System.assertEquals(cpRecordTypeId, cpd.cpRecordTypeId);

        cpd = ChairPersonsController.getChairPersonsData(null);
        System.assertEquals(null, cpd);

        Test.stopTest();



    }

    @isTest
    public static void test_deleteChairPerson(){
        Id cpRecordTypeId = Schema.SObjectType.Session_Speaker__c.getRecordTypeInfosByName().get('Chair Person').getRecordTypeId();
        String eventId = [SELECT Id FROM BR_Event__c LIMIT 1].Id;

        Test.startTest();
        ChairPersonsController.ChairPersonsData cpd = ChairPersonsController.getChairPersonsData(eventId);

        ChairPersonsController.deleteChairperson(cpd.persons[0].Id);

        Test.stopTest();
    }
}