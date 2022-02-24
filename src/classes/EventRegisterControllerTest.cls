/**
 * Created by lauren.lezberg on 8/17/2020.
 */
@isTest
private with sharing class EventRegisterControllerTest {

    @IsTest
    public static void test_getPrePostDocCertification(){
        Account acc = TestDataFactory.buildAccount('Test Account');
        insert acc;

        Contact con = TestDataFactory.buildContact(acc.Id);
        insert con;

        User u = TestDataFactory.buildUser(con.Id);
        insert u;

        ContentVersion cv = new ContentVersion();
        cv.VersionData = Blob.valueOf('TEST FILE');
        cv.Description = 'Pre/Post Doc TEST';
        cv.Title = 'Pre/Post Doc';
        cv.PathOnClient = 'Pre/Post Doc.txt';
        cv.IsMajorVersion = true;

        insert cv;
        cv = [SELECT Id, Title, ContentDocumentId FROM ContentVersion WHERE Id=:cv.Id];

        //create ContentDocumentLink  record
        ContentDocumentLink conDocLink = New ContentDocumentLink();
        conDocLink.LinkedEntityId = con.Id; // Specify RECORD ID here i.e Any Object ID (Standard Object/Custom Object)
        conDocLink.ContentDocumentId = cv.ContentDocumentId;  //ContentDocumentId Id from ContentVersion
        conDocLink.shareType = 'V';
        insert conDocLink;


        List<ContentDocumentLink> contactFiles = [SELECT ContentDocumentId, ContentDocument.LatestPublishedVersionId, ContentDocument.Title, LinkedEntityId
        FROM ContentDocumentLink WHERE LinkedEntityId =: con.Id ANd ContentDocument.Title LIKE 'Pre/Post Doc%' ORDER BY SystemModstamp DESC];

        System.assertEquals(contactFiles.size(), 1);

        Test.startTest();

        ContentVersion certification = EventRegisterController.getPrePostDocCertification(con.Id);
        System.assertNotEquals(null, certification);

        Test.stopTest();

    }

    @isTest(SeeAllData=true)
    public static void test_getRegistrationForm(){
        BR_Event__c testEvent = new BR_Event__c(
                Name = 'Test event0',
                Start_Date__c = Datetime.newInstance(2016, 10, 15, 12, 30, 0),
                End_Date__c = Datetime.newInstance(2016, 10, 15, 17, 30, 0),
                Location__Latitude__s = 51.5156950,
                Location__Longitude__s = -0.0893931,
                Venue_Address__c = 'Test ave 12/20',
                Event_Preferences_Form_Fieldset__c = 'test',
                Registration_Form_Fieldset__c = 'Registration_Basic'
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

        Test.startTest();
        System.runAs(u){
            EventRegisterController.RegistrationInfo regInfo = EventRegisterController.getRegistrationFieldset(testEvent.Id, null);
            System.assertEquals(regInfo.contactId, u.ContactId);
            System.assertEquals(regInfo.fieldsetName, 'Registration_Basic');
        }
        Test.stopTest();
    }

    @IsTest
    public static void test_updateTicket(){
        BR_Event__c testEvent = new BR_Event__c(
                Name = 'Test event0',
                Start_Date__c = Datetime.newInstance(2016, 10, 15, 12, 30, 0),
                End_Date__c = Datetime.newInstance(2016, 10, 15, 17, 30, 0),
                Location__Latitude__s = 51.5156950,
                Location__Longitude__s = -0.0893931,
                Venue_Address__c = 'Test ave 12/20',
                Event_Preferences_Form_Fieldset__c = 'test',
                Registration_Form_Fieldset__c = 'Registration_Basic'
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

        OrderApi__Sales_Order__c so = TestDataFactory.buildOpenSalesOrder(acc.Id, con.Id);
        insert so;

        OrderApi__Sales_Order_Line__c sol = TestDataFactory.buildSOLine(so.Id, item.Id, itemClass.Id);
        insert sol;

        insert new BR_Participation__c(Contact__c=con.Id, BR_Event__c=testEvent.Id, User__c=u.Id, Participate__c='Incomplete', Fon_Sales_Order__c=so.Id);

        System.runAs(u) {
            Test.startTest();

            EventRegisterController.updateTicket(testEvent.Id, so.Id);


            Test.stopTest();
        }
    }

    @IsTest
    public static void test_getJointInstitutionName(){
        Account acc = TestDataFactory.buildAccount('Test Account');
        insert acc;

        Contact con = TestDataFactory.buildContact(acc.Id);
        insert con;

        User u = TestDataFactory.buildUser(con.Id);
        insert u;

        BR_Event__c testEvent = new BR_Event__c(
                Name = 'Test event0',
                Start_Date__c = Datetime.newInstance(2016, 10, 15, 12, 30, 0),
                End_Date__c = Datetime.newInstance(2016, 10, 15, 17, 30, 0),
                Location__Latitude__s = 51.5156950,
                Location__Longitude__s = -0.0893931,
                Venue_Address__c = 'Test ave 12/20',
                Event_Preferences_Form_Fieldset__c = 'test',
                Joint_Providership_Institution__c = acc.Id,
                Registration_Form_Fieldset__c = 'Registration_Basic'
        );
        insert testEvent;

        OrderApi__Item_Class__c itemClass = TestDataFactory.buildItemClass('Live Event Tickets');
        itemClass.OrderApi__Is_Subscription__c = false;
        insert itemClass;

        OrderApi__Item__c item = TestDataFactory.buildItem(itemClass.Id, 'Test event0 Ticket');
        item.OrderApi__Is_Subscription__c= false;
        item.AC_Event__c = testEvent.Id;
        insert item;

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

        OrderApi__Sales_Order__c so = TestDataFactory.buildOpenSalesOrder(acc.Id, con.Id);
        insert so;

        BR_Participation__c participant = new BR_Participation__c(Contact__c=con.Id, BR_Event__c=testEvent.Id, User__c=u.Id, Participate__c='Incomplete', Fon_Sales_Order__c=so.Id);
        insert participant;

        Test.startTest();

        String providerName = EventRegisterController.getJointInstitutionName(participant.Id);
        System.assertEquals('Test Account', providerName);

        Test.stopTest();

    }


    @isTest
    public static void test_getParticipationFromSO(){
        BR_Event__c testEvent = new BR_Event__c(
                Name = 'Test event0',
                Start_Date__c = Datetime.newInstance(2016, 10, 15, 12, 30, 0),
                End_Date__c = Datetime.newInstance(2016, 10, 15, 17, 30, 0),
                Location__Latitude__s = 51.5156950,
                Location__Longitude__s = -0.0893931,
                Venue_Address__c = 'Test ave 12/20',
                Event_Preferences_Form_Fieldset__c = 'test',
                Registration_Form_Fieldset__c = 'Registration_Basic'
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

        OrderApi__Sales_Order__c so = TestDataFactory.buildOpenSalesOrder(acc.Id, con.Id);
        insert so;

        insert new BR_Participation__c(Contact__c=con.Id, BR_Event__c=testEvent.Id, User__c=u.Id, Participate__c='Incomplete', Fon_Sales_Order__c=so.Id);

        Test.startTest();

        String pId = EventRegisterController.getParticipantFromSO(so.Id);
        System.assertNotEquals(null, pId);

        Test.stopTest();
    }

    @IsTest(SeeAllData=true)
    public static void test_updateTicketEmptySalesOrder(){
        BR_Event__c testEvent = new BR_Event__c(
                Name = 'Test event0',
                Start_Date__c = Datetime.newInstance(2016, 10, 15, 12, 30, 0),
                End_Date__c = Datetime.newInstance(2016, 10, 15, 17, 30, 0),
                Location__Latitude__s = 51.5156950,
                Location__Longitude__s = -0.0893931,
                Venue_Address__c = 'Test ave 12/20',
                Event_Preferences_Form_Fieldset__c = 'test',
                Registration_Form_Fieldset__c = 'Registration_Basic'
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

        OrderApi__Sales_Order__c so = TestDataFactory.buildOpenSalesOrder(acc.Id, con.Id);
        so.OrderApi__Posting_Status__c = null;
        insert so;


        System.runAs(u) {
            Test.startTest();

            EventRegisterController.RegistrationInfo regInfo = EventRegisterController.getRegistrationFieldset(testEvent.Id, null);

            EventRegisterController.updateTicket(testEvent.Id, so.Id);

            Test.stopTest();

        }
    }


    @IsTest(SeeAllData=true)
    public static void test_getRegFieldsetEmptySalesOrder(){
        BR_Event__c testEvent = new BR_Event__c(
                Name = 'Test event0',
                Start_Date__c = Datetime.newInstance(2016, 10, 15, 12, 30, 0),
                End_Date__c = Datetime.newInstance(2016, 10, 15, 17, 30, 0),
                Location__Latitude__s = 51.5156950,
                Location__Longitude__s = -0.0893931,
                Venue_Address__c = 'Test ave 12/20',
                Event_Preferences_Form_Fieldset__c = 'test',
                Registration_Form_Fieldset__c = 'Registration_Basic'
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

        OrderApi__Sales_Order__c so = TestDataFactory.buildOpenSalesOrder(acc.Id, con.Id);
        so.OrderApi__Posting_Status__c = null;
        insert so;


        System.runAs(u) {
            Test.startTest();

            EventRegisterController.RegistrationInfo regInfo = EventRegisterController.getRegistrationFieldset(testEvent.Id, null);
            System.assertEquals(regInfo.contactId, u.ContactId);
            System.assertEquals(regInfo.fieldsetName, 'Registration_Basic');

            regInfo = EventRegisterController.getRegistrationFieldset(testEvent.Id, so.Id);


            Test.stopTest();
        }
    }

}