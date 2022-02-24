/**
 * Created by lauren.lezberg on 6/2/2020.
 */

global with sharing class Schedule_DeleteErrorExceptionLogs implements Schedulable{

    global void execute(SchedulableContext sc){
        //execute batch job
        database.executeBatch(new Batch_DeleteErrorExceptionLogs());
    }
}