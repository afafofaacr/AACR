/**
 * Created by lauren.lezberg on 9/29/2020.
 */

@IsTest
private class V_ZoomIntegrationTest {
    @TestSetup
    public static void setup(){
        Account acc = TestDataFactory.buildAccount('Test Account');
        insert acc;

        Contact con = TestDataFactory.buildContact(acc.Id);
        insert con;

        Id virtualRecTypeId = Schema.SObjectType.Venue__c.getRecordTypeInfosByName().get('Virtual').getRecordTypeId();
        Venue__c ven = new Venue__c(Name='Test Venue');
        ven.Base_URL__c = 'https://aacr.zoom.us/j/';
        ven.RecordTypeId=virtualRecTypeId;
        insert ven;

        BR_Event__c event = LiveTestDataFactory.buildEvent('Test Event', false, false);
        event.Virtual_Venue__c = ven.Id;
        insert event;

        insert new Zoom_Session__c(Client_Id__c = '92348u34', Client_Secret__c='4580568406856');

        Virtual_Event_Details__c ved = new Virtual_Event_Details__c();
        ved.External_Event_Id__c = '12345';
        ved.Event__c = event.Id;
        ved.Zoom_Type__c='Meeting';
        ved.Zoom_User_Id__c='5555';
        insert ved;

    }

    @IsTest
    static void testSendAttendee() {
        Contact con = [SELECT Id FROM Contact LIMIT 1];
        Callable extension = (Callable) Type.forName('V_ZoomIntegration').newInstance();

        String att = String.valueOf(extension.call('sendAttendee', new Map<String, Object>{'contactId'=>con.Id, 'externalEventId'=>null, 'flag'=>false}));
        System.assertEquals(null, att);

    }

    @IsTest
    static void testAsyncSendAttendee() {
        Contact con = [SELECT Id FROM Contact LIMIT 1];
        Callable extension = (Callable) Type.forName('V_ZoomIntegration').newInstance();

        extension.call('asyncSendAttendee', new Map<String, Object>{'contactId'=>con.Id, 'externalEventId'=>null, 'flag'=>false});

    }

    @IsTest
    static void testGoToVenue() {
        Contact con = [SELECT Id FROM Contact LIMIT 1];
        BR_Event__c evt = [SELECT Id FROM BR_Event__c WHERE Name='Test Event'];

        Callable extension = (Callable) Type.forName('V_ZoomIntegration').newInstance();

        String url = String.valueOf(extension.call('goToVenue', new Map<String, Object>{'contactId'=>con.Id, 'SFEventId'=>evt.Id}));
        System.assertEquals('https://aacr.zoom.us/j/12345', url);

    }

    @IsTest
    public static void test_createZoomMeeting(){
        BR_Event__c evt = [SELECT Id FROM BR_Event__c WHERE Name='Test Event'];

        Test.startTest();

        Test.setMock(HttpCalloutMock.class, new CreateMockHttpResponseGenerator());

        String var = V_ZoomIntegration.createZoomMeeting(evt.Id, '55555', 'pass123!', false);

        Test.stopTest();
    }

    @IsTest
    public static void test_createZoomWebinar(){
        BR_Event__c evt = [SELECT Id FROM BR_Event__c WHERE Name='Test Event'];

        Test.startTest();

        Test.setMock(HttpCalloutMock.class, new CreateMockHttpResponseGenerator());

        String var = V_ZoomIntegration.createZoomMeeting(evt.Id, '55555', null, true);

        Test.stopTest();
    }

    @IsTest
    public static void test_updateZoomMeeting(){
        BR_Event__c evt = [SELECT Id FROM BR_Event__c WHERE Name='Test Event'];

        Test.startTest();

        Test.setMock(HttpCalloutMock.class, new UpdateMockHttpResponseGenerator());

        V_ZoomIntegration.updateZoomMeeting(evt.Id, '55555', 'pass123!');

        Test.stopTest();
    }


    @IsTest
    public static void test_DeleteZoomMeeting(){
        BR_Event__c evt = [SELECT Id FROM BR_Event__c WHERE Name='Test Event'];
        Virtual_Event_Details__c ved = [SELECT External_Event_Id__c FROM Virtual_Event_Details__c WHERE Event__c=:evt.Id];

        Test.startTest();

        Test.setMock(HttpCalloutMock.class, new UpdateMockHttpResponseGenerator());

        V_ZoomIntegration.deleteMeeting(ved.External_Event_Id__c, false);

        Test.stopTest();
    }


    public class UpdateMockHTTPResponseGenerator implements HttpCalloutMock{
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setStatusCode(204);
            return res;
        }
    }


    public class CreateMockHTTPResponseGenerator implements HttpCalloutMock{
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"encrypted_password": "83459843758947594"}');
            res.setStatusCode(201);
            return res;
        }
    }

}