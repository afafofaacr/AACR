/**
 * Created by lauren.lezberg on 2/16/2021.
 */

@IsTest
private class CareerFairRegControllerTest {

    @TestSetup
    public static void setup(){

        BR_Event__c testEvent = new BR_Event__c(
                Name = 'Career Fair',
                Start_Date__c = Datetime.newInstance(2016, 10, 15, 12, 30, 0),
                End_Date__c = Datetime.newInstance(2016, 10, 15, 17, 30, 0),
                Location__Latitude__s = 51.5156950,
                Location__Longitude__s = -0.0893931,
                Venue_Address__c = 'Test ave 12/20',
                Event_Preferences_Form_Fieldset__c = 'test',
                Registration_Form_Fieldset__c = 'Registration_Basic',
                Registration_Confirmation_Message__c = 'TEST MSG'
        );
        insert testEvent;

        Blob b = Blob.valueOf('TEST FILE');
        ContentVersion cv = new ContentVersion();
        cv.VersionData = b;
        cv.Title = 'Event Image';
        cv.PathOnClient = 'Event Image.png';
        cv.IsMajorVersion = true;

        insert cv;
        cv = [SELECT Id, Title, ContentDocumentId FROM ContentVersion WHERE Id=:cv.Id];

        //create ContentDocumentLink  record
        ContentDocumentLink conDocLink = New ContentDocumentLink();
        conDocLink.LinkedEntityId = testEvent.Id; // Specify RECORD ID here i.e Any Object ID (Standard Object/Custom Object)
        conDocLink.ContentDocumentId = cv.ContentDocumentId;  //ContentDocumentId Id from ContentVersion
        conDocLink.shareType = 'V';
        insert conDocLink;

        testEvent.Main_Image_Filename__c = 'Event Image.png';
        update testEvent;

        OrderApi__Item_Class__c itemClass = TestDataFactory.buildItemClass('Live Event Tickets');
        itemClass.OrderApi__Is_Subscription__c = false;
        insert itemClass;

        OrderApi__Item__c item = TestDataFactory.buildItem(itemClass.Id, 'Career Fair Ticket');
        item.OrderApi__Is_Subscription__c= false;
        item.AC_Event__c = testEvent.Id;
        insert item;

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

        List<OrgWideEmailAddress> owas = [SELECT Id FROM OrgWideEmailAddress LIMIT 1];
        System.assertEquals(owas.size(), 1);

        insert new BrEvents_Settings__c(Name='org wide email id', Label__c = 'org wide email id', Value__c = owas[0].Id);
    }

    @IsTest
    public static void test_constructor(){
        BR_Event__c evt = [SELECT Id FROM BR_Event__c WHERE Name='Career Fair'];

        Test.startTest();

        Test.setCurrentPage(Page.CareerFairRegistration);
        ApexPages.currentPage().getParameters().put('eventId',evt.Id);

        CareerFairRegController ctrl = new CareerFairRegController();
        System.assertNotEquals(null, ctrl);

        Test.stopTest();
    }

    @IsTest
    static void test_careerFairRegistration() {
        Contact con = [SELECT Id FROM Contact WHERE Account.Name='Test Account'];
        User u = [SELECT Id FROM User WHERE ContactId=: con.Id];

        BR_Event__c evt = [SELECT Id FROM BR_Event__c WHERE Name='Career Fair'];

        SYstem.runAs(u) {

            Test.startTest();
            CareerFairRegController.CareerFairRegInfo cfri = CareerFairRegController.createCFSalesOrder(evt.Id);
            System.assertEquals(false, cfri.registered);
            System.assertNotEquals(null, cfri.salesOrderId);
            System.assertEquals(null, cfri.fileId);
            System.assertEquals(con.Id, cfri.contactId);

            cfri = CareerFairRegController.getCFRegInfo(evt.Id, cfri.salesOrderId);
            System.assertEquals(true, cfri.registered);
            System.assertNotEquals(null, cfri.salesOrderId);
            System.assertEquals(null, cfri.fileId);
            System.assertEquals(con.Id, cfri.contactId);

            CareerFairRegController.processTicket(cfri.salesOrderId);

            Test.stopTest();

            OrderApi__Sales_Order__c so = [SELECT OrderApi__Posting_Status__c, OrderApi__Status__c FROM OrderApi__Sales_Order__c WHERE Id=: cfri.salesOrderId];
            System.assertEquals('Closed', so.OrderApi__Status__c);
            System.assertEquals('Posted', so.OrderApi__Posting_Status__c);
        }

    }

    @IsTest
    static void test_addRemoveLines() {
        Contact con = [SELECT Id FROM Contact WHERE Account.Name = 'Test Account'];
        User u = [SELECT Id FROM User WHERE ContactId = :con.Id];

        BR_Event__c evt = [SELECT Id FROM BR_Event__c WHERE Name = 'Career Fair'];

        Blob b = Blob.valueOf('TEST FILE');



//        SYstem.runAs(u) {

            Test.startTest();

            ContentVersion cv = new ContentVersion();
            cv.VersionData = b;
            cv.Title = 'Resume';
            cv.PathOnClient = 'Resume.txt';
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
            FROM ContentDocumentLink WHERE LinkedEntityId =: con.Id ANd ContentDocument.Title LIKE '%Resume%' ORDER BY SystemModstamp DESC];

            System.assertEquals(contactFiles.size(), 1);

            OrderApi__Sales_Order__c so = new OrderApi__Sales_Order__c(OrderApi__Contact__c=con.Id);
            insert so;

            CareerFairRegController.addCareerFairTicket(con.Id, so.Id, evt.Id);

            CareerFairRegController.removeCareerFairTicket(so.Id, evt.Id);

            Test.stopTest();

            List<OrderApi__Sales_Order_Line__c> lines = [SELECT Id FROM OrderApi__Sales_Order_Line__c WHERE OrderApi__Sales_Order__c=: so.Id];
            System.assertEquals(0, lines.size());
//        }
    }



}