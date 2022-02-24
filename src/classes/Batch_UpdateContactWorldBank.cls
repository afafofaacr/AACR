/**
 * Created by afaf.awad on 11/13/2020.
 */

global class Batch_UpdateContactWorldBank implements Database.Batchable<sObject>, Database.Stateful, Database.AllowsCallouts{

//        List<String> countryCodes {get;set;}
//
//        global Batch_UpdateContactWorldBank(List<String> countryList){
//            countryCodes = countryList;
//        }

        global Batch_UpdateContactWorldBank(){
        }

        global Database.QueryLocator start(Database.BatchableContext BC){
            System.debug('starting Batch_UpdateContactWorldBank...');
            // call method to get country codes
            List<String> countryCodes = WorldBankIntegration.getupdatedCountries();
            System.debug('countryCodes == ' + countryCodes);
            String queryString = 'SELECT Id, MailingCountryCode, Income_Level__c FROM Contact WHERE MailingCountryCode IN: countryCodes';
            System.debug('queryString: ' + queryString);
            return Database.getQueryLocator(queryString);
        }

        global void execute(Database.BatchableContext BC, List<Contact> scope){
            update scope;
//
//            List<Contact> updateContacts = new List<Contact>();
//
//            for(Contact con : scope){
//                updateContacts.add(new Contact(Id = con.Id));
//            }
//            try{
//                update updateContacts;
//            }catch(Exception e){
//                System.debug('Error on Batch_UpdateContactWorldBank: Line number ====> '+ e.getLineNumber() + '--- Exception Message =====> ' + e.getMessage());
//            }
        }

        global void finish(Database.BatchableContext BC){

        }

}