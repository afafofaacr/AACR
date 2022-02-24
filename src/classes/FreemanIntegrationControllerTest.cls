/**
 * Created by lauren.lezberg on 4/25/2020.
 */
@isTest
private with sharing class FreemanIntegrationControllerTest {


    @isTest(seeAllData = true)
    public static void test_asyncCreateFuzionAttendee(){
        String freemanEventId = 'FREEMAN123456';

        Account acc = TestDataFactory.buildAccount('Test Account');
        insert acc;

        Contact con = TestDataFactory.buildContact(acc.Id);
        con.Title = 'Senior Scientist';
        con.Salutation = 'Mr';
        insert con;

        EventApi__Event__c testEvt = TestDataFactory.buildEvent();
        testEvt.EventApi__Event_Key__c = '3847294726';
        testEvt.EventApi__Start_Date__c = Date.today();
        testEvt.EventApi__Start_Time__c = '08:00 AM';
        testEvt.EventApi__End_Time__c = '08:00 PM';
        testEvt.EventApi__End_Date__c = Date.today().addDays(2);
        testEvt.EventApi__Logo_Image__c = 'https://www.testImgurl.com';
        testEvt.EventApi__Description__c = 'THIS IS A TEST EVENT.';
        insert testEvt;


        con = [SELECT Id, Title, AACR_Id__c, Salutation, FirstName, LastName, OrderApi__Preferred_Email__c FROM Contact WHERE Account.Name='Test Account'];
        EventApi__Event__c evt = [SELECT id FROM EventApi__Event__c WHERE Name='Test Event'];

        Test.startTest();

        Virtual_Meeting_Links__mdt vml = [SELECT Id FROM Virtual_Meeting_Links__mdt LIMIT 1];
        vml.Login_Background_Image__c = 'https://s3.us-east-1.amazonaws.com/fonteva-customer-media/undefined/lYVgTwcf_myAACR_4C_Oct22_2018_horiz3_png';
        vml.Login_Header_Image__c = 'https://s3.us-east-1.amazonaws.com/fonteva-customer-media/undefined/lYVgTwcf_myAACR_4C_Oct22_2018_horiz3_png';
        vml.DeveloperName = 'Virtual_Test_Event';
        vml.Event_Id__c = evt.Id;
        vml.View_Link__c = 'https://www.google.com';
        vml.Event_IsActive__c = false;
        vml.Computer_Check_Link__c = 'https://www.salesforce.com';
        vml.Check_IsActive__c = true;
        vml.Registration_Open__c = false;
        vml.Freeman_Event_Id__c = freemanEventId;


        FreemanIntegrationController.asyncCreateFreemanAttendee(JSON.serialize(con), freemanEventId, false);

//        System.assertNotEquals(null, redirectURL);

        Test.stopTest();
    }


    @isTest(seeAllData = true)
    public static void test_createFuzionAttendee(){
        String freemanEventId = 'FREEMAN123456';

        Account acc = TestDataFactory.buildAccount('Test Account');
        insert acc;

        Contact con = TestDataFactory.buildContact(acc.Id);
        con.Title = 'Senior Scientist';
        con.Salutation = 'Mr';
        insert con;

        EventApi__Event__c testEvt = TestDataFactory.buildEvent();
        testEvt.EventApi__Event_Key__c = '3847294726';
        testEvt.EventApi__Start_Date__c = Date.today();
        testEvt.EventApi__Start_Time__c = '08:00 AM';
        testEvt.EventApi__End_Time__c = '08:00 PM';
        testEvt.EventApi__End_Date__c = Date.today().addDays(2);
        testEvt.EventApi__Logo_Image__c = 'https://www.testImgurl.com';
        testEvt.EventApi__Description__c = 'THIS IS A TEST EVENT.';
        insert testEvt;


        con = [SELECT Id, Title, AACR_Id__c, Salutation, FirstName, LastName, OrderApi__Preferred_Email__c FROM Contact WHERE Account.Name='Test Account'];
        EventApi__Event__c evt = [SELECT id FROM EventApi__Event__c WHERE Name='Test Event'];

        Test.startTest();

        Virtual_Meeting_Links__mdt vml = [SELECT Id FROM Virtual_Meeting_Links__mdt LIMIT 1];
        vml.Login_Background_Image__c = 'https://s3.us-east-1.amazonaws.com/fonteva-customer-media/undefined/lYVgTwcf_myAACR_4C_Oct22_2018_horiz3_png';
        vml.Login_Header_Image__c = 'https://s3.us-east-1.amazonaws.com/fonteva-customer-media/undefined/lYVgTwcf_myAACR_4C_Oct22_2018_horiz3_png';
        vml.DeveloperName = 'Virtual_Test_Event';
        vml.Event_Id__c = evt.Id;
        vml.View_Link__c = 'https://www.google.com';
        vml.Event_IsActive__c = false;
        vml.Computer_Check_Link__c = 'https://www.salesforce.com';
        vml.Check_IsActive__c = true;
        vml.Registration_Open__c = false;
        vml.Freeman_Event_Id__c = freemanEventId;


        String redirectURL = FreemanIntegrationController.createFreemanAttendee(con, true);

        FreemanIntegrationController.createFreemanAttendee(JSON.serialize(con), vml.Freeman_Event_Id__c, true);

//        System.assertNotEquals(null, redirectURL);

        Test.stopTest();
    }

}