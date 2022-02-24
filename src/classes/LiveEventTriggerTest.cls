/**
 * Created by lauren.lezberg on 11/5/2020.
 */

@IsTest
private class LiveEventTriggerTest {


    @IsTest
    static void testUpdate() {
        List<OrgWideEmailAddress> owas = [SELECT Id FROM OrgWideEmailAddress LIMIT 1];
        System.assertEquals(owas.size(), 1);

        insert new BrEvents_Settings__c(Name='org wide email id', Label__c = 'org wide email id', Value__c = owas[0].Id);

        insert new Zoom_Session__c(Client_Id__c = '92348u34', Client_Secret__c='4580568406856');

        BR_Events_Zone__c zone = LiveTestDataFactory.buildZone('Test Zone', true);
        insert zone;

        Id virtualRecordTypeId = Schema.SObjectType.Venue__c.getRecordTypeInfosByName().get('Virtual').getRecordTypeId();
        Venue__c ven = new Venue__c(Name='Zoom', RecordTypeId=virtualRecordTypeId, Integration_Controller__c='V_ZoomIntegration', Base_URL__c = 'https://aacr.zoom.us/j/');
        insert ven;
        Venue__c ven2 = new Venue__c(Name='PathLMS', RecordTypeId=virtualRecordTypeId, Integration_Controller__c='V_PathLMSIntegration', Base_URL__c = 'https://www.pathlms.com/aacr/courses/');
        insert ven2;

        BR_Event__c testEvent = new BR_Event__c(
                Name = 'Test event0',
                Virtual_Venue__c = ven.Id,
                Start_Date__c = Datetime.newInstance(2016, 10, 15, 12, 30, 0),
                End_Date__c = Datetime.newInstance(2016, 10, 15, 17, 30, 0),
                Event_Preferences_Form_Fieldset__c = 'test',
                Registration_Form_Fieldset__c = 'Registration_Basic',
                Registration_Confirmation_Message__c = 'TEST MESSAGE'
        );
        insert testEvent;

        Virtual_Event_Details__c ved = new Virtual_Event_Details__c(Event__c=testEvent.Id, External_Event_Id__c='1234', Zoom_Type__c='Meeting', Zoom_User_Id__c='5555');
        insert ved;

        Test.startTest();

        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());

        testEvent.End_Date__c = Datetime.newInstance(2016, 10, 16, 17, 30, 0);
        update testEvent;

        testEvent.Virtual_Venue__c = ven2.Id;
        update testEvent;

        testEvent.Virtual_Venue__c = ven.Id;
        update testEvent;

        Test.stopTest();
    }

    @IsTest
    static void testDelete() {
        List<OrgWideEmailAddress> owas = [SELECT Id FROM OrgWideEmailAddress LIMIT 1];
        System.assertEquals(owas.size(), 1);

        insert new BrEvents_Settings__c(Name='org wide email id', Label__c = 'org wide email id', Value__c = owas[0].Id);

        insert new Zoom_Session__c(Client_Id__c = '92348u34', Client_Secret__c='4580568406856');

        BR_Events_Zone__c zone = LiveTestDataFactory.buildZone('Test Zone', true);
        insert zone;

        Id virtualRecordTypeId = Schema.SObjectType.Venue__c.getRecordTypeInfosByName().get('Virtual').getRecordTypeId();
        Venue__c ven = new Venue__c(Name='Zoom', RecordTypeId=virtualRecordTypeId, Integration_Controller__c='V_ZoomIntegration', Base_URL__c = 'https://aacr.zoom.us/j/');
        insert ven;

        BR_Event__c testEvent = new BR_Event__c(
                Name = 'Test event0',
                Virtual_Venue__c = ven.Id,
                Start_Date__c = Datetime.newInstance(2016, 10, 15, 12, 30, 0),
                End_Date__c = Datetime.newInstance(2016, 10, 15, 17, 30, 0),
                Event_Preferences_Form_Fieldset__c = 'test',
                Registration_Form_Fieldset__c = 'Registration_Basic',
                Registration_Confirmation_Message__c = 'TEST MESSAGE'
        );
        insert testEvent;

        Virtual_Event_Details__c ved = new Virtual_Event_Details__c(Event__c=testEvent.Id, External_Event_Id__c='1234', Zoom_Type__c='Meeting', Zoom_User_Id__c='5555');
        insert ved;

        Test.startTest();

        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());

        delete testEvent;

        Test.stopTest();
    }

    public class MockHTTPResponseGenerator implements HttpCalloutMock{
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setStatusCode(200);
            return res;
        }
    }


}