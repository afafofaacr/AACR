/**
 * Created by lauren.lezberg on 10/28/2020.
 */

trigger LiveEventTrigger on BR_Event__c (after update, before delete) {

    //get zoom venue Id
    List<Venue__c> virtualVenues = [SELECT Id FROM Venue__c WHERE RecordType.Name='Virtual' AND Name='Zoom'];
    Id zoomId = null;
    if(!virtualVenues.isEmpty()){
        zoomId = virtualVenues[0].Id;
    }
    if(Trigger.isAfter) {
        if(Trigger.isUpdate) {
            LiveEventTriggerHandler.handleUpdate(Trigger.newMap.keyset(), Trigger.oldMap);
//            List<BR_Event__c> evts = [SELECT Id, Virtual_Venue__r.Name, Virtual_Venue__c, Start_Date__c, End_Date__c FROM BR_Event__c WHERE Id IN:Trigger.new];
//            List<Virtual_Event_Details__c> ved = [SELECT Id, External_Event_Id__c, Zoom_Type__c, Event__c,
//                                                    Event__r.Virtual_Venue__r.Name, Event__r.Virtual_Venue__c,
//                                                    Event__r.Start_Date__c, Event__r.End_Date__c
//                                                    FROM Virtual_Event_Details__c
//                                                    WHERE Event__c IN: Trigger.new];
//
//            for (BR_Event__c evt : evts) {
//                if(Trigger.oldMap.get(evt.Id).Virtual_Venue__c!=null){ //old venue was virtual
//                    System.debug('old venue was virtual');
//                    System.debug('old venue name: ' + Trigger.oldMap.get(evt.Id).Virtual_Venue__c);
//                    if(Trigger.oldMap.get(evt.Id).Virtual_Venue__c == zoomId){ //old venue was zoom
//                        System.debug('old venue was zoom');
//                        if(evt.Virtual_Venue__c==null){ //new venue is physical --> delete zoom meeting
//                            System.debug('new venue is physical');
//                            LiveEventTriggerHandler.deleteZoomMeeting(evt.Id);
//                        } else { //new venue is virtual
//                            System.debug('new venue is virtual');
//                            if(evt.Virtual_Venue__c == zoomId){ //new venue is zoom --> check for date change and update
//                                System.debug('new venue is zoom');
//                                if (evt.Start_Date__c != Trigger.oldMap.get(evt.Id).Start_Date__c || evt.End_Date__c != Trigger.oldMap.get(evt.Id).End_Date__c) {
//                                    LiveEventTriggerHandler.updateZoomMeeting(evt.Id);
//                                }
//                            } else { //new venue is not zoom --> delete zoom meeting
//                                System.debug('new venue is not zoom');
//                                LiveEventTriggerHandler.deleteZoomMeeting(evt.Id);
//                            }
//                        }
//                    }
//                    else { //old venue was not zoom
//                        System.debug('old venue was not zoom');
//
//                        if(evt.Virtual_Venue__c!=null) {
//                            System.debug('new venue is virtual');
//                            if (evt.Virtual_Venue__c == zoomId) { // new venue is zoom --> create meeting
//                                System.debug('new venue is zoom');
//                                LiveEventTriggerHandler.createZoomMeeting(evt.Id);
//                            }
//                        }
//                    }
//
//                }
//            }
        }
    } else if(Trigger.isBefore){
        System.debug('isBefore...');
        if(Trigger.isDelete){
            System.debug('isDelete...');
            LiveEventTriggerHandler.handleDelete(Trigger.oldMap.keySet());
//            List<BR_Event__c> evts = [SELECT Id, Virtual_Venue__r.Name, Virtual_Venue__c, Start_Date__c, End_Date__c FROM BR_Event__c WHERE Id IN:Trigger.old];
//            System.debug('evts: ' + evts);
//            for (BR_Event__c evt : evts) {
//                System.debug('evt: ' + evt);
//                if (evt.Virtual_Venue__c != null ){
//                        if(evt.Virtual_Venue__c == zoomId) {
//                            List<Virtual_Event_Details__c> ved = [SELECT Id, External_Event_Id__c, Zoom_Type__c FROM Virtual_Event_Details__c WHERE Event__c=:evt.Id];
//                            System.debug('veds: ' + ved);
//                            if(!ved.isEmpty()) {
//                                LiveEventTriggerHandler.deleteZoomMeeting(ved[0].External_Event_Id__c);
//                            }
//                        }
//                }
//            }
        }
    }
}