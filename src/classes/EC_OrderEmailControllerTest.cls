/**
 * Created by afaf.awad on 3/24/2021.
 */
@IsTest
public with sharing class EC_OrderEmailControllerTest {

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

        BR_Event__c event = LiveTestDataFactory.buildEvent('Text Exhibitor Event', false, false, zone.Id);
        insert event;

        EC_Schedule__c schedule = ExhibitorTestDataFactory.buildECSchedule(event.Id);
        insert schedule;

        Time_Slot__c timeSlot = ExhibitorTestDataFactory.buildTimeSlot(order.Id, email.Id, schedule.Id);
        timeSlot.Status__c = 'Sent';
        insert timeSlot;

        insert new EC_Event__c(Event_Name__c = event.Name, Event_Id__c = event.Id);

    }

    @IsTest
    public static void test_getEmailRecord(){
        Contact con = [SELECT Id, AccountId FROM Contact WHERE Account.Name = 'Test Account' LIMIT 1];
        User user = [SELECT Id, ContactId FROM User WHERE ContactId =: con.Id];
        EC_Email__c email = [SELECT Id, EC_Order__c, Exhibitor_Setting__c FROM EC_Email__c];

        List<Process_Steps__mdt> pSteps = [SELECT Id, Step_Order__c, Process__c FROM Process_Steps__mdt WHERE Process__r.DeveloperName = 'New_Exhibitor_Order' AND Join_Step__r.DeveloperName = 'EC_Order_Email'];

        contact_last_accessed_step__c las = new contact_last_accessed_step__c(Contact__c=con.Id, JoinId__c=pSteps[0].Process__c, Step_Order__c = pSteps[0].Step_Order__c - 1);
        insert las;

        System.runAs(user) {
           EC_Email__c returnedEmail = EC_OrderEmailController.getEmailRecord(email.EC_Order__c,pSteps[0].Id);
            System.assertEquals(returnedEmail.Id,email.Id);

            EC_Order__c newOrder = ExhibitorTestDataFactory.buildECOrder(email.Exhibitor_Setting__c, con);

            EC_Email__c newEmail =  EC_OrderEmailController.getEmailRecord(newOrder.Id,pSteps[0].Id);
            System.assertEquals([SELECT Id FROM EC_Email__c WHERE EC_Order__c =:newOrder.Id].Id, newEmail.Id);

        }
    }

    @IsTest
    public static void test_sendTestEmail() {
        Contact con = [SELECT Id, AccountId FROM Contact WHERE Account.Name = 'Test Account' LIMIT 1];
        User user = [SELECT Id, ContactId FROM User WHERE ContactId = :con.Id];
        EC_Email__c email = [SELECT Id, EC_Order__c, Exhibitor_Setting__c FROM EC_Email__c];

        System.runAs(user) {
            Boolean isSuccess = EC_OrderEmailController.sendTestEmail('testEmail@yopmail.com',email.Id);
            System.assertEquals(isSuccess,true);

        }
    }

}