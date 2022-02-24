/**
 * Created by lauren.lezberg on 2/10/2021.
 */

@IsTest
private class StripeHelperTest {

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
    static void test_updateStripeCustomer() {
        Account acc = [SELECT Id FROM Account WHERE Name='Test Account'];
        acc.Stripe_Customer_Id__c = '1234567890';
        update acc;

        Test.startTest();

        Test.setMock(HttpCalloutMock.class, new SuccessStripeMockHttpResponseGenerator());

        String customerId = StripeHelper.updateStripeCustomer(acc.Id, 'test.testerson@yopmail.com');
        System.assertNotEquals(null, customerId);

        Test.setMock(HttpCalloutMock.class, new FailureStripeMockHttpResponseGenerator());
        customerId = StripeHelper.updateStripeCustomer(acc.Id, 'test.testerson@yopmail.com');
        System.assertEquals(null, customerId);

        Test.stopTest();

    }

    @IsTest
    static void test_createStripeCustomer() {
        Account acc = [SELECT Id FROM Account WHERE Name='Test Account'];

        Test.startTest();

        Test.setMock(HttpCalloutMock.class, new SuccessStripeMockHttpResponseGenerator());

        String customerId = StripeHelper.createStripeCustomer(acc.Id, 'test.testerson@yopmail.com');
        System.assertNotEquals(null, customerId);

        Test.setMock(HttpCalloutMock.class, new FailureStripeMockHttpResponseGenerator());
        customerId = StripeHelper.createStripeCustomer(acc.Id, 'test.testerson@yopmail.com');
        System.assertEquals(null, customerId);

        Test.stopTest();

    }

    @IsTest
    static void test_createStripeInvoiceWithItem() {
        Account acc = [SELECT Id, Stripe_Customer_Id__c FROM Account WHERE Name='Test Account'];
        acc.Stripe_Customer_Id__c = '1234567890';
        update acc;

        OrderApi__Item__c item = [SELECT Id FROM OrderApi__Item__c LIMIT 1];
        List<String> itemIds = new List<String>{item.Id};

        Test.startTest();

        Test.setMock(HttpCalloutMock.class, new SuccessStripeMockHttpResponseGenerator());
        String stripeInvId = StripeHelper.createStripeInvoiceItem(acc.Stripe_Customer_Id__c,itemIds, 5);
        System.assertNotEquals(null, stripeInvId);

        Test.setMock(HttpCalloutMock.class, new FailureStripeMockHttpResponseGenerator());
        stripeInvId = StripeHelper.createStripeInvoiceItem(acc.Stripe_Customer_Id__c,itemIds, 5);
        System.assertEquals(null, stripeInvId);

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