/**
 * Created by afaf.awad on 5/13/2020.
 */

global class Batch_AddAttendeestoEventScheduler implements Schedulable {

    global void execute(SchedulableContext ctx) {

        if (Test.isRunningTest()) {

            EventApi__Event__c newEvent = [Select Id from EventApi__Event__c WHERE Name LIKE 'New Event' LIMIT 1];

            String newEventId = newEvent.Id;

            EventApi__Event__c pastEvent = [Select Id from EventApi__Event__c WHERE Name LIKE 'Old Event' LIMIT 1];

            String pastEventId = pastEvent.Id;

            database.executeBatch(new Batch_AddAttendeesToEvent(pastEventId, newEventId, true));

        } else{
            Matching_Attendees__c ma = Matching_Attendees__c.getOrgDefaults();

            database.executeBatch(new Batch_AddAttendeesToEvent(ma.Past_Event__c, ma.Current_Event__c, false),1);
            
        }

    }

}