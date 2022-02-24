/**
 * Created by afaf.awad on 10/28/2021.
 */

global class Batch_MassContactUpdate implements Database.Batchable<sObject>, Database.Stateful{

    Integer recordsProcessed = 0;
    Map<Id,String> errorMap = new Map<Id,String>();

    global Database.QueryLocator start(Database.BatchableContext BC){
        System.debug('starting Batch_MassContactUpdate...');
        String queryString = 'SELECT Id FROM Contact';
        return Database.getQueryLocator(queryString);
    }

    global void execute(Database.BatchableContext BC, List<Contact> scope){

            Database.SaveResult[] updateResults = Database.update(scope, false);

            for(Integer i=0;i<updateResults.size();i++){
                if (updateResults.get(i).isSuccess()){
                    recordsProcessed++;
                } else if (!updateResults.get(i).isSuccess()){
                    errorMap.put(updateResults.get(i).getId(),updateResults.get(i).getErrors().get(0).getMessage());
                }
            }
    }

    global void finish(Database.BatchableContext BC){
        System.debug('finishing Batch_MassContactUpdate...');
        MassContactUpdateController.emailBatchResults(errorMap,recordsProcessed);
    }

}