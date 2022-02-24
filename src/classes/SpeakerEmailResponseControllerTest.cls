/**
 * Created by lauren.lezberg on 2/21/2020.
 */
@isTest
private with sharing class SpeakerEmailResponseControllerTest {

    @testSetup public static void setup(){
        Account acc = LiveTestDataFactory.buildAccount('Test Account');
        insert acc;

        Contact con = LiveTestDataFactory.buildContact(acc.Id);
        insert con;

        BR_Event__c event = LiveTestDataFactory.buildEvent('Test Event', false, false); 
        event.Disclosure_Link__c = 'www.google.com';
        insert event;

        AACR_Session__c eventSession = LiveTestDataFactory.buildSession(event.Id, 'Test Session', Date.valueOf(event.Start_Date__c), Time.newInstance(11, 0, 0, 0), Time.newInstance(11, 30, 0, 0) );
        insert eventSession;

        Session_Speaker__c speaker = LiveTestDataFactory.buildSessionSpeaker(eventSession.Id, 'Test Presentation', con.Id);
        insert speaker;

        List<OrgWideEmailAddress> emailAddresses = [
                SELECT Id, Address
                FROM OrgWideEmailAddress
                LIMIT 1
        ];

        BrEvents_Settings__c setting = new BrEvents_Settings__c();
        setting.Name = 'org wide email id';
        setting.Value__c = emailAddresses[0].Id;
        insert setting;

    }

    @isTest public static void test_setSpeakerResponse(){
        Session_Speaker__c speaker = [SELECT Id FROM Session_Speaker__c WHERE Name='Test Presentation'];

        Test.startTest();

        SpeakerEmailResponseController.SpeakerResponseInfo respInfo = SpeakerEmailResponseController.setSpeakerResponse(true, speaker.Id);
        System.assertEquals(respInfo.disclosureLink, 'www.google.com');

        speaker = [SELECT Status__c FROM Session_Speaker__c WHERE Id=: speaker.Id LIMIT 1];
        System.assertEquals('Accepted', speaker.Status__c);

        respInfo = SpeakerEmailResponseController.setSpeakerResponse(false, speaker.Id);

        speaker = [SELECT Status__c FROM Session_Speaker__c WHERE Id=: speaker.Id LIMIT 1];
        System.assertEquals('Declined', speaker.Status__c);

        Test.stopTest();
    }

}