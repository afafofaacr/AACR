/**
 * Created by lauren.lezberg on 6/2/2020.
 *
 * @purpose Deletes all error logs with record type error exception that were created more than 6 months ago.
 */

public with sharing class Batch_DeleteErrorExceptionLogs implements Database.Batchable<sObject>{

    public Database.Querylocator start(Database.BatchableContext bc) {
        Datetime logCutoffDate = Datetime.newInstance(Date.today().year(), Date.today().month() - 6, Date.today().day());

        String queryString = 'SELECT Id FROM AACR_Error_Log__c WHERE CreatedDate <=: logCutoffDate AND RecordType.Name = \'Error Exception\'';
        System.debug('queryString: ' + queryString);

        return Database.getQueryLocator(queryString);
    }

    public void execute(Database.BatchableContext bc, List<sObject> scope) {
        List<SObject> toDelete = new List<sObject>();
        for(SObject s : scope){
            toDelete.add(s);
        }

        delete toDelete;
    }


    public void finish(Database.BatchableContext BC) {
        AsyncApexJob a = [
                SELECT Id, Status, NumberOfErrors, JobItemsProcessed,
                        TotalJobItems, CreatedBy.Email
                FROM AsyncApexJob
                WHERE Id =
                        :BC.getJobId()
        ];
        System.debug('job summary: ' + a);
        
    }
}