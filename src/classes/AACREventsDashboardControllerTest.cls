/**
 * Created by lauren.lezberg on 2/20/2020.
 */
@isTest
private with sharing class AACREventsDashboardControllerTest {

    @testSetup public static void setup(){
        List<BR_Event__C> allEvents = new List<BR_Event__C>();
        for(Integer i=1; i<=12; i++){
            Date startDate = Date.newInstance(System.now().year(), i, 1);
            Date endDate = Date.newInstance(System.now().year(), i, 5);
            BR_Event__c evnt = new BR_Event__c();
            evnt.Start_Date__c = startDate;
            evnt.End_Date__c = endDate;
            evnt.Name = 'Test Event ' + i;
            evnt.Draft__c = false;
            allEvents.add(evnt);
        }

        insert allEvents;
        System.assertEquals(12, allEvents.size());
    }

    @IsTest
    public static void test_getAvailableYears(){
        List<Integer> years = new List<Integer>();
        Test.startTest();

        years = AACREventsDashboardController.getAvailableYears();
        System.assertNotEquals(true, years.isEmpty());

        Test.stopTest();
    }


    @isTest
    public static void test_getEventsPerMonth(){
        Test.startTest();
        List<AACREventsDashboardController.UpcomingEvent> janEvents = AACREventsDashboardController.getEventsPerMonth('1', SYstem.now().year());
        System.assertEquals(1, janEvents.size());

        List<AACREventsDashboardController.UpcomingEvent> febEvents = AACREventsDashboardController.getEventsPerMonth('2' , SYstem.now().year());
        System.assertEquals(1, febEvents.size());

        List<AACREventsDashboardController.UpcomingEvent> marchEvents = AACREventsDashboardController.getEventsPerMonth('3', SYstem.now().year());
        System.assertEquals(1, marchEvents.size());

        List<AACREventsDashboardController.UpcomingEvent> aprilEvents = AACREventsDashboardController.getEventsPerMonth('4', SYstem.now().year());
        System.assertEquals(1, aprilEvents.size());

        Test.stopTest();
    }
}