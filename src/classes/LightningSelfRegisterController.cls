global without sharing class LightningSelfRegisterController {

    public LightningSelfRegisterController() {

    }

   
    @TestVisible private static boolean isValidPassword(String password, String confirmPassword) {
        return password == confirmPassword;
    }
    
//    @TestVisible private static boolean siteAsContainerEnabled(Id networkId) {
//        Auth.AuthConfiguration authConfig = new Auth.AuthConfiguration(networkId,'');
//        return authConfig.isCommunityUsingSiteAsContainer();
//    }
//
    @TestVisible
    private static void validatePassword(User u, String password, String confirmPassword) {
        if(!Test.isRunningTest())Site.validatePassword(u, password, confirmPassword);
        return;
    }

//    private static Id createHouseholdAccount(String firstName, String lastName, String email){
//            List<RecordType> recordTypes = [SELECT Id FROM RecordType WHERE Name= 'Active Account' AND SobjectType='Account'];
//            Account householdAcct = new Account();
//            householdAcct.Name = firstname + ' ' + lastname + ' (Individual)';
//            householdAcct.OrderApi__Account_Email__c = email;
//            householdAcct.RecordTypeId = recordTypes[0].Id;
//            List<siteSettings__c> siteSettings = [SELECT ownerId__c FROM siteSettings__c LIMIT 1];
//            if( siteSettings.size()==1 ) {
//                householdAcct.OwnerId = siteSettings[0].ownerId__c;
//            }
//            try{
//                upsert householdAcct;
//                return householdAcct.Id;
//            } catch(Exception e){
//                System.debug('Could not insert individual account: ' + e.getMessage());
//                return null;
//            }
//    }
     
    @AuraEnabled
    public static String selfRegister(String firstname ,String lastname, String email, String password, String confirmPassword, String accountId, String regConfirmUrl, String extraFields, String startUrl, Boolean includePassword) {
        //create household account if account doesnt exist
        if(BriteVerifyHelper.verifyEmail(email)==false){
            return 'The email address you are attempting to use is invalid or unreachable. Please correct or update your email address.';
        }

        System.debug('selfRegister with account: ' + accountId );
        if(accountId == null){
            Account acc = ECRMUtils.createOrFindIndividualAccount(firstname, lastname, email, null);
            Id newAcctId = acc.Id;
            if(newAcctId!=null) {
                accountId = newAcctId;
            } else {
                System.debug('Account was not created');
            }
        }



        Savepoint sp = null;
        try {
            sp = Database.setSavepoint();
            
            if (lastname == null || String.isEmpty(lastname)) {
                return Label.Site.lastname_is_required;
            }
            
            if (email == null || String.isEmpty(email)) {
                return Label.Site.email_is_required;
            }


            //check for duplicates
            if(ECRMUtils.checkForUser(email)){
                //has user account
                return 'An account already exists with this email. Please click <a href="/DW_Forgot_Password">here</a> to reset your password';
            } else {
                //no user account
                AACR_Error_Log__c eLog;
                ServiceNow_Incident_Type__mdt incidentType;

                List<Contact> contacts = ECRMUtils.getContactDuplicates(email);
                System.debug('contacts: ' + contacts);

                if(!contacts.isEmpty()) {
                    if (contacts.size() > 1) {
                        //duplicate alert with no user alert
                        incidentType = [SELECT Id,Type__c FROM ServiceNow_Incident_Type__mdt WHERE Type__c = 'No User and Duplicate Contacts'];
                        eLog = ErrorHelper.buildErrorLog(contacts[0], incidentType.Id, incidentType.Type__c, 'A contact with duplicates is missing a user record.');

                    } else if (contacts.size() == 1) {
                        incidentType = [SELECT Id,Type__c FROM ServiceNow_Incident_Type__mdt WHERE Type__c = 'Contact Missing User Record'];
                        eLog = ErrorHelper.buildErrorLog(contacts[0], incidentType.Id, incidentType.Type__c, 'Contact is missing associated user record.');
                    }

                    insert eLog;

                    ErrorHelper.sendServiceNowRequestEmail(contacts[0].Id, eLog.Id, null);

                    return 'An error has occurred. A help form ticket has been created for you and someone from the AACR will reach out to you shortly.';
                }
            }
//
            User u = new User();
            u.Username = email;
            u.put('Email',email);
            
            u.FirstName = firstname;
            u.LastName = lastname;
            
            String networkId = Network.getNetworkId();

            // If using site to host the community the user should not hit s1 after logging in from mobile.
//            if(networkId != null && siteAsContainerEnabled(networkId)) {
//                u.put('UserPreferencesHideS1BrowserUI',true);
//            }
            
            String nickname = ((firstname != null && firstname.length() > 0) ? firstname.substring(0,1) : '' ) + lastname.substring(0,1);
            nickname += String.valueOf(Crypto.getRandomInteger()).substring(1,7);
            u.put('CommunityNickname', nickname);
                     
//            if (extraFields != null) {
//                List<Object> extraFieldsList = (List<Object>) JSON.deserializeUntyped(extraFields);
//                for (Object thisFieldObject : extraFieldsList) {
//                    Map<String,Object> thisField = (Map<String,Object>) thisFieldObject;
//                    Schema.SObjectField sof = Schema.SObjectType.User.fields.getMap().get((String) thisField.get('fieldPath'));
//                    u.put(sof, thisField.get('value'));
//                }
//            }
                        
            if (includePassword) {    
                if (!isValidPassword(password, confirmPassword)) {
                    return Label.site.passwords_dont_match;
                }
                validatePassword(u, password, confirmPassword);
            }
            else {
                password = null;
            } 


            // lastName is a required field on user, but if it isn't specified, we'll default it to the username
            String userId =Site.createPortalUser(u, accountId, password);

            if (userId != null || Test.isRunningTest() ) {
                //login and redirect
                if (password != null && password.length() > 1) {

                    //update contact's work email
                    if(!Test.isRunningTest())ECRMUtils.updateContactWorkEmail(userId, email);

                    PageReference lgn = Site.login(email, password, startUrl);
                    if(!Test.isRunningTest())aura.redirect(lgn);
                }
                else {
                    PageReference confirmRef = new PageReference(regConfirmUrl);
                    if(!Test.isRunningTest())aura.redirect(confirmRef);
                }
            }
            return null;
        }
        catch (Exception ex) {
            System.debug('exception: ' + ex.getMessage() + ' stackTrace: ' + ex.getStackTraceString());
            Database.rollback(sp);
            return ex.getMessage();            
        }
    }
    
//    @AuraEnabled
//    public static List<Map<String,Object>> getExtraFields(String extraFieldsFieldSet) {
//        List<Map<String,Object>> extraFields = new List<Map<String,Object>>();
//        Schema.FieldSet fieldSet = Schema.SObjectType.User.fieldSets.getMap().get(extraFieldsFieldSet);
//        if (fieldSet != null) {
//            for (Schema.FieldSetMember f : fieldSet.getFields()) {
//                Map<String, Object> fieldDetail = new Map<String, Object>();
//                fieldDetail.put('dbRequired', f.getDBRequired());
//                fieldDetail.put('fieldPath', f.getFieldPath());
//                fieldDetail.put('label', f.getLabel());
//                fieldDetail.put('required', f.getRequired());
//                fieldDetail.put('type', f.getType());
//                fieldDetail.put('value', '');   // client will populate
//                extraFields.add(fieldDetail);
//            }
//        }
//        return extraFields;
//    }
}