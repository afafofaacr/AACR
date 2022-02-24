/**
 * Created by lauren.lezberg on 2/20/2020.
 */
@isTest
private with sharing class EventScheduleViewerControllerTest {

    @testSetup public static void setup(){
        Account acc = LiveTestDataFactory.buildAccount('Test Account');
        insert acc;

        Contact con = LiveTestDataFactory.buildContact(acc.Id);
        insert con;

        BR_Event__c event = LiveTestDataFactory.buildEvent('Test Event', false, false);
        insert event;


    }

    @isTest
    public static void test_getEventSchedule(){
        Contact con = [SELECT Id FROM Contact LIMIT 1];
        BR_Event__c event  = [SELECT id, Start_Date__c, End_Date__c FROM  BR_Event__c WHERE Name='Test Event'];

        Test.startTest();
        EventScheduleViewerController.ScheduleData eventSched = EventScheduleViewerController.getEventSchedule(event.Id);
        System.assertNotEquals(null, eventSched);

        AACR_Session__c eventSession = LiveTestDataFactory.buildSession(event.Id, 'Test Session', Date.valueOf(event.Start_Date__c), Time.newInstance(11, 0, 0, 0), Time.newInstance(11, 30, 0, 0) );
        insert eventSession;

        Session_Speaker__c speaker = LiveTestDataFactory.buildSessionSpeaker(eventSession.Id, 'Test Presentation', con.Id);
        insert speaker;

        eventSched = EventScheduleViewerController.getEventSchedule(event.Id);
        System.assertNotEquals(null, eventSched);

        Test.stopTest();


    }
}