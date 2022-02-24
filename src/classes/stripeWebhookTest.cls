/**
 * Created by lauren.lezberg on 4/2/2021.
 */

@IsTest
private class stripeWebhookTest {

    @TestSetup
    public static void setup(){
        Account acc = TestDataFactory.buildAccount('Test Account');
        insert acc;

        Contact con = TestDataFactory.buildContact(acc.Id);
        insert con;

        OrderApi__Sales_Order__c so = TestDataFactory.buildOpenSalesOrder(acc.Id, con.Id);
        insert so;

        OrderApi__Invoice__c inv = new OrderApi__Invoice__c(OrderApi__Contact__c=con.Id, OrderApi__Sales_Order__c=so.Id);
        inv.Stripe_Invoice_Id__c = '12345';
        insert inv;
    }

    @IsTest
    static void test_doPost() {
        Test.startTest();

        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();

        request.requestUri ='https://uat-aacr.cs195.force.com/services/apexrest/stripe_webhook/';
        String body = '{"data": { "object" : { "id": "12345" } } }';
        request.requestBody = Blob.valueof(body);
        request.httpMethod = 'POST';


        RestContext.request = request;
        RestContext.response = response;


        stripeWebhook.doPost();

        Test.stopTest();
    }
}