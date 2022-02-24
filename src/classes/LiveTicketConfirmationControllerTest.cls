/**
 * Created by lauren.lezberg on 10/6/2020.
 */

@IsTest
private class LiveTicketConfirmationControllerTest {
    @TestSetup
    public static void setup(){
        Account acc = TestDataFactory.buildAccount('Test Account');
        insert acc;

        Contact con = TestDataFactory.buildContact(acc.Id);
        insert con;

        BR_Event__c evt = LiveTestDataFactory.buildEvent('Test Event', false, false);
        insert evt;

        String fileId = CustomFileUploadController.saveChunk(evt.Id,'Test File', 'THIS IS THE BODY', null,'', 'Main Image');
        System.assertNotEquals(null, fileId);
        ContentVersion cv = [SELECT ContentDocumentId FROM ContentVersion WHERE Id=:fileId];
        JP_EventOptionsController.setImageToPublic(cv.ContentDocumentId, evt.Id, 'Main');

        evt.Main_Image_Filename__c = 'Test File';
        update evt;

        OrderApi__Item_Class__c itemClass = TestDataFactory.buildItemClass('Live Event Tickets');
        insert itemClass;

        OrderApi__Item__c ticketItem = TestDataFactory.buildItem(itemClass.Id, 'Test Event Ticket');
        ticketItem.AC_Event__c = evt.Id;
        ticketItem.OrderApi__Price__c = 0.0;
        insert ticketItem;


        //Appeal codes for Opportunity
        Appeal_Code__c appealCode = new Appeal_Code__c(Name = 'Test Appeal Code');
        insert appealCode;

        OrderApi__GL_Account__c glAccount = TestDataFactory.buildGLAccount();
        glAccount.Distribution_Code__c = true;
        insert glAccount;

    }


    @IsTest
    static void testConstructor() {
        Account acc = [SELECT Id FROM ACcount WHERE Name='Test Account'];
        Contact con = [SELECT Id FROM Contact WHERE AccountId=:acc.Id];

        OrderApi__Item_Class__c itemClass = [SELECT Id FROM OrderApi__Item_Class__c WHERE Name='Live Event Tickets'];
        OrderApi__Item__c ticketItem = [SELECT Id FROM OrderApi__Item__c WHERE Name='Test Event Ticket'];

//        OrderApi__Sales_Order__c so = [SELECT Id, OrderApi__Contact__c FROM OrderApi__Sales_Order__c];

        OrderApi__Sales_Order__c SO = TestDataFactory.buildOpenSalesOrder(acc.Id, con.Id);
        insert SO;

        OrderApi__Sales_Order_Line__c line = TestDataFactory.buildSOLine(SO.Id, ticketItem.Id, itemClass.Id);
        insert line;

        so.OrderApi__Is_Closed__c=true;
        so.OrderApi__Is_Posted__c = true;
        update so;

        OrderApi__Receipt__c rec = new OrderApi__Receipt__c(
                OrderApi__Contact__c = so.OrderApi__Contact__c,
                OrderApi__Entity__c = 'Contact',
                OrderApi__Is_Posted__c = true,
                OrderApi__Sales_Order__c = so.Id
        );
        insert rec;


        BR_Event__c evt = [SELECT Id FROM BR_Event__c WHERE Name='Test Event'];


        PageReference pageRef = Page.LiveTicketConfirmation;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('salesOrder',so.id);
        ApexPages.currentPage().getParameters().put('receipt',rec.Id);

        Test.startTest();

        LiveTicketConfirmationController ctrl = new LiveTicketConfirmationController();
        System.assertEquals(ctrl.receiptId, rec.Id);
        System.assertEquals(ctrl.evt.Id, evt.Id);

        Test.stopTest();

    }

    @IsTest
    static void testConstructor2() {
        Account acc = [SELECT Id FROM ACcount WHERE Name='Test Account'];
        Contact con = [SELECT Id FROM Contact WHERE AccountId=:acc.Id];

        OrderApi__Item_Class__c iClass = [SELECT Id FROM OrderApi__Item_Class__c WHERE Name='Live Event Tickets'];

        BR_Event__c evt = [SELECT Id FROM BR_Event__c WHERE Name='Test Event'];

        OrderApi__Item__c ticketItem = [SELECT Id FROM OrderApi__Item__c WHERE Name='Test Event Ticket'];

        BR_Event__c childEvt = LiveTestDataFactory.buildEvent('Child Event', false, true);
        childEvt.Parent_Event__c = evt.Id;
        insert childEvt;

        OrderApi__Item__c childticketItem = TestDataFactory.buildItem(iClass.Id, 'Child Event Ticket');
        childticketItem.AC_Event__c = childEvt.Id;
        childticketItem.OrderApi__Price__c = 0.0;
        insert childticketItem;

        OrderApi__Sales_Order__c SO = TestDataFactory.buildOpenSalesOrder(acc.Id, con.Id);
        insert SO;

        OrderApi__Sales_Order_Line__c line = TestDataFactory.buildSOLine(SO.Id, ticketItem.Id, iClass.Id);
        insert line;

        OrderApi__Sales_Order_Line__c line2 = TestDataFactory.buildSOLine(SO.Id, childTicketItem.Id, iClass.Id);
        insert line2;

        so.OrderApi__Is_Closed__c=true;
        so.OrderApi__Is_Posted__c = true;
        update so;

//        List<OrderApi__Sales_Order_Line__c> lines = [SELECT Id FROM OrderApi__Sales_Order_Line__c WHERE OrderApi__Sales_Order__c=:so.Id AND  OrderApi__Item_Class__r.Name = 'Live Event Tickets'];
//        System.assertEquals(2, lines.size());

        OrderApi__Receipt__c rec = new OrderApi__Receipt__c(
                OrderApi__Contact__c = so.OrderApi__Contact__c,
                OrderApi__Entity__c = 'Contact',
                OrderApi__Is_Posted__c = true,
                OrderApi__Sales_Order__c = so.Id
        );
        insert rec;

        PageReference pageRef = Page.LiveTicketConfirmation;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('salesOrder',so.id);
//        ApexPages.currentPage().getParameters().put('receipt',rec.Id);

        Test.startTest();

        LiveTicketConfirmationController ctrl = new LiveTicketConfirmationController();
//        System.assertEquals(ctrl.receiptId, rec.Id);
        System.assertEquals(ctrl.evt.Id, evt.Id);

        Test.stopTest();

    }

    @IsTest
    public static void test_checkExhibitStatus(){

        Venue__c virtualVen = LiveTestDataFactory.buildVenue('Test Virtual Venue');
        virtualVen.Integration_Controller__c = 'CallableTest';
        insert virtualVen;

        BR_Event__c evt = [SELECT Id FROM BR_Event__c WHERE Name='Test Event'];
        evt.Virtual_Venue__c = virtualVen.Id;
        update evt;

        Virtual_Event_Details__c ved = new Virtual_Event_Details__c(Exhibit_Open__c=true, Event__c=evt.Id, External_Event_Id__c='1234');
        insert ved;

        Account acc = [SELECT Id FROM ACcount WHERE Name='Test Account'];
        Contact con = [SELECT Id FROM Contact WHERE AccountId=:acc.Id];

        OrderApi__Item_Class__c itemClass = [SELECT Id FROM OrderApi__Item_Class__c WHERE Name='Live Event Tickets'];
        OrderApi__Item__c ticketItem = [SELECT Id FROM OrderApi__Item__c WHERE Name='Test Event Ticket'];

        OrderApi__Sales_Order__c SO = TestDataFactory.buildOpenSalesOrder(acc.Id, con.Id);
        insert SO;

        OrderApi__Sales_Order_Line__c line = TestDataFactory.buildSOLine(SO.Id, ticketItem.Id, itemClass.Id);
        insert line;

        so.OrderApi__Is_Closed__c=true;
        so.OrderApi__Is_Posted__c = true;
        update so;

        OrderApi__Receipt__c rec = new OrderApi__Receipt__c(
                OrderApi__Contact__c = so.OrderApi__Contact__c,
                OrderApi__Entity__c = 'Contact',
                OrderApi__Is_Posted__c = true,
                OrderApi__Sales_Order__c = so.Id
        );
        insert rec;

        PageReference pageRef = Page.LiveTicketConfirmation;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('salesOrder',so.id);

        Test.startTest();
        LiveTicketConfirmationController ctrl = new LiveTicketConfirmationController();
        PageReference newPageRef = ctrl.checkExhibitStatus();
        System.assertNotEquals(null, newPageRef);

        Test.stopTest();

    }

}