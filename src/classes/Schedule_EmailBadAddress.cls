/**
 * Created by afaf.awad on 10/4/2021.
 */

global class Schedule_EmailBadAddress implements Schedulable{


        global void execute(SchedulableContext sc) {

            database.executeBatch(new Batch_EmailBadAddresses());

        }

}