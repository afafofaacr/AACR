/**
 * Created by lauren.lezberg on 8/17/2020.
 */
@isTest
private with sharing class SpeakerInviteHelperTest {

    @testsetup
    public static void setup(){
        Venue__c ven = new Venue__c(Name='Test Venue');
        insert ven;

        BR_Event__c event = LiveTestDataFactory.buildEvent('Test Event', false, false);
        event.Venue__c = ven.Id;
        insert event;
        
    }

    @isTest
    public static void test_getDocRelativeLink(){
        Folder fold = [SELECT Id FROM Folder WHERE Name='AACR Event Images'];

        Document doc = new Document();
        doc.FolderId = fold.Id;
        doc.Body = Blob.valueOf('aljdhflakjsfhlkasjdf');
        doc.Name='Test Doc';
        insert doc;


        Test.startTest();

        String link = SpeakerInviteHelper.getDocumentRelativeLink(doc.Id);
        System.assertNotEquals(null, link);

        Test.stopTest();

    }

    @isTest
    public static void test_buildTemplateMessage(){
        Account acc = TestDataFactory.buildAccount('Test Account');
        insert acc;

        Contact con = TestDataFactory.buildContact(acc.Id);
        insert con;

        BR_Event__c event = [SELECT Id, Start_Date__c FROM BR_Event__c WHERE Name='Test Event'];



        AACR_Session__c eventSession = LiveTestDataFactory.buildSession(event.Id, 'Test Session', Date.valueOf(event.Start_Date__c), Time.newInstance(11, 0, 0, 0), Time.newInstance(11, 30, 0, 0) );
        insert eventSession;

        Id cpRecordTypeId = Schema.SObjectType.Session_Speaker__c.getRecordTypeInfosByName().get('Chair Person').getRecordTypeId();
        Session_Speaker__c speaker = LiveTestDataFactory.buildSessionSpeaker(eventSession.Id, 'Test Presentation', con.Id);
        speaker.Use_for_Invite__c = true;
        speaker.Roles__c = 'Chair';
        speaker.Event__c = event.Id;
        speaker.RecordTypeId = cpRecordTypeId;
        insert speaker;

        Contact con2 = new Contact(AccountId=acc.Id, FirstName='Chairsy', LastName='Person', Email='chairPerson@yopmail.com');
        insert con2;

        speaker = LiveTestDataFactory.buildSessionSpeaker(eventSession.Id, 'Test Presentation2', con2.Id);
        speaker.Use_for_Invite__c = true;
        speaker.Roles__c = 'Chair';
        speaker.Event__c = event.Id;
        speaker.RecordTypeId = cpRecordTypeId;
        insert speaker;

        Test.startTest();

        String body = SpeakerInviteHelper.buildEventInviteTemplate(event.id, 'Test Invite Message');
        System.assertNotEquals(null, body);

        Test.stopTest();
    }


}