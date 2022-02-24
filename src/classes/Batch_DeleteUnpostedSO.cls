public class Batch_DeleteUnpostedSO implements Database.Batchable<sObject>,Database.Stateful{
    
    public Database.QueryLocator start(Database.BatchableContext bc) {
//        String queryString = 'SELECT Id, OrderApi__Contact__c, Name FROM OrderApi__Sales_Order__c WHERE Marked_For_Delete__c = TRUE';
        String queryString;
        /** can't update lastmodifieddate in test class **/
        if(!Test.isRunningTest()){
            queryString = 'SELECT Id, OrderApi__Contact__c, Name FROM OrderApi__Sales_Order__c WHERE OrderApi__Posting_Status__c != \'Posted\' AND (OrderApi__Status__c = \'Cancelled\' OR OrderApi__Status__c = \'Open\') AND LastModifiedDate < LAST_N_DAYS:90';
        } else {
            queryString = 'SELECT Id, OrderApi__Contact__c, Name FROM OrderApi__Sales_Order__c WHERE OrderApi__Posting_Status__c != \'Posted\' AND (OrderApi__Status__c = \'Cancelled\' OR OrderApi__Status__c = \'Open\') AND CreatedDate < LAST_N_DAYS:90';
        }
        return Database.getQueryLocator(queryString);
    }

    public void execute(Database.BatchableContext BC, List<OrderApi__Sales_Order__c> scope){
        if(scope.size() > 0) {
            delete scope;
        } 
    }

    public void finish(Database.BatchableContext BC){
        AsyncApexJob job;
        List<AsyncApexJob> jobs = [SELECT Id, NumberOfErrors, Status, JobItemsProcessed FROM AsyncApexJob WHERE Id =: BC.getJobId()];
        if(jobs.size()==1){
           job = jobs[0];
        }
        System.debug(LoggingLevel.DEBUG, 'Batch_DeleteUnpostedSO processed ' + job.JobItemsProcessed + ' records with a status of ' + job.Status + ' and ' + job.NumberOfErrors + ' errors ');
    }
    

}