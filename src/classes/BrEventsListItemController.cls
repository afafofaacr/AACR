public with sharing class BrEventsListItemController {

    @AuraEnabled
    public static String rsvpEvent(Id recordId, String rsvpType, Integer attendeesLimit) {
        return brEventParticipationManager.respondToEvent(recordId, rsvpType, attendeesLimit);
    }

    @AuraEnabled
    public static String goToVirtualMeeting(String eventId){
        BR_Event__c evt = [SELECT Id, Virtual_Venue__r.Integration_Controller__c FROM BR_Event__c WHERE Id=: eventId];

        String extensionClass = evt.Virtual_Venue__r.Integration_Controller__c;

        if(extensionClass!=null) {
            Callable ext = (Callable) Type.forName(extensionClass).newInstance();
                Map<String, Object> args = new Map<String, Object>();
                args.put('contactId', ECRMUtils.getCurrentLoginUserContactId());
                args.put('SFEventId', eventId);
                String result = (String) ext.call('goToVenue', args);

                return result;
        }

        return null;

    }
}