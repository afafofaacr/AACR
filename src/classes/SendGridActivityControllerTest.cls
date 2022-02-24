/**
 * Created by afaf.awad on 5/11/2021.
 */
@IsTest
public with sharing class SendGridActivityControllerTest {

    @TestSetup public static void setup() {
        Account account = LiveTestDataFactory.buildAccount('Test Account');
        insert account;

        Contact contact = LiveTestDataFactory.buildContact(account.Id);
        insert contact;

        User user = TestDataFactory.buildUser(contact.Id);
        insert user;

        //Participant Contacts
        Account partAccount = LiveTestDataFactory.buildAccount('Test Participant Account');
        insert partAccount;

        List<Contact> partContacts = new List<Contact>();
        for (Integer i = 0; i < 50; i++) {
            Contact con = LiveTestDataFactory.buildContact(partAccount.Id);
            con.LastName = con.LastName + i;
            con.Email = 'testEmail' + i + '@yopmail.com';
            partContacts.add(con);
        }
        insert partContacts;

        List<User> partUsers = new List<User>();
        for (Integer k = 0; k < partContacts.size(); k++){
            // Create users record
            User u = TestDataFactory.buildUser(partContacts[k].Id);
            u.LastName = 'Test User' + k;
            u.Email = 'test' + k + '@testorg.com';
            partUsers.add(u);
        }

        EC_Exhibitor_Setting__c ecSetting = ExhibitorTestDataFactory.buildExhibitorSetting(account.Id);
        ecSetting.Max_Budget__c = 10.00;
        ecSetting.Send_Invoice_To__c = 'testInvoice@testEmail.com';
        insert ecSetting;

        EC_Order__c order = ExhibitorTestDataFactory.buildECOrder(ecSetting.Id, contact);
        order.Attendee_Type__c = 'Non-Members';
        insert order;

        EC_Email__c email = ExhibitorTestDataFactory.buildECEmail(ecSetting.Id, order.Id);
        insert email;

        BR_Events_Zone__c zone = LiveTestDataFactory.buildZone('Default', true);
        insert zone;

        BR_Event__c event = LiveTestDataFactory.buildEvent('Exhibitor Test Event', false, false, zone.Id);
        event.Registration_Confirmation_Message__c = 'You are registered!';
        insert event;

        List<OrgWideEmailAddress> owas = [SELECT Id FROM OrgWideEmailAddress LIMIT 1];

        insert new Send_Grid__c(url__c = 'https://api.sendgrid.com/v3/mail/send', API_key__c = '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');

        insert new BrEvents_Settings__c(Name='org wide email id', Label__c = 'org wide email id', Value__c = owas[0].Id);

        List<BR_Participation__c> participations = new List<BR_Participation__c>();
        for(Integer j = 5;j<partContacts.size();j++){
            participations.add(new BR_Participation__c(Contact__c=partContacts[j].Id
                    , BR_Event__c=event.Id
                    , Participate__c='Yes'
                    , Bypass_Confirmation__c= true
                    , GDPR_Certification__c = true));
        }
        insert participations;

        OrderApi__Item_Class__c itemClass = TestDataFactory.buildItemClass('Exhibitor Connect');
        insert itemClass;

        OrderApi__Item__c item = TestDataFactory.buildItem(itemClass.Id, 'Exhibitor Request');
        insert item;

        EC_Schedule__c schedule = ExhibitorTestDataFactory.buildECSchedule(event.Id);
        insert schedule;

        Time_Slot__c timeSlot = ExhibitorTestDataFactory.buildTimeSlot(order.Id, email.Id, schedule.Id);
        timeSlot.Delivery_Date__c = System.today().addDays(-1) ;
        timeSlot.Status__c = 'Sent';
        insert timeSlot;

        insert new EC_Event__c(Event_Name__c = event.Name, Event_Id__c = event.Id);

    }

    @isTest
    public static void test_Schedule_EC_EmailActivity() {
        String CRON_EXP = '0 0 0 ? * * *';

        Test.startTest();
        String jobId = System.schedule('ScheduledApexTest',
                CRON_EXP,
                new Schedule_EC_EmailActivity());
        Test.stopTest();

    }

    @IsTest
    public static void test_downloadEmailActivity(){

        Time_Slot__c ts = [SELECT Id, Start_Time__c, Delivery_Date__c, EC_Email__r.Subject__c, EC_Order__c FROM Time_Slot__c];

        Test.setMock(HttpCalloutMock.class, new CreateMockHTTPResponseGenerator());

        Test.startTest();
        SendGridActivityController.downloadEmailActivity(ts.Delivery_Date__c, ts.Start_Time__c, ts.EC_Email__r.Subject__c, ts.EC_Order__c);
        Test.stopTest();

        List<Email_Activity__c> ea = [SELECT Id FROM Email_Activity__c];
        System.assertEquals(true, ea.size() > 0);
    }


    @IsTest
    public static void test_FAILdownloadEmailActivity(){

        Time_Slot__c ts = [SELECT Id, Start_Time__c, Delivery_Date__c, EC_Email__r.Subject__c, EC_Order__c FROM Time_Slot__c];

        Test.setMock(HttpCalloutMock.class, new FailureMockHTTPResponseGenerator());

        Test.startTest();
        SendGridActivityController.downloadEmailActivity(ts.Delivery_Date__c, ts.Start_Time__c, ts.EC_Email__r.Subject__c, ts.EC_Order__c);
        Test.stopTest();

    }

    public class CreateMockHTTPResponseGenerator implements HttpCalloutMock{
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/x-www-form-urlencoded');
            res.setBody('{"messages":[{"from_email":"testEmail@yopmail.com","msg_id":"TBKPAedYRmGscdFMlWZALw.filterdrecv-6b4886b6-th98w-1-609AD438-B5.180","subject":"Email Activity","to_email":"testEmail1@yopmail.com","status":"delivered","opens_count":1,"clicks_count":0,"last_event_time":"2021-05-11T23:22:27Z"}]}');
            res.setStatusCode(200);
            return res;
        }
    }


    public class FailureMockHTTPResponseGenerator implements HttpCalloutMock{
        public HTTPResponse respond(HTTPRequest req) {
            //This is will fail because setBody is missing closing brackets.
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/x-www-form-urlencoded');
            res.setBody('{"messages":[{"from_email":"testEmail@yopmail.com","msg_id":"TBKPAedYRmGscdFMlWZALw.filterdrecv-6b4886b6-th98w-1-609AD438-B5.180","subject":"Email Activity","to_email":"testEmail1@yopmail.com","status":"delivered","opens_count":1,"clicks_count":0,"last_event_time":"2021-05-11T23:22:27Z"}');
            res.setStatusCode(200);
            return res;
        }
    }

}