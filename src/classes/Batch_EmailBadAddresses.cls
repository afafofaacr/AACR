/**
 * Created by afaf.awad on 7/15/2021.
 */

global class Batch_EmailBadAddresses implements Database.Batchable<sObject>, Database.AllowsCallouts{

    global Database.QueryLocator start(Database.BatchableContext BC){
        String queryString = 'SELECT Id, OrderApi__Contact__r.Salutation, OrderApi__Contact__r.FirstName, OrderApi__Contact__r.LastName, OrderApi__Contact__r.Email FROM OrderApi__Known_Address__c WHERE Bad_Address__c = TRUE AND OrderApi__Contact__r.Do_Not_Mail__c = FALSE AND OrderApi__Contact__r.Email != NULL';
        System.debug('queryString: ' + queryString);
        return Database.getQueryLocator(queryString);

    }

    global void execute(Database.BatchableContext BC, List<OrderApi__Known_Address__c> scope){
        System.debug('executing Batch_EmailBadAddresses with ' + scope.size() + ' records.');
        EmailTemplate emailTemplate = [SELECT Id, HtmlValue, Body FROM EmailTemplate WHERE DeveloperName = 'Email_Returned_Addresses'];

        Map<String, String> emailMap = new Map<String,String>();

        for (OrderApi__Known_Address__c ka : scope) {

            String recipientName = ka.OrderApi__Contact__r.Salutation != null ? ka.OrderApi__Contact__r.Salutation + ' ' : '';
            recipientName += ka.OrderApi__Contact__r.FirstName + ' ' + ka.OrderApi__Contact__r.LastName;
            emailMap.put(ka.OrderApi__Contact__r.Email, recipientName);
        }

        OrgWideEmailAddress fromEmail = [SELECT Id, Address FROM OrgWideEmailAddress WHERE DisplayName = 'myAACR' ];

        PlatformEmailService.callSendGridAPI(emailMap, 'Did your address change?', fromEmail.Address, 'AACR', fromEmail.Address, emailTemplate.HtmlValue);
    }

    global void finish(Database.BatchableContext BC){

        System.debug('Finish Batch_EmailBadAddresses');

    }

}