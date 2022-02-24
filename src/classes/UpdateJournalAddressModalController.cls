/**
 * Created by lauren.lezberg on 9/16/2020.
 */

public without sharing class UpdateJournalAddressModalController {

    /**
     * @purpose Get journal type known address - if one doesn't exist, clone it from primary address but don't save
     * @param contactId
     *
     * @return Journal type known address
     */
    @AuraEnabled
    public static JournalAddressInfo getJournalAddress(String contactId){
        OrderApi__Known_Address__c jAddress = new OrderApi__Known_Address__c();
        OrderApi__Known_Address__c dAddress = new OrderApi__Known_Address__c();

        List<OrderApi__Known_Address__c> addresses = [
                SELECT Id, Type__c, Manual_Entry__c, OrderApi__Contact__c, OrderApi__Additional_Details__c, OrderApi__Is_Default__c, OrderApi__Street__c, OrderApi__City__c, OrderApi__Province__c, OrderApi__Country__c, OrderApi__Postal_Code__c
                FROM OrderApi__Known_Address__c
                WHERE Bad_Address__c = false AND OrderApi__Contact__c=:contactId
                ORDER BY OrderApi__Is_Default__c, CreatedDate DESC
        ];

        Boolean hasJournalAddress = false;
        if(!addresses.isEmpty()){
            for(OrderApi__Known_Address__c ka : addresses){
                System.debug('ka:' + ka);
                if(ka.Type__c == 'Journal'){
                    hasJournalAddress = true;
                    jAddress = ka;
                }
                if(ka.OrderApi__Is_Default__c){
                   dAddress = ka;
                }
            }

            if(!hasJournalAddress){
                System.debug('no journal address');
                jAddress = dAddress;
                jAddress.Id = null;
                jAddress.Type__c = 'Journal';
                jAddress.OrderApi__Is_Default__c = false;
                jAddress.Manual_Entry__c = false;
                jAddress.OrderApi__Additional_Details__c = null;
            }
        }

        jAddress.OrderApi__Contact__c = contactId;

        return new JournalAddressInfo(jAddress);
    }


    @AuraEnabled
    public static OrderApi__Known_Address__c saveJournalAddress(OrderApi__Known_Address__c ka){
        insert ka;

        return ka;
    }

    public class JournalAddressInfo{
        @AuraEnabled
        public Map<String, String> countryList;

        @AuraEnabled
        public OrderApi__Known_Address__c journalAddress;

        public JournalAddressInfo(OrderApi__Known_Address__c BA){
            this.countryList = ECRMUtils.getCountryPicklistValues();
            this.journalAddress = BA;

        }
    }



}