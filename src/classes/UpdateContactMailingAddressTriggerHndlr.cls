/**
 * Created by lauren.lezberg on 9/14/2020.
 */

public without sharing class UpdateContactMailingAddressTriggerHndlr {

    /**
     * @purpose Before Update - if known address has name, change name and details to billing address and type to other
     * @param billingAddresses
     */
    public static void updateBillingAddress(List<OrderApi__Known_Address__c> billingAddresses){
        System.debug('updateBillingAddress: ' + billingAddresses);
        for(OrderApi__Known_Address__c ka : billingAddresses){
                ka.OrderApi__Name__c = 'Billing Address';
                ka.Type__c = 'Other';
                ka.OrderApi__Additional_Details__c = 'Billing Address';
        }
        System.debug('addresses before update: ' + billingAddresses);
    }


    /**
     * @purpose After Update - if known address is default, update contact MailingAddress with known address fields
     * @param addressMap
     */
    public static void updateContactMailingAddress(Map<String, OrderApi__Known_Address__c> addressMap){
        System.debug('updateMailingAddress: ' + addressMap);

        List<Contact> contacts = [SELECT MailingStreet, MailingState, MailingPostalCode, MailingCountry FROM Contact WHERE Id IN: addressMap.keySet()];
        System.debug('contacts to be updated: ' + contacts);

        Map<String, String> countryValues = ECRMUtils.getCountryCodes();

        for(Contact con : contacts){

            con.MailingStreet = addressMap.get(con.Id).OrderApi__Street__c;
            con.MailingCity = addressMap.get(con.Id).OrderApi__City__c;

            /** Look for US territories **/
            if(countryValues.get(addressMap.get(con.Id).OrderApi__Country__c) == null){
                Map<String, String> stateValues = ECRMUtils.getDependentPicklistValuesReverse('Contact', 'MailingCountryCode', 'MailingStateCode', 'US');
                if(stateValues.get(addressMap.get(con.Id).OrderApi__Country__c)!=null){
                    con.MailingCountryCode = 'US';
                    con.MailingStateCode = stateValues.get(addressMap.get(con.Id).OrderApi__Country__c);
                }
            } else {
                con.MailingCountryCode = countryValues.get(addressMap.get(con.Id).OrderApi__Country__c);
                /** Look for states for US & Canada **/
                if (addressMap.get(con.Id).OrderApi__Country__c == 'United States' || addressMap.get(con.Id).OrderApi__Country__c == 'Canada') {
                    if (addressMap.get(con.Id).OrderApi__Province__c != null) {
                        if (addressMap.get(con.Id).OrderApi__Province__c.length() == 2) {
                            con.MailingStateCode = addressMap.get(con.Id).OrderApi__Province__c;
                        } else {
                            con.MailingState = addressMap.get(con.Id).OrderApi__Province__c;
                        }
                    }
                }
            }

            con.MailingPostalCode = addressMap.get(con.Id).OrderApi__Postal_Code__c!=null?addressMap.get(con.Id).OrderApi__Postal_Code__c:'';
            con.Bad_Mailing_Address__c = addressMap.get(con.Id).Bad_Address__c;
        }

        System.debug('contacts before update: ' + contacts);
        update contacts;
    }

    /**
     * @purpose After Update - if known address is journal address, update contact Journal Address with known address fields
     * @param addressMap
     */
    public static void updateContactJournalAddress(Map<String, OrderApi__Known_Address__c> addressMap){
        System.debug('updateMailingAddress: ' + addressMap);

        if(!addressMap.isEmpty()) {
            List<Contact> contacts = [SELECT MailingStreet, MailingState, MailingPostalCode, MailingCountry FROM Contact WHERE Id IN:addressMap.keySet()];
            System.debug('contacts to be updated: ' + contacts);

            Map<String, String> countryValues = ECRMUtils.getCountryCodes();

            for (Contact con : contacts) {

                con.Journal_Street__c = addressMap.get(con.Id).OrderApi__Street__c;
                con.Journal_City__c = addressMap.get(con.Id).OrderApi__City__c;

                /** Handle US Territories **/
                if(countryValues.get(addressMap.get(con.Id).OrderApi__Country__c) == null){
                    Map<String, String> stateValues = ECRMUtils.getDependentPicklistValuesReverse('Contact', 'MailingCountryCode', 'MailingStateCode', 'US');
                    if(stateValues.get(addressMap.get(con.Id).OrderApi__Country__c)!=null){
                        con.Journal_Country__c = 'United States';
                        con.Journal_State_Province__c = addressMap.get(con.Id).OrderApi__Country__c;
                    }
                } else {
                    con.Journal_Country__c = addressMap.get(con.Id).OrderApi__Country__c;
                    /** Handle states for US & Canada **/
                    if (addressMap.get(con.Id).OrderApi__Country__c == 'United States' || addressMap.get(con.Id).OrderApi__Country__c == 'Canada') {
                        if (addressMap.get(con.Id).OrderApi__Province__c != null) {
                            con.Journal_State_Province__c = addressMap.get(con.Id).OrderApi__Province__c;
                        }
                    }
                }

                con.Journal_Zip_Postal_Code__c = addressMap.get(con.Id).OrderApi__Postal_Code__c != null ? addressMap.get(con.Id).OrderApi__Postal_Code__c : '';
                con.Bad_Journal_Address__c = addressMap.get(con.Id).Bad_Address__c;
            }

            System.debug('contacts before update: ' + contacts);
            update contacts;
        }
    }


    public static void updateReturnedAddress(List<OrderApi__Known_Address__c> knownAddresses){

        System.debug('Update ReturnedAddresses...');
        for(OrderApi__Known_Address__c ka: knownAddresses){
            ka.Bad_Address__c = false;
        }
    }


}