/**
 * Created by lauren.lezberg on 4/28/2021.
 */

@IsTest
private class V_SimpleHTMLRedirectTest {
    @TestSetup
    public static void setup(){
        Account acc = TestDataFactory.buildAccount('Test Account');
        insert acc;

        Contact con = TestDataFactory.buildContact(acc.Id);
        insert con;

        Id virtualRecTypeId = Schema.SObjectType.Venue__c.getRecordTypeInfosByName().get('Virtual').getRecordTypeId();
        Venue__c ven = new Venue__c(Name='Test Venue');
        ven.Base_URL__c = 'https://www.google.com/';
        ven.RecordTypeId=virtualRecTypeId;
        insert ven;

        BR_Event__c event = LiveTestDataFactory.buildEvent('Test Event', false, false);
        event.Virtual_Venue__c = ven.Id;
        insert event;

        Virtual_Event_Details__c ved = new Virtual_Event_Details__c();
        ved.Custom_URL__c= 'https://www.google.com/12345';
        ved.Event__c = event.Id;
        insert ved;

    }

    @IsTest
    static void testSendAttendee() {
        Contact con = [SELECT Id FROM Contact LIMIT 1];
        Callable extension = (Callable) Type.forName('V_SimpleHTMLRedirect').newInstance();

        String att = String.valueOf(extension.call('sendAttendee', new Map<String, Object>{'contactId'=>con.Id, 'externalEventId'=>null, 'flag'=>false}));
        System.assertEquals(null, att);

        V_SimpleHTMLRedirect s = new V_SimpleHTMLRedirect();
        s.sendAttendee(null, null, null);

    }

    @IsTest
    static void testUpdateAttendee() {
        Contact con = [SELECT Id FROM Contact LIMIT 1];
        Callable extension = (Callable) Type.forName('V_SimpleHTMLRedirect').newInstance();

        String att = String.valueOf(extension.call('updateAttendee', new Map<String, Object>{'participantId'=>null}));
        System.assertEquals(null, att);

        V_SimpleHTMLRedirect.updateAttendee(null);

    }

    @IsTest
    static void testDeleteAttendee() {
        Contact con = [SELECT Id FROM Contact LIMIT 1];
        Callable extension = (Callable) Type.forName('V_SimpleHTMLRedirect').newInstance();

        String att = String.valueOf(extension.call('deleteAttendee', new Map<String, Object>{'fuzionAttendeeId'=>'123', 'fuzionEventId'=> '456'}));
        System.assertEquals(null, att);

        V_SimpleHTMLRedirect.deleteAttendee(null, null);

    }

    @IsTest
    static void testAsyncSendAttendee() {
        Contact con = [SELECT Id FROM Contact LIMIT 1];
        Callable extension = (Callable) Type.forName('V_SimpleHTMLRedirect').newInstance();

        extension.call('asyncSendAttendee', new Map<String, Object>{'contactId'=>con.Id, 'externalEventId'=>null, 'flag'=>false});

        V_SimpleHTMLRedirect.asyncSendAttendee(null, null, null);
    }

    @IsTest
    static void testGoToVenue() {
        Contact con = [SELECT Id FROM Contact LIMIT 1];
        BR_Event__c evt = [SELECT Id FROM BR_Event__c WHERE Name='Test Event'];

        Callable extension = (Callable) Type.forName('V_SimpleHTMLRedirect').newInstance();

        String url = String.valueOf(extension.call('goToVenue', new Map<String, Object>{'contactId'=>con.Id, 'SFEventId'=>evt.Id}));
        System.assertEquals('https://www.google.com/12345', url);

    }
}