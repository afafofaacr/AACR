/**
 * Created by afaf.awad on 2/5/2021.
 */

global class Batch_ApproveAccountsScheduler implements Schedulable {

    global void execute(SchedulableContext ctx) {

        database.executeBatch(new Batch_ApproveAccounts());

    }

}