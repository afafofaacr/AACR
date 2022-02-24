/**
 * Created by mitfity on 15.07.2019.
 */

@IsTest
private class brEventParticipationManagerTest {

    @TestSetup
    static void setup() {
        OrgWideEmailAddress add = [SELECT Id FROM OrgWideEmailAddress LIMIT 1];
        BrEvents_Settings__c settings = new BrEvents_Settings__c(Name = 'org wide email id', Value__c = add.Id);
        insert settings;

        Account acc = TestDataFactory.buildAccount('Test Account');
        insert acc;

        Contact con = TestDataFactory.buildContact(acc.Id);
        insert con;

        User u = TestDataFactory.buildUser(con.Id);
        insert u;

        BR_Event__c item = new BR_Event__c(
                Name = 'Test event0',
                Start_Date__c = Datetime.now().addDays(10),
                End_Date__c = Datetime.now().addDays(11),
                Location__Latitude__s = 51.5156950,
                Location__Longitude__s = -0.0893931,
                Venue_Address__c = 'Test ave 12/20',
                Registration_Confirmation_Message__c = 'TEST MESSAGE'
        );
        insert item;
        insert new BR_Participation__c(BR_Event__c = item.Id, Contact__c = con.Id, Participate__c = 'Yes', User__c = u.Id);

        Profile stdUserProfile = [SELECT Id FROM Profile WHERE Name = 'Standard User'];
        User user = new User(Alias = 'testusr1', Email = 'testusr100@testorg.com',
                EmailEncodingKey = 'UTF-8', LastName = 'Testing1', LanguageLocaleKey = 'en_US',
                LocaleSidKey = 'en_US', ProfileId = stdUserProfile.Id,
                TimeZoneSidKey = UserInfo.getTimeZone().getID(), Username = 'testusr100@testorg.com');

        insert user;
        System.assertNotEquals(null, user.Id, 'user is not created');
        BrEventsHelper.insertUser(user.Id);

        User testUser = new User(Alias = 'testusr', Email = 'testusr200@testorg.com',
                EmailEncodingKey = 'UTF-8', LastName = 'Testing2', LanguageLocaleKey = 'en_US',
                LocaleSidKey = 'en_US', ProfileId = stdUserProfile.Id,
                TimeZoneSidKey = UserInfo.getTimeZone().getID(), Username = 'testusr200@testorg.com');

        insert testUser;
        System.assertNotEquals(null, testUser.Id, 'user is not created');
        BrEventsHelper.insertUser(testUser.Id);
    }

    @isTest
    public static void checkForTicketTypes() {
        BR_Event__c item = new BR_Event__c(
                Name = 'Test event1',
                Start_Date__c = datetime.newInstance(2015, 10, 15, 12, 30, 0),
                End_Date__c = datetime.newInstance(2015, 10, 15, 17, 30, 0),
                Location__Latitude__s = 51.5156950,
                Location__Longitude__s = -0.0893931,
                Venue_Address__c = 'Test ave 12/2'
        );
        insert item;

        AC_User_Segment__c employees = new AC_User_Segment__c();
        employees.Name = 'Employees';
        employees.Description__c = 'Test';
        employees.Query__c = 'SELECT Id FROM User LIMIT 5';
        insert employees;

        AC_User_Segment__c partners = new AC_User_Segment__c();
        partners.Name = 'Partners';
        partners.Description__c = 'test';
        partners.Query__c = 'SELECT Id FROM User LIMIT 1';
        insert partners;



        Test.startTest();

        Boolean hastickets = brEventParticipationManager.checkForTicketTypes(item.Id);
        System.assertEquals(false, hastickets);


        AC_Event_User_Segment__c eventEmployees = new AC_Event_User_Segment__c();

        eventEmployees.AC_Event__c = item.Id;
        eventEmployees.AC_User_Segment__c = employees.Id;
        eventEmployees.Price__c = 3.88;
        eventEmployees.Priority__c = 10;
        insert eventEmployees;

        AC_Event_User_Segment__c eventPartners = new AC_Event_User_Segment__c();

        eventPartners.AC_Event__c = item.Id;
        eventPartners.AC_User_Segment__c = partners.Id;
        eventPartners.Price__c = 2.22;
        eventPartners.Priority__c = 9;
        insert eventPartners;

        hastickets = brEventParticipationManager.checkForTicketTypes(item.Id);
        System.assertEquals(true, hastickets);

        Test.stopTest();
    }

    @IsTest
    public static void testRespondToEvent() {

        Id recordId;
        String rsvpType = 'Yes';
        Integer attendeesLimit = 0; //attendeesLimit is zero, means no limit

        BR_Event__c item = new BR_Event__c(
                Name = 'Test event1',
                Start_Date__c = datetime.newInstance(2015, 10, 15, 12, 30, 0),
                End_Date__c = datetime.newInstance(2015, 10, 15, 17, 30, 0),
                Location__Latitude__s = 51.5156950,
                Location__Longitude__s = -0.0893931,
                Venue_Address__c = 'Test ave 12/2'
        );
        insert item;

        User user = [SELECT Id FROM User WHERE Username = 'testusr100@testorg.com'];

        System.runAs(user) {
            //reecord id is null or empty
            String result = brEventParticipationManager.respondToEvent(recordId, rsvpType, attendeesLimit);
            System.assertEquals('error', result, 'item id is empty');

            //rsvpType is empty
            recordId = item.Id;
            rsvpType = '';
            result = brEventParticipationManager.respondToEvent(recordId, rsvpType, attendeesLimit);
            System.assertEquals('error', result, 'rsvpType is empty');


            rsvpType = 'No';
            result = brEventParticipationManager.respondToEvent(recordId, rsvpType, attendeesLimit);
            System.assertEquals('0', result, 'wrong number of attendees');

//            rsvpType = 'Yes';
//            result = brEventParticipationManager.respondToEvent(recordId, rsvpType, attendeesLimit);
//            System.assertEquals('1', result, 'wrong number of attendees');
        }

        User testUser = [SELECT Id FROM User WHERE Username = 'testusr200@testorg.com'];

//        System.runAs(testUser) {
//            //attendeesLimit more than current number of attendees, current attendees number is 1
//            recordId = item.Id;
//            attendeesLimit = 1;
//            rsvpType = 'Yes';
//            String result = brEventParticipationManager.respondToEvent(recordId, rsvpType, attendeesLimit);
//            System.assertEquals('limit_exceded', result, 'limit of attendees is exceeded');
//        }
    }

    @isTest
    public static void testGetTicketPriceMap() {
        Test.startTest();

        Id currentUserId = UserInfo.getUserId();

        AC_User_Segment__c employees = new AC_User_Segment__c();
        employees.Name = 'Employees';
        employees.Description__c = 'Test';
        employees.Query__c = 'SELECT Id FROM User WHERE Country = \'United States\'';
        insert employees;

        AC_User_Segment__c partners = new AC_User_Segment__c();
        partners.Name = 'Partners';
        partners.Description__c = 'test';
        partners.Query__c = 'SELECT Id FROM User WHERE Country != \'United States\'';
        insert partners;

        BR_Event__c testEvent = [SELECT Id FROM BR_Event__c WHERE Name = 'Test event0'];
        AC_Event_User_Segment__c eventEmployees = new AC_Event_User_Segment__c();

        eventEmployees.AC_Event__c = testEvent.Id;
        eventEmployees.AC_User_Segment__c = employees.Id;
        eventEmployees.Price__c = 3.88;
        eventEmployees.Priority__c = 10;
        insert eventEmployees;

        AC_Event_User_Segment__c eventPartners = new AC_Event_User_Segment__c();

        eventPartners.AC_Event__c = testEvent.Id;
        eventPartners.AC_User_Segment__c = partners.Id;
        eventPartners.Price__c = 2.22;
        eventPartners.Priority__c = 9;
        insert eventPartners;

//        Double ticketPrice = brEventParticipationManager.getTicketPrice(testEvent.Id);
//        System.assertEquals(eventEmployees.Price__c, ticketPrice);

        Map<String, AC_Event_User_Segment__c> ticketMap = brEventParticipationManager.getTicketPrice(testEvent.Id, currentUserId);
        System.assertEquals(ticketMap.values().size(), 1);


        Test.stopTest();
    }

    @IsTest
    public static void testGetTicketPriceMapIgnorePriority() {
        Test.startTest();

        Id currentUserId = UserInfo.getUserId();

        AC_User_Segment__c employees = new AC_User_Segment__c();
        employees.Name = 'Employees';
        employees.Description__c = 'Test';
        employees.Query__c = 'SELECT Id FROM User WHERE Country = \'United States\'';
        insert employees;

        AC_User_Segment__c partners = new AC_User_Segment__c();
        partners.Name = 'Partners';
        partners.Description__c = 'test';
        partners.Query__c = 'SELECT Id FROM User WHERE Country != \'United States\'';
        insert partners;


        BR_Event__c testEvent = [SELECT Id FROM BR_Event__c WHERE Name = 'Test event0'];
        testEvent.Ignore_Segment_Priority__c = true;
        update testEvent;

        AC_Event_User_Segment__c eventEmployees = new AC_Event_User_Segment__c();

        eventEmployees.AC_Event__c = testEvent.Id;
        eventEmployees.AC_User_Segment__c = employees.Id;
        eventEmployees.Price__c = 3.25;
        eventEmployees.Priority__c = 5;
        insert eventEmployees;

        AC_Event_User_Segment__c eventPartners = new AC_Event_User_Segment__c();

        eventPartners.AC_Event__c = testEvent.Id;
        eventPartners.AC_User_Segment__c = partners.Id;
        eventPartners.Price__c = 2.12;
        eventPartners.Priority__c = 10;
        insert eventPartners;


        Map<String, AC_Event_User_Segment__c> ticketMap = brEventParticipationManager.getTicketPrice(testEvent.Id, currentUserId);
        System.assertEquals(ticketMap.values().size(), 1);

        Test.stopTest();
    }

    @IsTest
    public static void testGetTicketPrice() {
        Test.startTest();

        Id currentUserId = UserInfo.getUserId();

        AC_User_Segment__c employees = new AC_User_Segment__c();
        employees.Name = 'Employees';
        employees.Description__c = 'Test';
        employees.Query__c = 'SELECT Id FROM User WHERE Id = \'' + currentUserId + '\'';
        insert employees;

        AC_User_Segment__c partners = new AC_User_Segment__c();
        partners.Name = 'Partners';
        partners.Description__c = 'test';
        partners.Query__c = 'SELECT Id FROM User WHERE Id != \'' + currentUserId + '\' LIMIT 1';
        insert partners;

        BR_Event__c testEvent = [SELECT Id FROM BR_Event__c WHERE Name = 'Test event0'];
        AC_Event_User_Segment__c eventEmployees = new AC_Event_User_Segment__c();

        eventEmployees.AC_Event__c = testEvent.Id;
        eventEmployees.AC_User_Segment__c = employees.Id;
        eventEmployees.Price__c = 3.88;
        eventEmployees.Priority__c = 10;
        insert eventEmployees;

        AC_Event_User_Segment__c eventPartners = new AC_Event_User_Segment__c();

        eventPartners.AC_Event__c = testEvent.Id;
        eventPartners.AC_User_Segment__c = partners.Id;
        eventPartners.Price__c = 2.22;
        eventPartners.Priority__c = 9;
        insert eventPartners;

        Double ticketPrice = brEventParticipationManager.getTicketPrice(testEvent.Id);
        System.assertEquals(eventEmployees.Price__c, ticketPrice);


        Test.stopTest();
    }

    @IsTest
    public static void testGetTicketPriceByPriority() {
        Test.startTest();

        Id currentUserId = UserInfo.getUserId();

        AC_User_Segment__c employees = new AC_User_Segment__c();
        employees.Name = 'Employees';
        employees.Description__c = 'Test';
        employees.Query__c = 'SELECT Id FROM User WHERE Id=\'' + currentUserId + '\'';
        insert employees;

        AC_User_Segment__c partners = new AC_User_Segment__c();
        partners.Name = 'Partners';
        partners.Description__c = 'test';
        partners.Query__c = 'SELECT Id FROM User WHERE Id=\'' + currentUserId + '\'';
        insert partners;

        BR_Event__c testEvent = [SELECT Id FROM BR_Event__c WHERE Name = 'Test event0'];
        AC_Event_User_Segment__c eventEmployees = new AC_Event_User_Segment__c();

        eventEmployees.AC_Event__c = testEvent.Id;
        eventEmployees.AC_User_Segment__c = employees.Id;
        eventEmployees.Price__c = 3.88;
        eventEmployees.Priority__c = 10;
        insert eventEmployees;

        AC_Event_User_Segment__c eventPartners = new AC_Event_User_Segment__c();

        eventPartners.AC_Event__c = testEvent.Id;
        eventPartners.AC_User_Segment__c = partners.Id;
        eventPartners.Price__c = 2.22;
        eventPartners.Priority__c = 9;
        insert eventPartners;

        Double ticketPrice = brEventParticipationManager.getTicketPrice(testEvent.Id);

        System.assertEquals(eventPartners.Price__c, ticketPrice);

        Map<String, AC_Event_User_Segment__c> ticketMap = brEventParticipationManager.getTicketPrice(testEvent.Id, currentUserId);

        System.assertEquals(ticketMap.values().size(), 1);

        Test.stopTest();
    }

    @IsTest
    public static void testGetTicketPriceIgnorePriority() {
        Test.startTest();

        Id currentUserId = UserInfo.getUserId();

        AC_User_Segment__c employees = new AC_User_Segment__c();
        employees.Name = 'Employees';
        employees.Description__c = 'Test';
        employees.Query__c = 'SELECT Id FROM User WHERE Id = \'' + currentUserId + '\'';
        insert employees;

        AC_User_Segment__c partners = new AC_User_Segment__c();
        partners.Name = 'Partners';
        partners.Description__c = 'test';
        partners.Query__c = 'SELECT Id FROM User WHERE Id = \'' + currentUserId + '\'';
        insert partners;

        BR_Event__c testEvent = [SELECT Id FROM BR_Event__c WHERE Name = 'Test event0'];
        AC_Event_User_Segment__c eventEmployees = new AC_Event_User_Segment__c();

        eventEmployees.AC_Event__c = testEvent.Id;
        eventEmployees.AC_User_Segment__c = employees.Id;
        eventEmployees.Price__c = 3.25;
        eventEmployees.Priority__c = 5;
        insert eventEmployees;

        AC_Event_User_Segment__c eventPartners = new AC_Event_User_Segment__c();

        eventPartners.AC_Event__c = testEvent.Id;
        eventPartners.AC_User_Segment__c = partners.Id;
        eventPartners.Price__c = 2.12;
        eventPartners.Priority__c = 10;
        insert eventPartners;

        testEvent.Ignore_Segment_Priority__c = true;
        update testEvent;

        Double ticketPrice = brEventParticipationManager.getTicketPrice(testEvent.Id);

        System.assertEquals(eventPartners.Price__c, ticketPrice);

        Map<String, AC_Event_User_Segment__c> ticketMap = brEventParticipationManager.getTicketPrice(testEvent.Id, currentUserId);

        System.assertEquals(ticketMap.values().size(), 1);

        Test.stopTest();
    }

    @IsTest
    public static void testGetTicketPriceEarlyBird() {
        Test.startTest();

        Id currentUserId = UserInfo.getUserId();

        AC_User_Segment__c employees = new AC_User_Segment__c();
        employees.Name = 'Employees';
        employees.Description__c = 'Test';
        employees.Query__c = 'SELECT Id FROM User WHERE Id = \'' + currentUserId + '\'';
        insert employees;

        BR_Event__c testEvent = [SELECT Id FROM BR_Event__c WHERE Name = 'Test event0'];
        AC_Event_User_Segment__c eventEmployees = new AC_Event_User_Segment__c();

        eventEmployees.AC_Event__c = testEvent.Id;
        eventEmployees.AC_User_Segment__c = employees.Id;
        eventEmployees.Price__c = 3.88;
        eventEmployees.Priority__c = 10;
        eventEmployees.Early_Bird_Price__c = 2.22;
        eventEmployees.Early_Bird_Price_Deadline__c = Datetime.now().addDays(1);
        insert eventEmployees;

        Double ticketPrice = brEventParticipationManager.getTicketPrice(testEvent.Id);
        System.assertEquals(eventEmployees.Early_Bird_Price__c, ticketPrice);

        Map<String, AC_Event_User_Segment__c> ticketMap = brEventParticipationManager.getTicketPrice(testEvent.Id, currentUserId);

        System.assertEquals(ticketMap.values().size(), 1);

        Test.stopTest();
    }


    @IsTest
    static void testGetEventPreferencesFormFields() {
        Test.startTest();

        Contact con = [SELECT Id FROM Contact WHERE Account.Name = 'Test Account'];
        User u = [SELECT Id FROM User WHERE ContactId = :con.Id];
        Id currentUserId = u.Id;
        BR_Event__c testEvent = new BR_Event__c(
                Name = 'Test event0',
                Start_Date__c = Datetime.newInstance(2016, 10, 15, 12, 30, 0),
                End_Date__c = datetime.newInstance(2016, 10, 15, 17, 30, 0),
                Location__Latitude__s = 51.5156950,
                Location__Longitude__s = -0.0893931,
                Venue_Address__c = 'Test ave 12/20'
        );
        insert testEvent;

        AC_User_Segment__c employees = new AC_User_Segment__c();
        employees.Name = 'Employees';
        employees.Description__c = 'Test';
        employees.Query__c = 'SELECT Id FROM User WHERE Id = \'' + currentUserId + '\'';
        insert employees;

        AC_Event_User_Segment__c eventEmployees = new AC_Event_User_Segment__c();

        eventEmployees.AC_Event__c = testEvent.Id;
        eventEmployees.AC_User_Segment__c = employees.Id;
        eventEmployees.Price__c = 3.88;
        eventEmployees.Priority__c = 10;
        eventEmployees.Event_Preferences_Form_Fieldset__c = 'test';
        insert eventEmployees;


        System.runAs(u) {
            List<brIFieldWrap> fields = brEventParticipationManager.getEventPreferencesFormFields(testEvent.Id);

            System.assertNotEquals(null, fields);

            fields = brEventParticipationManager.getEventPreferencesFormFields(testEvent.Id, u.Id);
            System.assertNotEquals(null, fields);
        }

        Test.stopTest();
    }

    @IsTest
    static void testgenerateFonSalesOrder() {
        Test.startTest();

        Contact con = [SELECT Id FROM Contact WHERE Account.Name = 'Test Account'];
        User u = [SELECT Id FROM User WHERE ContactId = :con.Id];

        Id currentUserId = u.Id;
        BR_Event__c testEvent = new BR_Event__c(
                Name = 'Test event0',
                Start_Date__c = Datetime.newInstance(2016, 10, 15, 12, 30, 0),
                End_Date__c = datetime.newInstance(2016, 10, 15, 17, 30, 0),
                Location__Latitude__s = 51.5156950,
                Location__Longitude__s = -0.0893931,
                Venue_Address__c = 'Test ave 12/20'
        );
        insert testEvent;

        OrderApi__Item_Class__c iClass = TestDataFactory.buildItemClass('Live Event Tickets');
        insert iClass;

        OrderApi__Item__c ticket = TestDataFactory.buildItem(iClass.Id, 'Test event0 Ticket');
        ticket.AC_Event__c = testEvent.Id;
        insert ticket;

        AC_User_Segment__c employees = new AC_User_Segment__c();
        employees.Name = 'Employees';
        employees.Description__c = 'Test';
        employees.Query__c = 'SELECT Id FROM User WHERE Id = \'' + currentUserId + '\'';
        insert employees;

        AC_Event_User_Segment__c eventEmployees = new AC_Event_User_Segment__c();

        eventEmployees.AC_Event__c = testEvent.Id;
        eventEmployees.AC_User_Segment__c = employees.Id;
        eventEmployees.Price__c = 3.88;
        eventEmployees.Priority__c = 10;
        eventEmployees.Event_Preferences_Form_Fieldset__c = 'test';
        insert eventEmployees;

        System.runAs(u) {

            OrderApi__Sales_Order__c so = brEventParticipationManager.generateFonSalesOrderForTicket(eventEmployees, testEvent.Id);
            System.assertNotEquals(null, so);
        }

//        brEventParticipationManager.saveEventPreferences(testEvent.Id, currentUserId, so.Id, '{ "Participate__c": "Yes" }');

//        BR_Participation__c participation = [
//                SELECT Participate__c
//                FROM BR_Participation__c
//                WHERE BR_Event__c = :testEvent.Id
//                AND User__c = :UserInfo.getUserId()
//        ];
//
//        System.assertNotEquals('Yes', participation.Participate__c);

        Test.stopTest();
    }
}