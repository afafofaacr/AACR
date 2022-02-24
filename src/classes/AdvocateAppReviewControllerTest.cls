/**
 * Created by lauren.lezberg on 7/22/2021.
 */

@IsTest
private class AdvocateAppReviewControllerTest {

    @TestSetup
    public static void setup(){
        //set up admin user
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];

        User u2 = TestDataFactory.buildTestUser(p.Id, 'admin', 'user');
        insert u2;


        List<OrgWideEmailAddress> owas = [SELECT Id FROM OrgWideEmailAddress LIMIT 1];
        System.assertEquals(owas.size(), 1);

        insert new BrEvents_Settings__c(Name='org wide email id', Label__c = 'org wide email id', Value__c = owas[0].Id);

        String orgWideEmailId = BrEventsHelper.getConfigValue('org wide email id');
        SYstem.assertEquals(orgWideEmailId, owas[0].Id);


        Account acc = TestDataFactory.buildAccount('Test Account');
        insert acc;

        Contact con = TestDataFactory.buildContact(acc.Id);
        con.FirstName = 'Testy';
        con.MailingCountryCode = 'US';
        insert con;

        User u = TestDataFactory.buildUser(con.Id);
        u.Country = 'United States';
        insert u;

        BR_Event__c testEvent = LiveTestDataFactory.buildEvent('Test Event', true, false);
        testEvent.Start_Date__c = Datetime.newInstance(System.now().year(), System.now().month() +1, 12, 24, 0, 0);
        testEvent.End_Date__c = Datetime.newInstance(System.now().year(), System.now().month() +1, 13, 12, 0, 0);
        insert testEvent;

        AC_User_Segment__c employees = new AC_User_Segment__c();
        employees.Name = 'Employees';
        employees.Description__c = 'Test';
        employees.Query__c = 'SELECT Id FROM User WHERE Country = \'United States\'';
        insert employees;

        AC_Event_User_Segment__c eventEmployees = new AC_Event_User_Segment__c();
        eventEmployees.AC_Event__c = testEvent.Id;
        eventEmployees.AC_User_Segment__c = employees.Id;
        eventEmployees.Price__c = 15.00;
        eventEmployees.Priority__c = 10;
        eventEmployees.Event_Preferences_Form_Fieldset__c = 'test';
        insert eventEmployees;

        AC_User_Segment__c advocates = new AC_User_Segment__c();
        advocates.Name = 'Advocates';
        advocates.Description__c = 'Test';
        advocates.Query__c = 'SELECT Id FROM User WHERE ContactId IN (SELECT Id FROM Contact WHERE Advocate__c = true)';
        insert advocates;

        AC_Event_User_Segment__c eventAdvocates = new AC_Event_User_Segment__c();
        eventAdvocates.AC_Event__c = testEvent.Id;
        eventAdvocates.AC_User_Segment__c = advocates.Id;
        eventAdvocates.Price__c = 12.00;
        eventAdvocates.Priority__c = 9;
        eventAdvocates.Event_Preferences_Form_Fieldset__c = 'test';
        insert eventAdvocates;

        OrderApi__Item_Class__c itemClass = TestDataFactory.buildItemClass('Live Event Tickets');
        insert itemClass;

        OrderApi__Item__c itm = TestDataFactory.buildItem(itemClass.Id, 'Test event0 Ticket');
        itm.AC_Event__c = testEvent.Id;
        insert itm;

        OrderApi__Sales_Order__c ticketSO = TestDataFactory.buildOpenSalesOrder(acc.Id, con.Id);
        insert ticketSO;

        OrderApi__Sales_Order_Line__c ticketLine = new OrderApi__Sales_Order_Line__c(AC_User_Segment__c=employees.Id, OrderApi__Price_Override__c = true,OrderApi__Sale_Price__c=15.00,OrderApi__Sales_Order__c=ticketSO.Id, OrderApi__Item__c=itm.Id);
        insert ticketLine;

        BR_Participation__c ticket = new BR_Participation__c(AC_User_Segment__c=employees.Id, Fon_Sales_Order__c=ticketSO.Id,Contact__c=con.Id, BR_Event__c=testEvent.Id, Participate__c='Pending Approval');
        insert ticket;
    }

    @IsTest
    static void test_getButtonVisibility() {
        User u = [SELECT Id FROM User WHERE FirstName = 'admin' AND LastName = 'user'];

        PermissionSet ps = new PermissionSet();
        ps.Name = 'Advocate_Test';
        ps.Label = 'Advocate Test';
        insert ps;

        SetupEntityAccess sea = new SetupEntityAccess();
        sea.ParentId = ps.Id;
        sea.SetupEntityId = [SELECT Id, DeveloperName FROM CustomPermission WHERE DeveloperName = 'Advocate_Review'][0].Id;
        insert sea;

        PermissionSetAssignment psa = new PermissionSetAssignment();
        psa.AssigneeId = u.Id;
        psa.PermissionSetId = ps.Id;
        insert psa;

        Contact con = [SELECT Id FROM Contact WHERE Account.Name='Test Account'];

        Test.startTest();
        System.runAs(u){

            Boolean canReview = AdvocateAppReviewController.getButtonVisibility(con.Id);
            System.assertEquals(true, canReview);
        }

        Test.stopTest();

    }

    @IsTest
    public static void test_getAdvocateInfo(){
        Contact con = [SELECT Id FROM Contact WHERE Account.Name='Test Account'];

        Test.startTest();

        AdvocateAppReviewController.AdvocateInfoDTO ai = AdvocateAppReviewController.getAdvocateInfo(con.Id);
        System.assertEquals(con.Id, ai.con.Id);
        System.assertEquals(1, ai.tickets.size());

        Test.stopTest();
    }

    @IsTest
    public static void test_approveAdvocate(){
        Contact con = [SELECT Id FROM Contact WHERE Account.Name='Test Account'];

        Test.startTest();

        Boolean approved = AdvocateAppReviewController.approveAdvocate(con.Id);
        System.assertEquals(true, approved);

        Test.stopTest();
    }

    @IsTest
    public static void test_rejectAdvocate(){
        Contact con = [SELECT Id FROM Contact WHERE Account.Name='Test Account'];

        Test.startTest();

        Boolean rejected = AdvocateAppReviewController.rejectAdvocate(con.Id, 'You have been rejected.');
        System.assertEquals(true, rejected);

        Test.stopTest();
    }


}