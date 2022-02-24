/**
 * Created by lauren.lezberg on 12/4/2020.
 */

@IsTest
private class StripePaymentControllerTest {

    @TestSetup
    public static void setup(){
        Account acc = TestDataFactory.buildAccount('Test Account');
        insert acc;

        Contact con = TestDataFactory.buildContact(acc.Id);
        insert con;

        OrderApi__Known_Address__c billingAddress = new OrderApi__Known_Address__c(Type__c='Billing', OrderApi__Contact__c=con.Id, OrderApi__Street__c='123 Main St', OrderApi__City__c='TEST', OrderApi__Province__c='PA', OrderApi__Country__c='United States');
        insert billingAddress;

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
        soLine1.OrderApi__Sale_Price__c = 315.00;
        soLine1.OrderApi__Price_Override__c = true;
        insert soLine1;

        OrderApi__Store__c eStore = new OrderApi__Store__c(Name='AACR eStore');
        insert eStore;
    }


    @IsTest
    public static void test_initialize(){
        Contact con = [SELECT Id FROM Contact WHERE Account.Name = 'Test Account'];

        OrderApi__Item__c item = [SELECT Id FROM OrderApi__Item__c LIMIT 1];

        OrderApi__Sales_Order__c so = [SELECT Id FROM OrderApi__Sales_Order__c WHERE OrderApi__Contact__c=:con.Id];
        so.Payment_Intent_Id__c = '1234567890';
        update so;


        Test.startTest();
        PageReference pageRef = Page.JP_Container;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('id','123456');
        ApexPages.currentPage().getParameters().put('salesOrder',so.Id);


        StripePaymentController ctrl = new StripePaymentController();

        so.OrderApi__Status__c = 'Closed';
        so.OrderApi__Posting_Status__c = 'Posted';
        update so;

        ctrl = new StripePaymentController();

        Test.stopTest();
    }

    @IsTest
    public static void test_createNewPaymentIntent(){
        Contact con = [SELECT Id FROM Contact WHERE Account.Name = 'Test Account'];

        OrderApi__Sales_Order__c so = [SELECT Id FROM OrderApi__Sales_Order__c WHERE OrderApi__Contact__c=:con.Id];

        Test.startTest();
        PageReference pageRef = Page.JP_Container;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('id','123456');
        ApexPages.currentPage().getParameters().put('salesOrder',so.Id);

        Test.setMock(HttpCalloutMock.class, new CreateMockHttpResponseGenerator());

        StripePaymentController ctrl = new StripePaymentController();
        ctrl.createPaymentIntent();
        System.assertEquals(ctrl.piSecret!=null, true);

        Test.stopTest();
    }

    @IsTest
    public static void test_getOldPaymentIntent(){
        Contact con = [SELECT Id FROM Contact WHERE Account.Name = 'Test Account'];

        OrderApi__Sales_Order__c so = [SELECT Id FROM OrderApi__Sales_Order__c WHERE OrderApi__Contact__c=:con.Id];
        so.Payment_Intent_Id__c = '1234567890';
        update so;

        Test.startTest();
        PageReference pageRef = Page.JP_Container;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('id','123456');
        ApexPages.currentPage().getParameters().put('salesOrder',so.Id);

        Test.setMock(HttpCalloutMock.class, new CreateMockHttpResponseGenerator());

        StripePaymentController ctrl = new StripePaymentController();
        ctrl.createPaymentIntent();
        System.assertEquals(ctrl.piSecret!=null, true);

        Test.stopTest();
    }


    @IsTest
    public static void test_finalizePayment(){
        Contact con = [SELECT Id FROM Contact WHERE Account.Name = 'Test Account'];

        OrderApi__Sales_Order__c so = [SELECT Id FROM OrderApi__Sales_Order__c WHERE OrderApi__Contact__c=:con.Id];

        Test.startTest();
        PageReference pageRef = Page.JP_Container;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('id','123456');
        ApexPages.currentPage().getParameters().put('salesOrder',so.Id);
        ApexPages.currentPage().getParameters().put('pmID', 'pm_1234567890');

        Test.setMock(HttpCalloutMock.class, new CreateMockHttpResponseGenerator());

        StripePaymentController ctrl = new StripePaymentController();
        ctrl.finalizePayment();
        System.assertEquals(true, ctrl.processed);


        Test.stopTest();
    }

//    @IsTest
//    public static void test_processRefund(){
//        Contact con = [SELECT Id FROM Contact WHERE Account.Name = 'Test Account'];
//
//        OrderApi__Item__c item = [SELECT Id FROM OrderApi__Item__c LIMIT 1];
//
//        OrderApi__Sales_Order__c so = [SELECT Id, OrderApi__Total__c FROM OrderApi__Sales_Order__c WHERE OrderApi__Contact__c=:con.Id];
//        so.Payment_Intent_Id__c = '1234567890';
//        update so;
//
//        OrderApi__Receipt__c receipt = new OrderApi__Receipt__c(OrderApi__Sales_Order__c= so.Id, OrderApi__Contact__c=con.Id);
//        insert receipt;
//
//        OrderApi__Receipt_Line__c recLine = new OrderApi__Receipt_Line__c(OrderApi__Receipt__c=receipt.Id, OrderApi__Item__c=item.Id);
//        insert recLine;
//
//        Test.startTest();
//
//        Test.setMock(HttpCalloutMock.class, new CreateMockHttpResponseGenerator());
//
//        StripePaymentController.StripeDTO resp = RefundRequestController.processRefund(receipt.Id, so.OrderApi__Total__c);
//        System.assertEquals(true, resp.success);
//
//
//        Test.stopTest();
//    }

    @IsTest
    public static void test_Refund(){
        Contact con = [SELECT Id FROM Contact WHERE Account.Name = 'Test Account'];

        OrderApi__Item__c item = [SELECT Id FROM OrderApi__Item__c LIMIT 1];

        OrderApi__Sales_Order__c so = [SELECT Id, OrderApi__Total__c FROM OrderApi__Sales_Order__c WHERE OrderApi__Contact__c=:con.Id];
        so.Payment_Intent_Id__c = '1234567890';
        update so;

        OrderApi__Receipt__c receipt = new OrderApi__Receipt__c(OrderApi__Sales_Order__c= so.Id, OrderApi__Contact__c=con.Id);
        insert receipt;

        OrderApi__Receipt_Line__c recLine = new OrderApi__Receipt_Line__c(OrderApi__Receipt__c=receipt.Id, OrderApi__Item__c=item.Id);
        insert recLine;

        Test.startTest();

        Test.setMock(HttpCalloutMock.class, new CreateMockHttpResponseGenerator());

        StripePaymentController.StripeDTO resp = StripePaymentController.createStripeRefund('1234567890',receipt.Id, 315.00);
        System.assertEquals(true, resp.success);


        resp=StripePaymentController.getStripeRefund('392482394827934');
        System.assertEquals(true, resp.success);


        Test.stopTest();
    }

    @IsTest
    public static void test_RefundFailure(){
        Contact con = [SELECT Id FROM Contact WHERE Account.Name = 'Test Account'];

        OrderApi__Item__c item = [SELECT Id FROM OrderApi__Item__c LIMIT 1];

        OrderApi__Sales_Order__c so = [SELECT Id, OrderApi__Total__c FROM OrderApi__Sales_Order__c WHERE OrderApi__Contact__c=:con.Id];
        so.Payment_Intent_Id__c = '1234567890';
        update so;

        OrderApi__Receipt__c receipt = new OrderApi__Receipt__c(OrderApi__Sales_Order__c= so.Id, OrderApi__Contact__c=con.Id);
        insert receipt;

        OrderApi__Receipt_Line__c recLine = new OrderApi__Receipt_Line__c(OrderApi__Receipt__c=receipt.Id, OrderApi__Item__c=item.Id);
        insert recLine;

        Test.startTest();

        Test.setMock(HttpCalloutMock.class, new FailureMockHttpResponseGenerator());

        StripePaymentController.StripeDTO resp = StripePaymentController.createStripeRefund('1234567890',receipt.Id, 315.00);
        System.assertEquals(false, resp.success);


        resp=StripePaymentController.getStripeRefund('392482394827934');
        System.assertEquals(false, resp.success);


        Test.stopTest();
    }

    @IsTest
    public static void test_failureCallouts(){
        Contact con = [SELECT Id FROM Contact WHERE Account.Name = 'Test Account'];

        OrderApi__Sales_Order__c so = [SELECT Id FROM OrderApi__Sales_Order__c WHERE OrderApi__Contact__c=:con.Id];

        Test.startTest();
        PageReference pageRef = Page.JP_Container;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('id','123456');
        ApexPages.currentPage().getParameters().put('salesOrder',so.Id);

        Test.setMock(HttpCalloutMock.class, new FailureMockHTTPResponseGenerator());

        StripePaymentController ctrl = new StripePaymentController();
        ctrl.createPaymentIntent();
        ctrl.finalizePayment();


        Test.stopTest();
    }

    public class CreateMockHTTPResponseGenerator implements HttpCalloutMock{
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/x-www-form-urlencoded');
            res.setBody('{"id": "1234567890", "client_secret": "83459843758947594", "status":"succeeded", "card" : {"last4": "4242", "brand":"visa", "exp_year" : "2050", "exp_month" : "4" }}');
            res.setStatusCode(200);
            return res;
        }
    }

    public class FailureMockHTTPResponseGenerator implements HttpCalloutMock{
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/x-www-form-urlencoded');
            res.setBody('{"error": {"message": "FAIL"}}');
            res.setStatusCode(402);
            return res;
        }
    }
}