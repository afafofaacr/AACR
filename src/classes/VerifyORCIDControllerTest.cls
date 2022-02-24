/**
 * Created by lauren.lezberg on 3/31/2021.
 */
@isTest
private with sharing class VerifyORCIDControllerTest {

    @TestSetup
    public static void setup(){
        ORCID_Session__c os = new ORCID_Session__c(Base_URL__c='https://www.google.com', Client_Id__c='123456', Client_Secret__c = '7890123', Redirect_URI__c='https://www.google.com');
        insert os;

        Account acc = TestDataFactory.buildAccount('Test Account');
        insert acc;

        Contact con = TestDataFactory.buildContact(acc.Id);
        insert con;

        User u = TestDataFactory.buildUser(con.Id);
        u.ORCID__c = '1234-5678-9098-7654';
        insert u;
    }

    @IsTest
    public static void test_getORCIDAuthURL(){
        Test.startTest();

        String url = VerifyORCIDController.getVerifyURL('https://www.salesforce.com');
        System.assertNotEquals(null, url);

        Test.stopTest();
    }

    @IsTest
    public static void test_goBack(){
        Test.startTest();

        PageReference pageRef = VerifyORCIDController.goBack();
        System.assertNotEquals(null, pageRef);

        Test.stopTest();
    }

    @IsTest
    public static void test_checkORCID(){
        Contact con = [SELECT Id FROM Contact WHERE Account.Name='Test Account'];
        User u = [SELECT Id FROM User WHERE ContactId=: con.Id LIMIT 1];


        System.runAs(u) {
            Test.startTest();

            Boolean check = VerifyORCIDController.checkORCID();

            System.assertEquals(true, check);

            Test.stopTest();
        }
    }


    @IsTest
    public static void test_verify(){

        Test.startTest();

        Test.setMock(HttpCalloutMock.class, new CreateMockHttpResponseGenerator());

        String ret_URL =  EncodingUtil.urlEncode(EncodingUtil.base64Encode(Blob.valueOf('https://www.google.com')), 'UTF-8');

        PageReference pageRef = new PageReference('/VerifyORCID?ret_URL=' + ret_URL + '&code=12345');
        Test.setCurrentPage(pageRef);

        PageReference resp = VerifyORCIDController.verify();
        System.assertEquals(null, resp);


        Test.stopTest();
    }

    @IsTest
    public static void test_verifyFail(){

        Test.startTest();

        Test.setMock(HttpCalloutMock.class, new CreateFailureMockHTTPResponseGenerator());

        String ret_URL =  EncodingUtil.urlEncode(EncodingUtil.base64Encode(Blob.valueOf('https://www.google.com')), 'UTF-8');

        PageReference pageRef = new PageReference('/VerifyORCID?ret_URL=' + ret_URL + '&code=12345');
        Test.setCurrentPage(pageRef);

        PageReference resp = VerifyORCIDController.verify();
        System.assertEquals(null, resp);

        pageRef = new PageReference('/VerifyORCID?ret_URL=' + ret_URL);
        Test.setCurrentPage(pageRef);

        resp = VerifyORCIDController.verify();
        System.assertNotEquals(null, resp);


        Test.stopTest();
    }

    public class CreateMockHTTPResponseGenerator implements HttpCalloutMock{
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"orcid": "1234-5678-9098-7654"}');
            res.setStatusCode(200);
            return res;
        }
    }

    public class CreateFailureMockHTTPResponseGenerator implements HttpCalloutMock{
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"error": "error"}');
            res.setStatusCode(400);
            return res;
        }
    }

}