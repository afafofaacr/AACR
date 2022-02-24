/**
 * Created by lauren.lezberg on 3/2/2021.
 */

@IsTest
private class BriteVerifyHelperTest {
    @IsTest
    static void test_verifyEmailSuccess() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new SuccessMockHttpResponseGenerator());

        Boolean isValid = BriteVerifyHelper.verifyEmail('email@yopmail.com');
        System.assertEquals(true, isValid);

        Test.stopTest();
    }

    @IsTest
    static void test_verifyEmailFailure() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new FailureMockHttpResponseGenerator());

        Boolean isValid = BriteVerifyHelper.verifyEmail('email@example.com');
        System.assertEquals(false, isValid);

        Test.stopTest();
    }


    public class SuccessMockHTTPResponseGenerator implements HttpCalloutMock{
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/x-www-form-urlencoded');
            res.setBody('{"email" : {"status": "valid"}}');
            res.setStatusCode(200);
            return res;
        }
    }


    public class FailureMockHTTPResponseGenerator implements HttpCalloutMock{
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/x-www-form-urlencoded');
            res.setBody('{"email" : {"status": "invalid"}}');
            res.setStatusCode(200);
            return res;
        }
    }
}