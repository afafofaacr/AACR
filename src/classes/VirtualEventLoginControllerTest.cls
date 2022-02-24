/**
 * Created by lauren.lezberg on 4/25/2020.
 */
@isTest
private with sharing class VirtualEventLoginControllerTest {


    @testSetup
    public static void setup(){
        Account testAcc = TestDataFactory.buildAccount('Test Account');
        insert testAcc;

        Contact con = TestDataFactory.buildContact(testAcc.Id);
        insert con;

        User u = TestDataFactory.buildUser(con.Id);
        insert u;

        List<OrgWideEmailAddress> owas = [SELECT Id FROM OrgWideEmailAddress LIMIT 1];
        System.assertEquals(owas.size(), 1);

        insert new BrEvents_Settings__c(Name='org wide email id', Label__c = 'org wide email id', Value__c = owas[0].Id);

        Venue__c testVen = LiveTestDataFactory.buildVenue('Test Venue');
        insert testVen;

        BR_Event__c testEvt = LiveTestDataFactory.buildEvent('Test Event', false, false);
        testEvt.Registration_Confirmation_Message__c = 'Test Reg Confirmation Message';
        testEvt.Virtual_Venue__c = testVen.Id;
        testEvt.Registration_Form__c = 'Custom';
        testEvt.Custom_Registration_URL__c ='https://www.google.com';
        insert testEvt;

        Virtual_Event_Details__c ved = new Virtual_Event_Details__c();
        ved.Event__c = testEvt.Id;
        ved.External_Event_Id__c = '12345';
        ved.Exhibit_Open__c = true;
        insert ved;

//        BR_Participation__c ticket = new BR_Participation__c();
//        ticket.Contact__c = con.Id;
//        ticket.User__c = u.Id;
//        ticket.BR_Event__c = testEvt.Id;
//        ticket.Participate__c = 'Yes';
//        insert ticket;

    }

    @isTest
    public static void test_checkIsActiveTrue(){
        BR_Event__c evt = [SELECT Id FROM BR_Event__c WHERE Name = 'Test Event'];

        Pagereference currentPage = Page.VirtualEventLogin;
        Test.setCurrentPage(currentPage);

        Test.startTest();
        currentPage.getParameters().put('id',evt.Id);

        VirtualEventLoginController loginController = new VirtualEventLoginController();

        Branded_Login_Settings__mdt loginSettings = new Branded_Login_Settings__mdt();
        loginSettings.Live_Event_Id__c = evt.Id;
        loginSettings.Header_Image_URL__c = 'https://s3.us-east-1.amazonaws.com/fonteva-customer-media/undefined/lYVgTwcf_myAACR_4C_Oct22_2018_horiz3_png';
        loginSettings.Background_Image_URL__c = 'https://s3.us-east-1.amazonaws.com/fonteva-customer-media/undefined/lYVgTwcf_myAACR_4C_Oct22_2018_horiz3_png';
        loginSettings.DeveloperName='Virtual_Test_Event';
        loginSettings.Is_Active__c = true;

        VirtualEventLoginController.bls.add(loginSettings);

        PageReference pageRef = loginController.checkIsActive();

        System.assertEquals(null, pageRef);

        Test.stopTest();
    }

    @isTest
    public static void test_checkIsActiveFalse(){
        BR_Event__c evt = [SELECT Id FROM BR_Event__c WHERE Name = 'Test Event'];

        Pagereference currentPage = Page.VirtualEventLogin;
        Test.setCurrentPage(currentPage);

        Test.startTest();
        currentPage.getParameters().put('id',evt.Id);

        VirtualEventLoginController loginController = new VirtualEventLoginController();

        Branded_Login_Settings__mdt loginSettings = new Branded_Login_Settings__mdt();
        loginSettings.Live_Event_Id__c = evt.Id;
        loginSettings.Header_Image_URL__c = 'https://s3.us-east-1.amazonaws.com/fonteva-customer-media/undefined/lYVgTwcf_myAACR_4C_Oct22_2018_horiz3_png';
        loginSettings.Background_Image_URL__c = 'https://s3.us-east-1.amazonaws.com/fonteva-customer-media/undefined/lYVgTwcf_myAACR_4C_Oct22_2018_horiz3_png';
        loginSettings.DeveloperName='Virtual_Test_Event';
        loginSettings.Is_Active__c = false;

        VirtualEventLoginController.bls.add(loginSettings);

        PageReference pageRef = loginController.checkIsActive();

        SYstem.assertEquals(null, pageRef);

        Test.stopTest();
    }

    @isTest
    public static void testLogin(){
        BR_Event__c evt = [SELECT Id FROM BR_Event__c WHERE Name = 'Test Event'];

        User u = [SELECT Id, Username FROM User WHERE ContactId IN (SELECT Id FROM Contact WHERE Account.Name = 'Test Account')];

        Pagereference currentPage = Page.VirtualEventLogin;
        Test.setCurrentPage(currentPage);

        Test.startTest();
        currentPage.getParameters().put('system','');
        currentPage.getParameters().put('type','');
        currentPage.getParameters().put('id',evt.Id);

        VirtualEventLoginController customLoginCon = new VirtualEventLoginController();

        Branded_Login_Settings__mdt loginSettings = new Branded_Login_Settings__mdt();
        loginSettings.Live_Event_Id__c = evt.Id;
        loginSettings.Header_Image_URL__c = 'https://s3.us-east-1.amazonaws.com/fonteva-customer-media/undefined/lYVgTwcf_myAACR_4C_Oct22_2018_horiz3_png';
        loginSettings.Background_Image_URL__c = 'https://s3.us-east-1.amazonaws.com/fonteva-customer-media/undefined/lYVgTwcf_myAACR_4C_Oct22_2018_horiz3_png';
        loginSettings.DeveloperName='Virtual_Test_Event';
        loginSettings.Is_Active__c = true;

        VirtualEventLoginController.bls.add(loginSettings);

        customLoginCon.checkIsActive();

        customLoginCon.login();

        customLoginCon.username = u.username;
        customLoginCon.password = 'TestUser@1234';
        customLoginCon.login();


        Test.stopTest();

    }

//    @isTest
//    public static void testLoginAuthenticated(){
//        BR_Event__c evt = [SELECT Id FROM BR_Event__c WHERE Name = 'Test Event'];
//
//        User u = [SELECT Id, Username FROM User WHERE ContactId IN (SELECT Id FROM Contact WHERE Account.Name = 'Test Account')];
//
//        Pagereference currentPage = Page.VirtualEventLogin;
//        Test.setCurrentPage(currentPage);
//
//        System.runAs(u) {
//            Test.startTest();
//            currentPage.getParameters().put('system', '');
//            currentPage.getParameters().put('type', '');
//            currentPage.getParameters().put('id', evt.Id);
//
//            VirtualEventLoginController customLoginCon = new VirtualEventLoginController();
//
//            Branded_Login_Settings__mdt loginSettings = new Branded_Login_Settings__mdt();
//            loginSettings.Live_Event_Id__c = evt.Id;
//            loginSettings.Header_Image_URL__c = 'https://s3.us-east-1.amazonaws.com/fonteva-customer-media/undefined/lYVgTwcf_myAACR_4C_Oct22_2018_horiz3_png';
//            loginSettings.Background_Image_URL__c = 'https://s3.us-east-1.amazonaws.com/fonteva-customer-media/undefined/lYVgTwcf_myAACR_4C_Oct22_2018_horiz3_png';
//            loginSettings.DeveloperName = 'Virtual_Test_Event';
//            loginSettings.Is_Active__c = true;
//
//            VirtualEventLoginController.bls.add(loginSettings);
//
//            customLoginCon.checkIsActive();
//
//            customLoginCon.login();
//
//            customLoginCon.username = u.username;
//            customLoginCon.password = 'TestUser@1234';
//            customLoginCon.login();
//
//
//            Test.stopTest();
//        }
//
//    }

}