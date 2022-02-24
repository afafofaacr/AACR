/**
 * Created by afaf.awad on 5/22/2020.
 */

@IsTest
private class EventLetterControllerTest {

        @TestSetup
        public static void setup() {


                Account acc = LiveTestDataFactory.buildAccount('Test Account');
                insert acc;

                Contact contact = LiveTestDataFactory.buildContact(acc.Id);
                insert contact;

                List<OrgWideEmailAddress> owas = [SELECT Id FROM OrgWideEmailAddress LIMIT 1];

                insert new BrEvents_Settings__c(Name='org wide email id', Label__c = 'org wide email id', Value__c = owas[0].Id);

                BR_Events_Zone__c zone = LiveTestDataFactory.buildZone('Test Zone', true);
                insert zone;

                Venue__c ven = LiveTestDataFactory.buildVenue('Test Venue');
                insert ven;

                BR_Event__c event = LiveTestDataFactory.buildEvent('Test Event',false,false);
                event.Draft_Program__c = 'Test Draft Program';
                event.Venue__c = ven.Id;
                event.Publicly_available__c = TRUE;
                event.Draft__c = FALSE;
                event.Registration_Confirmation_Message__c = 'You Registered!';
                event.Event_Stage__c='In Person';
                insert event;

                BR_Participation__c part = new BR_Participation__c(Contact__c=contact.Id, BR_Event__c=event.Id, Participate__c='Yes');

                insert new BrEvents_Settings__c(Name='org wide email id', Label__c = 'org wide email id', Value__c = owas[0].Id);

                insert part;


//        // Create test records
//        Account acc = TestDataFactory.buildAccount('Test Account');
//        insert acc;
//
//        Contact con = TestDataFactory.buildContact(acc.Id);
//        con.Title = 'Example to Set';
//        con.Salutation = 'Ms.';
//        insert con;
//
//        BR_Event__c event = LiveTestDataFactory.buildEvent('Test Event',false,false);
//        event.Draft_Program__c = 'Test Draft Program';
//        event.Publicly_available__c = TRUE;
//        event.Draft__c = FALSE;
//        event.Registration_Confirmation_Message__c = 'You Registered!';
//        event.Event_Stage__c='In Person';
//                event.Letter_of_Participation__c = 'This is a test message for letter';
//        insert event;
//
////        EventApi__Event__c testEvt = TestDataFactory.buildEvent();
////        testEvt.Name = 'Test Event';
////        testEvt.EventApi__Event_Key__c = '3847294726';
////        testEvt.EventApi__Start_Date__c = Date.today();
////        testEvt.EventApi__Start_Time__c = '08:00 AM';
////        testEvt.EventApi__End_Time__c = '08:00 PM';
////        testEvt.EventApi__End_Date__c = Date.today().addDays(2);
////        testEvt.EventApi__Logo_Image__c = 'https://www.testImgurl.com';
////        testEvt.EventApi__Description__c = 'THIS IS A TEST EVENT.';
////                testEvt.Letter_of_Participation__c = 'This is a test message for letter';
////        insert testEvt;
//
//        EventApi__Attendee__c testAtt = new EventApi__Attendee__c(EventApi__Event__c = testEvt.Id,
//        EventApi__Contact__c = con.Id);
//        insert testAtt;
    }

        @IsTest
        public static void Test_getLetterContents(){

                String eventId = [SELECT Id FROM BR_Event__c WHERE Name LIKE 'Test Event' LIMIT 1 ].Id;

                Contact con = [SELECT Id from Contact LIMIT 1 ];

                PageReference pageRef = Page.LetterOfParticipation;
                Test.setCurrentPage(pageRef);
                ApexPages.currentPage().getParameters().put('eventId',eventId);

                Test.startTest();
                ApexPages.StandardController controller = new ApexPages.StandardController(con);
                EventLetterController elc = new EventLetterController(controller);

                elc.getLetterContents();

                Test.stopTest();

                System.assertEquals(true, !String.isBlank(elc.bodyContent));
        }
}