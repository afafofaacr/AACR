@isTest
private class FrRefreshTokenTest {
@isTest static void testRefreshToken() {
        FRSession__c fr_session = FRSession__c.getOrgDefaults();
        if (fr_session.Id == null){
            System.debug('Create custom setting');
            fr_session.SetupOwnerId = UserInfo.getOrganizationId();
            fr_session.FR_AccessToken__c = '12345';
            fr_session.FR_ClientID__c = '12345';
            fr_session.FR_ClientSecret__c = '12345';
            fr_session.FR_ConnectURL__c = 'https://aacr-sandbox2018.fluidreview.com/';
            fr_session.FR_RefreshToken__c = '12345';
            fr_session.FR_LastUpdate__c = System.now() - 1;
            insert fr_session;
            System.debug('Created custom setting');
        }
        
        //FRRefreshToken fr = new FRRefreshToken();      
        Test.startTest();
         // Create the mock response based on a static resource
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('FR_RefreshResponse');
        mock.setStatusCode(200);
        mock.setHeader('Content-Type', 'application/json;charset=UTF-8');
        // Associate the callout with a mock response
        Test.setMock(HttpCalloutMock.class, mock);
        
        FRRefreshToken.refreshToken();
        Test.stopTest();
    }
    
@isTest static void testFailedRefreshToken() {
        FRSession__c fr_session = FRSession__c.getOrgDefaults();
        if (fr_session.Id == null){
            System.debug('Create custom setting');
            fr_session.SetupOwnerId = UserInfo.getOrganizationId();
            fr_session.FR_AccessToken__c = '12345';
            fr_session.FR_ClientID__c = '12345';
            fr_session.FR_ClientSecret__c = '12345';
            fr_session.FR_ConnectURL__c = 'https://aacr-sandbox2018.fluidreview.com/';
            fr_session.FR_RefreshToken__c = '12345';
            fr_session.FR_LastUpdate__c = System.now() - 1;
            insert fr_session;
            System.debug('Created custom setting');
        }
        
        //FRRefreshToken fr = new FRRefreshToken();      
        Test.startTest();
         // Create the mock response based on a static resource
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('FR_RefreshResponse');
        mock.setStatusCode(401);
    	mock.setStatus('Unauthorized');
        mock.setHeader('Content-Type', 'application/json;charset=UTF-8');
        // Associate the callout with a mock response
        Test.setMock(HttpCalloutMock.class, mock);
        
        FRRefreshToken.refreshToken();
        Test.stopTest();
    }
    
    static testmethod void testScheduledJob() {
        Test.startTest();
        FRSession__c fr_session = FRSession__c.getOrgDefaults();
        if (fr_session.Id == null){
            System.debug('Create custom setting');
            fr_session.SetupOwnerId = UserInfo.getOrganizationId();
            fr_session.FR_AccessToken__c = '12345';
            fr_session.FR_ClientID__c = '12345';
            fr_session.FR_ClientSecret__c = '12345';
            fr_session.FR_ConnectURL__c = 'https://aacr-sandbox2018.fluidreview.com/';
            fr_session.FR_RefreshToken__c = '12345';
            fr_session.FR_LastUpdate__c = System.now() - 1;
            insert fr_session;
            System.debug('Created custom setting');
        }

        // Create the mock response based on a static resource
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('FR_RefreshResponse');
        mock.setStatusCode(200);
        mock.setHeader('Content-Type', 'application/json;charset=UTF-8');
        // Associate the callout with a mock response
        Test.setMock(HttpCalloutMock.class, mock);

        // Schedule the test job
        FRRefreshToken_Scheduler frRefresh = new FRRefreshToken_Scheduler();
        String CRON_EXP = '0 0 0 15 3 ? 2022';
        system.schedule('FRRefreshTokenTest', CRON_EXP, frRefresh);
        // Stopping the test will run the job synchronously
        Test.stopTest();
    }

}