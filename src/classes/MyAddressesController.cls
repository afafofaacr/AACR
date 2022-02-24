/**
 * Created by lauren.lezberg on 9/8/2020.
 */

public without sharing class MyAddressesController {
    public String contactId {get;set;}

    public MyAddressesController(){
        contactId = ApexPages.currentPage().getParameters().get('contactId');
        if(contactId == null){
            contactId = ECRMUtils.getCurrentLoginUserContactId();
        }
    }

    public PageReference goToRedirect(){
        String returnURL = ApexPages.currentPage().getParameters().get('retURL');

        if(returnURL!=null){
            return new PageReference(returnURL);
        }

        return new PageReference('javascript:window.close()');
    }


    /**
     * @purpose Updates business address if account changes
     * @param contactId
     * @param accountId
     *
     * @return TRUE if address updated, FALSE if not
     */
    @AuraEnabled
    public static Boolean updateBusinessAddress(String contactId, String accountId) {
        System.debug('updateBusinessAddress');

        if (accountId != null) {
            List<OrderApi__Known_Address__c> addresses = [
                    SELECT Id, OrderApi__Additional_Details__c, OrderApi__City__c,
                            OrderApi__Country__c, Type__c,
                            OrderApi__Is_Default__c, OrderApi__Postal_Code__c, OrderApi__Street__c, OrderApi__Province__c
                    FROM OrderApi__Known_Address__c
                    WHERE OrderApi__Contact__c = :contactId AND Bad_Address__c = false AND Type__c = 'Business'
            ];
            System.debug('addresses: ' + addresses);

            Account acc = [SELECT Id, Name, BillingAddress FROM Account WHERE Id = :accountId];
            System.debug('account: ' + acc);

            if (!addresses.isEmpty()) { //if there is a business address
                if (!acc.Name.contains('Household')) {  //account is valid and not household
                    System.debug('account is not household');
                    OrderApi__Known_Address__c ka = addresses[0];
                    ka.OrderApi__Street__c = acc.BillingAddress.getStreet();
                    ka.OrderApi__City__c = acc.BillingAddress.getCity();
                    ka.OrderApi__Province__c = acc.BillingAddress.getState();
                    ka.OrderApi__Postal_Code__c = acc.BillingAddress.getPostalCode();
                    ka.OrderApi__Country__c = acc.BillingAddress.getCountry();
                    try {
                        update ka;
                    } catch(Exception e){
                        System.debug('error: ' + e.getMessage());
                        new AACRCustomException(contactId, e.getMessage(), e.getStackTraceString(), 'Known Address');
                    }
                } else { //account is household - known address doesn't need to be updated
                    System.debug('account is household');
                    return false;
                }
            }
        }

        return true;
    }


    /**
     * @purpose Retrieves known addresses for given contact. If none exist accountId is not null or household - create
     * default business known address with account address.
     *
     * @param contactId
     * @param accountId
     *
     * @return All known addresses not marked as bad address for a given contact
     */
    @AuraEnabled
    public static MyAddressesDTO getAddresses(String contactId, String accountId) {
        List<OrderApi__Known_Address__c> addresses = new List<OrderApi__Known_Address__c>();

        addresses = [
                SELECT Id, OrderApi__Additional_Details__c, OrderApi__City__c, OrderApi__Country__c, Type__c, Manual_Entry__c,
                        OrderApi__Is_Default__c, OrderApi__Postal_Code__c, OrderApi__Street__c, OrderApi__Province__c, Bad_Address__c
                FROM OrderApi__Known_Address__c
                WHERE OrderApi__Contact__c = :contactId
                ORDER BY OrderApi__Is_Default__c DESC
        ];

        //if there are no known addresses and account is not empty - create default business address
        if (addresses.isEmpty() && accountId != null) {
            Account acc = [SELECT BillingAddress FROM Account WHERE Id = :accountId];
            if (acc.BillingAddress != null) {
                OrderApi__Known_Address__c ka = new OrderApi__Known_Address__c();
                ka.OrderApi__Contact__c = contactId;
                ka.Type__c = 'Business';
                ka.OrderApi__Is_Default__c = true;
                ka.OrderApi__Street__c = acc.BillingAddress.getStreet();
                ka.OrderApi__City__c = acc.BillingAddress.getCity();
                ka.OrderApi__Province__c = acc.BillingAddress.getState();
                ka.OrderApi__Postal_Code__c = acc.BillingAddress.getPostalCode();
                ka.OrderApi__Country__c = acc.BillingAddress.getCountry();
                try {
                    insert ka;
                    addresses.add(ka);
                } catch(Exception e){
                    System.debug('error: ' + e.getMessage());
                    new AACRCustomException(contactId, e.getMessage(), e.getStackTraceString(), 'Known Address');
                }
            }
        }


        return new MyAddressesDTO(addresses);
    }

    /**
     * @purpose Concatenate known address values into string and search google places API
     * @param addressId : unique known address id
     *
     * @return Google API response
     */
    @AuraEnabled
    public static String getPlaceId(String addressId) {
        OrderApi__Known_Address__c ka = [
                SELECT Id, OrderApi__Additional_Details__c, Type__c, OrderApi__Street__c,
                        OrderApi__City__c, OrderApi__Province__c, OrderApi__Postal_Code__c,
                        OrderApi__Country__c, Manual_Entry__c, OrderApi__Is_Default__c
                FROM OrderApi__Known_Address__c
                WHERE Id = :addressId
        ];
        String addressString = ka.OrderApi__Street__c + ', ' + ka.OrderApi__City__c + ', ' + ka.OrderApi__Province__c + ' ' + ka.OrderApi__Postal_Code__c + ', ' + ka.OrderApi__Country__c;

        return AddressAutocompleteController.findPlace(addressString);
    }

    /**
     * @purpose Retrieve known address info from id
     * @param addressId : unique known address Id
     *
     * @return
     */
    @AuraEnabled
    public static OrderApi__Known_Address__c getAddress(String addressId) {
        OrderApi__Known_Address__c ka = [
                SELECT Id, OrderApi__Additional_Details__c, Type__c, OrderApi__Street__c,
                        OrderApi__City__c, OrderApi__Province__c, OrderApi__Postal_Code__c,
                        OrderApi__Country__c, Manual_Entry__c, OrderApi__Is_Default__c
                FROM OrderApi__Known_Address__c
                WHERE Id = :addressId
        ];

        return ka;
    }


    /**
     * @purpose Delete known address
     * @param kaID : unique known address id
     */
    @AuraEnabled
    public static void deleteKnownAddress(String kaID) {
        ECRMUtils.deleteRecord(kaID);
    }


    /**
     * @purpose Updates provided known address to be default - Fonteva trigger will disable other default known address
     * This ensures only one address will be default at a time
     * @param defaultId : unique known address id
     * @param contactId : unique contact id
     */
    @AuraEnabled
    public static void updateDefault(String defaultId, String contactId) {
        List<OrderApi__Known_Address__c> addresses = new List<OrderApi__Known_Address__c>();

        addresses = [
                SELECT Id, OrderApi__Additional_Details__c, OrderApi__City__c, OrderApi__Country__c,
                        OrderApi__Is_Default__c, OrderApi__Postal_Code__c, OrderApi__Street__c, OrderApi__Province__c
                FROM OrderApi__Known_Address__c
                WHERE OrderApi__Contact__c = :contactId AND Id = :defaultId
        ];

        addresses[0].OrderApi__Is_Default__c = true;

        try {
            update addresses[0];
        } catch(Exception e){
            System.debug('ERROR: ' + e.getMessage());
            new AACRCustomException(defaultId, e.getMessage(), e.getStackTraceString(), 'Known Address');
        }

    }

    /**
     * @purpose Retrieves map of states based on specified country value, if country is park of the EU, automatically check DO not Display in Directory checkbox
     *
     * @param countryVal : country code
     *
     * @return map of states within country
     */
    @AuraEnabled
    public static Map<String, String> getStates(String countryVal) {
        System.debug('getStates was just called with country : ' + countryVal);
        List<EU_Countries__mdt> countries = [SELECT Label, Country_Code__c FROM EU_Countries__mdt];
        Set<String> countryCodes = new Set<String>();
        for (EU_Countries__mdt country : countries) {
            countryCodes.add(country.Country_Code__c);
        }

        Contact currentContact = ECRMUtils.getCurrentLoginContact();
        if(currentContact!=null) {
            if (countryCodes.contains(countryVal)) {
                currentContact.Do_Not_Display_in_Directory__c = true;
            }

            try {
                update currentContact;
            } catch (Exception e) {
                System.debug('Could not update contact: ' + e.getMessage());
                new AACRCustomException(currentContact.Id, e.getMessage(), e.getStackTraceString(), 'Do Not Display In Directory Update');
            }
        }

        return ECRMUtils.getDependentPicklistValues('Contact', 'MailingCountryCode', 'MailingStateCode', countryVal);
    }

    public class MyAddressesDTO {
        @AuraEnabled
        public List<OrderApi__Known_Address__c> addresses;

        @AuraEnabled
        public Map<String, String> countries;


        public MyAddressesDTO(List<OrderApi__Known_Address__c> add) {
            this.addresses = add;
            this.countries = ECRMUtils.getCountryPicklistValues();
        }

    }

}