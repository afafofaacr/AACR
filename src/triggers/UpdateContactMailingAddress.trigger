/**
 * Created by lauren.lezberg on 9/14/2020.
 */

/**
 * Trigger that updates Contact addresses from known address addition. Default known address is written to the contact
 * mailing address and journal address is written to contact journal address for reporting/price rule purposes (not
 * shown on layout). Billing address is updated to have specific structure that distinguishes it from other known
 * addresses
 */
trigger UpdateContactMailingAddress on OrderApi__Known_Address__c (after insert, after update, before insert, before update) {

    List<OrderApi__Known_Address__c> newAddresses = new List<OrderApi__Known_Address__c>();
    List<OrderApi__Known_Address__c> billingAddresses = new List<OrderApi__Known_Address__c>();
    Map<String,OrderApi__Known_Address__c> knownAddressMap = new Map<String,OrderApi__Known_Address__c>();
    Map<String,OrderApi__Known_Address__c> journalAddressMap = new Map<String,OrderApi__Known_Address__c>();

    /* Loop through known addresses and look for billing addresses (aka address with name) or default addresses */
    for(OrderApi__Known_Address__c ka : trigger.new){
        if(ka.OrderApi__Is_Default__c ){
            ECRMUtils.updateOpenSalesOrderLines(ka.OrderApi__Contact__c);
            if(ka.OrderApi__Name__c==null) {
                knownAddressMap.put(ka.OrderApi__Contact__c, ka);
            }
        }
        if(ka.OrderApi__Name__c!=null){
            billingAddresses.add(ka);
        }
        if(ka.Type__c == 'Journal'){
            journalAddressMap.put(ka.OrderApi__Contact__c, ka);
        }
        if(Trigger.isUpdate) {
            OrderApi__Known_Address__c oldKa = Trigger.oldMap.get(ka.Id);
            if ( ka.OrderApi__Street__c != oldKa.OrderApi__Street__c
                    || ka.OrderApi__City__c != oldKa.OrderApi__City__c
                    || ka.OrderApi__Province__c != oldKa.OrderApi__Province__c
                    || ka.OrderApi__Country__c != oldKa.OrderApi__Country__c
                    || ka.OrderApi__Postal_Code__c != oldKa.OrderApi__Postal_Code__c ) {
                System.debug('New Address: ' + ka);
                newAddresses.add(ka);
            }
        }
    }

    /* Depending on billing or default - process accordingly */
    if(Trigger.isAfter) {
        UpdateContactMailingAddressTriggerHndlr.updateContactMailingAddress(knownAddressMap);
        UpdateContactMailingAddressTriggerHndlr.updateContactJournalAddress(journalAddressMap);

    } else if(Trigger.isBefore) {
        if ( Trigger.isInsert ) {
            if ( !billingAddresses.isEmpty() ) {
                UpdateContactMailingAddressTriggerHndlr.updateBillingAddress(billingAddresses);
            }
        } else {
            if ( !newAddresses.isEmpty() ) {
                UpdateContactMailingAddressTriggerHndlr.updateReturnedAddress(newAddresses);
            }
        }
    }

}