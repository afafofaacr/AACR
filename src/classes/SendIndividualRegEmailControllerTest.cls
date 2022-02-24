/**
 * Created by lauren.lezberg on 4/21/2020.
 */
@isTest
private with sharing class SendIndividualRegEmailControllerTest {

    @testSetup
    public static void setup(){
        Account acc = TestDataFactory.buildAccount('test account');
        insert acc;

        Contact con = TestDataFactory.buildContact(acc.Id);
        insert con;

        User u = TestDataFactory.buildUser(con.Id);
        insert u;

        EventApi__Event__c evt = TestDataFactory.buildEvent();
        insert evt;

        EventApi__Attendee__c att = new EventApi__Attendee__c();
        att.EventApi__Contact__c = con.Id;
        att.EventApi__Event__c = evt.Id;
        insert att;
    }

    @isTest
    public static void test_getEventId(){
        Contact con = [SELECT Id FROM Contact WHERE Account.Name = 'test account'];
        EventApi__Attendee__c att = [SELECT Id, EventApi__Event__c FROM EventApi__Attendee__c WHERE EventApi__Contact__c=: con.Id];

        User u = [SELECT Id FROM User WHERE ContactId=: con.Id];

        PermissionSet ps = new PermissionSet();
        ps.Name = 'Test';
        ps.Label = 'Test';
        insert ps;

        SetupEntityAccess sea = new SetupEntityAccess();
        sea.ParentId = ps.Id;
        sea.SetupEntityId = [SELECT Id, DeveloperName FROM CustomPermission WHERE DeveloperName = 'Send_Reg_Emails'][0].Id;
        insert sea;

        PermissionSetAssignment psa = new PermissionSetAssignment();
        psa.AssigneeId = u.Id;
        psa.PermissionSetId = ps.Id;
        insert psa;

        Virtual_Meeting_Links__mdt vml = [SELECT Id FROM Virtual_Meeting_Links__mdt LIMIT 1];
        vml.DeveloperName='Virtual_Test_Event';
        vml.Event_Id__c = att.EventApi__Event__c;
        vml.View_Link__c = 'https://www.google.com';
        vml.Event_IsActive__c = false;
        vml.Computer_Check_Link__c = 'https://www.salesforce.com';
        vml.Check_IsActive__c = true;
        vml.Email_Template_Id__c = null;



        System.runAs(u) {
            Test.startTest();

            SendIndividualRegEmailController.virtualMeetings.add(vml);

            String eventId = SendIndividualRegEmailController.getEventId(att.Id);

            System.assertNotEquals(null, eventId);
            System.assertEquals(att.EventApi__Event__c, eventId);

            Test.stopTest();
        }
    }

    @isTest
    public static void test_sendEmail(){
        Contact con = [SELECT Id FROM Contact WHERE Account.Name = 'test account'];
        EventApi__Attendee__c att = [SELECT Id, EventApi__Event__c FROM EventApi__Attendee__c WHERE EventApi__Contact__c=: con.Id];

        Test.startTest();

        Boolean response = SendIndividualRegEmailController.sendRegistrationEmail(att.EventApi__Event__c, con.Id,null);
        System.assertEquals(true, response);

        response = SendIndividualRegEmailController.sendRegistrationEmail(att.EventApi__Event__c, con.Id,att.Id);
        System.assertEquals(true, response);

        Test.stopTest();
    }
}