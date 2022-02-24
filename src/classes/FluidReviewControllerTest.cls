@isTest
private class FluidReviewControllerTest {
                       
    @isTest	static void testFluidReview() {
    	 FluidReviewController fr; 
         FRSession__c fr_session;
        
         //Test as a Portal User
         account a = new account(name = 'test acct');
         insert a;
         contact c = new contact(lastname = 'test', accountid = a.id, imis_id__c='12345');
         insert c;
         profile p = [select id from profile where name = 'Fonteva Customer Community User' limit 1];
         user testUser = new User(alias = 'person', email='guest@testpkg.com',
                         emailencodingkey='UTF-8', firstname='Test', lastname='Person', languagelocalekey='en_US',
                         localesidkey='en_US', profileid = p.id,
                         timezonesidkey='America/Los_Angeles', username='guest@testpkg.com', contactId = c.id);
        insert testUser;
        
        //Insert badges
        List<OrderApi__Badge__c> badgeList = new List<OrderApi__Badge__c>();
        OrderApi__Badge__c badge = new OrderApi__Badge__c();
        
        List<OrderApi__Badge_Type__c> badgeType = [SELECT id FROM OrderApi__Badge_Type__c WHERE OrderApi__Badge_Type__c.Name = 'AACR Fellow' LIMIT 1];
        if (badgeType!= null && badgeType.size() >0){
            OrderApi__Badge_Type__c badgeTyperec = badgeType.get(0);
            badge.OrderApi__Badge_Type__c = badgeTyperec.id;           
            badge.OrderApi__Is_Active__c = true;
            badge.OrderApi__Contact__c = c.id;
            badgeList.add(badge);
        }    
        
        badgeType = [SELECT id FROM OrderApi__Badge_Type__c WHERE OrderApi__Badge_Type__c.Name = 'Behavioral Science in Cancer Research (BSCR)' LIMIT 1];
        if (badgeType!= null && badgeType.size() >0){
            OrderApi__Badge_Type__c badgeTyperec = badgeType.get(0);
            badge.OrderApi__Badge_Type__c = badgeTyperec.id;
            badge.OrderApi__Is_Active__c = true;
            badge.OrderApi__Contact__c = c.id;
            badgeList.add(badge);
        }
        
        badgeType = [SELECT id FROM OrderApi__Badge_Type__c WHERE OrderApi__Badge_Type__c.Name = 'Cancer Immunology (CIMM)' LIMIT 1];
        if (badgeType!= null && badgeType.size() >0){
            OrderApi__Badge_Type__c badgeTyperec = badgeType.get(0);
            badge.OrderApi__Badge_Type__c = badgeTyperec.id;
            badge.OrderApi__Is_Active__c = true;
            badge.OrderApi__Contact__c = c.id;
            badgeList.add(badge);
        }
        
        badgeType = [SELECT id FROM OrderApi__Badge_Type__c WHERE OrderApi__Badge_Type__c.Name = 'Chemistry in Cancer Research (CICR)' LIMIT 1];
        if (badgeType!= null && badgeType.size() >0){
            OrderApi__Badge_Type__c badgeTyperec = badgeType.get(0);
            badge.OrderApi__Badge_Type__c = badgeTyperec.id;
            badge.OrderApi__Is_Active__c = true;
            badge.OrderApi__Contact__c = c.id;
            badgeList.add(badge);
        }
        badgeType = [SELECT id FROM OrderApi__Badge_Type__c WHERE OrderApi__Badge_Type__c.Name = 'Molecular Epidemiology (MEG)' LIMIT 1];
        if (badgeType!= null && badgeType.size() >0){
            OrderApi__Badge_Type__c badgeTyperec = badgeType.get(0);
            badge.OrderApi__Badge_Type__c = badgeTyperec.id;
            badge.OrderApi__Is_Active__c = true;
            badge.OrderApi__Contact__c = c.id;
            badgeList.add(badge);
        }
        badgeType = [SELECT id FROM OrderApi__Badge_Type__c WHERE OrderApi__Badge_Type__c.Name = 'Pediatric Cancer (PCWG)' LIMIT 1];
        if (badgeType!= null && badgeType.size() >0){
            OrderApi__Badge_Type__c badgeTyperec = badgeType.get(0);
            badge.OrderApi__Badge_Type__c = badgeTyperec.id;
            badge.OrderApi__Is_Active__c = true;
            badge.OrderApi__Contact__c = c.id;
            badgeList.add(badge);
        }
        badgeType = [SELECT id FROM OrderApi__Badge_Type__c WHERE OrderApi__Badge_Type__c.Name = 'Radiation Science and Medicine (RSM)' LIMIT 1];
        if (badgeType!= null && badgeType.size() >0){
            OrderApi__Badge_Type__c badgeTyperec = badgeType.get(0);
            badge.OrderApi__Badge_Type__c = badgeTyperec.id;
            badge.OrderApi__Is_Active__c = true;
            badge.OrderApi__Contact__c = c.id;
            badgeList.add(badge);
        }
        badgeType = [SELECT id FROM OrderApi__Badge_Type__c WHERE OrderApi__Badge_Type__c.Name = 'Tumor Microenvironment (TME)' LIMIT 1];
        if (badgeType!= null && badgeType.size() >0){
            OrderApi__Badge_Type__c badgeTyperec = badgeType.get(0);
            badge.OrderApi__Badge_Type__c = badgeTyperec.id;
            badge.OrderApi__Is_Active__c = true;
            badge.OrderApi__Contact__c = c.id;
            badgeList.add(badge);
        }
        badgeType = [SELECT id FROM OrderApi__Badge_Type__c WHERE OrderApi__Badge_Type__c.Name = 'Women in Cancer Research (WICR)' LIMIT 1];
        if (badgeType!= null && badgeType.size() >0){
            OrderApi__Badge_Type__c badgeTyperec = badgeType.get(0);
            badge.OrderApi__Badge_Type__c = badgeTyperec.id;
            badge.OrderApi__Is_Active__c = true;
            badge.OrderApi__Contact__c = c.id;
            badgeList.add(badge);
        }
        insert badgeList;
        
        System.RunAs(testUser) {     
            fr_session = FRSession__c.getOrgDefaults();
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
            
            fr = new FluidReviewController();      
            Test.startTest();
             // Create the mock response based on a static resource
            StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
            mock.setStaticResource('FR_SignIn');
            mock.setStatusCode(200);
            mock.setHeader('Content-Type', 'application/json;charset=UTF-8');
            // Associate the callout with a mock response
            Test.setMock(HttpCalloutMock.class, mock);
            
            PageReference page = fr.login();
            System.debug('Page value returned is ' + page);
        	System.assert(page!=null, page);
 
            Test.stopTest();                       
        }
    }

    @isTest	static void testFluidReviewAsGuest() {
    	 FluidReviewController fr; 
         FRSession__c fr_session;
    
    	//Test as Guest user
        User guestUser = [select id, name from User where userType = 'Guest' Limit 1];
        System.RunAs(guestUser) {                  
            fr_session = FRSession__c.getOrgDefaults();
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
            
            fr = new FluidReviewController();      
            Test.startTest();
             // Create the mock response based on a static resource
            StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
            mock.setStaticResource('FR_SignIn');
            mock.setStatusCode(200);
            mock.setHeader('Content-Type', 'application/json;charset=UTF-8');
            // Associate the callout with a mock response
            Test.setMock(HttpCalloutMock.class, mock);
            
            PageReference page = fr.login();
            System.debug('Page value returned is ' + page);
        	System.assert(page!=null, page);
 
            Test.stopTest();                       
        }
        
    }  
    
    
    @isTest	static void testRefreshToken() {
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
        
        FluidReviewController fr = new FluidReviewController();      
        Test.startTest();
         // Create the mock response based on a static resource
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('FR_RefreshResponse');
        mock.setStatusCode(200);
        mock.setHeader('Content-Type', 'application/json;charset=UTF-8');
        // Associate the callout with a mock response
        Test.setMock(HttpCalloutMock.class, mock);
        
        fr.refreshToken();
        Test.stopTest();
    }    
    
    @isTest 
    static void testFluidReviewException(){
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
        
        FluidReviewController fr = new FluidReviewController();      
        try{
            Test.startTest();
             // Create the mock response based on a static resource
            StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
            mock.setStaticResource('FR_RefreshResponse');
            mock.setStatusCode(401);
            mock.setStatus('Unauthorized');
            mock.setHeader('Content-Type', 'application/json;charset=UTF-8');
            // Associate the callout with a mock response
            Test.setMock(HttpCalloutMock.class, mock);
            
            fr.refreshToken();
            Test.stopTest();
            throw new FluidReviewException('An exception should have been thrown by the trigger but was not.');           
        }
                
        catch(Exception e){
           	Boolean expectedExceptionThrown =  (e.getMessage().contains('Please generate new access token credentials')) ? true : false;
            System.AssertEquals(expectedExceptionThrown, true);
        } 
    }
    
   
}