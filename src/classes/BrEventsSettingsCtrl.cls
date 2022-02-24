public with sharing class BrEventsSettingsCtrl {
    public String email {get; set;}
    public String sendEmail {get; set;}
    public String createLeadGuestRegister {get; set;}
    public String guestAccountId {get; set;}
    public String recaptchaKey {get; set;}
    public String contactRecordTypeId {get; set;}
    public String orgWideEmailId {get;set;}

    public BrEventsSettingsCtrl() {
        email = '';
        guestAccountId = '';
        recaptchaKey = '';
        contactRecordTypeId = '';
        sendEmail = 'false';
        createLeadGuestRegister = 'false';
        orgWideEmailId = '';

        if (!BrEventsHelper.performAccessCheck('read', 'BrEvents_Settings__c', null)) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, Label.msg_no_appr_permissions));return;
        }

        String settingName = '';
        for (BrEvents_Settings__c setting : [SELECT Id, Name, Value__c FROM BrEvents_Settings__c LIMIT 1000]) {

            try {
                if (setting.Name == 'email') {
                    email = setting.Value__c;
                }
            } catch (Exception e) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, Label.msg_custom_setting_organization_email));
                System.debug('BrEventsSettingsCtrl: ' + e.getMessage());
            }
            try {
                if (setting.Name == 'guest_account_id') {
                    guestAccountId = setting.Value__c;
                }
            } catch (Exception e) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, Label.msg_custom_setting_organization_email));
                System.debug('BrEventsSettingsCtrl: ' + e.getMessage());
            }
            try {
                if (setting.Name == 'recaptcha_key') {
                    recaptchaKey = setting.Value__c;
                }
            } catch (Exception e) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, Label.msg_custom_setting_organization_email));
                System.debug('BrEventsSettingsCtrl: ' + e.getMessage());
            }
            try {
                if (setting.Name == 'contact_recordtype_id') {
                    contactRecordTypeId = setting.Value__c;
                }
            } catch (Exception e) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, Label.msg_custom_setting_organization_email));
                System.debug('BrEventsSettingsCtrl: ' + e.getMessage());
            }
            try {
                if (setting.Name == 'send email') {
                    sendEmail = setting.Value__c;
                }
            } catch (Exception e) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, Label.msg_custom_setting_send_email));
                System.debug('BrEventsSettingsCtrl: ' + e.getMessage());
            }
            try {
                if (setting.Name == 'create_lead_on_guest_register') {
                    createLeadGuestRegister = setting.Value__c;
                }
            } catch (Exception e) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, Label.msg_custom_setting_send_email));
                System.debug('BrEventsSettingsCtrl: ' + e.getMessage());
            }

            try {
                if (setting.Name == 'org wide email id') {
                    orgWideEmailId = setting.Value__c;
                }
            } catch (Exception e) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, Label.msg_custom_setting_org_wide_email_id));
                System.debug('BrEventsSettingsCtrl: ' + e.getMessage());
            }
        }
    }


    public PageReference saveSettings() {

        try {
            List<BrEvents_Settings__c> updatedSettings = new List<BrEvents_Settings__c>();
            List<BrEvents_Settings__c> settings = [SELECT Id, Name, Value__c FROM BrEvents_Settings__c LIMIT 1000];
            Map<String, BrEvents_Settings__c> nameToSettings = new Map<String, BrEvents_Settings__c>();

            for (BrEvents_Settings__c setting : settings) {
                nameToSettings.put(setting.Name, setting);
            }

            BrEvents_Settings__c emailSettings;
            if (nameToSettings.containsKey('email')) {
                emailSettings = nameToSettings.get('email');
            } else {
                emailSettings = new BrEvents_Settings__c();
                emailSettings.Name = 'email';
            }
            emailSettings.Value__c = email;
            updatedSettings.add(emailSettings);

            BrEvents_Settings__c guestAccountIdSettings;
            if (nameToSettings.containsKey('guest_account_id')) {
                guestAccountIdSettings = nameToSettings.get('guest_account_id');
            } else {
                guestAccountIdSettings = new BrEvents_Settings__c();
                guestAccountIdSettings.Name = 'guest_account_id';
            }
            guestAccountIdSettings.Value__c = guestAccountId;
            updatedSettings.add(guestAccountIdSettings);

            BrEvents_Settings__c captchaSettings;
            if (nameToSettings.containsKey('recaptcha_key')) {
                captchaSettings = nameToSettings.get('recaptcha_key');
            } else {
                captchaSettings = new BrEvents_Settings__c();
                captchaSettings.Name = 'recaptcha_key';
            }
            captchaSettings.Value__c = recaptchaKey;
            updatedSettings.add(captchaSettings);

            BrEvents_Settings__c contactRecordTypeSettings;
            if (nameToSettings.containsKey('contact_recordtype_id')) {
                contactRecordTypeSettings = nameToSettings.get('contact_recordtype_id');
            } else {
                contactRecordTypeSettings = new BrEvents_Settings__c();
                contactRecordTypeSettings.Name = 'contact_recordtype_id';
            }
            contactRecordTypeSettings.Value__c = contactRecordTypeId;
            updatedSettings.add(contactRecordTypeSettings);

            BrEvents_Settings__c sendEmailSettings;
            if (nameToSettings.containsKey('send email')) {
                sendEmailSettings = nameToSettings.get('send email');
            } else {
                sendEmailSettings = new BrEvents_Settings__c();
                sendEmailSettings.Name = 'send email';
            }
            sendEmailSettings.Value__c = sendEmail;
            updatedSettings.add(sendEmailSettings);

            BrEvents_Settings__c createLeadGuestRegisterSettings;
            if (nameToSettings.containsKey('create_lead_on_guest_register')) {
                createLeadGuestRegisterSettings = nameToSettings.get('create_lead_on_guest_register');
            } else {
                createLeadGuestRegisterSettings = new BrEvents_Settings__c();
                createLeadGuestRegisterSettings.Name = 'create_lead_on_guest_register';
            }
            createLeadGuestRegisterSettings.Value__c = createLeadGuestRegister;
            updatedSettings.add(createLeadGuestRegisterSettings);

            BrEvents_Settings__c orgWideEmailIdSettings;
            if (nameToSettings.containsKey('org wide email id')) {
                orgWideEmailIdSettings = nameToSettings.get('org wide email id');
            } else {
                orgWideEmailIdSettings = new BrEvents_Settings__c();
                orgWideEmailIdSettings.Name = 'org wide email id';
            }
            orgWideEmailIdSettings.Value__c = orgWideEmailId;
            updatedSettings.add(orgWideEmailIdSettings);

            if (Schema.SObjectType.BrEvents_Settings__c.fields.Value__c.isUpdateable()) {
                upsert updatedSettings;

                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, Label.msg_saved_successfully));
            }
            else {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,
                        Label.msg_no_permissions));
            }
        }
        catch (Exception e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, Label.msg_failed_to_save));
            System.debug('BrEventsSettingsCtrl::saveSettings: ' + e.getMessage());return null;
        }
        return ApexPages.currentPage();

    }
}