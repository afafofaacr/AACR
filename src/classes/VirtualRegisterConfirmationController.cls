/**
 * Created by lauren.lezberg on 5/15/2020.
 */

public with sharing class VirtualRegisterConfirmationController extends PagesApi.DefaultTemplateController {

    public static List<Virtual_Meeting_Links__mdt> virtualMeetings = new List<Virtual_Meeting_Links__mdt>();

    public EventApi__Event__c event {get;set;}
    public String contactId {get;set;}
    public String viewLink {get;set;}
    public String confirmationTxt {get;set;}
    public String eventId {get;set;}
    public String backgroundImg {get;set;}
    public String headerImg {get;set;}



    public PageReference checkIsActive(){

        if(this.getIsAuthenticated()) {
            eventId = ApexPages.currentPage().getParameters().get('id');
            if (eventId != null) {
                List<Virtual_Meeting_Links__mdt> vmls = new List<Virtual_Meeting_Links__mdt>();
                if(Test.isRunningTest()){
                    System.debug('running test: ' + virtualMeetings);
                    vmls = virtualMeetings;
                } else{
                    vmls = [SELECT Id, Exhibit_Open__c, View_Link__c, Event_Id__c, Confirmation_Text__c, Registration_Open__c, Login_Background_Image__c, Login_Header_Image__c FROM Virtual_Meeting_Links__mdt WHERE Freeman_Event_Id__c = :eventId];
                }
                if(!vmls.isEmpty()){
                    if(vmls[0].Exhibit_Open__c){
                        return new PageReference('/FreemanRedirect?id=' + eventId);
                    }
                    if(vmls[0].Registration_Open__c) {
                        Contact con = ECRMUtils.getCurrentLoginContact();
                        event = [SELECT Calendar_Invite_Msg__c, EventApi__Start_Date_Time__c, EventApi__End_Date_Time__c, EventApi__Location_And_Date_Text__c, EventApi__Start_Date__c, EventApi__Start_Time__c, EventApi__End_Date__c, EventApi__Logo_Image__c, EventApi__End_Time__c, EventApi__Time_Zone__c, EventApi__Description__c, EventApi__Display_Name__c FROM EventApi__Event__c WHERE Id=: vmls[0].Event_Id__c];
                        if(event.Calendar_Invite_Msg__c!=null) {
                            event.Calendar_Invite_Msg__c = event.Calendar_Invite_Msg__c.removeStart('\'').removeEnd('\'');
                        }

                        TimeZone targetTimezone = TimeZone.getTimeZone('America/New_York');

                        // The targetDate is used here to decide whether
                        // Daylight Savings should apply.
                        Integer offsetSeconds = targetTimezone.getOffset(event.EventApi__Start_Date__c) / 1000;
                        Datetime targetDatetime = event.EventApi__Start_Date_Time__c.addSeconds(offsetSeconds);
                        event.EventApi__Start_Date_Time__c = targetDatetime;

                        offsetSeconds = targetTimezone.getOffset(event.EventApi__End_Date__c) / 1000;
                        targetDatetime = event.EventApi__End_Date_Time__c.addSeconds(offsetSeconds);
                        event.EventApi__End_Date_Time__c = targetDatetime;

                        contactId = con.Id;
                        viewLink = vmls[0].View_Link__c.remove('&regId=');
                        confirmationTxt = vmls[0].Confirmation_Text__c;
                        backgroundImg = vmls[0].Login_Background_Image__c;
                        headerImg = vmls[0].Login_Header_Image__c;
                        return null;
                    } else {
                        return new PageReference('/MemberProfile');
                    }
                } else {
                    return new PageReference('/MemberProfile');
                }

            } else {
                return new PageReference('/MemberProfile');
            }
        } else {
            return new PageReference('/VirtualEventLogin?id='+ eventId);
        }

    }
}