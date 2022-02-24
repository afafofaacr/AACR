/**
 * Created by lauren.lezberg on 7/14/2020.
 */
@isTest
private with sharing class Batch_C19CLymphomaUserUpdatesTest {


    @testSetup
    public static void setup(){
        Account acc = TestDataFactory.buildAccount('Test Account');
        insert acc;

        EventApi__Event__c evt = TestDataFactory.buildEvent();
        insert evt;

        Integer i = 0;
        List<Contact> CtoInsert = new List<Contact>();

        List<EventApi__Attendee__c> AtoInsert = new List<EventApi__Attendee__c>();
        for(i=0;i<200;i++){
            Contact con = new Contact(FirstName = 'Test', LastName = 'Contact' + i, AccountId=acc.Id, Email='Test.Contact' + i + '@yopmail.com');
            CtoInsert.add(con);
        }
        insert CtoInsert;

        List<User> UtoInsert = TestDataFactory.buildPortalUsersFromContacts(CtoInsert);
        insert UtoInsert;

        for(Contact con : CtoInsert){
            EventApi__Attendee__c att = new EventApi__Attendee__c(EventApi__Contact__c=con.Id, EventApi__Event__c=evt.Id, EventApi__Status__c = 'Registered');
            AtoInsert.add(att);
        }
        insert AtoInsert;
    }


    @isTest
    public static void test_runCOVIDBatch(){
        EventApi__Event__c evt = [SELECT Id FROM EventApi__Event__c];

        Test.startTest();

        C19CLymphomaTriggerHandler.covidEventId = evt.Id;

        Database.executeBatch(new Batch_C19CLymphomaUserUpdates(evt.Id), 200);

        Test.stopTest();
    }

    @isTest
    public static void test_runLymphomaBatch(){
        EventApi__Event__c evt = [SELECT Id FROM EventApi__Event__c];

        Test.startTest();

        C19CLymphomaTriggerHandler.lymphomaEventId = evt.Id;

        Database.executeBatch(new Batch_C19CLymphomaUserUpdates(evt.Id), 200);

        Test.stopTest();
    }


}