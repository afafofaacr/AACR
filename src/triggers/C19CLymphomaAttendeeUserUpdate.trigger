/**
 * Created by lauren.lezberg on 7/14/2020.
 */

trigger C19CLymphomaAttendeeUserUpdate on EventApi__Attendee__c (after insert, after update, before delete ) {

    List<Id> C19CContactIds = new List<Id>();
    List<Id> LymphomaContactIds = new List<Id>();

    List<Id> cancelledC19CContactIds = new List<Id>();
    List<Id> cancelledLymphomaContactIds = new List<Id>();

    if(Trigger.isInsert || Trigger.isUpdate) {
        for (EventApi__Attendee__c att : Trigger.new) {
            if (att.EventApi__Event__c == C19CLymphomaTriggerHandler.lymphomaEventId) {
//            if (att.EventApi__Event__c == Label.Lymphoma_Event_Id) {
                if (att.EventApi__Status__c == 'Registered') {
                    LymphomaContactIds.add(att.EventApi__Contact__c);
                } else if (att.EventApi__Status__c == 'Cancelled') {
                    cancelledLymphomaContactIds.add(att.EventApi__Contact__c);
                }
            }
            if (att.EventApi__Event__c == C19CLymphomaTriggerHandler.covidEventId) {
//            if (att.EventApi__Event__c == Label.C19C_Event_Id) {
                if (att.EventApi__Status__c == 'Registered') {
                    C19CContactIds.add(att.EventApi__Contact__c);
                } else if (att.EventApi__Status__c == 'Cancelled') {
                    cancelledC19CContactIds.add(att.EventApi__Contact__c);
                }
            }
        }
    } else if (Trigger.isDelete){
        for (EventApi__Attendee__c att : Trigger.old) {
            if (att.EventApi__Event__c == C19CLymphomaTriggerHandler.lymphomaEventId) {
//            if (att.EventApi__Event__c == Label.Lymphoma_Event_Id) {
                cancelledLymphomaContactIds.add(att.EventApi__Contact__c);
            }
            if (att.EventApi__Event__c == C19CLymphomaTriggerHandler.covidEventId) {
//            if (att.EventApi__Event__c == Label.C19C_Event_Id) {
                cancelledC19CContactIds.add(att.EventApi__Contact__c);
            }
        }
    }

    C19CLymphomaTriggerHandler.updateC19CUserRecords(C19CContactIds, cancelledC19CContactIds);

    C19CLymphomaTriggerHandler.updateLymphomaUserRecords(LymphomaContactIds, cancelledLymphomaContactIds);

}