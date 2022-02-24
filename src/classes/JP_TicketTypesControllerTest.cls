/**
 * Created by lauren.lezberg on 2/21/2020.
 */
@isTest
private with sharing class JP_TicketTypesControllerTest {


    @testSetup public static void setup(){
        Account acc = LiveTestDataFactory.buildAccount('Test Account');
        insert acc;

        Contact con = LiveTestDataFactory.buildContact(acc.Id);
        insert con;

        BR_Events_Zone__c zone = LiveTestDataFactory.buildZone('Test Zone', true);
        insert zone;

        BR_Event__c event = LiveTestDataFactory.buildEvent('Test Event', false, true);
        event.Show_Workshop_Fields__c = true;
        event.Show_Pre_Post_Doc__c = true;
        event.Show_Joint_Fields__c = true;
        event.BR_Events_Zone__c = zone.Id;
        insert event;

        AC_User_Segment__c defaultSeg = LiveTestDataFactory.buildUserSegment('Nonmember Individual');
        insert defaultSeg;

        AC_User_Segment__c prePostSeg = LiveTestDataFactory.buildUserSegment('Pre/Post Doc');
        prePostSeg.Query__c = 'SELECT Id FROM User WHERE ContactId IN (SELECT Id FROM Contact WHERE Pre_Post_Doc__c = true)';
        prePostSeg.Available__c = true;
        prePostSeg.Active__c = true;
        insert prePostSeg;

        AC_User_Segment__c us1 = LiveTestDataFactory.buildUserSegment('Students');
        insert us1;

        AC_User_Segment__c us2 = LiveTestDataFactory.buildUserSegment('Members');
        insert us2;


    }

    @isTest public static void test_getTicketTypes(){
        BR_Event__c evt = [SELECT Id FROM BR_Event__c WHERE Name='Test Event' LIMIT 1];

        Test.startTest();
        JP_TicketTypesController.TicketTypeInfo tti = JP_TicketTypesController.getTicketTypes(evt.Id);
        System.assertNotEquals(null, tti);
        System.assertEquals(3, tti.userSegments.size());
        Test.stopTest();
    }

    @isTest public static void test_saveTicketTypes(){
        BR_Event__c evt = [SELECT Id FROM BR_Event__c WHERE Name='Test Event' LIMIT 1];
        AC_User_Segment__c studentSegment = [SELECT Id, Name FROM AC_User_Segment__c WHERE Name='Students'];

        Map<String, String> fieldSets = FS_SelectorController.getFieldSets('BR_Participation__c');

        String fieldSetName = 'Test Field Set';

        JP_TicketTypesController.TicketType tt = new JP_TicketTypesController.TicketType(100.00, 1.0,'Student Tickets', studentSegment.Id, 50.00, Datetime.newInstance(System.now().year(), System.now().month()-1, System.now().day()),null, null, fieldSetName);
        List<Object> ticketTypes = new List<Object>{tt};

        Test.startTest();

        JP_TicketTypesController.saveEventUserSegments(evt.Id, ticketTypes);

        JP_TicketTypesController.TicketTypeInfo tti = JP_TicketTypesController.getTicketTypes(evt.Id);

        JP_TicketTypesController.saveEventUserSegments(evt.Id, ticketTypes);

        Test.stopTest();

        System.assertNotEquals(null, tti);
        System.assertEquals(4, tti.userSegments.size());
        System.assertEquals(4, tti.ticketTypes.size());

        Integer segmentCount = [SELECT COUNT() FROM AC_Event_User_Segment__c WHERE AC_Event__c=: evt.Id];
        System.assertEquals(1, segmentCount);
    }

}