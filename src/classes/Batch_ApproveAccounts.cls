/**
 * Created by afaf.awad on 9/2/2020.
 */

global class Batch_ApproveAccounts implements Database.Batchable<sObject>{

    global Database.QueryLocator start(Database.BatchableContext BC) {
        String query = 'SELECT Id, Name, RecordTypeId, DNBoptimizer__DNB_D_U_N_S_Number__c FROM Account WHERE RecordType.Name = \'Unfiled\'';
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<Account> scope) {

        RecordType recordType = [SELECT Id FROM RecordType WHERE SobjectType = 'Account' AND Name = 'Unfiled'];
        List<Account> approveAccounts = new List<Account>();

        for(Account acc: scope){
            if(!String.isBlank(acc.DNBoptimizer__DNB_D_U_N_S_Number__c)){
                acc.RecordTypeId = recordType.Id;
                approveAccounts.add(acc);
            }
        }

        try{
            update approveAccounts;
        }catch(Exception e){
            System.debug('Can not update: ' + e.getMessage());
        }
    }

    global void finish(Database.BatchableContext BC) {

        AsyncApexJob a = [
                SELECT Id, Status, NumberOfErrors, JobItemsProcessed,
                        TotalJobItems, CreatedBy.Email
                FROM AsyncApexJob
                WHERE Id =
                        :BC.getJobId()
        ];
        System.debug('job summary: ' + a);

        if (a.NumberOfErrors > 0 || Test.isRunningTest()) {
            String body = '<p>Job Summary: ' + a + '</p>';
            body += '<br/> <p>OrgId: ' + UserInfo.getOrganizationId() + '</p>';
            List<Messaging.SingleEmailMessage> errorMessages = new List<Messaging.SingleEmailMessage>();

            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            email.setHtmlBody(body);
            email.setToAddresses(new List<String>{
                    'platformalert@aacr.org'
            });
            email.setSubject('Batch_CleanContactData Exception');
            email.setSenderDisplayName('American Association for Cancer Research');
            errorMessages.add(email);

            Messaging.sendEmail(errorMessages);
        }

    }

}