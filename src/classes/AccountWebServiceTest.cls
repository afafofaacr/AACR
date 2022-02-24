/**
 * Created by afaf.awad on 3/17/2021.
 */
@IsTest(SeeAllData = true)
public class AccountWebServiceTest {

        @IsTest
        static void testRequest() {

            RestRequest request = new RestRequest();
            RestResponse response = new RestResponse();
            request.requestUri ='https://aacr--UAT.my.salesforce.com/services/apexrest/AccountWebService/';
            request.httpMethod = 'GET';

            RestContext.request = request;
            RestContext.response = response;

            List<Account> acctResp = AccountWebService.getRecords();

            system.assertEquals(!acctResp.isEmpty(), true);


        }

}