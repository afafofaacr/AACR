@IsTest
private class BrSendRemindersForEventsTest {
    @TestSetup
    static void setup() {
        User adminUser = BrEventTestUtils.testCreateUser();

        System.runAs(adminUser) {
            List<BR_Event__c> events = BrEventTestUtils.testCreateEvents();
            List<BR_Participation__c> participations = new List<BR_Participation__c>();
            Contact contact = BrEventTestUtils.tesCreateContact();

            List<OrgWideEmailAddress> owas = [SELECT Id FROM OrgWideEmailAddress LIMIT 1];
            System.assertEquals(owas.size(), 1);

            insert new BrEvents_Settings__c(Name='org wide email id', Label__c = 'org wide email id', Value__c = owas[0].Id);

            BrEventTestUtils.testCreateParticipations(events, contact.Id, adminUser.Id);

        }
    }

    @isTest
    public static void testSchedule() {
        Test.startTest();

        String CRON_EXP = '0 0 0 1 1 ? 2025';
        String jobId = System.schedule('Event schedule', CRON_EXP, new BrSendRemindersForEvents() );

        CronTrigger ct = [
                SELECT Id, CronExpression, TimesTriggered, NextFireTime
                FROM CronTrigger
                WHERE id = :jobId
        ];

        System.assertEquals(CRON_EXP, ct.CronExpression, 'wrong expressions');
        System.assertEquals(0, ct.TimesTriggered, 'wrong time triggered');
        System.assertEquals('2025-01-01 00:00:00', String.valueOf(ct.NextFireTime), 'wrong next time triggered');

        Test.stopTest();
    }

    @isTest
    public static void testSendEventReminders() {
        Test.startTest();

        new BrSendRemindersForEvents().sendEventReminders();

        System.assert(true);

        Test.stopTest();
    }

    @isTest
    public static void testCreateEmails() {
        String eventId = [SELECT Id FROM BR_Event__c LIMIT 1].Id;

        Test.startTest();
        Integer reminderNum = 1;
        List<Integer> reminderNums = new List<Integer>();
        reminderNums.add(reminderNum);
        List<Messaging.SingleEmailMessage> emails = BrSendRemindersForEvents.createEmails(new Set<Id>{eventId}, Datetime.now(), reminderNums);

        Test.stopTest();

        System.assertNotEquals(true, emails.isEmpty());
    }
}