/**
 * Created by lauren.lezberg on 2/21/2020.
 */
@isTest
private with sharing class JP_EventInfoControllerTest {

    @testSetup public static void setup(){
        BR_Events_Zone__c zone = LiveTestDataFactory.buildZone('Test Zone', true);
        insert zone;

        Venue__c ven = LiveTestDataFactory.buildVenue('TEST VENUE');
        insert ven;

        BR_Event__c event = LiveTestDataFactory.buildEvent('Test Event', false, true, zone.Id );
        event.Venue__c = ven.Id;
        insert event;
    }

    @isTest
    public static void test_getZone(){
        BR_Events_Zone__c zone = [SELECT Id FROM BR_Events_Zone__c WHERE Is_Default__c = true LIMIT 1];

        Test.startTest();
        String zId = JP_EventInfoController.getZone();
        System.assertEquals(zone.Id, zId);

        Test.stopTest();
    }

    @isTest
    public static void test_getVenue(){
        BR_Event__c evt = [SELECT Id, Venue__r.Street_1__c, Venue__c FROM BR_Event__c WHERE Name='Test Event'];

        Test.startTest();
        Venue__c ven = JP_EventInfoController.getVenue(evt.Venue__c);
        System.assertEquals(evt.Venue__r.Street_1__c, ven.Street_1__c);

        ven = JP_EventInfoController.getVenue('1233458394583745');
        System.assertEquals(null, ven);
        Test.stopTest();

    }

    @isTest
    public static void test_createTicketItem(){
        BR_Event__c evt = [SELECT Id, Venue__r.Street_1__c, Venue__c FROM BR_Event__c WHERE Name='Test Event'];

        OrderApi__Item_Class__c itemClass = TestDataFactory.buildItemClass('Live Event Tickets');
        insert itemClass;

        Test.startTest();
        JP_EventInfoController.createTicketItem(evt.Id);
        JP_EventInfoController.createTicketItem(evt.Id);
        Test.stopTest();
    }


//    @isTest
//    public static void test_validateVenue(){
//        Venue__c ven = [SELECT Id, Name, Street_1__c, Street_2__c, Street_3__c, City__c, State__c, Zip__c, Country__c FROM Venue__c WHERE Name='TEST VENUE'];
//
//        Test.startTest();
//        List<Venue__c> foundVenues = JP_EventInfoController.validateVenue(ven.Street_1__c, ven.Street_2__c, ven.Street_3__c, ven.City__c, ven.Zip__c, ven.Name);
//        System.assertEquals(1, foundVenues.size());
//
//        foundVenues = JP_EventInfoController.validateVenue('1 Test Ln', null, null, 'Test City', '457397', 'Test VEN');
//        System.assertEquals(0, foundVenues.size());
//        Test.stopTest();
//    }
}