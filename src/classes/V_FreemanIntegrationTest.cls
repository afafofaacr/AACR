/**
 * Created by lauren.lezberg on 1/5/2021.
 */

@IsTest
private class V_FreemanIntegrationTest {

    @TestSetup
    public static void setup(){
        List<OrgWideEmailAddress> owas = [SELECT Id FROM OrgWideEmailAddress LIMIT 1];
        System.assertEquals(owas.size(), 1);

        insert new BrEvents_Settings__c(Name='org wide email id', Label__c = 'org wide email id', Value__c = owas[0].Id);

        Account acc = TestDataFactory.buildAccount('Test Account');
        insert acc;

        Contact con = TestDataFactory.buildContact(acc.Id);
        insert con;

        User u = TestDataFactory.buildUser(con.Id);
        insert u;

        Id virtualRecTypeId = Schema.SObjectType.Venue__c.getRecordTypeInfosByName().get('Virtual').getRecordTypeId();
        Venue__c ven = new Venue__c(Name='Test Venue');
        ven.Integration_Controller__c = 'CallableTest';
        ven.Base_URL__c = 'https://www.onlineevent.com';
        ven.RecordTypeId=virtualRecTypeId;
        insert ven;

        BR_Event__c event = LiveTestDataFactory.buildEvent('Test Event', false, false);
        event.Virtual_Venue__c = ven.Id;
        insert event;

        Virtual_Event_Details__c ved = new Virtual_Event_Details__c();
        ved.External_Event_Id__c = '12345';
        ved.Event__c = event.Id;
        insert ved;

        insert new Fuzion_Session__c(Client_Id__c = '92348u34', Client_Secret__c='4580568406856');

        BR_Participation__c participation = new BR_Participation__c(Participate__c = 'Yes', External_Attendee_Id__c='67890', User__c=u.Id,Contact__c=con.Id,BR_Event__c=event.Id);
        insert participation;



    }

    @IsTest
    public static void testUpdateAttendee(){
        Contact con = [SELECT Id FROM Contact LIMIT 1];
        BR_Participation__c p = [SELECT Id FROM BR_Participation__c WHERE Contact__c=:con.Id];
        Callable extension = (Callable) Type.forName('V_FreemanIntegration').newInstance();

        Test.startTest();

        Test.setMock(HttpCalloutMock.class, new CreateMockHttpResponseGenerator());
        String att = String.valueOf(extension.call('updateAttendee', new Map<String, Object>{'participantId'=>p.Id}));
        System.assertEquals(null, att);


        Test.stopTest();
    }

    @IsTest
    public static void testDeleteAttendee(){
        Contact con = [SELECT Id FROM Contact LIMIT 1];
        BR_Participation__c p = [SELECT Id FROM BR_Participation__c WHERE Contact__c=:con.Id];
        Callable extension = (Callable) Type.forName('V_FreemanIntegration').newInstance();

        Test.startTest();

        Test.setMock(HttpCalloutMock.class, new CreateMockHttpResponseGenerator());
        extension.call('deleteAttendee', new Map<String, Object>{'fuzionAttendeeId'=>'67890', 'fuzionEventId'=> '12345'});


        Test.stopTest();
    }

    @IsTest
    static void testSendAttendee() {
        Contact con = [SELECT Id FROM Contact LIMIT 1];
        Callable extension = (Callable) Type.forName('V_FreemanIntegration').newInstance();

        Test.startTest();

        Test.setMock(HttpCalloutMock.class, new CreateMockHttpResponseGenerator());
        String att = String.valueOf(extension.call('sendAttendee', new Map<String, Object>{'contactId'=>con.Id, 'externalEventId'=>'12345', 'flag'=>false}));
        System.assertEquals(null, att);


        Test.stopTest();
    }

    @IsTest
    static void testAsyncSendAttendee() {
        Contact con = [SELECT Id FROM Contact LIMIT 1];
        Callable extension = (Callable) Type.forName('V_FreemanIntegration').newInstance();

        Test.startTest();

        Test.setMock(HttpCalloutMock.class, new CreateMockHttpResponseGenerator());
        extension.call('asyncSendAttendee', new Map<String, Object>{'contactId'=>con.Id, 'externalEventId'=>'12345', 'flag'=>false});

        Test.stopTest();
    }

    @IsTest
    static void testGoToVenue() {
        Contact con = [SELECT Id FROM Contact LIMIT 1];
        BR_Event__c evt = [SELECT Id FROM BR_Event__c WHERE Name='Test Event'];


        Callable extension = (Callable) Type.forName('V_FreemanIntegration').newInstance();

        String url = String.valueOf(extension.call('goToVenue', new Map<String, Object>{'contactId'=>con.Id, 'SFEventId'=>evt.Id}));
        System.assertEquals('https://www.onlineevent.com', url);

    }



    public class CreateMockHTTPResponseGenerator implements HttpCalloutMock{
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"fuzion_attendee_id": "83459843758947594"}');
            res.setStatusCode(200);
            return res;
        }
    }
}