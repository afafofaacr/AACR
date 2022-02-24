public without sharing class BrParticipationTriggerHandler {

    public void setRegistrationDate(List<BR_Participation__c> participations){
        System.debug('setRegistrationDate...');
        System.debug('participations: ' + participations);
        if (!participations.isEmpty()) {
            for (BR_Participation__c p : participations) {
                if(p.Registration_Date__c==null && p.Participate__c == 'Yes') {
                    p.Registration_Date__c = Date.today();
                }
                if(p.COMP_Code__c == 'Exhibitor'){
                    p.Is_Booth_Staff__c = true;
                }
            }
        }
    }

    public void onBeforeDelete(Map<Id, BR_Participation__c> participationsByIds){
        System.debug('onBeforeDelete: ' + participationsByIds);
        List<BR_Participation__c> participations = [SELECT External_Attendee_Id__c, BR_Event__c, BR_Event__r.Virtual_Venue__r.Integration_Controller__c FROM BR_Participation__c WHERE Id IN: participationsByIds.keySet()];
        for(BR_Participation__c p : participations){
            List<Virtual_Event_Details__c> ved = [SELECT External_Event_Id__c FROM Virtual_Event_Details__c WHERE Event__c=:p.BR_Event__c];
            System.debug('participation:  ' + p);
            if(!ved.isEmpty()) {
                if (p.External_Attendee_Id__c != null) {
                    Callable extension = (Callable) Type.forName(p.BR_Event__r.Virtual_Venue__r.Integration_Controller__c).newInstance();
                    extension.call('deleteAttendee', new Map<String, Object>{
                            'fuzionAttendeeId' => (String) p.External_Attendee_Id__c,
                            'fuzionEventId' => (String) ved[0].External_Event_Id__c
                    });
                }
            }
        }
//        Map<Id, BR_Participation__c> participationMap = new Map<Id, BR_Participation__c>([SELECT Id, External_Attendee_Id__c, Participate__c, BR_Event__r.Virtual_Venue__r.Integration_Controller__c, BR_Event__r.Virtual_Venue__c, Bypass_Confirmation__c FROM BR_Participation__c WHERE Id IN: participations]);
//        for(Id key : participationMap.keySet()){
//            if(participationMap.get(key).External_Attendee_Id__c!=null){
//                Callable extension = (Callable) Type.forName(participationMap.get(key).BR_Event__r.Virtual_Venue__r.Integration_Controller__c).newInstance();
//                extension.call('deleteAttendee', new Map<String, Object>{
//                        'participantId' => (String)key
//                });
//            }
//        }
    }

    public void onAfterInsert(Map<Id, BR_Participation__c> newParticipationsByIds) {
        //get list of participations with necessary fields
        List<BR_Participation__c> participations = BrEventsHelper.getParticipationsById(newParticipationsByIds.keySet());
        List<BR_Participation__c> confirmations = new List<BR_Participation__c>();

        if (!participations.isEmpty()) {
//            BrEventsHelper.sendEmails(participations, 'Welcome event');
            for(BR_Participation__c p : participations){
                if(!p.Bypass_Confirmation__c){
                    confirmations.add(p);
                }
            }
            if(!confirmations.isEmpty()) {
                LiveEventsHelper.sendRegistrationConfirmationEmail(participations, null);
            }
        }
    }

    public void onAfterUpdate(List<BR_Participation__c> newParticipations,  Map<Id, BR_Participation__c> oldParticipations) {
        System.debug('onAfterUpdate...' + newParticipations[0]);
        System.debug('oldParticipation: ' + oldParticipations.get(newParticipations[0].Id));
        List<BR_Participation__c> changedParticipations = new List<BR_Participation__c>();
        Map<Id, BR_Participation__c> participationMap = new Map<Id, BR_Participation__c>([SELECT Id, External_Attendee_Id__c, Participate__c, BR_Event__r.Virtual_Venue__c, Bypass_Confirmation__c FROM BR_Participation__c WHERE Id IN: newParticipations]);

        Set<Id> eventIds = new Set<Id>();
        Set<Id> virtualParticipantIds = new Set<Id>();


        for (BR_Participation__c newParticipation : newParticipations) {
            BR_Participation__c oldParticipation = oldParticipations.get(newParticipation.Id);
            String oldParticipate = oldParticipation.Participate__c;
            String newParticipate = newParticipation.Participate__c;

            if (oldParticipate != newParticipate && newParticipate == 'Yes' && !participationMap.get(newParticipation.Id).Bypass_Confirmation__c) {
                changedParticipations.add(newParticipation);

                //if career fair - send to vFairs
                if(newParticipation.BR_Event__c == Label.Career_Fair_Event_Id) {
                    vFairsHelper.insertAttendee(newParticipation.Id);
                } else {
                    if (participationMap.get(newParticipation.Id).BR_Event__r.Virtual_Venue__c != null && oldParticipation.External_Attendee_Id__c == null && participationMap.get(newParticipation.Id).External_Attendee_Id__c == null) {
                        SYstem.debug('event is virtual...');
                        System.debug('newParticipation event: ' + newParticipation.BR_Event__c);
                        System.debug('newParticipationId: ' + newParticipation.Id);

                        eventIds.add(newParticipation.BR_Event__c);
                        virtualParticipantIds.add(newParticipation.Id);
                    }
                }
            } else if(newParticipation.BR_Event__c != Label.Career_Fair_Event_Id && oldParticipation.External_Attendee_Id__c!=null && participationMap.get(newParticipation.Id).External_Attendee_Id__c!=null && newParticipate == 'Yes'){
                SYstem.debug('external attendee id not null');
                if(participationMap.get(newParticipation.Id).BR_Event__r.Virtual_Venue__c!=null){
                    SYstem.debug('event is virtual...');
                    eventIds.add(newParticipation.BR_Event__c);
                    virtualParticipantIds.add(newParticipation.Id);
                }
            }
        }

        Set<Id> participationsIds = (new Map<Id, BR_Participation__c>(changedParticipations)).keySet();

        //get list of participations with necessary fields
        List<BR_Participation__c> participations = BrEventsHelper.getParticipationsById(participationsIds);
        if (!participations.isEmpty()) {
//            BrEventsHelper.sendEmails(participations, 'Welcome event');
            LiveEventsHelper.sendRegistrationConfirmationEmail(participations, null);
        }

        //send attendees for virtual events
        if(!virtualParticipantIds.isEmpty()) {
            System.debug('executing batch...');
            database.executeBatch(new Batch_ProcessVirtualParticipations(virtualParticipantIds, eventIds));
        }
    }
}