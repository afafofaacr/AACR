/**
 * Created by afaf.awad on 4/15/2021.
 */

@IsTest
private class CustomInvoiceControllerTest {


    @testSetup
    public static void setup(){
        Account acc = LiveTestDataFactory.buildAccount('Test Account');
        insert acc;

        Contact con = LiveTestDataFactory.buildContact(acc.Id);
        con.FirstName = 'Tester';
        con.Member_Type__c = 'Active Member';
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
        salesOrder.is_Transfer__c = True;
        insert salesOrder;

        OrderApi__Sales_Order_Line__c sol = TestDataFactory.buildSOLine(salesOrder.Id, ticket.Id ,ticketclass.Id);
        insert sol;

        BR_Participation__c part = new BR_Participation__c(BR_Event__c = event.Id,
                Contact__c = con.Id,
                AC_User_Segment__c = userSegment.Id,
                Fon_Sales_Order__c = salesOrder.Id);
        insert part;

        List<OrgWideEmailAddress> owas = [SELECT Id FROM OrgWideEmailAddress LIMIT 1];
        System.assertEquals(owas.size(), 1);
        insert new BrEvents_Settings__c(Name='org wide email id', Label__c = 'org wide email id', Value__c = owas[0].Id);

        Member_Count__c memCount = new Member_Count__c(Count__c='48000');
        insert memCount;

    }

    @IsTest
    public static void test_getReceiptInfo(){

        Id soID = [SELECT Id FROM OrderApi__Sales_Order__c LIMIT 1].Id;

        Pagereference receiptPage = Page.AACRCustomReceipt;
        Test.setCurrentPage(receiptPage);
        receiptPage.getParameters().put('soId',soID);

        CustomInvoiceController receiptCtrl = new CustomInvoiceController();

        receiptCtrl.getSalesInfo();

    }

    @IsTest
    public static void test_emailReceipt(){

        Id soID = [SELECT Id FROM OrderApi__Sales_Order__c LIMIT 1].Id;

        Boolean isSuccess = CustomInvoiceController.emailReceipt(soID);

        System.assertEquals(true, isSuccess);
    }

}