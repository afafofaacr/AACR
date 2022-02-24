/**
 * Created by mitfity on 17.07.2019.
 */

@IsTest
private class brPurchaseTicketControllerTest {


    @IsTest
    public static void test_registerForCoupledEvent(){
        BR_Event__c pEvent = new BR_Event__c(
                Name = 'Parent Event',
                Start_Date__c = Datetime.newInstance(2016, 10, 15, 12, 30, 0),
                End_Date__c = Datetime.newInstance(2016, 10, 15, 17, 30, 0),
                Location__Latitude__s = 51.5156950,
                Location__Longitude__s = -0.0893931,
                Venue_Address__c = 'Test ave 12/20',
                Registration_Confirmation_Message__c = 'TEST MESSAGE'
        );
        insert pEvent;

        AC_User_Segment__c def = new AC_User_Segment__c();
        def.Name = 'Default';
        def.Description__c = 'Test';
        def.Query__c = 'SELECT Id FROM User WHERE Country = \'United States\'';
        insert def;


        BR_Event__c cEvent = new BR_Event__c(
                Name = 'Child Event',
                Start_Date__c = Datetime.newInstance(2016, 10, 15, 12, 30, 0),
                End_Date__c = Datetime.newInstance(2016, 10, 15, 17, 30, 0),
                Location__Latitude__s = 51.5156950,
                Location__Longitude__s = -0.0893931,
                Venue_Address__c = 'Test ave 12/20',
                Parent_Event__c=pEvent.Id,
                Registration_Confirmation_Message__c = 'TEST MESSAGE'
        );
        insert cEvent;

        Account acc = TestDataFactory.buildAccount('Test Account');
        insert acc;

        Contact con = TestDataFactory.buildContact(acc.Id);
        insert con;

        User u = TestDataFactory.buildUser(con.Id);
        insert u;

        List<OrgWideEmailAddress> owas = [SELECT Id FROM OrgWideEmailAddress LIMIT 1];
        System.assertEquals(owas.size(), 1);

        insert new BrEvents_Settings__c(Name='org wide email id', Label__c = 'org wide email id', Value__c = owas[0].Id);

        BR_Participation__c p = new BR_Participation__c(BR_Event__c=pEvent.Id, AC_User_Segment__c=def.Id,Contact__c=con.Id, User__c=u.Id, Participate__c = 'Yes');
        insert p;

        System.runAs(u) {
            Test.startTest();

            Boolean registered = brPurchaseTicketController.registerForCoupledEvent(cEvent.Id);
            System.assertEquals(true, registered);

            Test.stopTest();
        }


    }


    @IsTest
    public static void test_sendRefundRequest(){
        BR_Event__c testEvent = new BR_Event__c(
                Name = 'Test event0',
                Start_Date__c = Datetime.newInstance(2016, 10, 15, 12, 30, 0),
                End_Date__c = Datetime.newInstance(2016, 10, 15, 17, 30, 0),
                Location__Latitude__s = 51.5156950,
                Location__Longitude__s = -0.0893931,
                Venue_Address__c = 'Test ave 12/20',
                Registration_Confirmation_Message__c = 'TEST MESSAGE'
        );

        insert testEvent;

        Account acc = TestDataFactory.buildAccount('Test Account');
        insert acc;

        Contact con = TestDataFactory.buildContact(acc.Id);
        insert con;

        User u = TestDataFactory.buildUser(con.Id);
        insert u;

        List<OrgWideEmailAddress> owas = [SELECT Id FROM OrgWideEmailAddress LIMIT 1];
        System.assertEquals(owas.size(), 1);

        insert new BrEvents_Settings__c(Name='org wide email id', Label__c = 'org wide email id', Value__c = owas[0].Id);

        BR_Participation__c p = new BR_Participation__c(BR_Event__c=testEvent.Id,Contact__c=con.Id, User__c=u.Id, Participate__c = 'Yes');
        insert p;

        System.runAs(u){
            Test.startTest();

            Boolean resp = brPurchaseTicketController.sendRefundRequest(testEvent.Id);
            System.assertEquals(true, resp);

            Test.stopTest();
        }
    }

    @isTest
    static void test_checkForTicket(){
        BR_Event__c testEvent = new BR_Event__c(
                Name = 'Test event0',
                Start_Date__c = Datetime.newInstance(2016, 10, 15, 12, 30, 0),
                End_Date__c = Datetime.newInstance(2016, 10, 15, 17, 30, 0),
                Location__Latitude__s = 51.5156950,
                Location__Longitude__s = -0.0893931,
                Venue_Address__c = 'Test ave 12/20'
        );

        insert testEvent;


        AC_User_Segment__c employees = new AC_User_Segment__c();
        employees.Name = 'Employees';
        employees.Description__c = 'Test';
        employees.Query__c = 'SELECT Id FROM User WHERE Country = \'United States\'';
        insert employees;

        AC_Event_User_Segment__c eventEmployees = new AC_Event_User_Segment__c();

        eventEmployees.AC_Event__c = testEvent.Id;
        eventEmployees.AC_User_Segment__c = employees.Id;
        eventEmployees.Price__c = 3.88;
        eventEmployees.Priority__c = 10;
        eventEmployees.Event_Preferences_Form_Fieldset__c = 'test';
        insert eventEmployees;

        OrderApi__Item_Class__c itemClass = TestDataFactory.buildItemClass('Live Event Tickets');
        insert itemClass;

        OrderApi__Item__c itm = TestDataFactory.buildItem(itemClass.Id, 'Test event0 Ticket');
        itm.AC_Event__c = testEvent.Id;
        insert itm;

        Account acc = TestDataFactory.buildAccount('Test Account');
        insert acc;

        Contact con = TestDataFactory.buildContact(acc.Id);
        insert con;

        User u = TestDataFactory.buildUser(con.Id);
        insert u;

        System.runAs(u) {
            Test.startTest();

            BR_Participation__c participation = brPurchaseTicketController.checkForTicket(testEvent.Id);
            System.assertEquals(null, participation);

            BR_Participation__c p = new BR_Participation__c(BR_Event__c = testEvent.Id, Contact__c = con.Id, User__c = u.Id, Participate__c = 'Pending Approval');
            insert p;

            participation = brPurchaseTicketController.checkForTicket(testEvent.Id);
            System.assertNotEquals(null, participation);


            Test.stopTest();
        }
    }

    @isTest
    static void test_completePurchase(){
        BR_Event__c testEvent = new BR_Event__c(
                Name = 'Test event0',
                Start_Date__c = Datetime.newInstance(2016, 10, 15, 12, 30, 0),
                End_Date__c = Datetime.newInstance(2016, 10, 15, 17, 30, 0),
                Location__Latitude__s = 51.5156950,
                Location__Longitude__s = -0.0893931,
                Venue_Address__c = 'Test ave 12/20'
        );

        insert testEvent;


        AC_User_Segment__c employees = new AC_User_Segment__c();
        employees.Name = 'Employees';
        employees.Description__c = 'Test';
        employees.Query__c = 'SELECT Id FROM User WHERE Country = \'United States\'';
        insert employees;

        AC_Event_User_Segment__c eventEmployees = new AC_Event_User_Segment__c();

        eventEmployees.AC_Event__c = testEvent.Id;
        eventEmployees.AC_User_Segment__c = employees.Id;
        eventEmployees.Price__c = 3.88;
        eventEmployees.Priority__c = 10;
        eventEmployees.Event_Preferences_Form_Fieldset__c = 'test';
        insert eventEmployees;

        OrderApi__Item_Class__c itemClass = TestDataFactory.buildItemClass('Live Event Tickets');
        insert itemClass;

        OrderApi__Item__c itm = TestDataFactory.buildItem(itemClass.Id, 'Test event0 Ticket');
        itm.AC_Event__c = testEvent.Id;
        insert itm;

        Account acc = TestDataFactory.buildAccount('Test Account');
        insert acc;

        Contact con = TestDataFactory.buildContact(acc.Id);
        insert con;

        User u = TestDataFactory.buildUser(con.Id);
        insert u;

        OrderApi__Sales_Order__c ticketSO = TestDataFactory.buildOpenSalesOrder(acc.Id, con.Id);
        insert ticketSO;

        OrderApi__Sales_Order_Line__c ticketLine = new OrderApi__Sales_Order_Line__c(OrderApi__Sales_Order__c=ticketSO.Id, OrderApi__Item__c=itm.Id);
        insert ticketLine;


        BR_Participation__c p = new BR_Participation__c(Fon_Sales_Order__c=ticketSO.Id, BR_Event__c = testEvent.Id, Contact__c = con.Id, User__c = u.Id, Participate__c = 'Awaiting Payment');
        insert p;

        System.runAs(u) {
            Test.startTest();

            String paymentURL = brPurchaseTicketController.completePurchase(testEvent.Id);
            System.assertNotEquals(null, paymentURL);

            Test.stopTest();
        }
    }

    @IsTest
    static void testGetEventPreferencesFormFields() {
        Test.startTest();

        Account acc = TestDataFactory.buildAccount('Test Account');
        insert acc;

        Contact con = TestDataFactory.buildContact(acc.Id);
        insert con;

        User u = TestDataFactory.buildUser(con.Id);
        insert u;

//        BrEventTestUtils.assignPermissionSet(u.Id, 'Live_Events');

        Id currentUserId = UserInfo.getUserId();
        BR_Event__c testEvent = new BR_Event__c(
                Name = 'Test event0',
                Start_Date__c = Datetime.newInstance(2016, 10, 15, 12, 30, 0),
                End_Date__c = Datetime.newInstance(2016, 10, 15, 17, 30, 0),
                Location__Latitude__s = 51.5156950,
                Location__Longitude__s = -0.0893931,
                Venue_Address__c = 'Test ave 12/20'
        );

        insert testEvent;


        AC_User_Segment__c employees = new AC_User_Segment__c();
        employees.Name = 'Employees';
        employees.Description__c = 'Test';
        employees.Query__c = 'SELECT Id FROM User WHERE Id = \'' + u.Id + '\'';
        insert employees;

        AC_Event_User_Segment__c eventEmployees = new AC_Event_User_Segment__c();

        eventEmployees.AC_Event__c = testEvent.Id;
        eventEmployees.AC_User_Segment__c = employees.Id;
        eventEmployees.Price__c = 3.88;
        eventEmployees.Priority__c = 10;
        eventEmployees.Event_Preferences_Form_Fieldset__c = 'test';
        insert eventEmployees;

        OrderApi__Sales_Order__c order = new OrderApi__Sales_Order__c();
        order.OrderApi__Contact__c = con.Id;
        order.OrderApi__Status__c = 'Open';
        insert order;

        OrderApi__Item_Class__c itemClass = TestDataFactory.buildItemClass('Live Event Tickets');
        insert itemClass;

        OrderApi__Item__c itm = TestDataFactory.buildItem(itemClass.Id, 'Test event0 Ticket');
        itm.AC_Event__c = testEvent.Id;
        insert itm;

        OrderApi__Sales_Order_Line__c line = new OrderApi__Sales_Order_Line__c();
        line.OrderApi__Sales_Order__c = order.Id;
        line.OrderApi__Item__c = itm.Id;
        insert line;

        BR_Participation__c participation = new BR_Participation__c();
        participation.Fon_Sales_Order__c = order.Id;
        participation.BR_Event__c = testEvent.Id;
        participation.User__c = UserInfo.getUserId();

        insert participation;

        Profile stdUserProfile = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
        User user = new User(Alias = 'testusr1', Email='testusr100@testorg.com',
                EmailEncodingKey='UTF-8', LastName='Testing1', LanguageLocaleKey='en_US',
                LocaleSidKey='en_US', ProfileId = stdUserProfile.Id,
                TimeZoneSidKey = UserInfo.getTimeZone().getID(), UserName='testusr100@testorg.com');

        insert user;
//        System.assertNotEquals(null, user.Id, 'user is not created');
//        BrEventTestUtils.assignPermissionSet(user.Id, 'Live_Events');

        System.runAs(user) {

            brPurchaseTicketController.FormFieldData fields = brPurchaseTicketController.getEventPreferencesFormFields(order.Id, order.Id);

            System.assertNotEquals(null, fields);
        }

        Test.stopTest();
    }

//    @IsTest
//    static void testSaveEventPreferences() {
//        Test.startTest();
//
//        Id currentUserId = UserInfo.getUserId();
//        BR_Event__c testEvent = new BR_Event__c(
//                Name = 'Test event0',
//                Start_Date__c = Datetime.newInstance(2016, 10, 15, 12, 30, 0),
//                Location__Latitude__s = 51.5156950,
//                Location__Longitude__s = -0.0893931,
//                Venue_Address__c = 'Test ave 12/20'
//        );
//        insert testEvent;
//
//        AC_User_Segment__c employees = new AC_User_Segment__c();
//        employees.Name = 'Employees';
//        employees.Description__c = 'Test';
//        employees.Query__c = 'SELECT Id FROM User WHERE Id = \'' + currentUserId + '\'';
//        insert employees;
//
//        AC_Event_User_Segment__c eventEmployees = new AC_Event_User_Segment__c();
//
//        eventEmployees.AC_Event__c = testEvent.Id;
//        eventEmployees.AC_User_Segment__c = employees.Id;
//        eventEmployees.Price__c = 3.88;
//        eventEmployees.Priority__c = 10;
//        eventEmployees.Event_Preferences_Form_Fieldset__c = 'test';
//        insert eventEmployees;
//
//        OrderApi__Sales_Order__c order = new OrderApi__Sales_Order__c();
//        order.OrderApi__Status__c = 'Open';
//        insert order;
//
//        BR_Participation__c participation = new BR_Participation__c();
//        participation.Fon_Sales_Order__c = order.Id;
//        participation.BR_Event__c = testEvent.Id;
//        participation.User__c = UserInfo.getUserId();
//
//        insert participation;
//
////        brPurchaseTicketController.saveEventPreferences(order.Id, '{ "Participate__c": "Yes" }');
//
//        participation = [
//                SELECT Participate__c
//                FROM BR_Participation__c
//                WHERE BR_Event__c = :testEvent.Id
//                AND User__c = :UserInfo.getUserId()
//        ];
//
//        System.assertNotEquals('Yes', participation.Participate__c);
//
//        Test.stopTest();
//    }


    @IsTest (SeeAllData=true)
    static void testGetTicketPurchaseUrl() {
        Test.startTest();

        BR_Event__c testEvent = new BR_Event__c(
                Name = 'Test event0',
                Start_Date__c = Datetime.newInstance(2016, 10, 15, 12, 30, 0),
                End_Date__c = Datetime.newInstance(2016, 10, 15, 17, 30, 0),
                Location__Latitude__s = 51.5156950,
                Location__Longitude__s = -0.0893931,
                Venue_Address__c = 'Test ave 12/20',
                Event_Preferences_Form_Fieldset__c = 'test'
        );
        insert testEvent;

        OrderApi__Item_Class__c itemClass = TestDataFactory.buildItemClass('Live Event Tickets');
        itemClass.OrderApi__Is_Subscription__c = false;
        insert itemClass;

        OrderApi__Item__c item = TestDataFactory.buildItem(itemClass.Id, 'Test event0 Ticket');
        item.OrderApi__Is_Subscription__c= false;
        item.AC_Event__c = testEvent.Id;
        insert item;

        Id currentUserId = UserInfo.getUserId();

        Account acc = TestDataFactory.buildAccount('Test Account');
        insert acc;

        Contact con = TestDataFactory.buildContact(acc.Id);
        insert con;

        User u = TestDataFactory.buildUser(con.Id);
        insert u;


        AC_User_Segment__c employees = new AC_User_Segment__c();
        employees.Name = 'Employees';
        employees.Description__c = 'Test';
        employees.Query__c = 'SELECT Id FROM User WHERE Id = \'' + u.Id + '\'';
        insert employees;

        AC_Event_User_Segment__c eventEmployees = new AC_Event_User_Segment__c();

        eventEmployees.AC_Event__c = testEvent.Id;
        eventEmployees.AC_User_Segment__c = employees.Id;
        eventEmployees.Price__c = 3.88;
        eventEmployees.Priority__c = 10;
        insert eventEmployees;

//        insert new BrEvents_Settings__c(Name = 'Join Process Id', Value__c = 'qwe');

//        Profile stdUserProfile = [SELECT Id FROM Profile WHERE Name = 'Standard User'];
//        User user = new User(Alias = 'testusr1', Email='testusr100@testorg.com',
//                EmailEncodingKey='UTF-8', LastName='Testing1', LanguageLocaleKey='en_US',
//                LocaleSidKey='en_US', ProfileId = stdUserProfile.Id,
//                TimeZoneSidKey = UserInfo.getTimeZone().getID(), UserName='testusr100@testorg.com');
//
//        insert user;
//        BrEventTestUtils.assignPermissionSet(u.Id, 'Live_Events');


        System.runAs(u) {

            String purchaseUrl = brPurchaseTicketController.getTicketPurchaseUrl(testEvent.Id);

            System.assertNotEquals(null, purchaseUrl);

            String newPurchaseUrl = brPurchaseTicketController.getTicketPurchaseUrl(testEvent.Id);

            System.assertNotEquals(purchaseUrl, newPurchaseUrl);
        }

        Test.stopTest();
    }

    @IsTest(seeAllData=true)
    public static void test_guestUser(){
        BR_Event__c testEvent = new BR_Event__c(
                Name = 'Test event0',
                Start_Date__c = Datetime.newInstance(2016, 10, 15, 12, 30, 0),
                End_Date__c = Datetime.newInstance(2016, 10, 15, 17, 30, 0),
                Location__Latitude__s = 51.5156950,
                Location__Longitude__s = -0.0893931,
                Venue_Address__c = 'Test ave 12/20',
                Event_Preferences_Form_Fieldset__c = 'test'
        );
        insert testEvent;

        OrderApi__Item_Class__c itemClass = TestDataFactory.buildItemClass('Live Event Tickets');
        itemClass.OrderApi__Is_Subscription__c = false;
        insert itemClass;

        OrderApi__Item__c item = TestDataFactory.buildItem(itemClass.Id, 'Test event0 Ticket');
        item.OrderApi__Is_Subscription__c= false;
        item.AC_Event__c = testEvent.Id;
        insert item;

        Id currentUserId = UserInfo.getUserId();

        Account acc = TestDataFactory.buildAccount('Test Account');
        insert acc;

        Contact con = TestDataFactory.buildContact(acc.Id);
        insert con;

        User u = TestDataFactory.buildUser(con.Id);
        insert u;


        AC_User_Segment__c employees = new AC_User_Segment__c();
        employees.Name = 'Employees';
        employees.Description__c = 'Test';
        employees.Query__c = 'SELECT Id FROM User WHERE Id = \'' + u.Id + '\'';
        insert employees;

        AC_Event_User_Segment__c eventEmployees = new AC_Event_User_Segment__c();

        eventEmployees.AC_Event__c = testEvent.Id;
        eventEmployees.AC_User_Segment__c = employees.Id;
        eventEmployees.Price__c = 3.88;
        eventEmployees.Priority__c = 10;
        insert eventEmployees;


        User portalGuest = [select id from user where usertype='Guest' AND IsActive=true limit 1];

        System.RunAs( portalGuest ) {
            Test.startTest();

            String purchaseUrl = brPurchaseTicketController.getTicketPurchaseUrl(testEvent.Id);

            System.assertNotEquals(null, purchaseUrl);

            Test.stopTest();
        }
    }
}