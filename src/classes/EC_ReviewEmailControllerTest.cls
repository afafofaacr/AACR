/**
 * Created by afaf.awad on 3/29/2021.
 */
@IsTest
public with sharing class EC_ReviewEmailControllerTest {

    @TestSetup public static void setup() {
        Account account = LiveTestDataFactory.buildAccount('Test Account');
        insert account;

        Contact contact = LiveTestDataFactory.buildContact(account.Id);
        insert contact;

        User user = TestDataFactory.buildUser(contact.Id);
        insert user;

        Account staffAccount = LiveTestDataFactory.buildAccount('AACR Test Account');
        insert staffAccount;

        Contact staffContact = LiveTestDataFactory.buildContact(staffAccount.Id);
        insert staffContact;

        User staffUser = LiveTestDataFactory.buildStandardUser(staffContact.Id);
        insert staffUser;

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
    public static void test_getOrderForApproval() {
        String orderApprovalId = EC_ReviewEmailController.getOrderForApproval();
        System.assertEquals([SELECT Id FROM Join_Process__mdt WHERE DeveloperName = 'EC_Approve_Order'].Id, orderApprovalId);
    }

    @IsTest
    public static void test_getPreviousStep() {
        Contact con = [SELECT Id, AccountId FROM Contact WHERE Account.Name = 'AACR Test Account' LIMIT 1];
        List<Process_Steps__mdt> pSteps = [SELECT Id, Step_Order__c, Process__c FROM Process_Steps__mdt WHERE Process__r.DeveloperName = 'EC_Approve_Order' AND Join_Step__r.DeveloperName = 'EC_Approve_Order'];

        contact_last_accessed_step__c las = new contact_last_accessed_step__c(Contact__c = con.Id, JoinId__c = pSteps[0].Process__c, Step_Order__c = pSteps[0].Step_Order__c);
        insert las;

        String stepId = EC_ReviewEmailController.getPreviousStep(pSteps[0].Id);
        System.assertEquals([SELECT Id FROM Process_Steps__mdt WHERE Process__r.DeveloperName = 'EC_Approve_Order' AND Join_Step__r.DeveloperName = 'EC_Review_Email'].Id, stepId);

    }

    @IsTest
    public static void test_getEmailRecord() {
        EC_Email__c email =  EC_ReviewEmailController.getEmailRecord([SELECT Id FROM EC_Order__c LIMIT 1].Id);
        System.assertEquals([SELECT Id FROM EC_Email__c LIMIT 1].Id, email.Id);
    }

    @IsTest
    public static void test_getEmailReview(){
        EC_ReviewEmailController.EmailReview emailReview = EC_ReviewEmailController.getEmailReview([SELECT Id FROM EC_Order__c LIMIT 1].Id);

        List<User> users = [
                Select Id, Name, Profile.UserLicense.Name
                From User
                WHERE (Profile.UserLicense.Name = 'Salesforce' OR Profile.UserLicense.Name = 'Salesforce Platform')
                AND IsActive = TRUE
                ORDER BY Name
        ];


        System.assertEquals([SELECT Id FROM EC_Email__c LIMIT 1].Id, emailReview.email.Id);
        System.assertEquals(users.size(), emailReview.users.size());
    }

    @IsTest
    public static void test_sendTestEmail(){
        Contact con = [SELECT Id, AccountId FROM Contact WHERE Account.Name = 'AACR Test Account' LIMIT 1];
        User user = [SELECT Id, Email, ContactId FROM User WHERE Email = 'test@testorg.com' limit 1];

        EC_Exhibitor_Setting__c ecSetting = [SELECT Id FROM EC_Exhibitor_Setting__c];
        ecSetting.Verified_Domain__c = 'testDomain.com';
        update ecSetting;

        List<String> usersToEmail = new List<String>();
        usersToEmail.add(user.Id);

        Boolean isSuccess = EC_ReviewEmailController.sendTestEmail([SELECT Id FROM EC_Email__c LIMIT 1].Id, JSON.serialize(usersToEmail));


        System.assertEquals(isSuccess, true);
    }

    @IsTest
    public static void test_approveRejectOrder(){
        EC_Order__c order = [SELECT Id FROM EC_Order__c];

        EC_ReviewEmailController.ApproveResponse arError = EC_ReviewEmailController.approveRejectOrder(order.Id, 'Approve');
        System.assertEquals('Exhibitor Setting must have a verified domain before their order can be approved.', arError.message);

        EC_Exhibitor_Setting__c ecSetting = [SELECT Id, Verified_Domain__c FROM EC_Exhibitor_Setting__c];
        ecSetting.Verified_Domain__c = 'verifiedtestdomain.com';
        update ecSetting;

        EC_ReviewEmailController.ApproveResponse arApprove = EC_ReviewEmailController.approveRejectOrder(order.Id, 'Approve');
        System.assertEquals(true, arApprove.isSuccess);

        EC_ReviewEmailController.ApproveResponse arReject = EC_ReviewEmailController.approveRejectOrder(order.Id, 'Reject');
        System.assertEquals(true, arReject.isSuccess);

    }
}