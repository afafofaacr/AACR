/**
 * Created by lauren.lezberg on 4/9/2020.
 */
@isTest
private without sharing class MyContentControllerTest {


    @testSetup
    public static void setup(){
        Account testAcc = TestDataFactory.buildAccount('Test Account');
        insert testAcc;

        Contact con = TestDataFactory.buildContact(testAcc.Id);
        insert con;

        User u = TestDataFactory.buildUser(con.Id);
        insert u;

        EventApi__Event__c testEvt = TestDataFactory.buildEvent();
        testEvt.EventApi__Start_Date__c = Date.today();
        testEvt.EventApi__End_Date__c = Date.today().addDays(2);
        testEvt.EventApi__Logo_Image__c = 'https://www.testImgurl.com';
        testEvt.EventApi__Description__c = 'THIS IS A TEST EVENT.';
        insert testEvt;



    }

    @IsTest
    public static void test_getLiveMessage(){
        MyContent_Settings__c setting = new MyContent_Settings__c();
        setting.Live_Redirect_Active__c = true;
        setting.Redirect_Message__c= 'HELLO TEST';
        setting.Redirect_Title__c = 'TEST TITLE';
        insert setting;

        Test.startTest();
        MyContent_Settings__c s = MyContentController.getLiveRedirectMessage();
        System.assertNotEquals(null, s);
        System.assertEquals(setting.Live_Redirect_Active__c, s.Live_Redirect_Active__c);
        System.assertEquals(setting.Redirect_Message__c, s.Redirect_Message__c);
        System.assertEquals(setting.Redirect_Title__c, s.Redirect_Title__c);


        Test.stopTest();
    }


    @isTest
    public static void test_getOpenRegistrations(){
        EventApi__Event__c evt = [SELECT id FROM EventApi__Event__c WHERE Name='Test Event'];

        Virtual_Meeting_Links__mdt vml = [SELECT Id FROM Virtual_Meeting_Links__mdt LIMIT 1];
        vml.DeveloperName='Virtual_Test_Event';
        vml.Event_Id__c = evt.Id;
        vml.View_Link__c = 'https://www.google.com';
        vml.Event_IsActive__c = false;
        vml.Computer_Check_Link__c = 'https://www.salesforce.com';
        vml.Check_IsActive__c = true;
        vml.Registration_Open__c = true;
        vml.My_Content_Image__c = 'https://www.google.com';

//            MyContentController.virtualMeetings = new List<Virtual_Meeting_Links__mdt>();
        MyContentController.virtualMeetings.add(vml);


        Test.startTest();

        List<MyContentController.EventRegContent> openRegs = MyContentController.getOpenRegistrations();
        System.assertEquals(1, openRegs.size());

        Test.stopTest();
    }

    @isTest
    public static void test_getFreemanEventId(){
        String freemantEvtId = 'FREEMANTEST123456';
        EventApi__Event__c evt = [SELECT id FROM EventApi__Event__c WHERE Name='Test Event'];

        Virtual_Meeting_Links__mdt vml = [SELECT Id FROM Virtual_Meeting_Links__mdt LIMIT 1];
        vml.DeveloperName='Virtual_Test_Event';
        vml.Event_Id__c = evt.Id;
        vml.View_Link__c = 'https://www.google.com';
        vml.Event_IsActive__c = false;
        vml.Computer_Check_Link__c = 'https://www.salesforce.com';
        vml.Check_IsActive__c = true;
        vml.Freeman_Event_Id__c = freemantEvtId;

//            MyContentController.virtualMeetings = new List<Virtual_Meeting_Links__mdt>();
        MyContentController.virtualMeetings.add(vml);


        Test.startTest();

        String regURL = MyContentController.getRegisterUrl(evt.Id);

        System.assertNotEquals(null, regURL);

        Test.stopTest();


    }

    @isTest
    public static void test_getVirtualMeetingLinks(){
        EventApi__Event__c evt = [SELECT id FROM EventApi__Event__c WHERE Name='Test Event'];

        Virtual_Meeting_Links__mdt vml = [SELECT Id FROM Virtual_Meeting_Links__mdt LIMIT 1];
        vml.DeveloperName='Virtual_Test_Event';
        vml.Event_Id__c = evt.Id;
        vml.View_Link__c = 'https://www.google.com';
        vml.Event_IsActive__c = false;
        vml.Computer_Check_Link__c = 'https://www.salesforce.com';
        vml.Check_IsActive__c = true;
        vml.My_Content_Image__c = 'https://www.google.com';

//            MyContentController.virtualMeetings = new List<Virtual_Meeting_Links__mdt>();
        MyContentController.virtualMeetings.add(vml);

        Test.startTest();

        Virtual_Meeting_Links__mdt newVml = MyContentController.getVirtualEventLinks(evt.Id);

        System.assertNotEquals(null, vml);
        Test.stopTest();
    }

    @isTest
    public static void test_getContent(){
        User u = [SELECT Id, ContactId FROM User WHERE ContactId IN (SELECT Id FROM Contact WHERE Account.Name = 'Test Account')];

        EventApi__Event__c evt = [SELECT id FROM EventApi__Event__c WHERE Name='Test Event'];

        System.runAs(u){
            Test.startTest();
            List<MyContentController.EventRegContent> contents = MyContentController.getContent();
            System.assert(contents.isEmpty(), 'Content is not empty.');



            System.assert(contents.isEmpty(), 'Content is not empty.');

            Virtual_Meeting_Links__mdt vml = [SELECT Id FROM Virtual_Meeting_Links__mdt LIMIT 1];
            vml.DeveloperName='Virtual_Test_Event';
            vml.Event_Id__c = evt.Id;
            vml.View_Link__c = 'https://www.google.com';
            vml.Event_IsActive__c = false;
            vml.Computer_Check_Link__c = 'https://www.salesforce.com';
            vml.Check_IsActive__c = true;
            vml.My_Content_Image__c = 'https://www.google.com';
            vml.Live_Event_Id__c = null;

//            MyContentController.virtualMeetings = new List<Virtual_Meeting_Links__mdt>();
            MyContentController.virtualMeetings.add(vml);
            AttendeeToParticipantTriggerHandler.links=new List<Virtual_Meeting_Links__mdt>{vml};

            EventApi__Attendee__c attendee = new EventApi__Attendee__c(EventApi__Event__c=evt.Id,EventApi__Contact__c=u.ContactId);
            insert attendee;

            contents = MyContentController.getContent();
            System.assertEquals(1, contents.size());

            Test.stopTest();
        }

    }

    @IsTest
    public static void test_getLetterToDownload(){

        User u = [SELECT Id, ContactId FROM User WHERE ContactId IN (SELECT Id FROM Contact WHERE Account.Name = 'Test Account')];

        EventApi__Event__c evt = [SELECT id FROM EventApi__Event__c WHERE Name='Test Event'];

        Virtual_Meeting_Links__mdt vml = [SELECT Id FROM Virtual_Meeting_Links__mdt LIMIT 1];
        vml.DeveloperName='Virtual_Test_Event';
        vml.Event_Id__c = evt.Id;
        vml.View_Link__c = 'https://www.google.com';
        vml.Event_IsActive__c = false;
        vml.Computer_Check_Link__c = 'https://www.salesforce.com';
        vml.Check_IsActive__c = true;
        vml.My_Content_Image__c = 'https://www.google.com';
        vml.Live_Event_Id__c = null;

//            MyContentController.virtualMeetings = new List<Virtual_Meeting_Links__mdt>();
        MyContentController.virtualMeetings.add(vml);
        AttendeeToParticipantTriggerHandler.links=new List<Virtual_Meeting_Links__mdt>{vml};

        EventApi__Attendee__c attendee = new EventApi__Attendee__c(EventApi__Event__c=evt.Id);
        insert attendee;

        System.runAs(u) {
            Test.startTest();
            String result = MyContentController.getLetterToDownload(attendee.Id);
            System.assertEquals(true, result.contains('/myAACRHelpCustom'));

            attendee.EventApi__Contact__c = u.ContactId;
            update attendee;

            String testURL = MyContentController.getLetterToDownload(attendee.Id);

            System.assertEquals(true, testURL.contains('/LetterOfParticipation?Id='));

            Test.stopTest();
        }

    }
}