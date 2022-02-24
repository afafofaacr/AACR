/**
 * Created by lauren.lezberg on 4/10/2020.
 */
@isTest
private with sharing class VirtualAttendeePasswordResetTriggerTest {

    @testSetup
    public static void setup(){
        Account testAcc = TestDataFactory.buildAccount('Test Account');
        insert testAcc;

        Contact con = TestDataFactory.buildContact(testAcc.Id);
        insert con;

        User u = TestDataFactory.buildUser(con.Id);
        u.IsActive = false;
        insert u;

        EventApi__Event__c testEvt = TestDataFactory.buildEvent();
        testEvt.EventApi__Start_Date__c = Date.today();
        testEvt.EventApi__End_Date__c = Date.today().addDays(2);
        testEvt.EventApi__Logo_Image__c = 'https://www.testImgurl.com';
        testEvt.EventApi__Description__c = 'THIS IS A TEST EVENT.';
        insert testEvt;

        EventApi__Attendee__c attendee = new EventApi__Attendee__c();
        attendee.EventApi__First_Name__c = con.FirstName;
        attendee.EventApi__Last_Name__c = con.LastName;
        attendee.EventApi__Email__c = con.Email;
        attendee.EventApi__Contact__c = con.Id;
        attendee.EventApi__Event__c = testEvt.Id;
        insert attendee;

    }

    @isTest
    public static void test_insertAndActivateUser(){
        Contact con = [SELECT Id FROM Contact WHERE Account.Name = 'Test Account'];

        User thisUser = [select Id from User where Id = :UserInfo.getUserId() ];

        System.runAs(thisUser) {

            User u = [SELECT Id FROM User WHERE ContactId = :con.Id];


            Test.startTest();

            u.IsActive = true;
            update u;


            Test.stopTest();
        }
    }

    @isTest
    public static void test_sendEmails(){
        Contact con = [SELECT Id FROM Contact WHERE Account.Name = 'Test Account'];

        User u = [SELECT Id FROM User WHERE ContactId = :con.Id];

        EventApi__Event__c evt = [SELECT id FROM EventApi__Event__c WHERE Name='Test Event'];

        EmailTemplate validEmailTemplate = new EmailTemplate();
        validEmailTemplate.isActive = true;
        validEmailTemplate.Name = 'TEMPLATE';
        validEmailTemplate.DeveloperName = 'template';
        validEmailTemplate.TemplateType = 'text';
        validEmailTemplate.FolderId = UserInfo.getUserId();

        insert validEmailTemplate;

        Virtual_Meeting_Links__mdt vml = [SELECT Id FROM Virtual_Meeting_Links__mdt LIMIT 1];
        vml.DeveloperName='Virtual_Test_Event';
        vml.Event_Id__c = evt.Id;
        vml.View_Link__c = 'https://www.google.com';
        vml.Event_IsActive__c = false;
        vml.Computer_Check_Link__c = 'https://www.salesforce.com';
        vml.Check_IsActive__c = true;
        vml.Email_Template_Id__c = validEmailTemplate.Id;


        User thisUser = [select Id from User where Id = :UserInfo.getUserId() ];

        System.runAs(thisUser) {


            Test.startTest();

            u.IsActive = true;
            update u;

            UserPasswordResetTriggerHandler.virtualMeetings.add(vml);

            UserPasswordResetTriggerHandler.checkForVirtualAttendeeRecords(new List<Id>{
                    u.Id
            });

            Test.stopTest();
        }
    }


}