/**
 * Created by lauren.lezberg on 12/4/2020.
 */
@IsTest
private with sharing class RefundRequestControllerTest {

    @TestSetup
    public static void setup(){
        Account acc = TestDataFactory.buildAccount('Test Account');
        insert acc;

        Contact con = TestDataFactory.buildContact(acc.Id);
        insert con;

        Appeal_Code__c appealCode = new Appeal_Code__c(Name = 'Test Appeal Code');
        insert appealCode;

        //adding membership item
        OrderApi__Item_Class__c itemClass = TestDataFactory.buildItemClass('Individual Memberships');
        insert itemClass;
        OrderApi__Item__c item = TestDataFactory.buildItem(itemClass.Id, 'Active Membership');
        insert item;

        //create sales order and sales order lines
        OrderApi__Sales_Order__c so = TestDataFactory.buildOpenSalesOrder(acc.Id, con.Id);
        so.OrderApi__Status__c = 'Closed';
        so.OrderApi__Posting_Status__c = 'Posted';
        insert so;
        OrderApi__Sales_Order_Line__c soLine1 = TestDataFactory.buildSOLine(so.Id, item.Id, itemClass.Id);
        insert soLine1;

        OrderApi__Receipt__c receipt = new OrderApi__Receipt__c(OrderApi__Sales_Order__c= so.Id, OrderApi__Contact__c=con.Id);
        insert receipt;

        OrderApi__Receipt_Line__c recLine = new OrderApi__Receipt_Line__c(OrderApi__Receipt__c=receipt.Id, OrderApi__Item__c=item.Id);
        insert recLine;

    }

    @IsTest
    public static void test_processRefundInvoice(){
        Contact con = [SELECT Id FROM Contact WHERE Account.Name = 'Test Account'];
        OrderApi__Receipt__c rec =  [SELECT Id FROM OrderApi__Receipt__c WHERE OrderApi__Contact__c=:con.Id LIMIT 1];
        OrderApi__Sales_Order__c so = [SELECT Id, OrderApi__Contact__c, OrderApi__Total__c FROM OrderApi__Sales_Order__c WHERE OrderApi__Contact__c=:con.Id];
        so.OrderApi__Posting_Entity__c = 'Invoice';
        so.OrderApi__Schedule_Type__c = 'Simple Invoice';
        update so;

        rec.Stripe_Payment_Intent_Id__c = '1234567890';
        update rec;

        OrderApi__Invoice__c inv = new OrderApi__Invoice__c(OrderApi__Sales_Order__c=so.Id, OrderApi__Contact__c= so.OrderApi__Contact__c);
        insert inv;
        List<OrderApi__Invoice_Line__c> invLines = new List<OrderApi__Invoice_Line__c>();
        List<OrderApi__Sales_Order_Line__c> soLines = [SELECT OrderApi__Item__c FROM OrderApi__Sales_Order_Line__c WHERE OrderApi__Sales_Order__c=:so.Id];
        for(OrderApi__Sales_Order_Line__c line: soLines){
            invLines.add(new OrderApi__Invoice_Line__c(OrderApi__Invoice__c=inv.Id, OrderApi__Item__c=line.OrderApi__Item__c));
        }
        insert invLines;


        Test.startTest();

        Test.setMock(HttpCalloutMock.class, new CreateMockHttpResponseGenerator());

        StripePaymentController.StripeDTO resp = RefundRequestController.processRefund(rec.Id);
        System.assertEquals(true, resp.success);


        Test.stopTest();
    }

    @IsTest
    public static void test_processRefundFail(){
        Contact con = [SELECT Id FROM Contact WHERE Account.Name = 'Test Account'];
        OrderApi__Receipt__c rec =  [SELECT Id FROM OrderApi__Receipt__c WHERE OrderApi__Contact__c=:con.Id LIMIT 1];

        Test.startTest();

        StripePaymentController.StripeDTO resp = RefundRequestController.processRefund(rec.Id);
        System.assertEquals(false, resp.success);

        Test.stopTest();
    }

    @IsTest
    public static void test_processPartialRefundPass(){
        Contact con = [SELECT Id FROM Contact WHERE Account.Name = 'Test Account'];
        OrderApi__Receipt__c rec =  [SELECT Id FROM OrderApi__Receipt__c WHERE OrderApi__Contact__c=:con.Id LIMIT 1];
        OrderApi__Sales_Order__c so = [SELECT Id FROM OrderApi__Sales_Order__c WHERE OrderApi__Contact__c=:con.Id];
        rec.Stripe_Payment_Intent_Id__c = '1234567890';
        update rec;

        List<OrderApi__Receipt_Line__c> lines = [SELECT Id, OrderApi__Sale_Price__c, OrderApi__Item__c, OrderApi__Item__r.Name FROM OrderApi__Receipt_Line__c WHERE OrderApi__Receipt__c=:rec.Id];
        lines[0].OrderApi__Sale_Price__c = 50.00;
        String linesJSON = JSON.serialize(lines);

        Test.startTest();

        Test.setMock(HttpCalloutMock.class, new CreateMockHttpResponseGenerator());

        StripePaymentController.StripeDTO resp = RefundRequestController.processPartialRefund(rec.Id, linesJSON);
        System.assertEquals(true, resp.success);


        Test.stopTest();
    }

    @IsTest
    public static void test_processRefundPass(){
        Contact con = [SELECT Id FROM Contact WHERE Account.Name = 'Test Account'];
        OrderApi__Receipt__c rec =  [SELECT Id FROM OrderApi__Receipt__c WHERE OrderApi__Contact__c=:con.Id LIMIT 1];
        OrderApi__Sales_Order__c so = [SELECT Id FROM OrderApi__Sales_Order__c WHERE OrderApi__Contact__c=:con.Id];
        rec.Stripe_Payment_Intent_Id__c = '1234567890';
        update rec;

        Test.startTest();

        Test.setMock(HttpCalloutMock.class, new CreateMockHttpResponseGenerator());

        StripePaymentController.StripeDTO resp = RefundRequestController.processRefund(rec.Id);
        System.assertEquals(true, resp.success);


        Test.stopTest();
    }

    public class CreateMockHTTPResponseGenerator implements HttpCalloutMock{
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/x-www-form-urlencoded');
            res.setBody('{"id": "1234567890", "client_secret": "83459843758947594", "status" : "succeeded"}');
            res.setStatusCode(200);
            return res;
        }
    }
}