/**
 * Created by afaf.awad on 3/31/2021.
 */
@IsTest
public with sharing class EC_HelperTest {

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
            con.Degrees_Held__c = 'AS';
            con.MailingCountry = 'United States';
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
        email.Template_Body__c = '<body>' + email.Template_Body__c + '</body>';
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
        for(Integer j = 0;j<partContacts.size();j++){
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

    @IsTest
    public static void test_getECSettingFromContact(){
        Contact con = [SELECT Id, AccountId FROM Contact WHERE Account.Name = 'Test Account' LIMIT 1];

        EC_Exhibitor_Setting__c ecSetting = EC_Helper.getECSettingFromContact(con.Id);
        System.assertEquals(con.AccountId, ecSetting.Company__c);

    }

    @IsTest
    public static void test_getOrderRecord(){
        Contact con = [SELECT Id, AccountId FROM Contact WHERE Account.Name = 'Test Account' LIMIT 1];
        EC_Order__c order = [SELECT Id FROM EC_Order__c];

        EC_Order__c returnedOrder = EC_Helper.getOrderRecord(order.Id);
        System.assertEquals(order.Id, returnedOrder.Id);

    }

    @IsTest
    public static void test_getAllOrdersForAccount(){
        Contact con = [SELECT Id, AccountId FROM Contact WHERE Account.Name = 'Test Account' LIMIT 1];
        User user = [SELECT Id, ContactId FROM User WHERE ContactId =: con.Id];

        Test.startTest();
        system.runAs(user) {
            List<EC_Order__c> orders = EC_Helper.getAllOrdersForAccount();
            System.assertEquals(1, orders.size());
        }
        Test.stopTest();

    }

    @IsTest
    public static void test_getEmailRecordFromOrder(){
        Contact con = [SELECT Id, AccountId FROM Contact WHERE Account.Name = 'Test Account' LIMIT 1];
        EC_Order__c order = [SELECT Id FROM EC_Order__c];

        EC_Email__c email = EC_Helper.getEmailRecordFromOrder(order.Id);
        System.assertEquals(order.Id, email.EC_Order__c);

    }

    @IsTest
    public static void test_getEmailRecord(){
        Contact con = [SELECT Id, AccountId FROM Contact WHERE Account.Name = 'Test Account' LIMIT 1];
        EC_Email__c email = [SELECT Id FROM EC_Email__c];

        EC_Email__c emailReturned = EC_Helper.getEmailRecord(email.Id);
        System.assertEquals(email.Id, emailReturned.Id);

    }

    @IsTest
    public static void test_getExhibitorSetting(){
        Contact con = [SELECT Id, AccountId FROM Contact WHERE Account.Name = 'Test Account' LIMIT 1];
        EC_Exhibitor_Setting__c ecSet = [SELECT Id FROM EC_Exhibitor_Setting__c];

        EC_Exhibitor_Setting__c ecSetting = EC_Helper.getExhibitorSetting(con.AccountId);
        System.assertEquals(ecSet.Id, ecSetting.Id);

        Account newAcc = TestDataFactory.buildAccount('New Test Account');
        insert newAcc;

        EC_Exhibitor_Setting__c ecSettingNull = EC_Helper.getExhibitorSetting(newAcc.Id);
        System.assertEquals(null, ecSettingNull );
    }

    @IsTest
    public static void test_getPreviousStep() {
        Contact con = [SELECT Id, AccountId FROM Contact WHERE Account.Name = 'Test Account' LIMIT 1];
        List<Process_Steps__mdt> pSteps = [SELECT Id, Step_Order__c, Process__c FROM Process_Steps__mdt WHERE Process__r.DeveloperName = 'EC_Approve_Order' AND Join_Step__r.DeveloperName = 'EC_Approve_Order'];

        contact_last_accessed_step__c las = new contact_last_accessed_step__c(Contact__c = con.Id, JoinId__c = pSteps[0].Process__c, Step_Order__c = pSteps[0].Step_Order__c);
        insert las;

        String stepId = EC_ReviewEmailController.getPreviousStep(pSteps[0].Id);
        System.assertEquals([SELECT Id FROM Process_Steps__mdt WHERE Process__r.DeveloperName = 'EC_Approve_Order' AND Join_Step__r.DeveloperName = 'EC_Review_Email'].Id, stepId);

    }

    @IsTest
    public static void test_getTargetCountNoFilters(){
        EC_Order__c order = [SELECT Id, Status__c FROM EC_Order__c];

        Integer targetCount = EC_Helper.getTargetCount(order.Id);
        System.assertEquals(50, targetCount);

        order.Attendee_Type__c = 'Non-Members ; Members';
        order.Countries__c = 'United States';
        order.Degrees__c = 'AS';
        order.Institution_Type__c = 'Academia';
        order.Organ_Sites__c = 'Bone';
        order.Research_Area_of_Expertise__c = 'Behavioral Science';
        update order;

        order.Status__c = 'Complete';
        update order;

        Integer completeTargetCount = EC_Helper.getTargetCount(order.Id);
        System.assertEquals(50, completeTargetCount);
    }

    @IsTest
    public static void test_getTargetCountFilters(){
        EC_Order__c order = [SELECT Id, Status__c FROM EC_Order__c];
        order.Attendee_Type__c = 'Non-Members ; Members';
        order.Countries__c = 'United States';
        order.Degrees__c = 'AS';
        order.Institution_Type__c = 'Academia';
        order.Organ_Sites__c = 'Bone';
        order.Research_Area_of_Expertise__c = 'Behavioral Science';
        update order;

        Integer completeTargetCount = EC_Helper.getTargetCount(order.Id);
        System.assertEquals(50, completeTargetCount);
    }

    @IsTest
    public static void test_getTargetCountComplete(){
        EC_Order__c order = [SELECT Id, Status__c FROM EC_Order__c];
        order.Status__c = 'Complete';
        update order;

        Integer completeTargetCount = EC_Helper.getTargetCount(order.Id);
        System.assertEquals(0, completeTargetCount);
    }


    @IsTest
    public static void test_createNewOrder(){
        Contact con = [SELECT Id, AccountId FROM Contact WHERE Account.Name = 'Test Account' LIMIT 1];
        User user = [SELECT Id, ContactId FROM User WHERE ContactId =: con.Id];
        EC_Order__c order;

        Test.startTest();
        system.runAs(user) {
             order = EC_Helper.createNewOrder();

        }
        insert order;
        Test.stopTest();

        List<EC_Order__c> orders = [SELECT Id FROM EC_Order__c];
        System.assertEquals(2, orders.size());

    }

    @IsTest
    public static void test_approveBudget(){
        EC_Order__c order = [SELECT Id, Exhibitor_Setting__r.Verified_Domain__c, Exhibitor_Setting__c FROM EC_Order__c];

        //Fail
        Boolean isSuccess = EC_Helper.approveBudget(order.Id);
        System.assertEquals(false, isSuccess);

        EC_Exhibitor_Setting__c ecSetting = new EC_Exhibitor_Setting__c(Id = order.Exhibitor_Setting__c, Verified_Domain__c = 'verifiedDomain.com');
        update ecSetting;

        //Success
        Boolean isSuccess2 = EC_Helper.approveBudget(order.Id);
        System.assertEquals(true, isSuccess2);
    }


    @IsTest
    public static void test_buildEmailTemplate(){
        EC_Email__c email = [SELECT Id FROM EC_Email__c];

        String template= EC_Helper.buildEmailTemplate(email.Id);
        System.assertEquals(true, template.contains('</br> <div style="text-align: center;" width="100%"> <p style="font-size: .7rem">'));
    }

    @isTest
    public static void test_sendOverBudgetEmail() {
        Time_Slot__c timeSlot = [SELECT Id, EC_Order__c, EC_Email__c, EC_Schedule__r.Event__c, EC_Email__r.Exhibitor_Setting__r.Max_Budget__c,
                EC_Order__r.Requested_By__r.FirstName, EC_Order__r.Requested_By__r.LastName, EC_Order__r.Requested_By__r.Email,
                Start_Time__c, Status__c, EC_Order__r.Status__c, EC_Order__r.Company__c, EC_Email__r.Exhibitor_Setting__r.Send_Invoice_To__c,
                EC_Email__r.Exhibitor_Setting__r.Verified_Domain__c, EC_Email__r.Template_Body__c, EC_Order__r.Name, EC_Order__r.Order_Name__c
        FROM Time_Slot__c];

       EC_Helper.sendOverBudgetEmail(timeSlot, 100, 200);

        Time_Slot__c timeSlotUpdated = [SELECT Id, Status__c FROM Time_Slot__c];
        EC_Order__c orderUpdated = [SELECT Id, Status__c FROM EC_Order__c];
        System.assertEquals('Over Budget', timeSlotUpdated.Status__c);
        System.assertEquals('Over Budget', orderUpdated.Status__c);

    }


    @isTest
    public static void test_sendCancelEmail() {
        Time_Slot__c timeSlot = [SELECT Id, EC_Order__c, EC_Email__c, EC_Schedule__r.Event__c, EC_Email__r.Exhibitor_Setting__r.Max_Budget__c,
                EC_Order__r.Requested_By__r.FirstName, EC_Order__r.Requested_By__r.LastName, EC_Order__r.Requested_By__r.Email,
                Start_Time__c, Status__c, EC_Order__r.Status__c, EC_Order__r.Company__c, EC_Email__r.Exhibitor_Setting__r.Send_Invoice_To__c,
                EC_Email__r.Exhibitor_Setting__r.Verified_Domain__c, EC_Email__r.Template_Body__c, EC_Order__r.Name, EC_Order__r.Order_Name__c
        FROM Time_Slot__c];

        EC_Helper.sendCancelEmail(timeSlot);

        Time_Slot__c timeSlotUpdated = [SELECT Id, Status__c FROM Time_Slot__c];
        EC_Order__c orderUpdated = [SELECT Id, Status__c FROM EC_Order__c];
        System.assertEquals('Cancelled', timeSlotUpdated.Status__c);
        System.assertEquals('Cancelled', orderUpdated.Status__c);

    }

    @IsTest
    public static void test_callSendGridAPI(){

        Map<String,String> emailMap = new Map<String, String>();
        emailMap.put('testemail@test.com', 'Test Name');

      EC_Helper.callSendGridAPI(emailMap, 'Test Subject', 'testFromEmail@test.com', 'Test Sender Name', 'Test Replyto', 'Test Body Content');
    }

}