/**
 * Created by afaf.awad on 3/10/2021.
 */

@RestResource(urlMapping='/Account/*')
global with sharing class AccountWebService {
    @HttpGet
    global static List<Account> getRecords(){
        List<BR_Participation__c> participations = [Select Contact__r.Account.Name, Contact__r.AccountId from BR_Participation__c where Exhibitor_ID__c != NULL];

        Set<Account> accSet = new Set<Account>();

        for(BR_Participation__c p : participations){
            Account a = new Account(Id = p.Contact__r.AccountId, Name = p.Contact__r.Account.Name);
            accSet.add(a);
        }

        List<Account> accounts = new List<Account>();

        accounts.addAll(accSet);

        return accounts;
    }
}