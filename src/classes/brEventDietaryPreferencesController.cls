/**
 * Created by mitfity on 28.08.2019.
 */

public with sharing class brEventDietaryPreferencesController {


    /**
     * Retrieves dietary preferences field set options.
     *
     * @return
     */
    @AuraEnabled
    public static List<Map<String, String>> getFieldSetOptions() {
        brSecurity.performAccessCheck('read', BR_Participation__c.SObjectType);

        return brSObjectHelper.getFieldSetOptions(BR_Participation__c.SObjectType);
    }

    /**
     * Retrieves selected dietary preferences field set name for specified event.
     *
     * @param eventId
     *
     * @return
     */
    @AuraEnabled
    public static String getSelectedFieldSetName(Id eventId) {
        brSecurity.performAccessCheck('read', AC_Event_User_Segment__c.SObjectType);

        List<AC_Event_User_Segment__c> eventResult = [
                SELECT Event_Preferences_Form_Fieldset__c
                FROM AC_Event_User_Segment__c
                WHERE Id = :eventId
        ];
        if (eventResult.isEmpty()) {
            throw new AACRCustomException('Event not found', 'brEventDietaryPreferencesController.getSelectedFieldsetName', 'Ticket Purchase');
//            throw new AuraHandledException('Event is not found.');
        }

        AC_Event_User_Segment__c event = eventResult[0];

        return event.Event_Preferences_Form_Fieldset__c;
    }

    /**
     * Saves field set name for specified event.
     *
     * @param eventId
     * @param fieldSetName
     */
    @AuraEnabled
    public static void saveFieldSetName(Id eventId, String fieldSetName) {
        brSecurity.performAccessCheck('edit', AC_Event_User_Segment__c.SObjectType);

        List<AC_Event_User_Segment__c> eventResult = [
                SELECT Event_Preferences_Form_Fieldset__c
                FROM AC_Event_User_Segment__c
                WHERE Id = :eventId
        ];

        if (eventResult.isEmpty()) {
            throw new AACRCustomException('Event not found', 'brEventDietaryPreferencesController.saveFieldSetName', 'Ticket Purchase');
//            throw new AuraHandledException('Event is not found.');
        }

        AC_Event_User_Segment__c event = eventResult[0];

        event.Event_Preferences_Form_Fieldset__c = fieldSetName;

        try {
            update event;
        } catch (Exception e) {
            throw new AACRCustomException(eventId, e.getMessage(), e.getStackTraceString(), 'Ticket Purchase');
//            throw new AuraHandledException('Failed to update event. ' + e.getMessage());
        }
    }
}