/**
 * Created by lauren.lezberg on 4/12/2021.
 */

@IsTest
private class V_VFairsIntegrationTest {
    @TestSetup
    public static void setup(){
        Account acc = TestDataFactory.buildAccount('Test Account');
        insert acc;

        Contact con = TestDataFactory.buildContact(acc.Id);
        con.FirstName = 'Testy';
        insert con;

        User u = TestDataFactory.buildUser(con.Id);
        insert u;

        Id virtualRecTypeId = Schema.SObjectType.Venue__c.getRecordTypeInfosByName().get('Virtual').getRecordTypeId();
        Venue__c ven = new Venue__c(Name='Test Venue');
        ven.Base_URL__c = 'https://www.google.com/';
        ven.RecordTypeId=virtualRecTypeId;
        insert ven;

        BR_Event__c event = LiveTestDataFactory.buildEvent('Test Event', false, false);
        event.Virtual_Venue__c = ven.Id;
        insert event;

        Virtual_Event_Details__c ved = new Virtual_Event_Details__c();
        ved.External_Event_Id__c = '12345';
        ved.Event__c = event.Id;
        insert ved;

        BR_Participation__c participation = new BR_Participation__c(BR_Event__c=event.Id, User__c=u.Id, Contact__c=con.Id, External_Attendee_Id__c = '12345');
        insert participation;

        vFairs_Session__c vSession = new vFairs_Session__c();
        vSession.API_Key__c = '3485723458720398457';
        insert vSession;

    }

    @IsTest
    static void testSendAttendee() {
        Contact con = [SELECT Id FROM Contact LIMIT 1];
        Callable extension = (Callable) Type.forName('V_VFairsIntegration').newInstance();

        String att = String.valueOf(extension.call('sendAttendee', new Map<String, Object>{'contactId'=>con.Id, 'externalEventId'=>null, 'flag'=>false}));
        System.assertEquals(null, att);

        V_SlidoIntegration s = new V_SlidoIntegration();
        s.sendAttendee(null, null, null);

    }

    @IsTest
    static void testUpdateAttendee() {
        Contact con = [SELECT Id FROM Contact LIMIT 1];
        Callable extension = (Callable) Type.forName('V_VFairsIntegration').newInstance();

        String att = String.valueOf(extension.call('updateAttendee', new Map<String, Object>{'participantId'=>null}));
        System.assertEquals(null, att);

        V_SlidoIntegration.updateAttendee(null);

    }

    @IsTest
    static void testDeleteAttendee() {
        Contact con = [SELECT Id FROM Contact LIMIT 1];
        Callable extension = (Callable) Type.forName('V_VFairsIntegration').newInstance();

        String att = String.valueOf(extension.call('deleteAttendee', new Map<String, Object>{'fuzionAttendeeId'=>'123', 'fuzionEventId'=> '456'}));
        System.assertEquals(null, att);

        V_SlidoIntegration.deleteAttendee(null, null);

    }

    @IsTest
    static void testAsyncSendAttendee() {
        Contact con = [SELECT Id FROM Contact LIMIT 1];
        Callable extension = (Callable) Type.forName('V_VFairsIntegration').newInstance();

        extension.call('asyncSendAttendee', new Map<String, Object>{'contactId'=>con.Id, 'externalEventId'=>null, 'flag'=>false});

        V_SlidoIntegration.asyncSendAttendee(null, null, null);
    }

    @IsTest
    static void testGoToVenue() {
        Contact con = [SELECT Id FROM Contact LIMIT 1];
        BR_Event__c evt = [SELECT Id FROM BR_Event__c WHERE Name='Test Event'];

        Test.setMock(HttpCalloutMock.class, new CreateMockHttpResponseGenerator());

        Callable extension = (Callable) Type.forName('V_VFairsIntegration').newInstance();

        String url = String.valueOf(extension.call('goToVenue', new Map<String, Object>{'contactId'=>con.Id, 'SFEventId'=>evt.Id}));
        System.assertNotEquals(null, url);

    }

    public class CreateMockHTTPResponseGenerator implements HttpCalloutMock{
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('[{"autologin_url": "https://www.login.com"}]');
            res.setStatusCode(200);
            return res;
        }
    }
}