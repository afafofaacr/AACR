/**
 * Created by afaf.awad on 10/23/2020.
 */
global class Scheduler_SendEventReminders implements Schedulable{

        global void execute(SchedulableContext SC) {
            RecordType cancelled = [SELECT Id FROM RecordType WHERE SobjectType = 'BR_Event__c' and Name = 'Cancelled'];

            Database.executeBatch(new Batch_SendEventReminders(cancelled.Id), 100);
        }

}