global without sharing class BrEventsInstallHandler implements InstallHandler {
    global void onInstall(InstallContext context) {
        this.setEmailSettings();
        this.setSendEmailSettings();
        this.setCreateLeadGuestRegisterSettings();
        this.setGuestAccountId();
        this.setRecaptchaKey();
        this.setContactRecordTypeId();
        this.setOrganizationWideEmailId();
        this.createEventReminderJobs();
    }

    public void onInstall(){
        this.setEmailSettings();
        this.setSendEmailSettings();
        this.setCreateLeadGuestRegisterSettings();
        this.setGuestAccountId();
        this.setRecaptchaKey();
        this.setContactRecordTypeId();
        this.setOrganizationWideEmailId();
        this.createEventReminderJobs();

    }

    private void setEmailSettings() {
        if(!BrEventsHelper.performAccessCheck('read', 'BrEvents_Settings__c', new List<String>{'Value__c'})
                || !BrEventsHelper.performAccessCheck('create', 'BrEvents_Settings__c', new List<String>{'Name','Label__c','Value__c'})){
            return;
        }

        List<BrEvents_Settings__c> settings = [SELECT Value__c FROM BrEvents_Settings__c WHERE Name = 'email'];

        if (settings.size() == 0 && BrEventsHelper.performAccessCheck('create', 'BrEvents_Settings__c', null)) {
            List<Organization> orgs = [SELECT PrimaryContact FROM Organization LIMIT 1];
            String email = 'undefined';

            if (!orgs.isEmpty()) {
                List<User> users = [SELECT Email FROM User WHERE Name = :orgs[0].PrimaryContact];
                if (!users.isEmpty()) {
                    email = users[0].Email;
                }
            }

            insert new BrEvents_Settings__c (Name = 'email', Label__c = 'Email', Value__c = email);
        }
    }

    private void setGuestAccountId() {
        if(!BrEventsHelper.performAccessCheck('read', 'BrEvents_Settings__c', new List<String>{'Value__c'})
                || !BrEventsHelper.performAccessCheck('create', 'BrEvents_Settings__c', new List<String>{'Name','Label__c','Value__c'})){
            return;
        }

        List<BrEvents_Settings__c> settings = [SELECT Id FROM BrEvents_Settings__c WHERE Name = 'guest_account_id'];

        if (settings.size() == 0 && BrEventsHelper.performAccessCheck('create', 'BrEvents_Settings__c', null)) {
            insert new BrEvents_Settings__c (Name = 'guest_account_id', Label__c = 'Guest Account ID', Value__c = 'undefined');
        }
    }

    private void setRecaptchaKey() {
        if(!BrEventsHelper.performAccessCheck('read', 'BrEvents_Settings__c', new List<String>{'Value__c'})
                || !BrEventsHelper.performAccessCheck('create', 'BrEvents_Settings__c', new List<String>{'Name','Label__c','Value__c'})){
            return;
        }

        List<BrEvents_Settings__c> settings = [SELECT Id FROM BrEvents_Settings__c WHERE Name = 'recaptcha_key'];

        if (settings.size() == 0 && BrEventsHelper.performAccessCheck('create', 'BrEvents_Settings__c', null)) {
            insert new BrEvents_Settings__c (Name = 'recaptcha_key', Label__c = 'reCAPTCHA API Key', Value__c = 'undefined');
        }
    }

    private void setContactRecordTypeId() {
        if(!BrEventsHelper.performAccessCheck('read', 'BrEvents_Settings__c', new List<String>{'Value__c'})
                || !BrEventsHelper.performAccessCheck('create', 'BrEvents_Settings__c', new List<String>{'Name','Label__c','Value__c'})){
            return;
        }

        List<BrEvents_Settings__c> settings = [SELECT Id FROM BrEvents_Settings__c WHERE Name = 'contact_recordtype_id'];

        if (settings.size() == 0 && BrEventsHelper.performAccessCheck('create', 'BrEvents_Settings__c', null)) {
            insert new BrEvents_Settings__c (Name = 'contact_recordtype_id', Label__c = 'Contact Record Type Id', Value__c = 'undefined');
        }
    }

    private void setSendEmailSettings() {
        if(!BrEventsHelper.performAccessCheck('read', 'BrEvents_Settings__c', new List<String>{'Value__c'})
                || !BrEventsHelper.performAccessCheck('create', 'BrEvents_Settings__c', new List<String>{'Name','Label__c','Value__c'})){
            return;
        }

        List<BrEvents_Settings__c> settings = [SELECT Value__c FROM BrEvents_Settings__c WHERE Name = 'send email'];

        if (settings.size() == 0 && BrEventsHelper.performAccessCheck('create', 'BrEvents_Settings__c', null)) {
            insert new BrEvents_Settings__c (Name = 'send email', Label__c = 'Send Email', Value__c = 'false');
        }
    }

    private void setCreateLeadGuestRegisterSettings() {
        if(!BrEventsHelper.performAccessCheck('read', 'BrEvents_Settings__c', new List<String>{'Value__c'})
                || !BrEventsHelper.performAccessCheck('create', 'BrEvents_Settings__c', new List<String>{'Name','Label__c','Value__c'})){
            return;
        }

        List<BrEvents_Settings__c> settings = [SELECT Value__c FROM BrEvents_Settings__c WHERE Name = 'create_lead_on_guest_register'];

        if (settings.size() == 0 && BrEventsHelper.performAccessCheck('create', 'BrEvents_Settings__c', null)) {
            insert new BrEvents_Settings__c (Name = 'create_lead_on_guest_register', Label__c = 'Create lead when guests register', Value__c = 'false');
        }
    }

    private void setOrganizationWideEmailId() {
        if(!BrEventsHelper.performAccessCheck('read', 'BrEvents_Settings__c', new List<String>{'Value__c'})
                || !BrEventsHelper.performAccessCheck('create', 'BrEvents_Settings__c', new List<String>{'Name','Label__c','Value__c'})){
            return;
        }

        List<BrEvents_Settings__c> settings = [SELECT Value__c FROM BrEvents_Settings__c WHERE Name = 'org wide email id'];

        if (settings.size() == 0 && BrEventsHelper.performAccessCheck('create', 'BrEvents_Settings__c', null)) {
            insert new BrEvents_Settings__c (Name = 'org wide email id', Label__c = 'org wide email id', Value__c = 'undefined');
        }
    }

    private void createEventReminderJobs() {
        List<CronTrigger> cronTriggers = [
                SELECT Id
                FROM CronTrigger
                WHERE CronJobDetail.Name IN ('Scheduled Job Event Reminder 1', 'Scheduled Job Event Reminder 2')];


        if (cronTriggers.isEmpty()) {
            System.schedule('Scheduled Job Event Reminder 1', '0 0 * * * ?', new BrSendRemindersForEvents());
            System.schedule('Scheduled Job Event Reminder 2', '0 30 * * * ?', new BrSendRemindersForEvents());
        }
    }
}