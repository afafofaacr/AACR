/**
 * Created by lauren.lezberg on 8/17/2020.
 */
@isTest
private with sharing class VenueNewModalControllerTest {

    @testSetup
    public static void setup(){
        Venue__c ven = LiveTestDataFactory.buildVenue('Test Venue');
        insert ven;
    }

    @isTest
    public static void test_getCountriesAndStates(){
        Test.startTest();

        Map<String, String> countryMap = VenueNewModalController.getCountries();
        System.assert(countryMap.size()>0);

        Map<string, String> stateMap = VenueNewModalController.getStates('US');
        System.assert(stateMap.size()>0);

        Test.stopTest();
    }

    @isTest
    public static void test_validateVenue(){

        Test.startTest();

        List<Venue__c> venues = VenueNewModalController.validateVenue('123 Main St', '', '', 'Philadelphia', '19130', 'Test Venue');
        System.assertEquals(1, venues.size());

        Test.stopTest();
    }

    @isTest
    public static void test_getVenueData(){
        Test.startTest();

        VenueNewModalController.VenueData vd = VenueNewModalController.getData();
        System.assertNotEquals(null, vd);

        Test.stopTest();
    }



}