/**
 * Created by afaf.awad on 3/29/2021.
 */
@IsTest
public with sharing class EC_InvoiceHelperTest {
    @TestSetup public static void setup() {
        Account account = LiveTestDataFactory.buildAccount('Test Account');
        account.Stripe_Customer_Id__c = '123456789';
        account.Phone = '555-555-5555';
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
        for(Integer j = 5;j<partContacts.size();j++) {
            participations.add(new BR_Participation__c(Contact__c = partContacts[j].Id
                    , BR_Event__c = event.Id
                    , Participate__c = 'Yes'
                    , Bypass_Confirmation__c = true
                    , GDPR_Certification__c = true));
        }
        insert participations;

        OrderApi__Item_Class__c itemClass = TestDataFactory.buildItemClass('Exhibitor Connect');
        insert itemClass;

        OrderApi__Item__c item = TestDataFactory.buildItem(itemClass.Id, 'Exhibitor Request');
        item.OrderApi__SKU__c = 'abc-987-th54';
        insert item;

        EC_Schedule__c schedule = ExhibitorTestDataFactory.buildECSchedule(event.Id);
        insert schedule;

        Time_Slot__c timeSlot = ExhibitorTestDataFactory.buildTimeSlot(order.Id, email.Id, schedule.Id);
        timeSlot.Status__c = 'Scheduled';
        insert timeSlot;

        insert new EC_Event__c(Event_Name__c = event.Name, Event_Id__c = event.Id);

    }

    @isTest
    public static void test_EC_QueueableStripeInvoice() {
        Time_Slot__c timeSlot = [SELECT Id, EC_Order__c, EC_Email__c, EC_Schedule__r.Event__c, EC_Email__r.Exhibitor_Setting__r.Max_Budget__c,
                EC_Order__r.Requested_By__r.FirstName, EC_Order__r.Requested_By__r.LastName, EC_Order__r.Requested_By__r.Email,
                Start_Time__c, Status__c, EC_Order__r.Status__c, EC_Order__r.Company__c, EC_Email__r.Exhibitor_Setting__r.Send_Invoice_To__c,
                EC_Email__r.Exhibitor_Setting__r.Verified_Domain__c, EC_Email__r.Template_Body__c, EC_Order__r.Exhibitor_Setting__c
        FROM Time_Slot__c];
        timeSlot.Start_Time__c = Time.newInstance(6,0,0,0);
        Account acc = new Account(Id = timeSlot.EC_Order__r.Company__c, Stripe_Customer_Id__c = null);

        update timeSlot;
        update acc;

        Test.setMock(HttpCalloutMock.class, new CreateMockHttpResponseGenerator());

        Test.startTest();
        System.enqueueJob(new EC_QueueableStripeInvoice(EC_Helper.queryTargetAudience(timeSlot.EC_Order__c, timeSlot.EC_Schedule__r.Event__c).size(), timeSlot));
        Test.stopTest();

    }

    @isTest
    public static void test_EC_QueueableStripeInvoice_Fail() {
        Time_Slot__c timeSlot = [SELECT Id, EC_Order__c, EC_Email__c, EC_Schedule__r.Event__c, EC_Email__r.Exhibitor_Setting__r.Max_Budget__c,
                EC_Order__r.Requested_By__r.FirstName, EC_Order__r.Requested_By__r.LastName, EC_Order__r.Requested_By__r.Email,
                Start_Time__c, Status__c, EC_Order__r.Status__c, EC_Order__r.Company__c, EC_Email__r.Exhibitor_Setting__r.Send_Invoice_To__c,
                EC_Email__r.Exhibitor_Setting__r.Verified_Domain__c, EC_Email__r.Template_Body__c, EC_Order__r.Exhibitor_Setting__c
        FROM Time_Slot__c];

        Test.setMock(HttpCalloutMock.class, new FailureMockHTTPResponseGenerator());

        Test.startTest();
        System.enqueueJob(new EC_QueueableStripeInvoice(EC_Helper.queryTargetAudience(timeSlot.EC_Order__c, timeSlot.EC_Schedule__r.Event__c).size(), timeSlot));
        Test.stopTest();

    }


    @isTest
    public static void test_EC_QueueableStripeInvoice_Fail500() {
        Time_Slot__c timeSlot = [SELECT Id, EC_Order__c, EC_Email__c, EC_Schedule__r.Event__c, EC_Email__r.Exhibitor_Setting__r.Max_Budget__c,
                EC_Order__r.Requested_By__r.FirstName, EC_Order__r.Requested_By__r.LastName, EC_Order__r.Requested_By__r.Email,
                Start_Time__c, Status__c, EC_Order__r.Status__c, EC_Order__r.Company__c, EC_Email__r.Exhibitor_Setting__r.Send_Invoice_To__c,
                EC_Email__r.Exhibitor_Setting__r.Verified_Domain__c, EC_Email__r.Template_Body__c, EC_Order__r.Exhibitor_Setting__c
        FROM Time_Slot__c];

        Test.setMock(HttpCalloutMock.class, new FailureMockHTTPResponseGenerator500());

        Test.startTest();
        System.enqueueJob(new EC_QueueableStripeInvoice(EC_Helper.queryTargetAudience(timeSlot.EC_Order__c, timeSlot.EC_Schedule__r.Event__c).size(), timeSlot));
        Test.stopTest();

    }

    @isTest
    public static void test_EC_QueueableStripeInvoice_Fail501() {
        Time_Slot__c timeSlot = [SELECT Id, EC_Order__c, EC_Email__c, EC_Schedule__r.Event__c, EC_Email__r.Exhibitor_Setting__r.Max_Budget__c,
                EC_Order__r.Requested_By__r.FirstName, EC_Order__r.Requested_By__r.LastName, EC_Order__r.Requested_By__r.Email,
                Start_Time__c, Status__c, EC_Order__r.Status__c, EC_Order__r.Company__c, EC_Email__r.Exhibitor_Setting__r.Send_Invoice_To__c,
                EC_Email__r.Exhibitor_Setting__r.Verified_Domain__c, EC_Email__r.Template_Body__c, EC_Order__r.Exhibitor_Setting__c
        FROM Time_Slot__c];

        Test.setMock(HttpCalloutMock.class, new FailureMockHTTPResponseGenerator501());

        Test.startTest();
        System.enqueueJob(new EC_QueueableStripeInvoice(EC_Helper.queryTargetAudience(timeSlot.EC_Order__c, timeSlot.EC_Schedule__r.Event__c).size(), timeSlot));
        Test.stopTest();

    }

    public class CreateMockHTTPResponseGenerator implements HttpCalloutMock{
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/x-www-form-urlencoded');
            res.setBody('{"id": "1234567890", "client_secret": "83459843758947594", "status":"succeeded", "card" : {"last4": "4242", "brand":"visa", "exp_year" : "2050", "exp_month" : "4" }}');
            res.setStatusCode(200);
            return res;
        }
    }

    public class FailureMockHTTPResponseGenerator implements HttpCalloutMock{
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/x-www-form-urlencoded');
            res.setBody('{"error": {"message": "FAIL"}}');
            res.setStatusCode(402);
            return res;
        }
    }

    public class FailureMockHTTPResponseGenerator500 implements HttpCalloutMock{
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/x-www-form-urlencoded');
            res.setBody('{"error": {"message": "FAIL"}}');
            res.setStatusCode(500);
            return res;
        }
    }

    public class FailureMockHTTPResponseGenerator501 implements HttpCalloutMock{
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/x-www-form-urlencoded');
            res.setBody('{"error": {"message": "FAIL"}}');
            res.setStatusCode(501);
            return res;
        }
    }
}