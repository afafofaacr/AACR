/**
 * Created by lauren.lezberg on 2/10/2021.
 */
@IsTest
private with sharing class SpecializedOrderingControllerTest {

    @TestSetup
    public static void setup(){

        Account acc = TestDataFactory.buildAccount('Test Account');
        acc.Institution_Type__c = 'Other';
        insert acc;

        OrderApi__Item_Class__c iClass = TestDataFactory.buildItemClass('Specialized Items');
        insert iClass;

        OrderApi__Item__c item = TestDataFactory.buildItem(iClass.Id, 'Symposium Charge');
        item.OrderApi__SKU__c = 'price_238472934729834729347';
        insert item;

        BR_Event__c evt = LiveTestDataFactory.buildEvent('Test Event', false, false);
        insert evt;

    }

    @IsTest
    public static void test_upsertStripeCustomer(){
        Account acc = [SELECT Id FROM Account WHERE Name='Test Account'];

        Test.startTest();

        Test.setMock(HttpCalloutMock.class, new SuccessStripeMockHttpResponseGenerator());

        String customerId = SpecializedOrderingController.upsertStripeCustomer(acc.Id, 'test.testerson@yopmail.com');
        System.assertNotEquals(null, customerId);


        Test.stopTest();

        acc = [SELECT Id, Stripe_Customer_Id__c FROM Account WHERE Id=: acc.Id];
        System.assertNotEquals(null, acc.Stripe_Customer_Id__c);
        System.assertEquals(customerId, acc.Stripe_Customer_Id__c);
    }

    @IsTest
    public static void test_sendAccountInvoice(){
        Account acc = [SELECT Id, Stripe_Customer_Id__c FROM Account WHERE Name='Test Account'];
        acc.Stripe_Customer_Id__c = '1234567890';
        update acc;

        BR_Event__c evt = [SELECT Id FROM BR_Event__c LIMIT 1];
        OrderApi__Item__c item = [SELECT Id FROM OrderApi__Item__c LIMIT 1];

        List<String> itemIds = new List<String>{item.Id};
        String itemJSON = JSON.serialize(itemIds);

        Test.startTest();

        Test.setMock(HttpCalloutMock.class, new SuccessStripeMockHttpResponseGenerator());

        OrderApi__Invoice__c inv = SpecializedOrderingController.sendAccountInvoice(acc.Stripe_Customer_Id__c, itemJSON, Date.today().addDays(10), 'Live_Event__c', evt.Id);
        System.assertEquals(null, inv);

        Test.stopTest();

    }

    @IsTest
    public static void test_getAvailableObjects(){
        List<Specialized_Order_Lookups__mdt> objects = new List<Specialized_Order_Lookups__mdt>();

        Test.startTest();

        objects = SpecializedOrderingController.getAvailableObjects();
        System.assertEquals(false, objects.isEmpty());

        Test.stopTest();
    }

    @IsTest
    public static void test_buildAccountSalesOrder(){
        Account acc = [SELECT Id FROM Account WHERE Name='Test Account'];
        BR_Event__c evt = [SELECT Id FROM BR_Event__c LIMIT 1];
        OrderApi__Item__c item = [SELECT Id FROM OrderApi__Item__c LIMIT 1];
        List<String> itemIds = new List<String>{item.Id};
        String itemJSON = JSON.serialize(itemIds);

        Test.startTest();

        String salesOrderId = SpecializedOrderingController.buildAccountSalesOrder(acc.Id, itemJSON, 'Live_Event__c', evt.Id);
        System.assertNotEquals(null, salesOrderId);

        Test.stopTest();

    }

    @IsTest
    public static void test_createSalesOrderLine(){
        Account acc = [SELECT Id FROM Account WHERE Name='Test Account'];

        OrderApi__Item__c item = [SELECT Id FROM OrderApi__Item__c LIMIT 1];

        OrderApi__Sales_Order__c so = new OrderApi__Sales_Order__c(OrderApi__Account__c=acc.Id, OrderApi__Posting_Entity__c='Account');
        insert so;

        Test.startTest();

        SpecializedOrderingController.createSOLine(item.Id, so.Id);

        Test.stopTest();
    }

    public class SuccessStripeMockHTTPResponseGenerator implements HttpCalloutMock{
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/x-www-form-urlencoded');
            res.setBody('{"id": "1234567890", "client_secret": "83459843758947594", "status":"succeeded", "card" : {"last4": "4242", "brand":"visa", "exp_year" : "2050", "exp_month" : "4" }}');
            res.setStatusCode(200);
            return res;
        }
    }

    public class FailureStripeMockHTTPResponseGenerator implements HttpCalloutMock{
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/x-www-form-urlencoded');
            res.setBody('{"error": {"message": "FAIL"}}');
            res.setStatusCode(402);
            return res;
        }
    }


}