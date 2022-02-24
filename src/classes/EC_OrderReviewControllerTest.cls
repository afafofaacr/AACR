/**
 * Created by afaf.awad on 3/29/2021.
 */
@IsTest
public with sharing class EC_OrderReviewControllerTest {

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
    public static void test_getReviewOrder() {
        Contact con = [SELECT Id, AccountId FROM Contact WHERE Account.Name = 'Test Account' LIMIT 1];
        User user = [SELECT Id, ContactId FROM User WHERE ContactId = :con.Id];
        EC_Order__c order = [SELECT Id FROM EC_Order__c];
        List<Time_Slot__c> timeSlots = [SELECT Id FROM Time_Slot__c WHERE EC_Order__c =: order.Id];

        List<Process_Steps__mdt> pSteps = [SELECT Id, Step_Order__c, Process__c FROM Process_Steps__mdt WHERE Process__r.DeveloperName = 'New_Exhibitor_Order' AND Join_Step__r.DeveloperName = 'EC_Order_Review'];

        contact_last_accessed_step__c las = new contact_last_accessed_step__c(Contact__c = con.Id, JoinId__c = pSteps[0].Process__c, Step_Order__c = pSteps[0].Step_Order__c - 1);
        insert las;


        System.runAs(user) {
            EC_OrderReviewController.ReviewOrder reviewOrder = EC_OrderReviewController.getReviewOrder(pSteps[0].Id, order.Id);
            System.assertEquals(order.Id, reviewOrder.order.Id);
            System.assertEquals(timeSlots[0].Id, reviewOrder.timeSlot.Id);

            EC_OrderReviewController.getPreviousStep(pSteps[0].Id);
            EC_OrderReviewController.clearLastStep(pSteps[0].Id);

        }
    }
}