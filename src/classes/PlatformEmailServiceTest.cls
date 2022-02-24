/**
 * Created by afaf.awad on 11/10/2020.
 */

@IsTest
private class PlatformEmailServiceTest {
    @IsTest(SeeAllData=true)
    public static void test_callSendGridAPI(){

        SingleRequestMock fakeResponse = new SingleRequestMock(200,
                'Complete',
                '[{"Name": "Test Contact"}]',
                null);


        Map<String, HttpCalloutMock> endpoint2TestResp = new Map<String,HttpCalloutMock>();
        endpoint2TestResp.put('https://api.sendgrid.com/v3/mail/send',fakeResponse);

        HttpCalloutMock mockPlatformService = new MockHttpResponseGenerator(endpoint2TestResp);

        // Set mock callout class
        Test.setMock(HttpCalloutMock.class, mockPlatformService);

        // Call method to test.
        // This causes a fake response to be sent
        // from the class that implements HttpCalloutMock.
        Map<String, String> emailMap = new Map<String,String>();
        emailMap.put('testcontact@yopmail.com', 'Test Contact');

        PlatformEmailService.callSendGridAPI(emailMap, 'Run PlatformEmailServiceTest', 'meetings@yopmail.com', 'AACR', 'meetings@yopmail.com', 'This is a test email.');
    }


}