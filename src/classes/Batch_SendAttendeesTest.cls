/**
 * Created by afaf.awad on 4/24/2020.
 */

@IsTest
private without sharing class Batch_SendAttendeesTest {

    @IsTest(SeeAllData=true)
    static void testBatch_SendAttendees() {


        Account acc = TestDataFactory.buildAccount('Test Account');
        insert acc;

        Contact con = TestDataFactory.buildContact(acc.Id);
        con.Title = 'Example to Set';
        con.Salutation = 'Ms.';
        insert con;

        EventApi__Event__c testEvt = TestDataFactory.buildEvent();
        testEvt.EventApi__Event_Key__c = '3847294726';
        testEvt.EventApi__Start_Date__c = Date.today();
        testEvt.EventApi__Start_Time__c = '08:00 AM';
        testEvt.EventApi__End_Time__c = '08:00 PM';
        testEvt.EventApi__End_Date__c = Date.today().addDays(2);
        testEvt.EventApi__Logo_Image__c = 'https://www.testImgurl.com';
        testEvt.EventApi__Description__c = 'THIS IS A TEST EVENT.';
        insert testEvt;


        EventApi__Attendee__c testAtt = new EventApi__Attendee__c(EventApi__Event__c = testEvt.Id,
        EventApi__Contact__c = con.Id);
        insert testAtt;


        String event = [Select Id from EventApi__Event__c WHERE Name LIKE 'Test Event' LIMIT 1].Id;

        Test.startTest();

        System.debug('Test is starting...');
        System.debug('EventId = ' + event);

        database.executeBatch(new Batch_SendAttendees(event, true, '1234567890'));

        Test.stopTest();
    }

}