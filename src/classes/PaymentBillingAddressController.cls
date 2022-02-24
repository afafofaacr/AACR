/**
 * Created by lauren.lezberg on 12/14/2020.
 */

public without sharing class PaymentBillingAddressController {

    @AuraEnabled
    public static BillingAddressInfo getBillingAddressInfo(String contactId){
        List<OrderApi__Known_Address__c> kas = [SELECT Id, OrderApi__Street__c, OrderApi__City__c, OrderApi__Province__c, OrderApi__Country__c, OrderApi__Postal_Code__c FROM OrderApi__Known_Address__c WHERE Type__c='Billing' AND OrderApi__Contact__c=:contactId];
        if(kas.isEmpty()){
            return new BillingAddressInfo(null);
        }

        return new BillingAddressInfo(kas[0]);
    }

    public class BillingAddressInfo{
        @AuraEnabled
        public Map<String, String> countryList;

        @AuraEnabled
        public OrderApi__Known_Address__c billingAddress;

        public BillingAddressInfo(OrderApi__Known_Address__c BA){
            this.countryList = ECRMUtils.getCountryPicklistValues();
            this.billingAddress = BA;

        }
    }

}