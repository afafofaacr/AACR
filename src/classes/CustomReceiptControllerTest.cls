/**
 * Created by afaf.awad on 1/7/2021.
 */

@IsTest
private class CustomReceiptControllerTest {

    @testSetup
    public static void setup(){
        Account acc = LiveTestDataFactory.buildAccount('Test Account');
        insert acc;

        Contact con = LiveTestDataFactory.buildContact(acc.Id);
        con.FirstName = 'Tester';
        insert con;

        BR_Event__c event = LiveTestDataFactory.buildEvent('Test Event', false, false);
        insert event;

        AC_User_Segment__c userSegment = LiveTestDataFactory.buildUserSegment('Test Segment');
        insert userSegment;

        AC_Event_User_Segment__c eus = LiveTestDataFactory.buildEventUserSegment(event.Id, userSegment.Id, 'dietary_preferences');
        eus.Price__c = 100.00;
        insert eus;

        OrderApi__Item_Class__c ticketclass = TestDataFactory.buildItemClass('Live Event Tickets');
        insert ticketclass;

        OrderApi__Item__c ticket = TestDataFactory.buildItem(ticketclass.Id, 'Test event0 Ticket');
        ticket.AC_Event__c = event.Id;
        insert ticket;

        OrderApi__Sales_Order__c  salesOrder = TestDataFactory.buildOpenSalesOrder(acc.Id, con.Id);
        insert salesOrder;

        OrderApi__Sales_Order_Line__c sol = TestDataFactory.buildSOLine(salesOrder.Id, ticket.Id ,ticketclass.Id);
        insert sol;

        salesOrder.OrderApi__Is_Closed__c = true;
        salesOrder.OrderApi__Is_Posted__c = true;
        update salesOrder;

        BR_Participation__c part = new BR_Participation__c(BR_Event__c = event.Id,
                Contact__c = con.Id,
                AC_User_Segment__c = userSegment.Id,
                Fon_Sales_Order__c = salesOrder.Id);
        insert part;

        List<OrgWideEmailAddress> owas = [SELECT Id FROM OrgWideEmailAddress LIMIT 1];
        System.assertEquals(owas.size(), 1);
        insert new BrEvents_Settings__c(Name='org wide email id', Label__c = 'org wide email id', Value__c = owas[0].Id);

        
    }

    @IsTest
    public static void test_getReceiptInfo(){

        Id partId = [SELECT Id FROM BR_Participation__c LIMIT 1].Id;

        Pagereference receiptPage = Page.AACRCustomReceipt;
        Test.setCurrentPage(receiptPage);
        receiptPage.getParameters().put('partId',partId);

        CustomReceiptController receiptCtrl = new CustomReceiptController();

        receiptCtrl.getReceiptInfo();

    }

    @IsTest
    public static void test_emailReceipt(){

        Id partId = [SELECT Id FROM BR_Participation__c LIMIT 1].Id;

        List<String> ccEmails = new List<String>{'test@example.com'};

        CustomReceiptController.EmailResults results = CustomReceiptController.emailReceipt(partId, JSON.serialize(ccEmails), 'TESTING 123');

        System.assertEquals(false, results.error);
    }
}