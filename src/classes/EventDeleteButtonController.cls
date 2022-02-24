/**
 * Created by lauren.lezberg on 4/15/2020.
 */

public with sharing class EventDeleteButtonController {


    @AuraEnabled
    public static Boolean getShowButton(String eventId) {
        BR_Event__c evt = [SELECT id, Draft__c, Cancelled__c FROM BR_Event__c WHERE Id = :eventId];
        if (evt.Draft__c && !evt.Cancelled__c && FeatureManagement.checkPermission('Event_Delete')) {
            return true;
        }

        return false;
    }

    @AuraEnabled
    public static Map<Boolean, String> deleteEvent(String eventId) {
        System.debug('deleting event...');
        Map<Boolean, String> errorMap = new Map<Boolean, String>();
        Boolean hasError = false;


        hasError = LiveEventsHelper.deleteEventTicket(eventId);

        if (!hasError) {
            hasError = LiveEventsHelper.deleteEventSchedule(eventId);

            System.debug('error deleting event schedule: ' + hasError);
            if (!hasError) {
                hasError = LiveEventsHelper.deleteEventUserSegments(eventId);
                System.debug('error deleting event user segments: ' + hasError);
                if (!hasError) {
                    hasError = LiveEventsHelper.deleteEvent(eventId);
                    System.debug('error deleting event: ' + hasError);
                    if (!hasError) {
                        errorMap.put(true, 'Success!');
                    } else {
                        errorMap.put(false, 'Could not delete event.');
                    }
                } else {
                    errorMap.put(false, 'Could not delete event user segments.');
                }
            }
        } else {
            errorMap.put(false, 'Could not delete event schedule.');
        }


        return errorMap;
    }

}