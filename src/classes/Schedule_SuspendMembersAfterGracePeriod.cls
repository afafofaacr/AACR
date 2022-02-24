/**
 * Created by lauren.lezberg on 1/22/2020.
 */

global class Schedule_SuspendMembersAfterGracePeriod implements Schedulable{

    global void execute(SchedulableContext sc){

        //instantiate batch class
        Batch_SuspendMembersAfterGracePeriod SAGP = new Batch_SuspendMembersAfterGracePeriod();

        //execute batch job
        database.executeBatch(SAGP, 200);

    }

}