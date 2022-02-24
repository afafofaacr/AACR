/**
 * Created by lauren.lezberg on 8/17/2020.
 */
@isTest
private with sharing class VirtualEventDetailsControllerTest {

//    @testSetup
//    public static void setup(){
//        Id virtualRecTypeId = Schema.SObjectType.Venue__c.getRecordTypeInfosByName().get('Virtual').getRecordTypeId();
//        Venue__c ven = new Venue__c(Name='Test Venue');
//        ven.RecordTypeId=virtualRecTypeId;
//        insert ven;
//
//        BR_Event__c event = LiveTestDataFactory.buildEvent('Test Event', false, false);
//        event.Virtual_Venue__c = ven.Id;
//        insert event;
//    }

    @IsTest
    public static void test_getZoomUsers(){
        Test.startTest();
        List<Zoom_User__mdt> users = VirtualEventDetailsController.getZoomUsers('Meeting');
        System.assertEquals(false, users.isEmpty());
        Test.stopTest();
    }

    @isTest(SeeAllData = true)
    public static void test_getVirtualDetails(){

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());

        Id virtualRecTypeId = Schema.SObjectType.Venue__c.getRecordTypeInfosByName().get('Virtual').getRecordTypeId();
        Venue__c ven = new Venue__c(Name='Zoom', Integration_Controller__c='V_ZoomIntegration', Base_URL__c='https://aacr.zoom.us/j/');
        ven.RecordTypeId=virtualRecTypeId;
        insert ven;

        BR_Event__c evt = LiveTestDataFactory.buildEvent('Test Event', false, false);
        evt.Virtual_Venue__c = ven.Id;
        insert evt;

        VirtualEventDetailsController.VirtualDetails ved = VirtualEventDetailsController.getVirtualDetailRecord(evt.Id);
        System.assertEquals(null, ved.details);

        insert new Virtual_Event_Details__c(
                Event__c=evt.Id,
                External_Event_Id__c = '1234567890',
                Zoom_Type__c='Meeting',
                Zoom_User_Id__c= '5555'
        );

        ved = VirtualEventDetailsController.getVirtualDetailRecord(evt.Id);
        System.assertNotEquals(null, ved.details);

        Test.stopTest();
    }

    @isTest(SeeAllData = true)
    public static void test_getVirtualDetails2(){

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());

        Id virtualRecTypeId = Schema.SObjectType.Venue__c.getRecordTypeInfosByName().get('Virtual').getRecordTypeId();
        Venue__c ven = new Venue__c(Name='Simple HTML Redirect', Integration_Controller__c='V_SimpleHTMLRedirect');
        ven.RecordTypeId=virtualRecTypeId;
        insert ven;

        BR_Event__c evt = LiveTestDataFactory.buildEvent('Test Event', false, false);
        evt.Virtual_Venue__c = ven.Id;
        insert evt;

        VirtualEventDetailsController.VirtualDetails ved = VirtualEventDetailsController.getVirtualDetailRecord(evt.Id);
        System.assertEquals(null, ved.details);

        insert new Virtual_Event_Details__c(
                Event__c=evt.Id,
                External_Event_Id__c = '1234567890',
                Zoom_Type__c='Meeting',
                Zoom_User_Id__c= '5555'
        );

        ved = VirtualEventDetailsController.getVirtualDetailRecord(evt.Id);
        System.assertNotEquals(null, ved.details);

        Test.stopTest();
    }

    @isTest(SeeAllData = true)
    public static void test_updateExhibit() {
        Id virtualRecTypeId = Schema.SObjectType.Venue__c.getRecordTypeInfosByName().get('Virtual').getRecordTypeId();
        Venue__c ven = new Venue__c(Name='Test Venue');
        ven.RecordTypeId=virtualRecTypeId;
        insert ven;

        BR_Event__c evt = LiveTestDataFactory.buildEvent('Test Event', false, false);
        evt.Virtual_Venue__c = ven.Id;
        insert evt;

        Virtual_Event_Details__c ved =  new Virtual_Event_Details__c(
                Event__c=evt.Id,
                External_Event_Id__c = '1234567890',
                Exhibit_Open__c = false
        );
        insert ved;

        Test.startTest();

        Boolean exhibitOpen = VirtualEventDetailsController.updateExhibit(ved.Id);
        System.assertEquals(true, exhibitOpen);

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