@IsTest
private class BrEventsInstallHandlerTest {


    @isTest
    public static void testOnInstall1() {
        BrEventsInstallHandler installHandler = new BrEventsInstallHandler();
        Test.testInstall(installHandler, null);

        List<BrEvents_Settings__c> settings = [SELECT Name, Value__c FROM BrEvents_Settings__c];

        for (BrEvents_Settings__c setting : settings) {
            String settingName = setting.Name;

            if (settingName == 'email') {
                if (setting != null) {
                    String contactName = [SELECT PrimaryContact FROM Organization LIMIT 1].PrimaryContact;
                    String email = [SELECT Email FROM User WHERE Name = :contactName LIMIT 1].Email;
                    System.assertEquals(setting.Value__c, email, 'Invalid value');
                } else {
                    System.assertEquals(false, true, 'Settings value has not been created');
                }
            } else if (settingName == 'send email') {
                if (setting != null) {
                    System.assertEquals('false', setting.Value__c, 'Invalid value');
                } else {
                    System.assertEquals(false, true, 'Settings value has not been created');
                }
            } else if (settingName == 'guest_account_id') {
                if (setting != null) {
                    System.assertEquals('undefined', setting.Value__c, 'Invalid value');
                } else {
                    System.assertEquals(false, true, 'Settings value has not been created');
                }
            } else if (settingName == 'recaptcha_key') {
                if (setting != null) {
                    System.assertEquals('undefined', setting.Value__c, 'Invalid value');
                } else {
                    System.assertEquals(false, true, 'Settings value has not been created');
                }
            } else if (settingName == 'contact_recordtype_id') {
                if (setting != null) {
                    System.assertEquals('undefined', setting.Value__c, 'Invalid value');
                } else {
                    System.assertEquals(false, true, 'Settings value has not been created');
                }
            } else if (settingName == 'org wide email id') {
                if (setting != null) {
                    System.assertEquals('undefined', setting.Value__c, 'Invalid value');
                } else {
                    System.assertEquals(false, true, 'Settings value has not been created');
                }
            }
        }
    }

    @isTest
    public static void testOnInstall(){
        BrEventsInstallHandler installHandler = new BrEventsInstallHandler();
        installHandler.onInstall();
    }

    @isTest
    public static void testOnInstall2() {
        BrEventsInstallHandler installHandler = new BrEventsInstallHandler();
        Test.testInstall(installHandler, new Version(1,0));


        List<BrEvents_Settings__c> settings = [SELECT Name, Value__c FROM BrEvents_Settings__c];

        for (BrEvents_Settings__c setting : settings) {
            String settingName = setting.Name;

            if (settingName == 'email') {
                if (setting != null) {
                    String contactName = [SELECT PrimaryContact FROM Organization LIMIT 1].PrimaryContact;
                    String email = [SELECT Email FROM User WHERE Name = :contactName LIMIT 1].Email;
                    System.assertEquals(setting.Value__c, email, 'Invalid value');
                } else {
                    System.assertEquals(false, true, 'Settings value has not been created');
                }
            } else if (settingName == 'send email') {
                if (setting != null) {
                    System.assertEquals('false', setting.Value__c, 'Invalid value');
                } else {
                    System.assertEquals(false, true, 'Settings value has not been created');
                }
            } else if (settingName == 'guest_account_id') {
                if (setting != null) {
                    System.assertEquals('undefined', setting.Value__c, 'Invalid value');
                } else {
                    System.assertEquals(false, true, 'Settings value has not been created');
                }
            } else if (settingName == 'recaptcha_key') {
                if (setting != null) {
                    System.assertEquals('undefined', setting.Value__c, 'Invalid value');
                } else {
                    System.assertEquals(false, true, 'Settings value has not been created');
                }
            } else if (settingName == 'contact_recordtype_id') {
                if (setting != null) {
                    System.assertEquals('undefined', setting.Value__c, 'Invalid value');
                } else {
                    System.assertEquals(false, true, 'Settings value has not been created');
                }
            } else if (settingName == 'org wide email id') {
                if (setting != null) {
                    System.assertEquals('undefined', setting.Value__c, 'Invalid value');
                } else {
                    System.assertEquals(false, true, 'Settings value has not been created');
                }
            }
        }

        List<CronTrigger> cronFirstTriggers = [
                SELECT Id, CronExpression, TimesTriggered, NextFireTime
                FROM CronTrigger
                WHERE CronJobDetail.Name = 'Scheduled Job Event Reminder 1'
        ];

        System.assertEquals(1, cronFirstTriggers.size(), 'wrong number of reminders');

        List<CronTrigger> cronSecondTriggers = [
                SELECT Id, CronExpression, TimesTriggered, NextFireTime
                FROM CronTrigger
                WHERE CronJobDetail.Name = 'Scheduled Job Event Reminder 2'
        ];

        System.assertEquals(1, cronSecondTriggers.size(), 'wrong number of reminders');
    }
}