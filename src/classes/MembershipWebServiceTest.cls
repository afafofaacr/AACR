/**
 * Created by lauren.lezberg on 3/31/2021.
 */

@IsTest
private class MembershipWebServiceTest {

    @TestSetup
    public static void setup(){
        Account acc = TestDataFactory.buildAccount('Test Account');
        insert acc;

        Contact con = TestDataFactory.buildContactMemberCurrent(acc.Id);
        insert con;

        User u = TestDataFactory.buildUser(con.Id);
        u.ORCID__c = '1234-5678-9098-7654';
        insert u;

    }

    @IsTest
    static void testGetAACRIDOnly() {
        Contact con = [SELECT AACR_ID__c FROM Contact WHERE Account.Name='Test Account'];

        Test.startTest();


//        Testing AACRID
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();

        request.requestUri ='https://uat-aacr.cs195.force.com/services/apexrest/Membership';
        request.addParameter('aacrid', con.AACR_ID__c);
        request.httpMethod = 'GET';

        RestContext.request = request;
        RestContext.response = response;


        MembershipWebService.getMembership();

        Test.stopTest();
    }

    @IsTest
    static void testGetORCIDOnly() {
        Contact con = [SELECT AACR_ID__c FROM Contact WHERE Account.Name='Test Account'];

        Test.startTest();


//        Testing AACRID
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();

        request.requestUri ='https://uat-aacr.cs195.force.com/services/apexrest/Membership';
        request.addParameter('orcid', '1234-5678-9098-7654');
        request.httpMethod = 'GET';

        RestContext.request = request;
        RestContext.response = response;


        MembershipWebService.getMembership();


        Test.stopTest();
    }

    @IsTest
    static void testGetORCANDAACRID() {
        Contact con = [SELECT AACR_ID__c FROM Contact WHERE Account.Name='Test Account'];

        Test.startTest();


//        Testing AACRID
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();

        request.requestUri ='https://uat-aacr.cs195.force.com/services/apexrest/Membership';
        request.addParameter('orcid', '1234-5678-9098-7654');
        request.addParameter('aacrid', con.AACR_ID__c);
        request.httpMethod = 'GET';

        RestContext.request = request;
        RestContext.response = response;


        MembershipWebService.getMembership();


        Test.stopTest();
    }
}