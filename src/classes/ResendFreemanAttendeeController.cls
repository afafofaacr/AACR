/**
 * Created by lauren.lezberg on 6/22/2020.
 */

public with sharing class ResendFreemanAttendeeController {
    public static List<Virtual_Meeting_Links__mdt> virtualMeetings = new List<Virtual_Meeting_Links__mdt>();

    @AuraEnabled
    public static Boolean getShowCmp(String attId){
        EventAPi__Attendee__c att = [SELECT Id, EventApi__Contact__c, EventApi__Event__c FROM EventApi__Attendee__c WHERE Id=: attId];

        if(att!=null) {
            List<Virtual_Meeting_Links__mdt> vmls = new List<Virtual_Meeting_Links__mdt>();
            if(Test.isRunningTest()){
                System.debug('running test: ' + virtualMeetings);
                vmls = virtualMeetings;
            } else{
                vmls = [SELECT Freeman_Event_Id__c FROM Virtual_Meeting_Links__mdt WHERE Event_Id__c = :att.EventApi__Event__c];
            }
            return !vmls.isEmpty() && FeatureManagement.checkPermission('Freeman_Send');
        }

        return false;
    }

    @AuraEnabled
    public static boolean resendAttendee(String attId){
        EventAPi__Attendee__c att = [SELECT Id, EventApi__Contact__c, EventApi__Event__c FROM EventApi__Attendee__c WHERE Id=: attId];

        if(att!=null) {
            List<Virtual_Meeting_Links__mdt> vmls = new List<Virtual_Meeting_Links__mdt>();
            if(Test.isRunningTest()){
                System.debug('running test: ' + virtualMeetings);
                vmls = virtualMeetings;
            } else{
                vmls = [SELECT Freeman_Event_Id__c FROM Virtual_Meeting_Links__mdt WHERE Event_Id__c = :att.EventApi__Event__c];
            }

            if(!vmls.isEmpty()) {
                if(vmls[0].Freeman_Event_Id__c!=null) {
                    Contact con = [SELECT Id, Title, AACR_Id__c, Salutation, FirstName, LastName, OrderApi__Preferred_Email__c FROM Contact WHERE Id = :att.EventApi__Contact__c];
                    String conString = JSON.serialize(con);

                    FreemanIntegrationController.createFreemanAttendee(conString, vmls[0].Freeman_Event_Id__c, false);

                    return true;
                }
            }

        }

        return false;

    }

}