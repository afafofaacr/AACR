/**
 * Created by lauren.lezberg on 10/11/2019.
 */
@isTest
private with sharing class AddressEntryControllerTest {

    @testSetup
    public static void setup(){
        Account acc = TestDataFactory.buildAccount('Test Account');
        insert acc;

        Contact con = TestDataFactory.buildContact(acc.Id);
        insert con;

        User u = TestDataFactory.buildUser(con.Id);
        insert u;
    }


    @isTest
    public static void test_getCountries(){

        Test.startTest();
        Map<String, String> countryMap = AddressEntryController.getCountries();
        Test.stopTest();

        System.assert(!countryMap.isEmpty(), 'Country map should have values');
    }

    @isTest
    public static void test_getStatesUS(){
        Contact con = [SELECT Id, OtherCountryCode, MailingCountryCode, MailingCountry FROM Contact WHERE Account.Name='Test Account'];
        con.MailingCountryCode = 'US';
        con.MailingCountry = 'United States';
        User u = [SELECT Id FROM User WHERE ContactId=:con.Id];

        System.runAs(u) {
            Test.startTest();
            Map<String, String> stateMap = AddressEntryController.getStates(con.MailingCountryCode, con.MailingCountryCode, con.OtherCountryCode);
            Test.stopTest();

            System.assert(stateMap.size()>0, 'State map should not be empty');

            con = [SELECT Do_Not_Display_in_Directory__c FROM Contact WHERE Id=:con.Id];
            System.assertEquals(con.Do_Not_Display_in_Directory__c, false);
        }
    }

    @isTest
    public static void test_getStatesEU(){
        Contact con = [SELECT Id, OtherCountryCode, MailingCountryCode, MailingCountry FROM Contact WHERE Account.Name='Test Account'];
        con.MailingCountryCode = 'FR';
        con.MailingCountry = 'France';
        con.OtherCountryCode = 'FR';
        update con;
        User u = [SELECT Id FROM User WHERE ContactId=:con.Id];

        System.runAs(u) {
            Test.startTest();
            Map<String, String> stateMap = AddressEntryController.getStates(con.MailingCountryCode, con.MailingCountryCode, con.OtherCountryCode);
            Test.stopTest();
            System.assert(stateMap.isEmpty(), 'State map should be empty');

            con = [SELECT Do_Not_Display_in_Directory__c FROM Contact WHERE Id=:con.Id];
            System.assertEquals(con.Do_Not_Display_in_Directory__c, true);
        }
    }
}