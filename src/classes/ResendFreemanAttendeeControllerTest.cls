/**
 * Created by lauren.lezberg on 6/22/2020.
 */
@isTest
private with sharing class ResendFreemanAttendeeControllerTest {

    @testSetup
    public static void setup(){
        Account acc = TestDataFactory.buildAccount('Test Account');
        insert acc;

        Contact con = TestDataFactory.buildContact(acc.Id);
        insert con;

        User u = TestDataFactory.buildUser(con.Id);
        insert u;

        EventApi__Event__c evt = TestDataFactory.buildEvent();
        evt.Name = 'Test Event';
        insert evt;

        EventApi__Attendee__c att = new EventApi__Attendee__c(EventApi__Contact__c=con.Id, EventApi__Event__c=evt.Id);
        insert att;

        Fuzion_Session__c fSession = new Fuzion_Session__c();
        fSession.Client_Id__c = '1233453464575676';
        fSession.Client_Secret__c = '485967495867489567';
        insert fSession;

    }


    @isTest
    public static void test_getShowCmp(){
        Contact con = [SELECT Id FROM Contact WHERE Account.Name='Test Account'];

        User u = [SELECT Id FROM User WHERE ContactId=: con.Id];

        EventApi__Event__c evt = [SELECT Id FROM EventApi__Event__c WHERE Name='Test Event'];

        EventApi__Attendee__c att = [SELECT Id FROM EventApi__Attendee__c WHERE EventApi__Contact__c=:con.Id AND EventApi__Event__c=:evt.Id];

        PermissionSet ps = new PermissionSet();
        ps.Name = 'Test';
        ps.Label = 'Test';
        insert ps;

        SetupEntityAccess sea = new SetupEntityAccess();
        sea.ParentId = ps.Id;
        sea.SetupEntityId = [SELECT Id, DeveloperName FROM CustomPermission WHERE DeveloperName = 'Freeman_Send'][0].Id;
        insert sea;

        PermissionSetAssignment psa = new PermissionSetAssignment();
        psa.AssigneeId = u.Id;
        psa.PermissionSetId = ps.Id;
        insert psa;

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
        vml.Freeman_Event_Id__c = '1234566';

        ResendFreemanAttendeeController.virtualMeetings.add(vml);



        System.runAs(u) {

            Test.startTest();

            Boolean showCmp = ResendFreemanAttendeeController.getShowCmp(att.Id);

            System.assertEquals(true, showCmp);

            Test.stopTest();

        }
    }


    @isTest
    public static void test_resendToFreeman(){


        Contact con = [SELECT Id FROM Contact WHERE Account.Name='Test Account'];

        User u = [SELECT Id FROM User WHERE ContactId=: con.Id];

        EventApi__Event__c evt = [SELECT Id FROM EventApi__Event__c WHERE Name='Test Event'];

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
        vml.Freeman_Event_Id__c = '1234566';

        ResendFreemanAttendeeController.virtualMeetings.add(vml);

        EventApi__Attendee__c att = [SELECT Id FROM EventApi__Attendee__c WHERE EventApi__Contact__c=:con.Id AND EventApi__Event__c=:evt.Id];


        Test.startTest();

        Boolean sendResult = ResendFreemanAttendeeController.resendAttendee(att.Id);

        System.assertEquals(true, sendResult);

        Test.stopTest();

    }

}