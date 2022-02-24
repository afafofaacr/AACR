/**
 * Created by afaf.awad on 6/15/2021.
 */

trigger DnBAccountTrigger on Account (after insert, before update) {

    List<Account> accounts = new List<Account>();

    for(Account acc: Trigger.New){
        System.debug('DNBAccountTrigger...');
        if(!acc.Institution_Type_Override__c) {
            if (String.isNotBlank(acc.DNBoptimizer__DnBCompanyRecord__c)) {
                accounts.add(acc);
            }
        }
    }

    System.debug('accounts == ' + accounts.size());
    if(!accounts.isEmpty()) {
        DnBTriggerHandler.updateInstitutionType(accounts);
    }
    


}