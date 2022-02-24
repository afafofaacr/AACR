/**
 * Created by lauren.lezberg on 4/25/2020.
 */
@isTest
private with sharing class VirtualEventRegisterControllerTest {

    @testSetup
    public static void setup(){
        Account testAcc = TestDataFactory.buildAccount('Test Account');
        insert testAcc;

        Id recordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(System.Label.Contact_Non_Member_Record_Type).getRecordTypeId();
        Contact con2 = new Contact(LastName = 'Test contact', AccountId = testAcc.Id,RecordTypeId = recordTypeId, Phone ='9878986789', Fax = 'fax', Email = 'testEmail2@yopmail.com');
        con2.FirstName = 'Testy';
        insert con2;
    }

    @isTest
    public static void test_sentToFreeman(){
        Fuzion_Session__c fSession = new Fuzion_Session__c();
        fSession.Client_Id__c = '1233453464575676';
        fSession.Client_Secret__c = '485967495867489567';
        insert fSession;

        Account testAcc = [SELECT Id FROM Account WHERE Name='Test Account'];

        Contact con = TestDataFactory.buildContact(testAcc.Id);
        insert con;


        User u = TestDataFactory.buildUser(con.Id);
        insert u;

        EventApi__Event__c testEvt = TestDataFactory.buildEvent();
        testEvt.Name='testEvent-123456';
        testEvt.EventApi__Event_Key__c = '3847294726';
        testEvt.EventApi__Start_Date__c = Date.today();
        testEvt.EventApi__Start_Time__c = '12:00 PM';
        testEvt.EventApi__End_Date__c = Date.today().addDays(2);
        testEvt.EventApi__End_Time__c = '02:00 PM';
        testEvt.EventApi__Logo_Image__c = 'https://www.testImgurl.com';
        testEvt.EventApi__Description__c = 'THIS IS A TEST EVENT.';
        insert testEvt;


        con.Email = null;
        con.FirstName = null;
        con.LastName = null;
        String conString = JSON.serialize(con);

        Virtual_Meeting_Links__mdt vml = [SELECT Id FROM Virtual_Meeting_Links__mdt LIMIT 1];
        vml.Login_Background_Image__c = 'https://s3.us-east-1.amazonaws.com/fonteva-customer-media/undefined/lYVgTwcf_myAACR_4C_Oct22_2018_horiz3_png';
        vml.Login_Header_Image__c = 'https://s3.us-east-1.amazonaws.com/fonteva-customer-media/undefined/lYVgTwcf_myAACR_4C_Oct22_2018_horiz3_png';
        vml.DeveloperName = 'Virtual_Test_Event';
        vml.Event_Id__c = testEvt.Id;
        vml.View_Link__c = 'https://www.google.com';
        vml.Event_IsActive__c = false;
        vml.Computer_Check_Link__c = 'https://www.salesforce.com';
        vml.Check_IsActive__c = true;
        vml.Registration_Open__c = false;
        vml.Freeman_Event_Id__c = '1234566';

        VirtualEventRegisterController.virtualMeetings.add(vml);

        System.runAs(u) {

            Test.startTest();

            VirtualEventRegisterController.freemanRegister(conString, vml.Freeman_Event_Id__c);

            Test.stopTest();

        }


    }

    @isTest
    public static void test_getCurrentContact(){
        Account testAcc = [SELECT Id FROM Account WHERE Name='Test Account'];

        Contact con = TestDataFactory.buildContact(testAcc.Id);
        insert con;

        User u = TestDataFactory.buildUser(con.Id);
        insert u;

        System.runAs(u){
            Contact currentContact = VirtualEventRegisterController.getCurrentContact();
            SYstem.assertEquals(currentContact.Id, con.Id);
        }

    }

    @isTest
    public static void test_GetStates(){
        Map<string, String> stateMap = new Map<String, String>();

        Test.startTest();

        stateMap = VirtualEventRegisterController.getStates('US');
        System.assertNotEquals(null, stateMap);

        Test.stopTest();
    }

    @isTest
    public static void test_getEventRegInfo(){
        Account testAcc = [SELECT Id FROM Account WHERE Name='Test Account'];

        Contact con = TestDataFactory.buildContact(testAcc.Id);
        insert con;

        User u = TestDataFactory.buildUser(con.Id);
        insert u;

        EventApi__Event__c testEvt = TestDataFactory.buildEvent();
        testEvt.Name='testEvent-123456';
        testEvt.EventApi__Event_Key__c = '3847294726';
        testEvt.EventApi__Start_Date__c = Date.today();
        testEvt.EventApi__Start_Time__c = '12:00 PM';
        testEvt.EventApi__End_Date__c = Date.today().addDays(2);
        testEvt.EventApi__End_Time__c = '02:00 PM';
        testEvt.EventApi__Logo_Image__c = 'https://www.testImgurl.com';
        testEvt.EventApi__Description__c = 'THIS IS A TEST EVENT.';
        insert testEvt;


        Virtual_Meeting_Links__mdt vml = [SELECT Id FROM Virtual_Meeting_Links__mdt LIMIT 1];
        vml.Login_Background_Image__c = 'https://s3.us-east-1.amazonaws.com/fonteva-customer-media/undefined/lYVgTwcf_myAACR_4C_Oct22_2018_horiz3_png';
        vml.Login_Header_Image__c = 'https://s3.us-east-1.amazonaws.com/fonteva-customer-media/undefined/lYVgTwcf_myAACR_4C_Oct22_2018_horiz3_png';
        vml.Reg_Logo_Image__c = 'https://s3.us-east-1.amazonaws.com/fonteva-customer-media/undefined/lYVgTwcf_myAACR_4C_Oct22_2018_horiz3_png';
        vml.DeveloperName = 'Virtual_Test_Event';
        vml.Event_Id__c = testEvt.Id;
        vml.View_Link__c = 'https://www.google.com';
        vml.Event_IsActive__c = false;
        vml.Donation_Link__c = 'https://www.google.com';
        vml.Free_Ticket_Description__c = 'TEST FREE';
        vml.Donation_Ticket_Description__c = 'TEST DONATION';
        vml.Exhibit_Open__c = false;
        vml.Computer_Check_Link__c = 'https://www.salesforce.com';
        vml.Check_IsActive__c = true;
        vml.Registration_Open__c = false;
        vml.Freeman_Event_Id__c = '1234566';

        VirtualEventRegisterController.virtualMeetings.add(vml);

        Test.startTest();

        System.runAs(u) {

            VirtualEventRegisterController.EventRegInfo regInfo = VirtualEventRegisterController.getEventRegInfo('1234566');
            System.assertNotEquals(null, regInfo);

        }

        Test.stopTest();
    }

    @isTest
    public static void test_failRegisterUser(){
        Fuzion_Session__c fSession = new Fuzion_Session__c();
        fSession.Client_Id__c = '1233453464575676';
        fSession.Client_Secret__c = '485967495867489567';
        insert fSession;

        Account testAcc = [SELECT Id FROM Account WHERE Name='Test Account'];

        Contact con = TestDataFactory.buildContact(testAcc.Id);
        insert con;


        User u = TestDataFactory.buildUser(con.Id);
        insert u;

        EventApi__Event__c testEvt = TestDataFactory.buildEvent();
        testEvt.Name='testEvent-123456';
        testEvt.EventApi__Event_Key__c = '3847294726';
        testEvt.EventApi__Start_Date__c = Date.today();
        testEvt.EventApi__Start_Time__c = '12:00 PM';
        testEvt.EventApi__End_Date__c = Date.today().addDays(2);
        testEvt.EventApi__End_Time__c = '02:00 PM';
        testEvt.EventApi__Logo_Image__c = 'https://www.testImgurl.com';
        testEvt.EventApi__Description__c = 'THIS IS A TEST EVENT.';
        insert testEvt;


        con.Email = null;
        con.FirstName = null;
        con.LastName = null;
        String conString = JSON.serialize(con);

        Virtual_Meeting_Links__mdt vml = [SELECT Id FROM Virtual_Meeting_Links__mdt LIMIT 1];
        vml.Login_Background_Image__c = 'https://s3.us-east-1.amazonaws.com/fonteva-customer-media/undefined/lYVgTwcf_myAACR_4C_Oct22_2018_horiz3_png';
        vml.Login_Header_Image__c = 'https://s3.us-east-1.amazonaws.com/fonteva-customer-media/undefined/lYVgTwcf_myAACR_4C_Oct22_2018_horiz3_png';
        vml.DeveloperName = 'Virtual_Test_Event';
        vml.Event_Id__c = testEvt.Id;
        vml.View_Link__c = 'https://www.google.com';
        vml.Event_IsActive__c = false;
        vml.Computer_Check_Link__c = 'https://www.salesforce.com';
        vml.Check_IsActive__c = true;
        vml.Registration_Open__c = false;
        vml.Freeman_Event_Id__c = '1234566';

        VirtualEventRegisterController.virtualMeetings.add(vml);

        System.runAs(u) {

            Test.startTest();

            VirtualEventRegisterController.RegResponse regRsp = VirtualEventRegisterController.registerUser(conString, vml.Freeman_Event_Id__c);
            System.assertNotEquals(null, regRsp);
            System.assertEquals(false, regRsp.success);
            Test.stopTest();
        }
    }

    @isTest
    public static void test_registerUser(){
        Fuzion_Session__c fSession = new Fuzion_Session__c();
        fSession.Client_Id__c = '1233453464575676';
        fSession.Client_Secret__c = '485967495867489567';
        insert fSession;

        Account testAcc = [SELECT Id FROM Account WHERE Name='Test Account'];

        Contact con = TestDataFactory.buildContact(testAcc.Id);
        insert con;


        User u = TestDataFactory.buildUser(con.Id);
        insert u;

        EventApi__Event__c testEvt = TestDataFactory.buildEvent();
        testEvt.Name='testEvent-123456';
        testEvt.EventApi__Event_Key__c = '3847294726';
        testEvt.EventApi__Start_Date__c = Date.today();
        testEvt.EventApi__Start_Time__c = '12:00 PM';
        testEvt.EventApi__End_Date__c = Date.today().addDays(2);
        testEvt.EventApi__End_Time__c = '02:00 PM';
        testEvt.EventApi__Logo_Image__c = 'https://www.testImgurl.com';
        testEvt.EventApi__Description__c = 'THIS IS A TEST EVENT.';
        insert testEvt;

        String conString = JSON.serialize(con);

        Virtual_Meeting_Links__mdt vml = [SELECT Id FROM Virtual_Meeting_Links__mdt LIMIT 1];
        vml.Login_Background_Image__c = 'https://s3.us-east-1.amazonaws.com/fonteva-customer-media/undefined/lYVgTwcf_myAACR_4C_Oct22_2018_horiz3_png';
        vml.Login_Header_Image__c = 'https://s3.us-east-1.amazonaws.com/fonteva-customer-media/undefined/lYVgTwcf_myAACR_4C_Oct22_2018_horiz3_png';
        vml.DeveloperName = 'Virtual_Test_Event';
        vml.Event_Id__c = testEvt.Id;
        vml.View_Link__c = 'https://www.google.com';
        vml.Event_IsActive__c = false;
        vml.Computer_Check_Link__c = 'https://www.salesforce.com';
        vml.Check_IsActive__c = true;
        vml.Registration_Open__c = false;
        vml.Freeman_Event_Id__c = '1234566';

        VirtualEventRegisterController.virtualMeetings.add(vml);

        System.runAs(u) {

            Test.startTest();

            VirtualEventRegisterController.RegResponse regRsp = VirtualEventRegisterController.registerUser(conString, vml.Freeman_Event_Id__c);
            System.assertNotEquals(null, regRsp);
            System.assertEquals(true, regRsp.success);

            con.Email = 'testEmail2@yopmail.com';
            con.FirstName = 'Testy';
            conString = JSON.serialize(con);
            regRsp = VirtualEventRegisterController.registerUser(conString, vml.Freeman_Event_Id__c);
            System.assertNotEquals(null, regRsp);
            System.assertEquals(false, regRsp.success);

            Test.stopTest();
        }
    }

    @isTest
    public static void test_checkIsActive(){
        Account testAcc = [SELECT Id FROM Account WHERE Name='Test Account'];

        Contact con = TestDataFactory.buildContact(testAcc.Id);
        insert con;


        User u = TestDataFactory.buildUser(con.Id);
        insert u;

        EventApi__Event__c testEvt = TestDataFactory.buildEvent();
        testEvt.Name='testEvent-123456';
        testEvt.EventApi__Event_Key__c = '3847294726';
        testEvt.EventApi__Start_Date__c = Date.today();
        testEvt.EventApi__Start_Time__c = '12:00 PM';
        testEvt.EventApi__End_Time__c = '02:00 PM';
        testEvt.EventApi__End_Date__c = Date.today().addDays(2);
        testEvt.EventApi__Logo_Image__c = 'https://www.testImgurl.com';
        testEvt.EventApi__Description__c = 'THIS IS A TEST EVENT.';
        insert testEvt;

        String freemanEventId = 'FREEMAN123456';


        Pagereference currentPage = Page.VirtualEventLogin;
        Test.setCurrentPage(currentPage);
        currentPage.getParameters().put('id', freemanEventId);

        System.runAs(u) {
            Test.startTest();

            VirtualEventRegisterController registerController = new VirtualEventRegisterController();

            Virtual_Meeting_Links__mdt vml = [SELECT Id FROM Virtual_Meeting_Links__mdt LIMIT 1];
            vml.Login_Background_Image__c = 'https://s3.us-east-1.amazonaws.com/fonteva-customer-media/undefined/lYVgTwcf_myAACR_4C_Oct22_2018_horiz3_png';
            vml.Login_Header_Image__c = 'https://s3.us-east-1.amazonaws.com/fonteva-customer-media/undefined/lYVgTwcf_myAACR_4C_Oct22_2018_horiz3_png';
            vml.DeveloperName = 'Virtual_Test_Event';
            vml.Event_Id__c = testEvt.Id;
            vml.View_Link__c = 'https://www.google.com';
            vml.Event_IsActive__c = false;
            vml.Computer_Check_Link__c = 'https://www.salesforce.com';
            vml.Check_IsActive__c = true;
            vml.Registration_Open__c = false;
            vml.Freeman_Event_Id__c = freemanEventId;

            VirtualEventRegisterController.virtualMeetings.add(vml);

            PageReference pageRef = registerController.checkIsActive();

            SYstem.assertEquals(new PageReference('/MemberProfile').getUrl(), pageRef.getUrl());

            vml.Registration_Open__c = true;

            VirtualEventRegisterController.virtualMeetings.clear();
            VirtualEventRegisterController.virtualMeetings.add(vml);

            pageRef = registerController.checkIsActive();

            System.assertEquals(null,pageRef);


            Test.stopTest();
        }
    }
}