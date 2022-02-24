/**
 * Created by lauren.lezberg on 7/14/2020.
 */
@isTest
private with sharing class C19CLymphomaTriggerTest {


    @testSetup
    public static void setup(){
        Account acc = TestDataFactory.buildAccount('Test Account');
        insert acc;

        Contact con = TestDataFactory.buildContact(acc.Id);
        insert con;

        User u = TestDataFactory.buildUser(con.Id);
        insert u;

        EventApi__Event__c evt = TestDataFactory.buildEvent();
        insert evt;

    }

    @isTest
    public static void test_C19CCreateAttendee(){
        EventApi__Event__c evt = [SELECT Id FROM EventApi__Event__c];

        Contact con = [SELECT Id FROM Contact LIMIT 1];

        User u = [SELECT Id FROM User WHERE ContactId =: con.Id];

        System.runAs(u) {

            Test.startTest();

            C19CLymphomaTriggerHandler.covidEventId = evt.Id;

            EventApi__Attendee__c att = new EventApi__Attendee__c(EventApi__Event__c=evt.Id, EventApi__Contact__c = con.Id, EventApi__Status__c = 'Registered');
            insert att;


            Test.stopTest();
        }

        u = [SELECT Registered_for_Covid__c FROM User WHERE ContactId = :con.Id];
        System.assertEquals(true, u.Registered_for_Covid__c);

    }

    @isTest
    public static void test_C19CCancelAttendee(){
        EventApi__Event__c evt = [SELECT Id FROM EventApi__Event__c];

        Contact con = [SELECT Id FROM Contact LIMIT 1];

        User u = [SELECT Id FROM User WHERE ContactId =: con.Id];

        System.runAs(u) {

            Test.startTest();

            C19CLymphomaTriggerHandler.covidEventId = evt.Id;

            EventApi__Attendee__c att = new EventApi__Attendee__c(EventApi__Event__c=evt.Id, EventApi__Contact__c = con.Id, EventApi__Status__c = 'Cancelled');
            insert att;


            Test.stopTest();
        }

        u = [SELECT Registered_for_Covid__c FROM User WHERE ContactId = :con.Id];
        System.assertEquals(false, u.Registered_for_Covid__c);

    }

    @isTest
    public static void test_C19CDeleteAttendee(){
        EventApi__Event__c evt = [SELECT Id FROM EventApi__Event__c];

        Contact con = [SELECT Id FROM Contact LIMIT 1];

        User u = [SELECT Id FROM User WHERE ContactId =: con.Id];

        System.runAs(u) {

            Test.startTest();

            C19CLymphomaTriggerHandler.covidEventId = evt.Id;

            EventApi__Attendee__c att = new EventApi__Attendee__c(EventApi__Event__c=evt.Id, EventApi__Contact__c = con.Id, EventApi__Status__c = 'Cancelled');
            insert att;

            delete att;

            Test.stopTest();
        }

        u = [SELECT Registered_for_Covid__c FROM User WHERE ContactId = :con.Id];
        System.assertEquals(false, u.Registered_for_Covid__c);

    }

    @isTest
    public static void test_LymphomaCreateAttendee(){
        EventApi__Event__c evt = [SELECT Id FROM EventApi__Event__c];

        Contact con = [SELECT Id FROM Contact LIMIT 1];

        User u = [SELECT Id FROM User WHERE ContactId =: con.Id];

        System.runAs(u) {

            Test.startTest();

            C19CLymphomaTriggerHandler.lymphomaEventId= evt.Id;

            EventApi__Attendee__c att = new EventApi__Attendee__c(EventApi__Event__c=evt.Id, EventApi__Contact__c = con.Id, EventApi__Status__c = 'Registered');
            insert att;


            Test.stopTest();
        }

        u = [SELECT Registered_for_Lymphoma__c FROM User WHERE ContactId = :con.Id];
        System.assertEquals(true, u.Registered_for_Lymphoma__c);

    }

    @isTest
    public static void test_LymphomaCancelAttendee(){
        EventApi__Event__c evt = [SELECT Id FROM EventApi__Event__c];

        Contact con = [SELECT Id FROM Contact LIMIT 1];

        User u = [SELECT Id FROM User WHERE ContactId =: con.Id];

        System.runAs(u) {

            Test.startTest();

            C19CLymphomaTriggerHandler.lymphomaEventId = evt.Id;

            EventApi__Attendee__c att = new EventApi__Attendee__c(EventApi__Event__c=evt.Id, EventApi__Contact__c = con.Id, EventApi__Status__c = 'Cancelled');
            insert att;


            Test.stopTest();
        }

        u = [SELECT Registered_for_Lymphoma__c FROM User WHERE ContactId = :con.Id];
        System.assertEquals(false, u.Registered_for_Lymphoma__c);

    }

    @isTest
    public static void test_LymphomaDeleteAttendee(){
        EventApi__Event__c evt = [SELECT Id FROM EventApi__Event__c];

        Contact con = [SELECT Id FROM Contact LIMIT 1];

        User u = [SELECT Id FROM User WHERE ContactId =: con.Id];

        System.runAs(u) {

            Test.startTest();

            C19CLymphomaTriggerHandler.lymphomaEventId = evt.Id;

            EventApi__Attendee__c att = new EventApi__Attendee__c(EventApi__Event__c=evt.Id, EventApi__Contact__c = con.Id, EventApi__Status__c = 'Registered');
            insert att;

            delete att;

            Test.stopTest();
        }

        u = [SELECT Registered_for_Lymphoma__c FROM User WHERE ContactId = :con.Id];
        System.assertEquals(false, u.Registered_for_Lymphoma__c);

    }

    @isTest
    public static void test_catchBlocks(){
        EventApi__Event__c evt = [SELECT Id FROM EventApi__Event__c];

        Contact con = [SELECT Id FROM Contact LIMIT 1];

        Test.startTest();
        EventApi__Attendee__c att = new EventApi__Attendee__c(EventApi__Event__c=evt.Id, EventApi__Contact__c = con.Id, EventApi__Status__c = 'Cancelled');
        insert att;

        Test.stopTest();
    }



}