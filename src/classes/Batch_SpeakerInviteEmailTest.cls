/**
 * Created by lauren.lezberg on 2/20/2020.
 */
@isTest
private with sharing class Batch_SpeakerInviteEmailTest {


    @testSetup public static void setup(){
        Account acc = LiveTestDataFactory.buildAccount('Test Account');
        insert acc;

        Contact con = LiveTestDataFactory.buildContact(acc.Id);
        insert con;

        Contact assistant = LiveTestDataFactory.buildAssistant(acc.Id); 
        insert assistant;

//        npe4__Relationship__c assistRelationship = LiveTestDataFactory.buildAssistantRelationship(con.Id, assistant.Id);
//        insert assistRelationship;

        BR_Event__c event = LiveTestDataFactory.buildEvent('Test Event', false, false);
        insert event;

        AACR_Session__c eventSession = LiveTestDataFactory.buildSession(event.Id, 'Test Session', Date.valueOf(event.Start_Date__c), Time.newInstance(11, 0, 0, 0), Time.newInstance(11, 30, 0, 0) );
        insert eventSession;

        Session_Speaker__c speaker = LiveTestDataFactory.buildSessionSpeaker(eventSession.Id, 'Test Presentation', con.Id);
        insert speaker;
    }

    @isTest
    public static void test_sendSpeakerInvites(){
        BR_Event__c evt = [SELECT Id FROM BR_Event__c WHERE Name ='Test Event'];
        List<Session_Speaker__c> speakers = [SELECT ID FROM Session_Speaker__c WHERE Session__r.Event__c =: evt.Id];
        List<String> speakerIds = new List<STring>();
        for(Session_Speaker__c speaker : speakers){
            speakerIds.add(speaker.Id);
        }

        Test.startTest();
        database.executeBatch(new Batch_SpeakerInviteEmail(speakerIds, evt.Id), 1);
        Test.stopTest();

        speakers = [SELECT ID FROM Session_Speaker__c WHERE Session__r.Event__r.Name = 'Test Event' AND Status__c = 'Invited'];
        System.assertEquals(1, speakers.size());

    }
}