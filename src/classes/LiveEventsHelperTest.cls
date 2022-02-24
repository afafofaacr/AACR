/**
 * Created by lauren.lezberg on 8/17/2020.
 */

@IsTest
private class LiveEventsHelperTest {

    @testsetup
    public static void setup(){

        List<OrgWideEmailAddress> owas = [SELECT Id FROM OrgWideEmailAddress LIMIT 1];
        System.assertEquals(owas.size(), 1);

        insert new BrEvents_Settings__c(Name='org wide email id', Label__c = 'org wide email id', Value__c = owas[0].Id);

        BR_Events_Zone__c zone = LiveTestDataFactory.buildZone('Test Zone', true);
        insert zone;

        Venue__c ven = new Venue__c(Name='Test Venue');
        insert ven;

        BR_Event__c testEvent = new BR_Event__c(
                Name = 'Test event0',
                Venue__c = ven.Id,
                Start_Date__c = Datetime.newInstance(2016, 10, 15, 12, 30, 0),
                End_Date__c = Datetime.newInstance(2016, 10, 15, 17, 30, 0),
                Location__Latitude__s = 51.5156950,
                Location__Longitude__s = -0.0893931,
                Venue_Address__c = 'Test ave 12/20',
                Event_Preferences_Form_Fieldset__c = 'test',
                Registration_Form_Fieldset__c = 'Registration_Basic',
                Registration_Confirmation_Message__c = 'TEST MESSAGE'
        );
        insert testEvent;

        OrderApi__Item_Class__c ticketclass = TestDataFactory.buildItemClass('Live Event Tickets');
        insert ticketclass;

        OrderApi__Item__c ticket = TestDataFactory.buildItem(ticketclass.Id, 'Test event0 Ticket');
        ticket.AC_Event__c = testEvent.Id;
        insert ticket;

        AC_User_Segment__c us1 = LiveTestDataFactory.buildUserSegment('Students');
        insert us1;

        AC_User_Segment__c us2 = LiveTestDataFactory.buildUserSegment('Members');
        insert us2;

        Account acc = TestDataFactory.buildAccount('Test Account');
        insert acc;

        Contact con = TestDataFactory.buildContact(acc.Id);
        insert con;

        User u = TestDataFactory.buildUser(con.Id);
        insert u;
    }

    @IsTest
    public static void test_deleteEventTicket(){
        BR_Event__c evt = [SELECT Id FROM BR_Event__c WHERE Name='Test event0'];

        Test.startTest();
        Boolean hasError = LiveEventsHelper.deleteEventTicket(evt.Id);
        Test.stopTest();

        System.assertEquals(false, hasError);

        Integer ticketCount = [SELECT COUNT() FROM OrderApi__Item__c WHERE AC_Event__c =: evt.Id];
        System.assertEquals(0, ticketCount);
    }

    @IsTest
    static void test_sendRegistrationConfirmationEmails() {
        BR_Event__c evt = [SELECT Id FROM BR_Event__c WHERE Name='Test event0'];

        User u = [SELECT Id, ContactId FROM User WHERE ContactId IN (SELECT Id FROM COntact WHERE Account.Name='Test Account')];

        Test.startTest();

        BR_Participation__c participation = new BR_Participation__c(BR_Event__c=evt.Id, Participate__c='Yes', Contact__c=u.ContactId, User__c=u.Id);
        insert participation;

        evt.Venue__c = null;
        update evt;

        participation = new BR_Participation__c(BR_Event__c=evt.Id, Participate__c='Yes', Contact__c=u.ContactId, User__c=u.Id);
        insert participation;

        Test.stopTest();
    }

    @isTest
    public static void test_cancelEvent(){
        BR_Event__c evt = [SELECT Id FROM BR_Event__c WHERE Name='Test event0'];
        evt.Draft__c = false;
        update evt;


        Test.startTest();

        LiveEventsHelper.cancelEvent(evt.Id);

        Test.stopTest();

        evt = [SELECT Cancelled__c FROM BR_Event__c WHERE Id=: evt.Id];
        System.assertEquals(evt.Cancelled__c, true);
    }

    @isTest
    public static void test_deleteEvent(){
        BR_Event__c evt = [SELECT Id FROM BR_Event__c WHERE Name='Test event0'];

        List<AC_User_Segment__c> segments = [SELECT Id FROM AC_User_Segment__c];

        AC_Event_User_Segment__c eus = LiveTestDataFactory.buildEventUserSegment(evt.Id, segments[0].Id, 'dietary_preferences');
        eus.Price__c = 100.00;
        insert eus;

        Test.startTest();

        LiveEventsHelper.deleteEventSchedule(evt.Id);

        LiveEventsHelper.deleteEventUserSegments(evt.Id);

        LiveEventsHelper.deleteEvent(evt.Id);

        Test.stopTest();


    }
}