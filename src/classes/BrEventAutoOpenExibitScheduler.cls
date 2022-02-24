/**
 * Created by afaf.awad on 10/19/2020.
 */

global class BrEventAutoOpenExibitScheduler implements Schedulable{

        global void execute(SchedulableContext SC) {
            BrEventAutoOpenExibit.openExibit();
        }

}