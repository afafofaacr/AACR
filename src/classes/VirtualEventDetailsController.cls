/**
 * Created by lauren.lezberg on 7/6/2020.
 */

public without sharing class VirtualEventDetailsController {

    @AuraEnabled
    public static VirtualDetails getVirtualDetailRecord(String eventId){
        Map<String, String> zoomUsers = new Map<String, String>();
        Boolean hideDetails = false;
        BR_Event__c evt = [SELECT Virtual_Venue__c, Virtual_Venue__r.Name FROM BR_Event__c WHERE Id=:eventId];

        List<Virtual_Event_Details__c> details = [SELECT Id, Zoom_Type__c, Meeting_Password__c, Zoom_User_Id__c, Zoom_Account__c, Exhibit_Open__c, Event__r.Virtual_Venue__c, Event__r.Virtual_Venue__r.Name FROM Virtual_Event_Details__c WHERE Event__c=:eventId];
        if(!details.isEmpty()){
            if(details[0].Event__r.Virtual_Venue__c==null) {
                delete details[0];
                return null;
            } else {
                if(evt.Virtual_Venue__r.Name == 'Zoom'){
                    List<Zoom_User__mdt> users = [SELECT MasterLabel, UserId__c, Meeting_User__c, Webinar_User__c FROM Zoom_User__mdt];
                    for(Zoom_User__mdt u : users){
                        System.debug('u: ' + u);
                        System.debug('details: ' + details[0]);
                        if(details[0].Zoom_Type__c == 'Meeting' && u.Meeting_User__c) {
                            System.debug('adding meeting user...');
                            zoomUsers.put(u.UserId__c, u.MasterLabel);
                        } else if(details[0].Zoom_Type__c == 'Webinar' && u.Webinar_User__c){
                            System.debug('adding webinar user...');
                            zoomUsers.put(u.UserId__c, u.MasterLabel);
                        } else {
                            zoomUsers.put(u.UserId__c, u.MasterLabel);
                        }
                    }
                } else if(evt.Virtual_Venue__r.Name == 'Simple HTML Redirect'){
                    hideDetails = true;
                }
            }

            System.debug('zoom users: ' + zoomUsers);
            return new VirtualDetails(details[0], zoomUsers, hideDetails);
        } else {
            if(evt.Virtual_Venue__r.Name == 'Zoom'){
                List<Zoom_User__mdt> users = [SELECT MasterLabel, UserId__c, Meeting_User__c, Webinar_User__c FROM Zoom_User__mdt];
                for(Zoom_User__mdt u : users){
                    zoomUsers.put(u.UserId__c, u.MasterLabel);
                }
            } else if(evt.Virtual_Venue__r.Name == 'Simple HTML Redirect'){
                hideDetails = true;
            }
            return new VirtualDetails(null, zoomUsers, hideDetails);
        }
    }

    @AuraEnabled
    public static List<Zoom_User__mdt> getZoomUsers(String type){
        List<Zoom_User__mdt> users = new List<Zoom_User__mdt>();
        String queryString = 'SELECT MasterLabel, UserId__c FROM Zoom_User__mdt WHERE ';
        if(type == 'Meeting'){
            queryString += 'Meeting_User__c = TRUE';
        } else {
            queryString += 'Webinar_User__c = TRUE';
        }
        users = (List<Zoom_User__mdt>)Database.query(queryString);

        return users;
    }

    @AuraEnabled
    public static Boolean updateExhibit(String detailEvent){

        List<Virtual_Event_Details__c> details = [SELECT Id, Exhibit_Open__c, Event__c FROM Virtual_Event_Details__c WHERE Id=:detailEvent];
        BR_Event__c evt = [SELECT Id, CME_Open__c, LOP_Open__c, CME_Survey_Link__c FROM BR_Event__c WHERE Id=: details[0].Event__c];
        if(!details.isEmpty()){
            if(details[0].Exhibit_Open__c){
                details[0].Exhibit_Open__c = false;
            } else {
                details[0].Exhibit_Open__c = true;
                if(evt.CME_Survey_Link__c!=null) {
                    evt.CME_Open__c = true;
                }
                evt.LOP_Open__c = true;
                update evt;
            }

            update details[0];
        }

        return details[0].Exhibit_Open__c;

    }

    public class VirtualDetails{
        @AuraEnabled
        public Virtual_Event_Details__c details;

        @AuraEnabled
        public Map<String, String> zoomUsers;

        @AuraEnabled
        public Boolean hideDetails;

        public VirtualDetails(Virtual_Event_Details__c ved, Map<String, String> users, Boolean hideDetails){
            this.details = ved;
            this.zoomUsers = users;
            this.hideDetails = hideDetails;

        }
    }

}