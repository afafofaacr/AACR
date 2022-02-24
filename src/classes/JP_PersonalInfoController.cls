/**
 * Created by lauren.lezberg on 2/25/2019.
 */

public without sharing class JP_PersonalInfoController {
 
    public class PersonalInfo{

        @AuraEnabled
        public Contact currentContact;

        @AuraEnabled
        public Boolean disableDoNotDisplay;

        @AuraEnabled
        public Boolean hideDoNotDisplay;

        @AuraEnabled
        public List<String> degreesHeldValues;

        @AuraEnabled
        public List<OrderApi__Known_Address__c> addresses;


        public PersonalInfo(Contact con, Boolean disable, Boolean hide){
            this.currentContact = con;
            this.addresses = new List<OrderApi__Known_Address__c>();
            this.addresses = [SELECT Id, OrderApi__Is_Default__c, OrderApi__Street__c, OrderApi__City__c, OrderApi__Province__c, OrderApi__Country__c, OrderApi__Postal_Code__c, Type__c FROM OrderApi__Known_Address__c WHERE OrderApi__Contact__c=:con.Id];
            this.disableDoNotDisplay = disable;
            this.hideDoNotDisplay = hide;
            this.degreesHeldValues = ECRMUtils.getPicklistValues('Contact','Degrees_Held__c');

        }
    }

    @AuraEnabled
    public static Boolean setContactAccount(String contactId, String accountId){
        Boolean success = false;
        Contact con = [SELECT FirstName, LastName, Email FROM Contact WHERE Id = :contactId];
        if(accountId==null) {
            Account acc = ECRMUtils.createOrFindIndividualAccount(con.FirstName, con.LastName, con.Email, contactId);
            accountId = acc.Id;
        }
//        else {
            try {
                con.AccountId = accountId;
                update con;

                success = true;
            } catch (Exception e) {
                System.debug('Could not update account: ' + e.getMessage());
                return null;
            }
//        }

        return success;
    }

    @AuraEnabled
    public static Contact getCurrentContact(){
        return ECRMUtils.getCurrentLoginContact();
    }

    /**
     * @purpose Gets current contact record information
     *
     * @return PersonalInfo wrapper object
     */
    @AuraEnabled
    public static PersonalInfo getPersonalInfo(Id joinId){

        Contact currentContact = ECRMUtils.getCurrentLoginContact();
        Boolean disableDoNotDisplay = false;
        Boolean hideDoNotDisplay = false;

        if(joinId!=null){
            String selfRegId = [SELECT Id FROM Join_Process__mdt WHERE DeveloperName = 'myAACR_Registration'].Id;
            if (selfRegId == joinId) {
                hideDoNotDisplay = true;
            }
        }

        if(currentContact.Birthdate!=null) {
            Decimal age = Math.floor(currentContact.Birthdate.daysBetween(Date.today()) / 365.2425);

            if (age <= 17) {
                currentContact.Do_Not_Display_in_Directory__c = true;
                update currentContact;
                disableDoNotDisplay = true;
            }

        }

        return new PersonalInfo(currentContact, disableDoNotDisplay, hideDoNotDisplay);

    }


    /**
     * @purpose Retrieves map of states based on specified country value
     *
     * @param countryVal
     *
     * @return map of states within country
     */
    @AuraEnabled
    public static Map<String, String> getStates(String countryVal, String mailingCountryCode, String otherCountryCode){
        System.debug('getStates was just called with country : ' + countryVal);
        List<EU_Countries__mdt> countries = [SELECT Label, Country_Code__c FROM EU_Countries__mdt];
        Set<String> countryCodes = new Set<String>();
        for (EU_Countries__mdt country : countries) {
            countryCodes.add(country.Country_Code__c);
        }

            Contact currentContact = ECRMUtils.getCurrentLoginContact();
            if (countryCodes.contains(countryVal)) {
                System.debug('country code is in the EU');
                currentContact.Do_Not_Display_in_Directory__c = true;
            } else {
                System.debug('country code is NOT in the EU');
                if(mailingCountryCode!=null && otherCountryCode!=null) {
                    if (!countryCodes.contains(mailingCountryCode) && !countryCodes.contains(otherCountryCode)) {
                        currentContact.Do_Not_Display_in_Directory__c = false;
                    }
                }
            }

            try {
                update currentContact;
            } catch (Exception e) {
                System.debug('Could not update contact: ' + e.getMessage());
            }



        return ECRMUtils.getDependentPicklistValues('Contact', 'MailingCountryCode', 'MailingStateCode', countryVal);
    }

    @AuraEnabled
    public static Map<String, Boolean> verifyEmails(String workEmail, String personalEmail){
        Map<String, Boolean> emailValidityMap = new Map<String, Boolean>();
        if(workEmail!=null) {
            emailValidityMap.put('work', BriteVerifyHelper.verifyEmail(workEmail));
        }

        if(personalEmail!=null) {
            emailValidityMap.put('personal', BriteVerifyHelper.verifyEmail(personalEmail));
        }

        return emailValidityMap;
    }


}