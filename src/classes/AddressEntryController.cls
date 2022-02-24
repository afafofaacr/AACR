/**
 * Created by lauren.lezberg on 9/13/2019.
 */

public with sharing class AddressEntryController {

    /**
    * @purpose Retrieves map of available countries
    *
    * @return map of countries
    */
    @AuraEnabled(cacheable=true)
    public static Map<String, String> getCountries(){
        return ECRMUtils.getCountryPicklistValues();
    }

    /**
     * @purpose Retrieves map of states based on specified country value, if country is park of the EU, automatically check DO not Display in Directory checkbox
     *
     * @param countryVal
     *
     * @return map of states within country
     */
    @AuraEnabled(cacheable=true)
    public static Map<String, String> getStates(String countryVal, String mailingCountryCode, String otherCountryCode){
        System.debug('getStates was just called with country : ' + countryVal + 'mailingCountryCode: ' + mailingCountryCode + ' and otherCountryCode: ' + otherCountryCode);
        List<EU_Countries__mdt> countries = [SELECT Label, Country_Code__c FROM EU_Countries__mdt];
        Set<String> countryCodes = new Set<String>();
        for (EU_Countries__mdt country : countries) {
            countryCodes.add(country.Country_Code__c);
        }

        Contact currentContact = ECRMUtils.getCurrentLoginContact();
        if (countryCodes.contains(countryVal)) {
            currentContact.Do_Not_Display_in_Directory__c = true;
        } else {
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

}