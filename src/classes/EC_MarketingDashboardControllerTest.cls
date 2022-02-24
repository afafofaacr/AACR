/**
 * Created by afaf.awad on 3/24/2021.
 */
@isTest
public with sharing class EC_MarketingDashboardControllerTest {

    @TestSetup public static void setup() {
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

        Time_Slot__c timeSlot = ExhibitorTestDataFactory.buildTimeSlot(order.Id, email.Id, schedule.Id);
        timeSlot.Status__c = 'Sent';
        insert timeSlot;

    }

    @IsTest
    public static void test_getAvailableYears(){
        List<Integer> years = EC_MarketingDashboardController.getAvailableYears();
        System.assertEquals(years.size(), 1);

        Time_Slot__c timeSlot = [SELECT Id, Blocked__c FROM Time_Slot__c];
        timeSlot.Blocked__c = true;
        update timeSlot;

        List<Integer> emptyYears = EC_MarketingDashboardController.getAvailableYears();
        System.assertEquals(emptyYears.size(), 1);
    }

    @IsTest
    public static void test_getEventsPerMonth(){
        List<Time_Slot__c> timeSlots = EC_MarketingDashboardController.getEventsPerMonth(String.valueOf(System.today().month()), System.today().year());
        System.assertEquals(timeSlots.size(), 1);
    }

    }