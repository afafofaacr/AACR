/**
 * Created by lauren.lezberg on 4/15/2020.
 */

public with sharing class EventCancelButtonController {

    @AuraEnabled
    public static Boolean getShowButton(String eventId){
        BR_Event__c evt = [SELECT id, Draft__c, Cancelled__c FROM BR_Event__c WHERE Id=: eventId];
        if(!evt.Draft__c && !evt.Cancelled__c && FeatureManagement.checkPermission('Event_Cancel')){
            return true;
        }

        return false;
    }

    @AuraEnabled
    public static Map<Boolean, String> cancelEvent(Id eventId){
        Map<Boolean, String> errorMap = new Map<Boolean, String>();
        Boolean success = false;

        success = LiveEventsHelper.cancelEvent(eventId);

        if(success) {
            errorMap.put(success, 'Success!');
        } else {
            errorMap.put(success, 'Could not cancel event.');
        }

        return errorMap;
    }

}