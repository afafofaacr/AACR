/**
 * Created by lauren.lezberg on 3/10/2021.
 */

global class Batch_ProcessVirtualEventParticipants implements Database.Batchable<sObject>, Database.AllowsCallouts, Database.Stateful {
    public String internalEventId;
    public String externalEventId;
    public String integrationController;

    public Batch_ProcessVirtualEventParticipants(String eventId){
        this.internalEventId = eventId;
        List<Virtual_Event_Details__c> ved = [SELECT External_Event_Id__c FROM Virtual_Event_Details__c WHERE Event__c=:eventId];
        if(ved.size()==1){
            externalEventId = ved[0].External_Event_Id__c;
        } else {
            externalEventId = null;
        }
        this.integrationController = [SELECT Virtual_Venue__r.Integration_Controller__c FROM BR_Event__c WHERE Id=:eventId].Virtual_Venue__r.Integration_Controller__c;
    }

    global Database.Querylocator start(Database.BatchableContext bc){
        String query = 'SELECT Contact__c, Id, External_Attendee_Id__c FROM BR_Participation__c WHERE BR_Event__c=: internalEventId AND Participate__c = \'Yes\'';
        return Database.getQuerylocator(query);
    }

    global void execute(Database.BatchableContext bc, List<BR_Participation__c> scope) {
        List<BR_Participation__c> toUpdate = new List<BR_Participation__c>();
        if(integrationController!=null && externalEventId!=null) {
            Callable extension = (Callable) Type.forName(integrationController).newInstance();
            for (BR_Participation__c p : scope) {
                if (p.External_Attendee_Id__c == null) {
                    String attendeeId = (String) extension.call('sendAttendee', new Map<String, Object>{
                            'contactId' => (String) p.Contact__c, 'externalEventId' => externalEventId, 'flag' => false
                    });
                    if (attendeeId != null) {
                        p.External_Attendee_Id__c = attendeeId;
                        toUpdate.add(p);
                    }
                }
//                else {
//                    extension.call('updateAttendee', new Map<String, Object>{
//                            'participantId' => (String) p.Id
//                    });
//                }
            }
            update toUpdate;
        }
    }

    global void finish(Database.BatchableContext BC){
        AsyncApexJob a = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed,
                TotalJobItems, CreatedBy.Email
        FROM AsyncApexJob WHERE Id =
                :BC.getJobId()];
        System.debug('job summary: ' + a);
    }
}