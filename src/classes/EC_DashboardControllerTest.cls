/**
 * Created by afaf.awad on 3/23/2021.
 */

@IsTest
public with sharing class EC_DashboardControllerTest {

    @TestSetup public static void setup(){
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

        insert new Send_Grid__c(url__c = 'https://api.sendgrid.com/v3', API_key__c = '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');

        insert new EC_Event__c(Event_Name__c = event.Name, Event_Id__c = event.Id);
    }

    @IsTest
    public static void test_getDashboardInfo(){
        Contact con = [SELECT Id, AccountId FROM Contact WHERE Account.Name = 'Test Account' LIMIT 1];
        User user = [SELECT Id, ContactId FROM User WHERE ContactId =: con.Id];
        system.runAs(user) {
            EC_DashboardController.DashboardInfo dashInfo = EC_DashboardController.getDashboardInfo();
            System.assertEquals(dashInfo.timeSlots.size(), 1);
        }
    }

    @IsTest
    public static void test_getExhibitorOrderProcessId(){
        Contact con = [SELECT Id, AccountId FROM Contact WHERE Account.Name = 'Test Account' LIMIT 1];
        User user = [SELECT Id, ContactId FROM User WHERE ContactId =: con.Id];
        system.runAs(user) {
            EC_DashboardController.getExhibitorOrderProcessId();
            List<EC_Order__c> orders = [SELECT Id FROM EC_Order__c];
            System.assertEquals(2, orders.size());
        }
    }

    @IsTest
    public static void test_getExhbitorSettingURL(){
        Contact con = [SELECT Id, AccountId FROM Contact WHERE Account.Name = 'Test Account' LIMIT 1];
        User user = [SELECT Id, ContactId FROM User WHERE ContactId =: con.Id];
        EC_Exhibitor_Setting__c ecSetting = [SELECT Id FROM EC_Exhibitor_Setting__c];
        system.runAs(user) {
            EC_DashboardController.getExhbitorSettingURL();
            System.assertEquals(ecSetting.Id != null, true);
        }

        delete ecSetting;
        system.runAs(user) {
            EC_DashboardController.getExhbitorSettingURL();
            EC_Exhibitor_Setting__c newSetting = [SELECT Id FROM EC_Exhibitor_Setting__c];
            System.assertEquals(newSetting.Id != null, true);
        }

    }

    @IsTest
    public static void test_getIncompleteOrder(){
        Contact con = [SELECT Id, AccountId FROM Contact WHERE Account.Name = 'Test Account' LIMIT 1];
        User user = [SELECT Id, ContactId FROM User WHERE ContactId =: con.Id];
        EC_Order__c order = [SELECT Id FROM EC_Order__c WHERE Status__c = 'Incomplete' LIMIT 1];
        system.runAs(user) {
            String url = EC_DashboardController.getIncompleteOrder(order.Id);
            System.assertEquals(url.contains(order.Id), true);
        }
    }

    @IsTest
    public static void test_deleteRecord(){
        Contact con = [SELECT Id, AccountId FROM Contact WHERE Account.Name = 'Test Account' LIMIT 1];
        User user = [SELECT Id, ContactId FROM User WHERE ContactId =: con.Id];
        EC_Order__c order = [SELECT Id FROM EC_Order__c WHERE Status__c = 'Incomplete' LIMIT 1];
        system.runAs(user) {
            List<EC_Order__c> orders = EC_DashboardController.deleteRecord(order.Id);
            System.assertEquals(orders.size(), 0);
        }
    }

//    @IsTest
//    public static void test_getEmailActivityList(){
//        List<Time_Slot__c> timeSlots = [SELECT Id, Status__c, EC_Order__c FROM Time_Slot__c];
//
//        List<String> orderIds = new List<String>();
//        for(Time_Slot__c ts : timeSlots){
//            orderIds.add(ts.EC_Order__c);
//        }
//
//        SingleRequestMock fakeResponse = new SingleRequestMock(200,
//                'Complete',
//                '{[{"from_email":"info@em7398.aacrtest.org"' +
//                        ',"msg_id":"zk5cgN5WQOmkzcOiLsWXGg.filterdrecv-p3iad2-7b664dbcb7-npmqz-20-6058A623-46.0"' +
//                        ',"subject":"AACR Annual Meeting 2021"' +
//                        ',"to_email":"testemail@testemail.org"' +
//                        ',"status":"delivered"' +
//                        ',"opens_count":1' +
//                        ',"clicks_count":0' +
//                        ',"last_event_time":"2021-03-22T14:14:11Z"}]}',
//                null);
//
//        Map<String, HttpCalloutMock> endpoint2TestResp = new Map<String, HttpCalloutMock>();
//        endpoint2TestResp.put('https://api.sendgrid.com/v3/messages?query=subject%3D%22Clickbait%22AND%20last_event_time%20BETWEEN%20TIMESTAMP%20%222021-03-11T06%3A00%3A00Z%22%20AND%20TIMESTAMP%20%222021-03-11T17%3A00%3A00Z%22&limit=10', fakeResponse);
//
//        HttpCalloutMock mockPlatformService = new MockHttpResponseGenerator(endpoint2TestResp);
//
//        Test.startTest();
//        Test.setMock(HttpCalloutMock.class, mockPlatformService);
//        List<EC_DashboardController.EmailActivity> emailActivities = EC_DashboardController.getEmailActivityList(JSON.serialize(orderIds));
//        System.debug('Email Activity: ' + emailActivities );
//        System.assertEquals(emailActivities[0].clicks, 1);
//        Test.stopTest();
//    }


}