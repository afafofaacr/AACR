/**
 * Created by afaf.awad on 10/15/2020.
 */

@IsTest
private class ParticipantLetterControllerTest {

    @testSetup
    public static void setup(){
        Account acc = LiveTestDataFactory.buildAccount('Test Account');
        insert acc;

        Contact con = LiveTestDataFactory.buildContact(acc.Id);
        insert con;

        BR_Event__c event = LiveTestDataFactory.buildEvent('Test Event', false, false);
        event.Letter_Participation__c = 'You Participated!';
        insert event;

        BR_Participation__c part = new BR_Participation__c(BR_Event__c = event.Id,
                Contact__c = con.Id);
        insert part;

        //        ***FONTEVA EVENT OBJECTS***
        EventApi__Event__c fonEvent = TestDataFactory.buildEvent();
        fonEvent.Letter_of_Participation__c = 'You Participated!';
        insert fonEvent;

        EventApi__Attendee__c att = new EventApi__Attendee__c(EventApi__Contact__c=con.Id, EventApi__Event__c=fonEvent.Id);
        insert att;

    }

    @IsTest
    static void test_getLiveEvents() {

        BR_Event__c event = [SELECT Id FROM BR_Event__c LIMIT 1];
        Contact con = [SELECT Id, Name FROM Contact LIMIT 1];

        Test.startTest();
        Pagereference lopPage = Page.LetterOfParticipation;
        Test.setCurrentPage(lopPage);
        lopPage.getParameters().put('eventId',event.Id);
        lopPage.getParameters().put('isLive','true');

        Apexpages.StandardController stdController = new Apexpages.StandardController(con);

        ParticipantLetterController letterCtrl = new ParticipantLetterController(stdController);

        letterCtrl.getLetterContents();

        System.debug('letterCtrl: ' + letterCtrl);

        System.assertEquals(event.Id, letterCtrl.eventId);

        Test.stopTest();
    }

    @IsTest
    static void test_getFontevaEvents() {

        EventApi__Event__c event = [SELECT Id FROM EventApi__Event__c LIMIT 1];
        Contact con = [SELECT Id, Name FROM Contact LIMIT 1];

        Test.startTest();
        Pagereference lopPage = Page.LetterOfParticipation;
        Test.setCurrentPage(lopPage);
        lopPage.getParameters().put('eventId',event.Id);
        lopPage.getParameters().put('isLive','false');

        Apexpages.StandardController stdController = new Apexpages.StandardController(con);

        ParticipantLetterController letterCtrl = new ParticipantLetterController(stdController);

        letterCtrl.getLetterContents();

        System.debug('letterCtrl: ' + letterCtrl);

        System.assertEquals(event.Id, letterCtrl.eventId);

        Test.stopTest();
    }
}