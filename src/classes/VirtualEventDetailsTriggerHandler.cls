/**
 * Created by lauren.lezberg on 10/27/2020.
 */

public with sharing class VirtualEventDetailsTriggerHandler {

    @Future(Callout=true)
    public static void createZoomMeeting(String vedID){
//        String userId = '6pwXvs6bQ2-bwZFL_xmYkA';
        Virtual_Event_Details__c ved = [SELECT Zoom_Type__c, Meeting_Password__c, Zoom_User_Id__c, Event__c,Event__r.Virtual_Venue__r.Name, Event__r.Virtual_Venue__c FROM Virtual_Event_Details__c WHERE Id=:vedID];

        if(ved.Event__r.Virtual_Venue__c!=null && ved.Event__r.Virtual_Venue__r.Name.contains('Zoom')) {
            V_ZoomIntegration.createZoomMeeting(ved.Event__c, ved.Zoom_User_Id__c, ved.Meeting_Password__c, ved.Zoom_Type__c == 'Webinar');
        }
    }

    @Future(Callout=true)
    public static void updateZoomMeeting(String vedID){
//        String userId = '6pwXvs6bQ2-bwZFL_xmYkA';
        Virtual_Event_Details__c ved = [SELECT Meeting_Password__c, Zoom_User_Id__c, Event__c,Event__r.Virtual_Venue__r.Name, Event__r.Virtual_Venue__c FROM Virtual_Event_Details__c WHERE Id=:vedID];

        if(ved.Event__r.Virtual_Venue__c!=null && ved.Event__r.Virtual_Venue__r.Name.contains('Zoom')) {
            V_ZoomIntegration.updateZoomMeeting(ved.Event__c, ved.Zoom_User_Id__c, ved.Meeting_Password__c);
        }
    }

}