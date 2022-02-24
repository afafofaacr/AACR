/**
 * Created by lauren.lezberg on 10/27/2020.
 */

trigger VirtualEventDetailsTrigger on Virtual_Event_Details__c (after insert, after update) {

    if(Trigger.isAfter) {
        if (Trigger.isInsert) {
            for(Virtual_Event_Details__c ved : Trigger.new){
                VirtualEventDetailsTriggerHandler.createZoomMeeting(ved.Id);
            }
        } else if (Trigger.isUpdate){
            for(Virtual_Event_Details__c ved : Trigger.new){
                if(ved.Meeting_Password__c!= Trigger.oldMap.get(ved.Id).Meeting_Password__c) {
                    VirtualEventDetailsTriggerHandler.updateZoomMeeting(ved.Id);
                }
            }
        }
    }

}