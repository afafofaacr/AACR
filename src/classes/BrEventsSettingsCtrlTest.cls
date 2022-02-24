@IsTest
private class BrEventsSettingsCtrlTest {
    @IsTest
    public static void testNoSettings() {
        Test.startTest();

        BrEventsSettingsCtrl ctrlObj2 = new BrEventsSettingsCtrl();

        ctrlObj2.email = 'test';
        PageReference pageRefRes2 = ctrlObj2.saveSettings();

        System.assertNotEquals(null, pageRefRes2, 'Method should return PageReference instance');

        Profile stdUserProfile = [SELECT Id FROM Profile WHERE Name = 'Standard User'];
        User user = new User(Alias = 'testusr1', Email='testusr100@testorg.com',
                EmailEncodingKey='UTF-8', LastName='Testing1', LanguageLocaleKey='en_US',
                LocaleSidKey='en_US', ProfileId = stdUserProfile.Id,
                TimeZoneSidKey = UserInfo.getTimeZone().getID(), UserName='testusr100@testorg.com');

        insert user;

        System.runAs(user){
            ctrlObj2.email = 'test2';
            PageReference pageRefRes3 = ctrlObj2.saveSettings();

            System.assertNotEquals(null, pageRefRes3, 'Method should return PageReference instance');
        }

        Test.stopTest();
    }

    @IsTest
    public static void testHasSettings() {
        Test.startTest();

        List<BrEvents_Settings__c> settings = new List<BrEvents_Settings__c>();
        settings.add(new BrEvents_Settings__c(Name='email', Label__c = 'Organization Email', Value__c = 'email'));
        settings.add(new BrEvents_Settings__c(Name='send email', Label__c = 'Send Email', Value__c = 'false'));
        settings.add(new BrEvents_Settings__c(Name='create_lead_on_guest_register', Label__c = 'create_lead_on_guest_register', Value__c = 'false'));
        settings.add(new BrEvents_Settings__c(Name='guest_account_id', Label__c = 'Guest Account ID', Value__c = 'bf44f7w79qef'));
        settings.add(new BrEvents_Settings__c(Name='recaptcha_key', Label__c = 'reCAPTCHA API Key', Value__c = '79r4r297rh472h99rf7'));
        settings.add(new BrEvents_Settings__c(Name='contact_recordtype_id', Label__c = 'Contact Record Type Id', Value__c = 'u3u04t83u08r'));
        settings.add(new BrEvents_Settings__c(Name='org wide email id', Label__c = 'org wide email id', Value__c = 'undefined'));
        insert settings;

        BrEventsSettingsCtrl ctrlObj2 = new BrEventsSettingsCtrl();

        ctrlObj2.email = 'test';
        PageReference pageRefRes2 = ctrlObj2.saveSettings();

        System.assertNotEquals(null, pageRefRes2, 'Method should return PageReference instance');

        Profile stdUserProfile = [SELECT Id FROM Profile WHERE Name = 'Standard User'];
        User user = new User(Alias = 'testusr1', Email='testusr100@testorg.com',
                EmailEncodingKey='UTF-8', LastName='Testing1', LanguageLocaleKey='en_US',
                LocaleSidKey='en_US', ProfileId = stdUserProfile.Id,
                TimeZoneSidKey = UserInfo.getTimeZone().getID(), UserName='testusr100@testorg.com');

        insert user;

        System.runAs(user){
            ctrlObj2.email = 'test2';
            PageReference pageRefRes3 = ctrlObj2.saveSettings();

            System.assertNotEquals(null, pageRefRes3, 'Method should return PageReference instance');
        }

        Test.stopTest();
    }
}