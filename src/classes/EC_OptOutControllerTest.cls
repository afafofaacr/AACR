/**
 * Created by afaf.awad on 3/31/2021.
 */

@IsTest
public with sharing class EC_OptOutControllerTest {


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

        BR_Participation__c part = new BR_Participation__c(Contact__c=contact.Id
                                                        , BR_Event__c=event.Id
                                                        , Participate__c='Yes'
                                                        , Bypass_Confirmation__c= true
                                                        , GDPR_Certification__c = true
                                                        , User__c = user.Id);
        insert part;

        insert new EC_Event__c(Event_Name__c = event.Name, Event_Id__c = event.Id);

    }

    @IsTest
    public static void test_optOutOfEmails(){
        Contact con = [SELECT Id, AccountId FROM Contact WHERE Account.Name = 'Test Account' LIMIT 1];
        User user = [SELECT Id, ContactId, Email FROM User WHERE ContactId = :con.Id];
        BR_Event__c event = [SELECT Id FROM BR_Event__c WHERE Name = 'Exhibitor Test Event' ];

        EC_OptOutController.optOutOfEmails(event.Id, user.Email);

        BR_Participation__c part = [SELECT Id, GDPR_Certification__c FROM BR_Participation__c WHERE Contact__c =: con.Id];
        System.assertEquals(false, part.GDPR_Certification__c);

    }

    @IsTest
    public static void test_optOutOfEmailsNull(){
        Contact con = [SELECT Id, AccountId FROM Contact WHERE Account.Name = 'Test Account' LIMIT 1];
        User user = [SELECT Id, ContactId, Email FROM User WHERE ContactId = :con.Id];
        BR_Event__c event = [SELECT Id FROM BR_Event__c WHERE Name = 'Exhibitor Test Event' ];

        Boolean isSuccess = EC_OptOutController.optOutOfEmails(event.Id, 'failme@testemail.com');
        System.assertEquals(null, isSuccess);

    }
}