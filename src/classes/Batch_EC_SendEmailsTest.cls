/**
 * Created by afaf.awad on 3/29/2021.
 */

@IsTest
public with sharing class Batch_EC_SendEmailsTest {

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
        timeSlot.Status__c = 'Scheduled';
        insert timeSlot;

        insert new EC_Event__c(Event_Name__c = event.Name, Event_Id__c = event.Id);

    }

    @isTest
    public static void test_EC_Scheduler_CheckBudget() {
        String CRON_EXP = '8 0 0 15 3 ? 2022';

        Test.startTest();
        String jobId = System.schedule('ScheduledApexTest',
                CRON_EXP,
                new Batch_EC_SendEmailsScheduler());
        Test.stopTest();

        Time_Slot__c timeSlot = [SELECT Id, Status__c FROM Time_Slot__c];
        System.assertEquals('Over Budget', timeSlot.Status__c);

    }

    @isTest
    public static void test_EC_Scheduler_OverBudget() {
        Time_Slot__c timeSlot = [SELECT Id, Start_Time__c, Status__c FROM Time_Slot__c];
        timeSlot.Start_Time__c = Time.newInstance(6,0,0,0);
        timeSlot.Status__c = 'Over Budget';
        update timeSlot;

        String CRON_EXP = '8 0 0 15 3 ? 2022';

        Test.startTest();
        String jobId = System.schedule('ScheduledApexTest',
                CRON_EXP,
                new Batch_EC_SendEmailsScheduler());
        Test.stopTest();

        Time_Slot__c updatedTimeSlot = [SELECT Id, Status__c FROM Time_Slot__c];
        System.assertEquals('Cancelled', updatedTimeSlot.Status__c);

    }

    @isTest
    public static void test_EC_Scheduler_NoVerifiedDomain() {
        Time_Slot__c timeSlot = [SELECT Id, Start_Time__c, Status__c FROM Time_Slot__c];
        timeSlot.Start_Time__c = Time.newInstance(6,0,0,0);
        update timeSlot;

        String CRON_EXP = '8 0 0 15 3 ? 2022';

        Test.startTest();
        String jobId = System.schedule('ScheduledApexTest',
                CRON_EXP,
                new Batch_EC_SendEmailsScheduler());
        Test.stopTest();

        Time_Slot__c updatedTimeSlot = [SELECT Id, Status__c FROM Time_Slot__c];
        System.assertEquals('Scheduled', updatedTimeSlot.Status__c);

    }

    @isTest
    public static void test_EC_Scheduler_SendEmails() {
        Time_Slot__c timeSlot = [SELECT Id, Start_Time__c, Status__c, EC_Order__r.Exhibitor_Setting__c FROM Time_Slot__c];
        timeSlot.Start_Time__c = Time.newInstance(6,0,0,0);

        EC_Exhibitor_Setting__c ecSetting = new EC_Exhibitor_Setting__c(Id = timeSlot.EC_Order__r.Exhibitor_Setting__c, Verified_Domain__c = 'testDomain.com');

        update ecSetting;
        update timeSlot;

        String CRON_EXP = '8 0 0 15 3 ? 2022';

        Test.startTest();
        String jobId = System.schedule('ScheduledApexTest',
                CRON_EXP,
                new Batch_EC_SendEmailsScheduler());
        Test.stopTest();

    }

}