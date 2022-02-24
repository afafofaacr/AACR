/**
 * Created by lauren.lezberg on 4/22/2020.
 */

public without sharing class FreemanRedirectController {
    public static List<Virtual_Meeting_Links__mdt> virtualMeetings = new List<Virtual_Meeting_Links__mdt>();


    public class RedirectInfo {
        @AuraEnabled
        public String url;

        @AuraEnabled
        public Boolean hasDelay;

    }


    @AuraEnabled
    public static RedirectInfo getFreemanURL(String eventId) {
        RedirectInfo ri = new RedirectInfo();

        //check user is logged in
        if (UserInfo.getUserId() == null) {
            ri.url = '/VirtualEventLogin?id=' + eventId;
            ri.hasDelay = false;
            return ri;
        }

        //get contact
        Contact con = ECRMUtils.getCurrentLoginContact();

        List<Virtual_Meeting_Links__mdt> vml = new List<Virtual_Meeting_Links__mdt>();
        if (Test.isRunningTest()) {
            System.debug('running test: ' + virtualMeetings);
            vml = virtualMeetings;
        } else {
            vml = [SELECT Exhibit_Open__c, View_Link__c, Event_Id__c, Registration_Open__c, Event_IsActive__c FROM Virtual_Meeting_Links__mdt WHERE Freeman_Event_Id__c = :eventId];
        }


        if (!vml.isEmpty()) {
            ri.url = vml[0].View_Link__c + con.Id;

            //look for attendee record
            List<EventApi__Attendee__c> att = [SELECT Id, CreatedDate FROM EventApi__Attendee__c WHERE EventApi__Contact__c = :con.Id AND EventApi__Event__c = :vml[0].Event_Id__c];

            //if user has attendee record - check exhibit hall
            if (!att.isEmpty()) {
                //if exhibit hall is closed - redirect to freeman landing page
                if (!vml[0].Exhibit_Open__c) {
                    ri.hasDelay = false;
                    return ri;
                } else { // stay on spinner then redirect
                    if(att[0].CreatedDate.addMinutes(10) < Datetime.now()){
                        ri.hasDelay = false;
                    } else {
                        ri.hasDelay = true;
                    }

                    return ri;
                }
            } else {

                if (vml[0].Registration_Open__c) {
                    ri.url = '/VirtualRegisterForm?id=' + eventId;
                    ri.hasDelay = false;
                    return ri;
                }
            }
        }

        return null;

    }

}