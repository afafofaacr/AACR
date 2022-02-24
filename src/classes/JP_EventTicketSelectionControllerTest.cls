/**
 * Created by lauren.lezberg on 6/11/2020.
 */
@isTest
public with sharing class JP_EventTicketSelectionControllerTest {

    @testSetup
    public static void setup(){
        Account acc = TestDataFactory.buildAccount('Test Account');
        insert acc;

        Contact con = TestDataFactory.buildContact(acc.Id);
        insert con;

        User u = TestDataFactory.buildUser(con.Id);
        insert u;

        BR_Event__c evt = LiveTestDataFactory.buildEvent('Test Event', false, false);
        insert evt;

        AC_User_Segment__c uSeg = LiveTestDataFactory.buildUserSegment('Default');
        uSeg.Query__c = 'SELECT Id FROM User WHERE IsActive = true';
        insert uSeg;

        AC_Event_User_Segment__c euSeg = LiveTestDataFactory.buildEventUserSegment(evt.Id, uSeg.Id, null);
        euSeg.Price__c = 100;
        euSeg.Early_Bird_Price__c=50;
        euSeg.Early_Bird_Price_Deadline__c = System.now().addDays(-5);
        insert euSeg;

        AC_User_Segment__c uSeg2 = LiveTestDataFactory.buildUserSegment('Portal Users');
        uSeg.Query__c = 'SELECT Id FROM User WHERE IsActive = true AND ContactId!=null';
        insert uSeg2;

        AC_Event_User_Segment__c euSeg2 = LiveTestDataFactory.buildEventUserSegment(evt.Id, uSeg.Id, null);
        euSeg2.Price__c = 200;
        euSeg2.On_Demand_Price__c = 150;
        euSeg2.On_Demand_Start_Date__c = Date.today();
        insert euSeg2;

        OrderApi__Item_Class__c iClass = TestDataFactory.buildItemClass('Live Event Tickets');
        insert iClass;

        OrderApi__Item__c ticketItem = TestDataFactory.buildItem(iClass.Id, 'Test Event Ticket');
        ticketItem.AC_Event__c = evt.Id;
        insert ticketItem;
    }

    @isTest
    public static void test_getUserPrice(){
        Contact con = [SELECT Id, AccountId FROM Contact WHERE Account.Name = 'Test Account'];

        User u = [SELECT Id FROM User WHERE ContactId=: con.Id];

        BR_Event__c evt = [SELECT Id FROM BR_Event__c WHERE Name = 'Test Event'];

        OrderApi__Sales_Order__c so = TestDataFactory.buildOpenSalesOrder(con.AccountId, con.Id);
        insert so;

        OrderApi__Item_Class__c iClass = [SELECT Id FROM OrderApi__Item_Class__c];
        OrderApi__Item__c item = [SELECT Id FROM OrderApi__Item__c];



        Test.startTest();
        System.runAs(u) {
            JP_EventTicketSelectionController.EventTickets tickets = JP_EventTicketSelectionController.getUserTicketPrice(evt.Id, so.Id);
            System.assertNotEquals(null, tickets);

            OrderApi__Sales_Order_Line__c line = TestDataFactory.buildSOLine(so.Id, item.Id, iClass.Id);
            insert line;

            tickets = JP_EventTicketSelectionController.getUserTicketPrice(evt.Id, so.Id);
            System.assertNotEquals(null, tickets);

        }

        Test.stopTest();
    }

    @isTest
    public static void test_getUserSegments(){
        BR_Event__c evt = [SELECT Id FROM BR_Event__c WHERE Name = 'Test Event'];

        Test.startTest();
        Map<String,Decimal> segments = JP_EventTicketSelectionController.getUserSegments(evt.Id);
        System.assertEquals(3, segments.size());

        Test.stopTest();
    }

    @isTest
    public static void test_addTicketToSalesOrder(){
        Contact con = [SELECT Id, AccountId FROM Contact WHERE Account.Name = 'Test Account'];

        User u = [SELECT Id FROM User WHERE ContactId=: con.Id];

        BR_Event__c evt = [SELECT Id FROM BR_Event__c WHERE Name = 'Test Event'];

        OrderApi__Sales_Order__c so = TestDataFactory.buildOpenSalesOrder(con.AccountId, con.Id);
        insert so;

        System.runAs(u) {

            Test.startTest();

            Boolean ticketAdded = JP_EventTicketSelectionController.addTicketToSalesOrder(so.Id, evt.Id, 100.00, 'Default');
            System.assertEquals(true, ticketAdded);

            Test.stopTest();
        }
    }


    @isTest
    public static void test_getUserTicketPrice() {
        Contact con = [SELECT Id, AccountId FROM Contact WHERE Account.Name = 'Test Account'];

        User u = [SELECT Id FROM User WHERE ContactId=: con.Id];

        OrderApi__Item__c item = [SELECT Id, OrderApi__Item_Class__c, AC_Event__c FROM OrderApi__Item__c WHERE Name = 'Test Event Ticket'];

        OrderApi__Sales_Order__c so = TestDataFactory.buildOpenSalesOrder(con.AccountId, con.Id);
        insert so;

        System.runAs(u) {

            Test.startTest();

            //TODO: Fix tests
            JP_EventTicketSelectionController.EventTickets priceMap = JP_EventTicketSelectionController.getUserTicketPrice(null, so.Id);
            System.assertEquals(null, priceMap);

            priceMap = JP_EventTicketSelectionController.getUserTicketPrice(item.AC_Event__c, null);
            System.assertEquals(null, priceMap);

            priceMap = JP_EventTicketSelectionController.getUserTicketPrice(item.AC_Event__c, so.Id);
            System.assertNotEquals(null, priceMap);

            OrderApi__Sales_Order_Line__c sol = TestDataFactory.buildSOLine(so.Id, item.Id, item.OrderApi__Item_Class__c);
            insert sol;

            priceMap = JP_EventTicketSelectionController.getUserTicketPrice(item.AC_Event__c, so.Id);
            System.assertNotEquals(null, priceMap);


            Test.stopTest();
        }
    }



    @isTest
    public static void test_getEventId(){
        Contact con = [SELECT Id, AccountId FROM Contact WHERE Account.Name = 'Test Account'];

        OrderApi__Item__c item = [SELECT Id, OrderApi__Item_Class__c, AC_Event__c FROM OrderApi__Item__c WHERE Name = 'Test Event Ticket'];

        OrderApi__Sales_Order__c so = TestDataFactory.buildOpenSalesOrder(con.AccountId, con.Id);
        insert so;


        Test.startTest();


        String eventId = JP_EventTicketSelectionController.getEventId(so.Id);
        System.assertEquals(null, eventId);

        OrderApi__Sales_Order_Line__c sol = TestDataFactory.buildSOLine(so.Id, item.Id, item.OrderApi__Item_Class__c);
        insert sol;

        eventId = JP_EventTicketSelectionController.getEventId(so.Id);
        System.assertEquals(item.AC_Event__c, eventId);


        Test.stopTest();

    }

}