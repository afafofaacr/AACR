/**
 * Created by lauren.lezberg on 3/11/2020.
 */

public with sharing class VenueNewModalController {

    public class VenueData{
        @AuraEnabled
        public Boolean virtualAccess;

        @AuraEnabled
        public Map<String, String> countries;

        public VenueData(){
            virtualAccess = false;
            for(RecordTypeInfo info: Venue__c.SObjectType.getDescribe().getRecordTypeInfos()) {
                if(info.isAvailable() && info.getName() == 'Virtual') {
                   virtualAccess = true;
                }
            }

            countries = getCountries();
        }
    }


//    private static List<RecordType> getRecordTypes(){
//
//        List<RecordType> rTypes = [SELECT Id, Name FROM RecordType WHERE SobjectType='Venue__c'];
//        return rTypes;
//    }

    @AuraEnabled
    public static VenueData getData(){
        return new VenueData();
    }

    /**
     * @purpose Search for duplicate venues based on address and name
     *
     * @param street1
     * @param street2
     * @param street3
     * @param city
     * @param zip
     * @param name
     *
     * @return List of similar venues if any are found
     */
    @AuraEnabled
    public static List<Venue__c> validateVenue(String street1, String street2, String street3, String city,String zip, String name){
        List<Venue__c> venues = new List<Venue__c>();

        venues = [SELECT Id, Name, Street_1__c, Street_2__c, Street_3__c, City__c, State__c, Zip__c, Country__c FROM Venue__c WHERE (Street_1__c=: street1 AND City__c=: city AND Zip__c =: zip) OR Name=: name];
        System.debug('---venues: ' + venues);
        return venues;
    }


    /**
     * @purpose Retrieves map of available countries
     *
     * @return map of countries
     */
    @AuraEnabled
    public static Map<String, String> getCountries(){
        return ECRMUtils.getCountryPicklistValues();
    }

    /**
     * @purpose Retrieves map of states based on specified country value
     *
     * @param countryVal
     *
     * @return map of states within country
     */
    @AuraEnabled
    public static Map<String, String> getStates(String countryVal){
        return ECRMUtils.getDependentPicklistValues('Contact', 'MailingCountryCode', 'MailingStateCode', countryVal);
    }
}