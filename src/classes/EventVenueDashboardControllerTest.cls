/**
 * Created by afaf.awad on 5/19/2021.
 */

@IsTest
public class EventVenueDashboardControllerTest {

    @TestSetup public static void setup() {
        Account account = LiveTestDataFactory.buildAccount('Test Account');
        insert account;

        Contact contact = LiveTestDataFactory.buildContact(account.Id);
        insert contact;

        User user = TestDataFactory.buildUser(contact.Id);
        insert user;

        Id virtualRecTypeId = Schema.SObjectType.Venue__c.getRecordTypeInfosByName().get('Virtual').getRecordTypeId();
        Venue__c ven = new Venue__c(Name='Test Venue');
        ven.RecordTypeId=virtualRecTypeId;
        ven.Show_In_Dashboard__c = true;
        insert ven;

        BR_Event__c evt = LiveTestDataFactory.buildEvent('Test Event', false, false);
        evt.Virtual_Venue__c = ven.Id;
        insert evt;

        Virtual_Event_Details__c ved =  new Virtual_Event_Details__c(
                Event__c=evt.Id,
                External_Event_Id__c = '1234567890',
                Exhibit_Open__c = false
        );
        insert ved;

    }

    @IsTest
    public static void test_getAvailableYears(){
        List<Integer> years = EventVenueDashboardController.getAvailableYears();
        System.assertEquals(years.size(), 1);

        BR_Event__c event = [SELECT Id, End_Date__c, Start_Date__c FROM BR_Event__c];
        event.Start_Date__c = System.now().addDays(-5);
        event.End_Date__c = System.now().addDays(-2);
        update event;

        List<Integer> defaultYears = EventVenueDashboardController.getAvailableYears();
        System.assertEquals(defaultYears.size(), 1);
    }

    @IsTest
    public static void test_getEventsPerMonth(){
       EventVenueDashboardController.EventVenueInfo evInfo = EventVenueDashboardController.getEventsPerMonth(String.valueOf(System.today().month()), System.today().year());
        System.assertEquals(1, evInfo.events.size());
        System.assertEquals(1, evInfo.venues.size());
    }

    @IsTest
    public static void test_updateExhibit(){
        Virtual_Event_Details__c ved = [SELECT Id FROM Virtual_Event_Details__c LIMIT 1];
        Boolean exhibitStatus = EventVenueDashboardController.updateExhibit(ved.Id);
        System.assertEquals(true, exhibitStatus);
    }
}