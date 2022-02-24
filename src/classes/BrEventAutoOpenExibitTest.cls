/**
 * Created by afaf.awad on 10/23/2020.
 */

@IsTest
private class BrEventAutoOpenExibitTest {
    
    @IsTest
    public static void test_OpenExibit() {

        BR_Event__c testEvent = LiveTestDataFactory.buildEvent('Test Event', false , false);
        testEvent.Start_Date__c = System.now().addMinutes(15);
        testEvent.Event_Stage__c = 'Virtual';
        insert testEvent;

        Virtual_Event_Details__c ved = new Virtual_Event_Details__c(
                Name = 'Test Virtual Details',
                Event__c = testEvent.Id,
                Exhibit_Open__c = false
        );
        insert ved;


        Test.startTest();
        String jobId = System.schedule('ScheduledApexTest',
                '0 0 0 15 3 ? 2022',
                new BrEventAutoOpenExibitScheduler());
        Test.stopTest();

        Virtual_Event_Details__c ved_post = [SELECT Exhibit_Open__c FROM Virtual_Event_Details__c LIMIT 1];
        System.assertEquals(true, ved_post.Exhibit_Open__c);

    }


}