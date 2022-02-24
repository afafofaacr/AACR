/**
 * Created by afaf.awad on 7/29/2020.
 */

global class Schedule_CleanContactData implements Schedulable {

    global void execute(SchedulableContext sc) {

        database.executeBatch(new Batch_CleanContactData());

    }
}