/**
 * Created by lauren.lezberg on 8/17/2020.
 */

@IsTest
private class SpeakerInviteEmailPreviewControllerTest {

    @testSetup
    public static void setup(){
        BR_Event__c event = LiveTestDataFactory.buildEvent('Test Event', false, false);
        event.Disclosure_Link__c = 'www.google.com';
        event.Invite_Message__c = 'TEST INVITE MESSAGE';
        insert event;
    }
    @IsTest
    static void test_getTemplateBody() {
        BR_Event__c evt = [SELECT Id FROM BR_Event__c WHERE Name='Test Event'];

        Test.startTest();

        String body = SpeakerInviteEmailPreviewController.getEmailTemplateBody(evt.Id);
        System.assertNotEquals(null, body);

        Test.stopTest();


    }
}