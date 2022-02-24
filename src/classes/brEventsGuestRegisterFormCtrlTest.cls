@IsTest
private class brEventsGuestRegisterFormCtrlTest {
    @TestSetup
    static void setup() {
        BrEventTestUtils.testCreateEvents();

        List<OrgWideEmailAddress> owas = [SELECT Id FROM OrgWideEmailAddress LIMIT 1];
        System.assertEquals(owas.size(), 1);

        insert new BrEvents_Settings__c(Name='org wide email id', Label__c = 'org wide email id', Value__c = owas[0].Id);

        String orgWideEmailId = BrEventsHelper.getConfigValue('org wide email id');
        SYstem.assertEquals(orgWideEmailId, owas[0].Id);


    }

    @isTest
    public static void testGetRegisterFormInputsForContact() {
        Test.startTest();
        insert new BrEvents_Settings__c(Name='create_lead_on_guest_register', Label__c = 'create_lead_on_guest_register', Value__c = 'false');
        System.assertNotEquals(null, brEventsGuestRegisterFormCtrl.getRegisterFormInputs(), 'wrong field set data');

        Test.stopTest();
    }

    @isTest
    public static void testGetRegisterFormInputsForLead() {
        Test.startTest();
        insert new BrEvents_Settings__c(Name='create_lead_on_guest_register', Label__c = 'create_lead_on_guest_register', Value__c = 'true');
        System.assertNotEquals(null, brEventsGuestRegisterFormCtrl.getRegisterFormInputs(), 'wrong field set data');

        Test.stopTest();
    }

    @isTest
    public static void testRegisterGuestForEventWithoutSetting() {
        BR_Event__c event = [SELECT Id FROM BR_Event__c LIMIT 1];
        Account acc = new Account(Name = 'Test Account');
        insert acc;

        String jsonData = '[ ' +
                '{"FirstName":"Tim"},' +
                '{"LastName":"Larson"},' +
                '{"Email":"test@gmail.com"},' +
                '{"Phone":"12345678"},' +
                '{"Title":"Test"}]';
        Test.startTest();

        brEventsGuestRegisterFormCtrl.registerGuestForEvent(jsonData, event.Id);

        Test.stopTest();

//        List<BR_Participation__c> participations = [SELECT Id FROM BR_Participation__c];
//        System.assertEquals(0, participations.size(), 'wrong number of participations');
    }

    @isTest
    public static void testRegisterGuestForEventWithoutContactBefore() {


        BR_Event__c event = [SELECT Id FROM BR_Event__c LIMIT 1];
        Account acc = new Account(Name = 'Test Account');
        insert acc;
        insert new BrEvents_Settings__c(Name='guest_account_id', Label__c = 'Account Id', Value__c = acc.Id);
        insert new BrEvents_Settings__c(Name='create_lead_on_guest_register', Label__c = 'create_lead_on_guest_register', Value__c = 'false');
        String jsonData = '[ ' +
                '{"FirstName":"Tim"},' +
                '{"LastName":"Larson"},' +
                '{"Email":"test@gmail.com"},' +
                '{"Phone":"12345678"},' +
                '{"Title":"Test"}]';

        Profile stdUserProfile = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
        User user = new User(Alias = 'testusr1', Email='testusr100@testorg.com',
                EmailEncodingKey='UTF-8', LastName='Testing1', LanguageLocaleKey='en_US',
                LocaleSidKey='en_US', ProfileId = stdUserProfile.Id,
                TimeZoneSidKey = UserInfo.getTimeZone().getID(), UserName='testusr100@testorg.com');

        insert user;

        BrEventTestUtils.assignPermissionSet(user.Id, 'Live_Events');

        System.runAs(user) {
            Test.startTest();

            brEventsGuestRegisterFormCtrl.registerGuestForEvent(jsonData, event.Id);

            Test.stopTest();
        }

//        List<BR_Participation__c> participations = [SELECT Id FROM BR_Participation__c];
//        System.assertEquals(1, participations.size(), 'wrong number of participations');
    }

    @isTest
    public static void testRegisterGuestForEventWithContactBefore() {
        BR_Event__c event = [SELECT Id FROM BR_Event__c LIMIT 1];
        Account acc = new Account(Name = 'Test Account');
        insert acc;

        Contact contact = new Contact(Email = 'test@gmail.com', LastName = 'Larson');
        insert contact;


        insert new BrEvents_Settings__c(Name='guest_account_id', Label__c = 'Account Id', Value__c = acc.Id);
        insert new BrEvents_Settings__c(Name='create_lead_on_guest_register', Label__c = 'create_lead_on_guest_register', Value__c = 'false');
        String jsonData = '[ ' +
                '{"FirstName":"Tim"},' +
                '{"LastName":"Larson"},' +
                '{"Email":"test@gmail.com"},' +
                '{"Phone":"12345678"},' +
                '{"Title":"Test"}]';

        Profile stdUserProfile = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
        User user = new User(Alias = 'testusr1', Email='testusr100@testorg.com',
                EmailEncodingKey='UTF-8', LastName='Testing1', LanguageLocaleKey='en_US',
                LocaleSidKey='en_US', ProfileId = stdUserProfile.Id,
                TimeZoneSidKey = UserInfo.getTimeZone().getID(), UserName='testusr100@testorg.com');

        insert user;

        BrEventTestUtils.assignPermissionSet(user.Id, 'Live_Events');

        System.runAs(user) {
            Test.startTest();

            brEventsGuestRegisterFormCtrl.registerGuestForEvent(jsonData, event.Id);

            Test.stopTest();
        }

//        List<BR_Participation__c> participations = [SELECT Id FROM BR_Participation__c];
//        System.assertEquals(1, participations.size(), 'wrong number of participations');
    }

    @isTest
    public static void testRegisterGuestForEventWithoutLeadBefore() {
        BR_Event__c event = [SELECT Id FROM BR_Event__c LIMIT 1];
        insert new BrEvents_Settings__c(Name='create_lead_on_guest_register', Label__c = 'create_lead_on_guest_register', Value__c = 'true');
        String jsonData = '[ ' +
                '{"FirstName":"Tim"},' +
                '{"LastName":"Larson"},' +
                '{"Email":"test@gmail.com"},' +
                '{"Phone":"12345678"},' +
                '{"Company":"Test Company"},' +
                '{"Title":"Test"}]';

        Profile stdUserProfile = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
        User user = new User(Alias = 'testusr1', Email='testusr100@testorg.com',
                EmailEncodingKey='UTF-8', LastName='Testing1', LanguageLocaleKey='en_US',
                LocaleSidKey='en_US', ProfileId = stdUserProfile.Id,
                TimeZoneSidKey = UserInfo.getTimeZone().getID(), UserName='testusr100@testorg.com');

        insert user;

        BrEventTestUtils.assignPermissionSet(user.Id, 'Live_Events');

        System.runAs(user) {
            Test.startTest();

            brEventsGuestRegisterFormCtrl.registerGuestForEvent(jsonData, event.Id);

            Test.stopTest();
        }
//
//        List<BR_Participation__c> participations = [SELECT Id FROM BR_Participation__c];
//        System.assertEquals(1, participations.size(), 'wrong number of participations');
    }

    @isTest
    public static void testRegisterGuestForEventWithLeadBefore() {
        BR_Event__c event = [SELECT Id FROM BR_Event__c LIMIT 1];
        insert new BrEvents_Settings__c(Name='create_lead_on_guest_register', Label__c = 'create_lead_on_guest_register', Value__c = 'true');
        String jsonData = '[ ' +
                '{"FirstName":"Tim"},' +
                '{"LastName":"Larson"},' +
                '{"Email":"test@gmail.com"},' +
                '{"Phone":"12345678"},' +
                '{"Company":"Test Company"},' +
                '{"Title":"Test"}]';

        Profile stdUserProfile = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
        User user = new User(Alias = 'testusr1', Email='testusr100@testorg.com',
                EmailEncodingKey='UTF-8', LastName='Testing1', LanguageLocaleKey='en_US',
                LocaleSidKey='en_US', ProfileId = stdUserProfile.Id,
                TimeZoneSidKey = UserInfo.getTimeZone().getID(), UserName='testusr100@testorg.com');

        insert user;

        BrEventTestUtils.assignPermissionSet(user.Id, 'Live_Events');

        System.runAs(user) {
            Test.startTest();

            brEventsGuestRegisterFormCtrl.registerGuestForEvent(jsonData, event.Id);

            Test.stopTest();
        }

//        List<BR_Participation__c> participations = [SELECT Id FROM BR_Participation__c];
//        System.assertEquals(1, participations.size(), 'wrong number of participations');
    }
}