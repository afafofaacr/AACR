/**
 * Created by lauren.lezberg on 2/21/2020.
 */
@isTest
private with sharing class SpeakerInviteControllerTest {


    @testSetup public static void setup(){
        Account acc = LiveTestDataFactory.buildAccount('Test Account');
        insert acc;

        Contact con = LiveTestDataFactory.buildContact(acc.Id);
        insert con;

        BR_Event__c event = LiveTestDataFactory.buildEvent('Test Event', false, false);
        event.Disclosure_Link__c = 'www.google.com';
        event.Invite_Message__c = 'TEST INVITE MESSAGE';
        insert event;

        AACR_Session__c eventSession = LiveTestDataFactory.buildSession(event.Id, 'Test Session', Date.valueOf(event.Start_Date__c), Time.newInstance(11, 0, 0, 0), Time.newInstance(11, 30, 0, 0) );
        insert eventSession;

        Session_Speaker__c speaker = LiveTestDataFactory.buildSessionSpeaker(eventSession.Id, 'Test Presentation', con.Id);
        insert speaker;

    }


    @isTest public static void test_getJPID(){
        Join_Process__mdt jp = [SELECT Id FROM Join_Process__mdt WHERE DeveloperName='Speaker_Invitations'];

        Test.startTest();

        Id jpId = SpeakerInviteController.getSpeakerInviteJPId();

        System.assertEquals(jpId, jp.Id);
        Test.stopTest();
    }

    @isTest
    public static void test_getEmailTemplate(){
        BR_Event__c evt = [SELECT Id FROM BR_Event__c WHERE Name='Test Event'];

        Test.startTest();
        String response = SpeakerInviteController.getEmailTemplate(evt.Id);
        System.assertNotEquals(null, response);

        Boolean resp = SpeakerInviteController.updateEventAndPreview(evt.Id, 'TEST UPDATE', 'Test Sig 1', 'Test Sig 2', null, null, null, null);
        System.assertEquals(true, resp);
        Test.stopTest();
    }

    @isTest
    public static void test_sendSpeakerInvites(){
        BR_Event__c evt = [SELECT Id FROM BR_Event__c WHERE Name='Test Event'];
        List<Session_Speaker__c> speakers = [SELECT Id FROM Session_Speaker__c WHERE Session__r.Event__c=:evt.Id];
        List<String> speakerIds = new List<String>();
        for(Session_Speaker__c speaker : speakers){
            speakerIds.add(speaker.Id);
        }

        Test.startTest();
        SpeakerInviteController.sendSpeakerInvitations(evt.Id, speakerIds);

        Test.stopTest();

        speakers = [SELECT Id FROM Session_Speaker__c WHERE Session__r.Event__c=:evt.Id AND Status__c = 'Invited'];
        System.assertEquals(1, speakers.size());

    }


    @isTest
    public static void test_uploadImage(){
        BR_Event__c evt = [SELECT Id FROM BR_Event__c WHERE Name='Test Event'];

        Id mainfileId = CustomFileUploadController.saveChunk(evt.Id, 'Main Image File', EncodingUtil.base64Encode(Blob.valueOf('Testing 123..')), 'text/plain', '', 'Header Image');

        ContentVersion cv= [SELECT ContentDocumentId FROM ContentVersion WHERE Id=: mainfileId];

        Test.startTest();

        SpeakerInviteController.uploadDocImage(cv.ContentDocumentId, evt.Id);
        SpeakerInviteController.uploadDocImage(cv.ContentDocumentId, evt.Id);

        Test.stopTest();

    }

    @isTest
    public static void test_getInviteConfirmInfo(){
        BR_Event__c evt = [SELECT Id FROM BR_Event__c WHERE Name='Test Event'];

        Session_Speaker__c sp = [SELECT Id, Status__c FROM Session_Speaker__c];
        sp.Status__c = 'Pending';
        update sp;

        Test.startTest();
        List<Session_Speaker__c> info = SpeakerInviteController.getInviteConfirmInfo(evt.Id);
        System.assert(!info.isEmpty());

        Test.stopTest();
    }

    @isTest
    public static void test_setSpeakersToPending(){
        BR_Event__c evt = [SELECT Id FROM BR_Event__c WHERE Name='Test Event'];
        List<Session_Speaker__c> speakers = [SELECT Id, Name, Speaker__c, Speaker__r.Name, Speaker__r.Email, Roles__c FROM Session_Speaker__c WHERE Session__r.Event__c=:evt.Id];

        SpeakerInviteController.SessionSpeaker speaker = new SpeakerInviteController.SessionSpeaker(speakers[0].Speaker__r.Name, speakers[0].id, speakers[0].Name, speakers[0].Speaker__r.Email, speakers[0].Roles__c, null);
        List<SpeakerInviteController.SessionSpeaker> speakersToUpdate = new List<SpeakerInviteController.SessionSpeaker>{speaker};

        Test.startTest();
        Boolean result = SpeakerInviteController.setSpeakersToPending(JSON.serialize(speakersToUpdate));
        System.assertEquals(true, result);

        List<SpeakerInviteController.SessionSpeaker> sessionSpeakers = SpeakerInviteController.getSpeakers(evt.Id);
        System.assertEquals(speakers.size(), sessionSpeakers.size());
        Test.stopTest();



    }

}