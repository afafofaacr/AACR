/**
 * Created by lauren.lezberg on 8/6/2020.
 */

global class Batch_ProcessVirtualParticipations implements Database.Batchable<sObject>, Database.AllowsCallouts{
    public Set<Id> participationIds = new Set<Id>();
    public Set<Id> eventIds = new Set<Id>();

    public Batch_ProcessVirtualParticipations(Set<Id> participations, Set<Id> events){
        this.participationIds = participations;
        this.eventIds = events;
    }

    global Database.Querylocator start(Database.BatchableContext bc){
        System.debug('start....');
        String query = 'SELECT Id, Virtual_Venue__r.Integration_Controller__c, (SELECT External_Event_Id__c FROM Virtual_Event_Details__r), (SELECT Contact__c, Id, External_Attendee_Id__c FROM BR_Participations__r WHERE Id IN: participationIds) FROM BR_Event__c WHERE Id IN: eventIds';

        System.debug('query: ' + query);
        System.debug('result: ' + Database.query(query));
        return Database.getQuerylocator(query);
    }

    global void execute(Database.BatchableContext bc, List<BR_Event__c> scope) {
        System.debug('execute....');
        System.debug('scope: ' + scope);
        List<BR_Participation__c> toUpdate = new List<BR_Participation__c>();
        for (BR_Event__c e : scope) {
            System.debug('e: ' + e);
            Callable extension = (Callable) Type.forName(e.Virtual_Venue__r.Integration_Controller__c).newInstance();
            for (BR_Participation__c p : e.BR_Participations__r) {
                System.debug('p: ' + p);
                //new participant
                if (p.External_Attendee_Id__c == null) {
                    String attendeeId = (String) extension.call('sendAttendee', new Map<String, Object>{
                            'contactId' => (String) p.Contact__c, 'externalEventId' => (String) e.Virtual_Event_Details__r[0].External_Event_Id__c, 'flag' => false
                    });
                    System.debug('after call...');
                    if (attendeeId != null) {
                        p.External_Attendee_Id__c = attendeeId;
                        toUpdate.add(p);
                    }
                } else {
                    extension.call('updateAttendee', new Map<String, Object>{
                            'participantId' => (String) p.Id
                    });
                }

            }

            try {
                update toUpdate;
            } catch(Exception ex){
                new AACRCustomException(ex.getMessage(), ex.getStackTraceString(), 'Freeman Write Back');
            }
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