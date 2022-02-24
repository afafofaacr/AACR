/**
 * Created by lauren.lezberg on 3/29/2021.
 */

public without sharing class V_SlidoIntegration implements Callable, VirtualEventIntegration {

    public Object call(String action, Map<String, Object> args){
        switch on action {
            when 'sendAttendee' {
                return null;
            }
            when 'asyncSendAttendee' {
                return null;
            }
            when 'updateAttendee' {
                return null;
            }
            when 'deleteAttendee' {
                return null;
            }
            when 'goToVenue' {
                return this.goToVenue((String)args.get('contactId'), (String)args.get('SFEventId'));
            }
            when else {
                throw new AACRCustomException('Failure to execute action: ' + action, 'SlidoIntegration.call()', 'SlidoIntegration');
            }
        }
    }

    public static void deleteAttendee(String fuzionAttendeeId, String fuzionEventId){

    }

    public static void updateAttendee(String participantId){

    }

    public String sendAttendee(String contactId, String externalEventId, Boolean flag){

        return null;
    }

    @Future(callout=true)
    public static void asyncSendAttendee(String contactId, String externalEventId, Boolean flag){

    }

    public String goToVenue(String contactId, String SFEventId){
        String redirectURL = '';

        BR_Event__c evt = [SELECT Id, Virtual_Venue__r.Base_URL__c FROM BR_Event__c WHERE Id=: SFEventId];

        Virtual_Event_Details__c ved = [SELECT External_Event_Id__c FROM Virtual_Event_Details__c WHERE Event__c=: SFEventId];

        redirectURL = evt.Virtual_Venue__r.Base_URL__c + ved.External_Event_Id__c;

        return redirectURL;
    }
}