/**
 * Created by lauren.lezberg on 4/28/2021.
 */

public without sharing class V_SimpleHTMLRedirect implements Callable, VirtualEventIntegration{
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
                throw new AACRCustomException('Failure to execute action: ' + action, 'SimpleHTMLRedirectIntegration.call()', 'SimpleHTMLRedirectIntegration');
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

        Virtual_Event_Details__c ved = [SELECT External_Event_Id__c, Custom_URL__c FROM Virtual_Event_Details__c WHERE Event__c=: SFEventId];


        return ved.Custom_URL__c;
    }
}