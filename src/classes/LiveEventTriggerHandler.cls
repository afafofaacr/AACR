/**
 * Created by lauren.lezberg on 10/28/2020.
 */

public with sharing class LiveEventTriggerHandler {

    public static void handleUpdate(Set<Id> eventIds, Map<Id, BR_Event__c> oldMap){
        //get zoom venue Id
        List<Venue__c> virtualVenues = [SELECT Id FROM Venue__c WHERE RecordType.Name='Virtual' AND Name='Zoom'];
        Id zoomId = null;
        if(!virtualVenues.isEmpty()){
            zoomId = virtualVenues[0].Id;
        }

        List<BR_Event__c> evts = [SELECT Id, Virtual_Venue__r.Name, Virtual_Venue__c, Start_Date__c, End_Date__c FROM BR_Event__c WHERE Id IN:Trigger.new];
        List<Virtual_Event_Details__c> veds = [SELECT Id, External_Event_Id__c, Zoom_Type__c, Event__c,
                                                Event__r.Virtual_Venue__r.Name, Event__r.Virtual_Venue__c,
                                                Event__r.Start_Date__c, Event__r.End_Date__c
                                                FROM Virtual_Event_Details__c
                                                WHERE Event__c IN: eventIds];

        Map<String, Virtual_Event_Details__c> eventIdMap = new Map<String, Virtual_Event_Details__c>();
        for(Virtual_Event_Details__c ved : veds){
            eventIdMap.put(ved.Event__c, ved);
        }

        for (BR_Event__c evt : evts) {
            if (oldMap.get(evt.Id).Virtual_Venue__c != null) { //old venue was virtual
                System.debug('old venue was virtual');
                System.debug('old venue name: ' + oldMap.get(evt.Id).Virtual_Venue__c);
                if (oldMap.get(evt.Id).Virtual_Venue__c == zoomId) { //old venue was zoom
                    System.debug('old venue was zoom');
                    if(evt.Virtual_Venue__c==null){ //new venue is physical --> delete zoom meeting
                        System.debug('new venue is physical');
                        LiveEventTriggerHandler.deleteZoomMeeting(eventIdMap.get(evt.Id).External_Event_Id__c, eventIdMap.get(evt.Id).Zoom_Type__c=='Webinar');
                    } else { //new venue is virtual
                        System.debug('new venue is virtual');
                        if(evt.Virtual_Venue__c == zoomId){ //new venue is zoom --> check for date change and update
                            System.debug('new venue is zoom');
                            if (evt.Start_Date__c != oldMap.get(evt.Id).Start_Date__c || evt.End_Date__c != oldMap.get(evt.Id).End_Date__c) {
                                LiveEventTriggerHandler.updateZoomMeeting(evt.Id);
                            }
                        } else { //new venue is not zoom --> delete zoom meeting
                            System.debug('new venue is not zoom');
                            if(eventIdMap.get(evt.Id)!=null) {
                                LiveEventTriggerHandler.deleteZoomMeeting(eventIdMap.get(evt.Id).External_Event_Id__c, eventIdMap.get(evt.Id).Zoom_Type__c == 'Webinar');
                            }
                        }
                    }
                } else { //old venue was not zoom
                    System.debug('old venue was not zoom');

                    if(evt.Virtual_Venue__c!=null) {
                        System.debug('new venue is virtual');
                        if (evt.Virtual_Venue__c == zoomId) { // new venue is zoom --> create meeting
                            System.debug('new venue is zoom');
                            LiveEventTriggerHandler.createZoomMeeting(evt.Id);
                        }
                    }
                }

            }
        }


    }

    public static void handleDelete(Set<Id> eventIds){
        //get zoom venue Id
        List<Venue__c> virtualVenues = [SELECT Id FROM Venue__c WHERE RecordType.Name='Virtual' AND Name='Zoom'];
        Id zoomId = null;
        if(!virtualVenues.isEmpty()){
            zoomId = virtualVenues[0].Id;
        }

        List<BR_Event__c> evts = [SELECT Id, Virtual_Venue__r.Name, Virtual_Venue__c, Start_Date__c, End_Date__c FROM BR_Event__c WHERE Id IN:eventIds];
        System.debug('evts: ' + evts);
        List<Virtual_Event_Details__c> veds = [SELECT Id, External_Event_Id__c, Zoom_Type__c, Event__c,
                Event__r.Virtual_Venue__r.Name, Event__r.Virtual_Venue__c,
                Event__r.Start_Date__c, Event__r.End_Date__c
        FROM Virtual_Event_Details__c
        WHERE Event__c IN: eventIds];

        if(!veds.isEmpty()) {
            Map<String, Virtual_Event_Details__c> eventIdMap = new Map<String, Virtual_Event_Details__c>();
            for (Virtual_Event_Details__c ved : veds) {
                eventIdMap.put(ved.Event__c, ved);
            }

            for (BR_Event__c evt : evts) {
                System.debug('evt: ' + evt);
                if (evt.Virtual_Venue__c != null) {
                    if (evt.Virtual_Venue__c == zoomId) {
                        LiveEventTriggerHandler.deleteZoomMeeting(eventIdMap.get(evt.Id).External_Event_Id__c, eventIdMap.get(evt.Id).Zoom_Type__c == 'Webinar');
                    }
                }
            }
        }
    }


    @Future(Callout=true)
    public static void updateZoomMeeting(String evtId){
        List<Virtual_Event_Details__c> details = [SELECT Meeting_Password__c, Zoom_User_Id__c, Event__c,Event__r.Virtual_Venue__r.Name, Event__r.Virtual_Venue__c FROM Virtual_Event_Details__c WHERE Event__c=:evtId];
        if(!details.isEmpty()) {
            Virtual_Event_Details__c ved = details[0];
            if (ved.Event__r.Virtual_Venue__c != null && ved.Event__r.Virtual_Venue__r.Name.contains('Zoom')) {
                V_ZoomIntegration.updateZoomMeeting(evtId, ved.Zoom_User_Id__c, ved.Meeting_Password__c);
            }
        }
    }

    @Future(Callout=true)
    public static void createZoomMeeting(String evtId){
        List<Virtual_Event_Details__c> details = [SELECT Zoom_Type__c, Meeting_Password__c, Zoom_User_Id__c, Event__c,Event__r.Virtual_Venue__r.Name, Event__r.Virtual_Venue__c FROM Virtual_Event_Details__c WHERE Event__c=:evtId];
        if(!details.isEmpty()) {
            Virtual_Event_Details__c ved = details[0];
            if (ved.Event__r.Virtual_Venue__c != null && ved.Event__r.Virtual_Venue__r.Name.contains('Zoom')) {
                V_ZoomIntegration.createZoomMeeting(evtId, ved.Zoom_User_Id__c, ved.Meeting_Password__c, ved.Zoom_Type__c=='Webinar');
            }
        }
    }

    @Future(Callout=true)
    public static void deleteZoomMeeting(String meetingId, Boolean isWebinar){
        V_ZoomIntegration.deleteMeeting(meetingId,isWebinar);
    }
}