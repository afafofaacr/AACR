/**
 * Created by afaf.awad on 11/19/2020.
 */

global class Batch_UpdateContactWorldBankScheduler implements Schedulable{

        global void execute(SchedulableContext SC) {
            callWorldBank();
        }

    public static void callWorldBank(){
        database.executeBatch(new Batch_UpdateContactWorldBank());
    }

}