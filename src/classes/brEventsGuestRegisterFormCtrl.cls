public with sharing class brEventsGuestRegisterFormCtrl {

    @AuraEnabled
    public static String getRegisterFormInputs() {
        Schema.FieldSet fs;
        List<Map<String,String>> listMap = new List<Map<String,String>>();

        BrEvents_Settings__c setting = BrEvents_Settings__c.getValues('create_lead_on_guest_register');

        if (setting != null) {
            if(setting.Value__c == 'false') {
                fs = Schema.SObjectType.Contact.fieldSets.getMap().get('Event_Guest_Registration');
            } else if(setting.Value__c == 'true') {
                fs = Schema.SObjectType.Lead.fieldSets.getMap().get('Event_Guest_Registration');
            } else {
                return '';
            }

        } else {
            return '';
        }

        for(Schema.FieldSetMember field: fs.getFields()) {
            Map<String,String> newMap = new Map<String,String>();
            newMap.put('name', field.getFieldPath());
            newMap.put('label', field.getLabel());
            newMap.put('type', String.valueOf(field.getType()));
            newMap.put('required', String.valueOf(field.getRequired()));
            newMap.put('db_required', String.valueOf(field.getDbRequired()));
            listMap.add(newMap);
        }

        return JSON.serialize(listMap);
    }

    @AuraEnabled
    public static void registerGuestForEvent(String jsonString, String eventId) {

        BrEvents_Settings__c setting = BrEvents_Settings__c.getValues('create_lead_on_guest_register');

        if (setting != null) {
            if(setting.Value__c == 'false') {
                BrEventsHelper.createContactParticipation(jsonString, eventId);
            } else if(setting.Value__c == 'true') {
                BrEventsHelper.createLeadParticipation(jsonString, eventId);
            } else {
                return ;
            }

        } else {
            return ;
        }
    }
}