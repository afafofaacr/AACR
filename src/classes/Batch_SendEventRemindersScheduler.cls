/**
 * Created by afaf.awad on 11/9/2020.
 */

global class Batch_SendEventRemindersScheduler implements Schedulable{

    global void execute(SchedulableContext SC) {

        database.executeBatch(new Batch_SendEventReminders());
    }

}