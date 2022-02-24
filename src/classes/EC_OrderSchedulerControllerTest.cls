/**
 * Created by afaf.awad on 3/29/2021.
 */
@IsTest
public with sharing class EC_OrderSchedulerControllerTest {

    @TestSetup public static void setup() {
        Account account = LiveTestDataFactory.buildAccount('Test Account');
        insert account;

        Contact contact = LiveTestDataFactory.buildContact(account.Id);
        insert contact;

        User user = TestDataFactory.buildUser(contact.Id);
        insert user;

        EC_Exhibitor_Setting__c ecSetting = ExhibitorTestDataFactory.buildExhibitorSetting(account.Id);
        insert ecSetting;

        EC_Order__c order = ExhibitorTestDataFactory.buildECOrder(ecSetting.Id, contact);
        insert order;

        EC_Email__c email = ExhibitorTestDataFactory.buildECEmail(ecSetting.Id, order.Id);
        insert email;

        BR_Events_Zone__c zone = LiveTestDataFactory.buildZone('Default', true);
        insert zone;

        BR_Event__c event = LiveTestDataFactory.buildEvent('Exhibitor Test Event', false, false, zone.Id);
        insert event;

        EC_Schedule__c schedule = ExhibitorTestDataFactory.buildECSchedule(event.Id);
        insert schedule;

        Time_Slot__c timeSlot = ExhibitorTestDataFactory.buildTimeSlot(order.Id, email.Id, schedule.Id);
        insert timeSlot;

        insert new EC_Event__c(Event_Name__c = event.Name, Event_Id__c = event.Id);

    }

    @IsTest
    public static void test_getSchedule() {
        Contact con = [SELECT Id, AccountId FROM Contact WHERE Account.Name = 'Test Account' LIMIT 1];
        User user = [SELECT Id, ContactId FROM User WHERE ContactId = :con.Id];
        EC_Order__c order = [SELECT Id FROM EC_Order__c];
        List<Time_Slot__c> timeSlots = [SELECT Id FROM Time_Slot__c WHERE EC_Order__c =: order.Id];
        EC_Schedule__c schedule = [SELECT Id FROM EC_Schedule__c];

        List<Process_Steps__mdt> pSteps = [SELECT Id, Step_Order__c, Process__c FROM Process_Steps__mdt WHERE Process__r.DeveloperName = 'New_Exhibitor_Order' AND Join_Step__r.DeveloperName = 'EC_Order_Scheduler'];

        contact_last_accessed_step__c las = new contact_last_accessed_step__c(Contact__c = con.Id, JoinId__c = pSteps[0].Process__c, Step_Order__c = pSteps[0].Step_Order__c - 1);
        insert las;


        System.runAs(user) {
            EC_OrderSchedulerController.ScheduleTimes scheduleTimes = EC_OrderSchedulerController.getSchedule(pSteps[0].Id, order.Id);
            System.assertEquals(schedule.Id, scheduleTimes.schedule[0].Id);
            System.assertEquals(timeSlots[0].Id, scheduleTimes.timeSlot.Id);

        }
    }

    @IsTest
    public static void test_getTimeSlots() {
        Contact con = [SELECT Id, AccountId FROM Contact WHERE Account.Name = 'Test Account' LIMIT 1];
        User user = [SELECT Id, ContactId FROM User WHERE ContactId = :con.Id];
        Time_Slot__c ts = [SELECT Id, Delivery_Date__c, Status__c, EC_Schedule__c FROM Time_Slot__c WHERE EC_Order__c IN (SELECT Id FROM EC_Order__c)];
        System.debug('TimeSlots == ' + ts);
//        Time_Slot__c cancelledTS = ExhibitorTestDataFactory.buildTimeSlot(null, null, schedule.Id);
//        cancelledTS.Status__c = 'Cancelled';
//        insert cancelledTS;

//        DateTime timeSlotDate = Datetime.newInstance(ts.Delivery_Date__c.year(), ts.Delivery_Date__c.month(), ts.Delivery_Date__c.day());

        System.runAs(user) {
            List<Time_Slot__c> timeSlotsTaken = EC_OrderSchedulerController.getTimeSlots(ts.EC_Schedule__c, Datetime.now().format('yyyy-MM-dd'));
            System.assertEquals(1, timeSlotsTaken.size());
        }
    }

    @IsTest
    public static void test_saveTimeSlot() {
        Contact con = [SELECT Id, AccountId FROM Contact WHERE Account.Name = 'Test Account' LIMIT 1];
        User user = [SELECT Id, ContactId FROM User WHERE ContactId = :con.Id];
        List<Time_Slot__c> timeSlots = [SELECT Id, Delivery_Date__c, EC_Order__c FROM Time_Slot__c WHERE EC_Order__c IN (SELECT Id FROM EC_Order__c)];
        EC_Schedule__c schedule = [SELECT Id FROM EC_Schedule__c];

        DateTime timeSlotDate = Datetime.newInstance(timeSlots[0].Delivery_Date__c.year(), timeSlots[0].Delivery_Date__c.month(), timeSlots[0].Delivery_Date__c.day());

        System.runAs(user) {
            EC_OrderSchedulerController.saveTimeSlot(timeSlots[0].EC_Order__c, schedule.Id, timeSlots[0].Id, 8, 0, 9, 0, timeSlotDate.format('yyyy-MM-dd'));
        }

        List<Time_Slot__c> newTimeSlots = [SELECT Id, Start_Time__c FROM Time_Slot__c];
        System.assertEquals( Time.newInstance(8,0,0,0) , newTimeSlots[0].Start_Time__c);
    }
}