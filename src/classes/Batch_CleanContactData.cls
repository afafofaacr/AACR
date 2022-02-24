/**
 * Created by afaf.awad on 7/14/2020.
 */

global class Batch_CleanContactData implements Database.Batchable<sObject> {

    global Database.QueryLocator start(Database.BatchableContext BC) {
        String query = 'SELECT FirstName, LastName, MiddleName FROM Contact WHERE LastModifiedDate >= YESTERDAY';
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<Contact> scope) {

        List<Contact> contacts = new List<Contact>();
        for(Contact c : scope){

            if(c.LastName.isAllLowerCase() || c.LastName.isAllUpperCase()){
                c.LastName = ECRMUtils.cleanStringCase(c.LastName);
            }
            if(String.isNotBlank(c.FirstName)  && (c.FirstName.isAllLowerCase() || c.FirstName.isAllUpperCase())){
                c.FirstName = ECRMUtils.cleanStringCase(c.FirstName);
            }
            if(String.isNotBlank(c.MiddleName) && (c.MiddleName.isAllLowerCase() || c.MiddleName.isAllUpperCase())){
                c.MiddleName = ECRMUtils.cleanStringCase(c.MiddleName);
            }
            contacts.add(c);
        }

        try{
           update contacts;
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