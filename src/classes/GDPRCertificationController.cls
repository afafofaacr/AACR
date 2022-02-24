/**
 * Created by lauren.lezberg on 1/13/2021.
 */

public with sharing class GDPRCertificationController {

    @AuraEnabled
    public static String getGDPRInfo(String salesOrderId){
        System.debug('getGDPRInfo: ' + salesOrderId);
        return EventRegisterController.getParticipantFromSO(salesOrderId);

    }

    public static Boolean getGDPRDefault(Id contactId){
        Contact contact = [SELECT Preferred_Address__c, MailingState, MailingCountryCode, OtherCountryCode, OtherState FROM COntact where Id=:contactId];
        List<EU_Countries__mdt> countries = [SELECT Label, Country_Code__c FROM EU_Countries__mdt];
        Set<String> countryCodes = new Set<String>();
        for (EU_Countries__mdt country : countries) {
            countryCodes.add(country.Country_Code__c);
        }

        Boolean gdprConsent = true;
        String countryVal;
        String stateVal;
        if (contact.Preferred_Address__c == 'Business') {
            countryVal = contact.MailingCountryCode;
            stateVal = contact.MailingState;
        } else {
            countryVal = contact.OtherCountryCode;
            stateVal = contact.OtherState;
        }

        if (countryCodes.contains(countryVal) || countryVal == 'CA' || stateVal == 'California') {
            System.debug('country code is in the EU');
            gdprConsent = false;
        } else {
            gdprConsent = true;
        }

        return gdprConsent;
    }


}