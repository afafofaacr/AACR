/**
 * Created by lauren.lezberg on 5/22/2020.
 */

@isTest
private with sharing class Schedule_VirtualRegConfirmationsTest {

    @testsetup
    public static void setup(){
        Account testAcc = TestDataFactory.buildAccount('Test Account');
        insert testAcc;

        Contact con = TestDataFactory.buildContact(testAcc.Id);
        insert con;

        User u = TestDataFactory.buildUser(con.Id);
        insert u;

        EventApi__Event__c testEvt = TestDataFactory.buildEvent();
        testEvt.Calendar_Invite_Msg__c = 'TEST';
        testEvt.EventApi__Start_Date__c = Date.today();
        testEvt.EventApi__Start_Date_Time__c = System.now();
        testEvt.EventApi__End_Date_Time__c = SYstem.now().addDays(2);
        testEvt.EventApi__End_Date__c = Date.today().addDays(2);
        testEvt.EventApi__Logo_Image__c = 'https://www.testImgurl.com';
        testEvt.EventApi__Description__c = 'THIS IS A TEST EVENT.';
        insert testEvt;

        EventApi__Attendee__c att = new EventApi__Attendee__c();
        att.EventApi__Contact__c = con.Id;
        att.EventApi__Event__c = testEvt.Id;
        insert att;
    }


    @isTest
    public static void test_sendBatchEmails(){
        EventApi__Event__c evt = [SELECT id FROM EventApi__Event__c WHERE Name='Test Event'];

        EmailTemplate validEmailTemplate = new EmailTemplate();
        validEmailTemplate.isActive = true;
        validEmailTemplate.Name = 'name';
        validEmailTemplate.DeveloperName = 'unique_name_addSomethingSpecialHere';
        validEmailTemplate.TemplateType = 'text';
        validEmailTemplate.FolderId = UserInfo.getUserId();

        insert validEmailTemplate;

            Virtual_Meeting_Links__mdt vml = [SELECT Id, Email_Template_Id__c FROM Virtual_Meeting_Links__mdt WHERE DeveloperName='Virtual_AM_2' LIMIT 1];

            vml.Login_Background_Image__c = 'https://s3.us-east-1.amazonaws.com/fonteva-customer-media/undefined/lYVgTwcf_myAACR_4C_Oct22_2018_horiz3_png';
            vml.Login_Header_Image__c = 'https://s3.us-east-1.amazonaws.com/fonteva-customer-media/undefined/lYVgTwcf_myAACR_4C_Oct22_2018_horiz3_png';
            vml.Event_Id__c = evt.Id;
            vml.View_Link__c = 'https://www.google.com';
            vml.Event_IsActive__c = true;
            vml.Computer_Check_Link__c = 'https://www.salesforce.com';
            vml.Check_IsActive__c = true;
            vml.Registration_Open__c = true;
            vml.Email_Template_Id__c = validEmailTemplate.Id;

            Scheduled_VirtualRegConfirmations.virtualMeetings.add(vml);


            Test.StartTest();
            SchedulableContext sc = null;
            Scheduled_VirtualRegConfirmations obj = new Scheduled_VirtualRegConfirmations();
            obj.execute(sc);
            Test.stopTest();
        }
}