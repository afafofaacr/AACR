/**
 * Created by afaf.awad on 3/24/2021.
 */
@isTest
public with sharing class EC_DatePickerControllerTest {

    @testSetup static void setup() {
        Account account = LiveTestDataFactory.buildAccount('Test Account');
        insert account;

        Contact contact = LiveTestDataFactory.buildContact(account.Id);
        insert contact;

        User user = TestDataFactory.buildUser(contact.Id);
        insert user;

        EC_Exhibitor_Setting__c ecSetting = ExhibitorTestDataFactory.buildExhibitorSetting(account.Id);
        insert ecSetting;

        EC_Order__c order = ExhibitorTestDataFactory.buildECOrder(ecSetting.Id, contact);
        insert order;

        EC_Email__c email = ExhibitorTestDataFactory.buildECEmail(ecSetting.Id, order.Id);
        insert email;

        BR_Events_Zone__c zone = LiveTestDataFactory.buildZone('Default', true);
        insert zone;

        BR_Event__c event = LiveTestDataFactory.buildEvent('Text Exhibitor Event', false, false, zone.Id);
        insert event;

        EC_Schedule__c schedule = ExhibitorTestDataFactory.buildECSchedule(event.Id);
        insert schedule;

        insert new EC_Event__c(Event_Name__c = event.Name, Event_Id__c = event.Id);
    }

    @isTest
    public static void testGetEventsForMonth() {
        Contact con = [SELECT Id, AccountId FROM Contact WHERE Account.Name = 'Test Account' LIMIT 1];
        User user = [SELECT Id, ContactId FROM User WHERE ContactId =: con.Id];
        BR_Event__c event = [SELECT Id FROM BR_Event__c WHERE Name= 'Text Exhibitor Event'];
        System.runAs(user) {
            BR_Events_Zone__c zone = [SELECT Id FROM BR_Events_Zone__c WHERE Name = 'Default' LIMIT 1];
            String zoneId = String.valueOf(zone.Id);

            List<EC_Schedule__c> itemsList = EC_DatePickerController.getEventsForMonth(zoneId, System.today().year() + 1, System.now().month(), event.Id);
            System.assertEquals(1, itemsList.size());

        }
    }

}