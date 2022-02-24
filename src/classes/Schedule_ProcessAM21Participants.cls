/**
 * Created by lauren.lezberg on 3/16/2021.
 */

global class Schedule_ProcessAM21Participants implements Schedulable{

    global void execute(SchedulableContext sc) {
        BR_Event__c evt = [SELECT Id FROM BR_Event__c WHERE Name='AACR Annual Meeting 2021'];
        database.executeBatch(new Batch_ProcessVirtualEventParticipants(evt.Id), 10);

    }
}