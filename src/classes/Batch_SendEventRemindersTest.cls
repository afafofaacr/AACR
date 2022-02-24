/**
 * Created by afaf.awad on 10/23/2020.
 */

@IsTest
private class Batch_SendEventRemindersTest {

    @testsetup
    public static void setup(){

        Account acc = LiveTestDataFactory.buildAccount('Test Account');
        insert acc;

        List<Contact> contacts = new List<Contact>();
        for (Integer i = 0; i < 10; i++) {
            Contact con = LiveTestDataFactory.buildContact(acc.Id);
            con.LastName = con.LastName + i;
            con.Email = 'testEmail' + i + '@yopmail.com';
            contacts.add(con);
        }
        insert contacts;

        List<OrgWideEmailAddress> owas = [SELECT Id FROM OrgWideEmailAddress LIMIT 1];

        insert new Send_Grid__c(url__c = 'https://api.sendgrid.com/v3/mail/send', API_key__c = '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');

        insert new BrEvents_Settings__c(Name='org wide email id', Label__c = 'org wide email id', Value__c = owas[0].Id);

        BR_Events_Zone__c zone = LiveTestDataFactory.buildZone('Test Zone', true);
        insert zone;

        Venue__c ven = LiveTestDataFactory.buildVenue('Test Venue');
        ven.Virtual_Instructions__c = 'Testing Instructions.';
        insert ven;

        BR_Event__c physicalEvt = LiveTestDataFactory.buildEvent('Test Event',false,false);
        physicalEvt.Draft_Program__c = 'Test Draft Program';
        physicalEvt.Venue__c = ven.Id;
        physicalEvt.Publicly_available__c = TRUE;
        physicalEvt.Draft__c = FALSE;
        physicalEvt.Registration_Confirmation_Message__c = 'You Registered!';
        physicalEvt.Event_Stage__c='In Person';
        physicalEvt.Start_Date__c = Date.today();
        insert physicalEvt;

        BR_Event__c virtualEvt = LiveTestDataFactory.buildEvent('Test Event',false,false);
        virtualEvt.Draft_Program__c = 'Test Draft Program';
        virtualEvt.Venue__c = ven.Id;
        virtualEvt.Virtual_Venue__c = ven.Id;
        virtualEvt.Publicly_available__c = TRUE;
        virtualEvt.Draft__c = FALSE;
        virtualEvt.Registration_Confirmation_Message__c = 'You Registered!';
        virtualEvt.Event_Stage__c='Virtual';
        virtualEvt.Start_Date__c = date.today().addDays(1);
        insert virtualEvt;

        List<BR_Participation__c> participations = new List<BR_Participation__c>();
        for(Integer i = 0;i<5;i++){
            participations.add(new BR_Participation__c(Contact__c=contacts[i].Id, BR_Event__c=physicalEvt.Id, Participate__c='Yes'));
        }

        for(Integer j = 5;j<contacts.size();j++){
            participations.add(new BR_Participation__c(Contact__c=contacts[j].Id, BR_Event__c=virtualEvt.Id, Participate__c='Yes'));
        }

        insert new BrEvents_Settings__c(Name='org wide email id', Label__c = 'org wide email id', Value__c = owas[0].Id);

        system.debug('Insert Participants.size = ' + participations.size());
        insert participations;
    }

    @isTest
    public static void test_schedule() {
        String CRON_EXP = '0 0 0 15 3 ? 2022';

        Test.startTest();
        String jobId = System.schedule('ScheduledApexTest',
                CRON_EXP,
                new Batch_SendEventRemindersScheduler());
        Test.stopTest();

    }

    @isTest
    public static void test_sendEmailReminders() {

        Date today = Date.today();

        List<BR_Participation__c> parts = [SELECT Id FROM BR_Participation__c
                WHERE BR_Event__r.Publicly_available__c = TRUE
                AND BR_Event__r.Draft__c = FALSE
                AND BR_Event__r.Start_Date__c >=: today];

        System.debug('Participants size == : ' + parts.size());

        Test.startTest();

        database.executeBatch(new Batch_SendEventReminders());
        Test.stopTest();

    }
}