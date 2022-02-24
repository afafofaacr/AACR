/**
 * Created by afaf.awad on 11/12/2020.
 */

@IsTest
private class AddToCalendarControllerTest {
    @testSetup
    public static void setup(){
        Account acc = LiveTestDataFactory.buildAccount('Test Account');
        insert acc;

        Contact con = LiveTestDataFactory.buildContact(acc.Id);
        insert con;

        Venue__c ven = LiveTestDataFactory.buildVenue('Test Venue');
        ven.Virtual_Instructions__c = 'These instructions are fake.';
        insert ven;

        BR_Event__c event = LiveTestDataFactory.buildEvent('Test Event', false, false);
        event.Description__c = 'Test Event';
        event.Registration_Confirmation_Message__c = 'You are Registered!';
        event.Venue__c = ven.Id;
        event.Virtual_Venue__c = null;
        event.Invite_Image_Id__c = '';
        event.Draft_Program__c = 'www.google.com';
        insert event;

        BR_Event__c am21Event = LiveTestDataFactory.buildEvent('AACR Annual Meeting 2021', false, false);
        am21Event.Description__c = 'Test Event';
        am21Event.Registration_Confirmation_Message__c = 'You are Registered!';
        am21Event.Venue__c = ven.Id;
        am21Event.Virtual_Venue__c = null;
        am21Event.Invite_Image_Id__c = '';
        am21Event.Draft_Program__c = 'www.google.com';
        insert am21Event;

        BR_Participation__c part = new BR_Participation__c(BR_Event__c = event.Id,
                Contact__c = con.Id);
        insert part;

    }

    @IsTest
    static void test_getPhysicalEvent() {

        BR_Event__c event = [SELECT Id FROM BR_Event__c LIMIT 1];

        Test.startTest();
        PageReference addCalPage = Page.LetterOfParticipation;
        Test.setCurrentPage(addCalPage);
        addCalPage.getParameters().put('Id',event.Id);

        AddToCalendarController addCal = new AddToCalendarController();
        addCal.getEvent();

        System.assertEquals(event.Id, addCal.event.Id);
        Test.stopTest();
    }

    @IsTest
    static void test_getVirtualEvent() {

        Venue__c ven = [SELECT Id FROM Venue__c LIMIT 1];

        BR_Event__c event = [SELECT Id FROM BR_Event__c LIMIT 1];
        event.Virtual_Venue__c = ven.Id;
        update event;

        Test.startTest();
        Pagereference addCalPage = Page.LetterOfParticipation;
        Test.setCurrentPage(addCalPage);
        addCalPage.getParameters().put('Id',event.Id);

        AddToCalendarController addCal = new AddToCalendarController();
        addCal.getEvent();

        System.assertEquals(event.Id, addCal.event.Id);
        Test.stopTest();
    }

    @IsTest
    static void test_getAM21Event() {
        BR_Event__c am21Event = [SELECT Id FROM BR_Event__c WHERE Name = 'AACR Annual Meeting 2021'];

        Test.startTest();
        PageReference addCalPage = Page.LetterOfParticipation;
        Test.setCurrentPage(addCalPage);
        addCalPage.getParameters().put('Id',am21Event.Id);

        AddToCalendarController addCal = new AddToCalendarController();
        addCal.getEvent();

        System.assertEquals(am21Event.Id, addCal.event.Id);
        Test.stopTest();
    }
}