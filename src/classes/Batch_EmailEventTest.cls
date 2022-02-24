/**
 * Created by afaf.awad on 9/2/2020.
 */

@IsTest
private with sharing class Batch_EmailEventTest {
    @testSetup public static void setup() {

        List<OrgWideEmailAddress> owas = [SELECT Id FROM OrgWideEmailAddress LIMIT 1];
        insert new BrEvents_Settings__c(Name='org wide email id', Label__c = 'org wide email id', Value__c = owas[0].Id);

//        BR_Events_Zone__c zone = LiveTestDataFactory.buildZone('Test Zone', true);
//        insert zone;
//
//        Venue__c ven = LiveTestDataFactory.buildVenue('Test Venue');
//        insert ven;

        Account acc = TestDataFactory.buildAccount('Test Account');
        insert acc;

        List<Contact> contacts = new List<Contact>();
        for (Integer i = 0; i < 50; i++) {
            Contact con = TestDataFactory.buildContact(acc.Id);
            con.LastName = con.LastName + i;
            con.Email = 'testEmail' + i + '@yopmail.com';
            contacts.add(con);
        }
        insert contacts;

        EventApi__Event__c event = TestDataFactory.buildEvent();
        insert event;

        //Live Event and VMl Links are to accommodate AttendeeToParticipantTrigger
        BR_Event__c liveEVT = LiveTestDataFactory.buildEvent('Test Event', true, false);
        insert liveEVT;

        List<BR_Participation__c> participants = new List<BR_Participation__c>();

        for (Contact con : contacts) {
            participants.add(new BR_Participation__c(Contact__c = con.Id, BR_Event__c = liveEVT.Id, Participate__c = 'Yes'));
        }
        insert participants;

//        List<EventApi__Attendee__c> attendees = new List<EventApi__Attendee__c>();
//        for (Contact con : contacts) {
//            EventApi__Attendee__c att = new EventApi__Attendee__c(EventApi__Event__c = event.Id,
//                    EventApi__Contact__c = con.Id,
//                    EventApi__Full_Name__c = con.FirstName + ' ' + con.LastName);
//            attendees.add(att);
//        }
//
//        insert attendees;
    }

    @isTest
    public static void test_sendEmailEvent() {

//        List<EventApi__Event__c> event = [SELECT Id FROM EventApi__Event__c WHERE Name = 'Test Event'];
        List<BR_Event__c> event = [SELECT Id FROM BR_Event__c WHERE Name = 'Test Event'];


        Test.startTest();
        database.executeBatch(new Batch_EmailEvent(event[0].Id));
        Test.stopTest();

//        List<EventApi__Attendee__c> attendees = [SELECT ID FROM EventApi__Attendee__c WHERE EventApi__Event__r.Name = 'Test Event'];
//        System.assertEquals(200, attendees.size());
    }
}