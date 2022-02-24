/**
 * Created by lauren.lezberg on 3/31/2021.
 */

@IsTest
private class ORCIDHelperTest {

    @TestSetup
    public static void setup(){
        ORCID_Session__c os = new ORCID_Session__c(Base_URL__c='https://www.google.com', Client_Id__c='123456', Client_Secret__c = '7890123', Redirect_URI__c='https://www.google.com');
        insert os;

        Account acc = TestDataFactory.buildAccount('Test Account');
        insert acc;

        Contact con = TestDataFactory.buildContact(acc.Id);
        insert con;

        User u = TestDataFactory.buildUser(con.Id);
        insert u;
    }



    @IsTest
    public static void test_getVerifyURL(){
        Test.startTest();

        String url = VerifyORCIDController.getVerifyURL('https://www.salesforce.com');
        System.assertNotEquals(null, url);

        Test.stopTest();
    }

    @IsTest
    public static void test_goBack(){
        Test.startTest();

        VerifyORCIDController.redirectURL = 'https://www.yopmail.com';
        PageReference pageRef = VerifyORCIDController.goBack();
        System.assertNotEquals(null, pageRef);

        Test.stopTest();
    }

    @IsTest
    public static void test_checkORCID(){
        Contact con = [SELECT Id FROM Contact WHERE Account.Name = 'Test Account'];

        User u = [SELECT Id FROM User WHERE ContactId=:con.Id];

        System.runAs(u){
            Test.startTest();

            Boolean hasORCID = VerifyORCIDController.checkORCID();
            System.assertEquals(false, hasORCID);

            Test.stopTest();
        }
    }

    @IsTest
    public static void test_verifyORCID(){

        Test.startTest();

        Test.setMock(HttpCalloutMock.class, new CreateMockHttpResponseGenerator());
        Boolean verified = ORCIDHelper.verifyORCID('12345', 'https://www.google.com');
        System.assertEquals(true, verified);


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
}