/**
 * Created by afaf.awad on 5/13/2020.
 */

@IsTest
private class Batch_AddAttendeesToEventTest {

    // Dummy CRON expression: midnight on March 15.
    // Because this is a test, job executes
    // immediately after Test.stopTest().
    public static String CRON_EXP = '0 0 0 15 3 ? 2022';

    @IsTest(SeeAllData=true)
    static void testScheduledJob() {
        // Create test records
        Account acc = TestDataFactory.buildAccount('Test Account');
        insert acc;

        Contact con = TestDataFactory.buildContact(acc.Id);
        con.Title = 'Example to Set';
        con.Salutation = 'Ms.';
        insert con;

        Contact con2 = TestDataFactory.buildContact(acc.Id);
        con2.LastName = 'Another Test contact';
        con2.Title = 'Another Example to Set';
        con2.Salutation = 'Mr.';
        con2.Email = 'testEmail2@yopmail.com';
        insert con2;

        EventApi__Event__c oldtestEvt = TestDataFactory.buildEvent();
        oldtestEvt.Name = 'Old Event';
        oldtestEvt.EventApi__Event_Key__c = '3847294726';
        oldtestEvt.EventApi__Start_Date__c = Date.today();
        oldtestEvt.EventApi__Start_Time__c = '08:00 AM';
        oldtestEvt.EventApi__End_Time__c = '08:00 PM';
        oldtestEvt.EventApi__End_Date__c = Date.today().addDays(2);
        oldtestEvt.EventApi__Logo_Image__c = 'https://www.testImgurl.com';
        oldtestEvt.EventApi__Description__c = 'THIS IS THE OLD EVENT.';
        insert oldtestEvt;

        EventApi__Event__c newtestEvt = TestDataFactory.buildEvent();
        newtestEvt.Name = 'New Event';
        newtestEvt.EventApi__Event_Key__c = '3847294727';
        newtestEvt.EventApi__Start_Date__c = Date.today();
        newtestEvt.EventApi__Start_Time__c = '08:00 AM';
        newtestEvt.EventApi__End_Time__c = '08:00 PM';
        newtestEvt.EventApi__End_Date__c = Date.today().addDays(2);
        newtestEvt.EventApi__Logo_Image__c = 'https://www.testImgurl.com';
        newtestEvt.EventApi__Description__c = 'THIS IS THE NEW EVENT.';
        insert newtestEvt;

        EventApi__Attendee__c testAtt = new EventApi__Attendee__c(EventApi__Event__c = newtestEvt.Id,
                EventApi__Contact__c = con.Id);
        insert testAtt;

        EventApi__Attendee__c testAtt2 = new EventApi__Attendee__c(EventApi__Event__c = oldtestEvt.Id,
                EventApi__Contact__c = con2.Id);
        insert testAtt2;

        String oldEvent = [Select Id from EventApi__Event__c WHERE Name LIKE 'Old Event' LIMIT 1].Id;

        // Schedule the test job
        Test.startTest();
        String jobId = System.schedule('ScheduledApexTest',
                CRON_EXP,
                new Batch_AddAttendeestoEventScheduler());

        List<EventApi__Attendee__c> a = [ SELECT Id FROM EventApi__Attendee__c WHERE EventApi__Event__c = :OldEvent];

        System.assertEquals(1, a.size(), 'Event is empty');

        Test.stopTest();

    }
}