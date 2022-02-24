/**
 * Created by lauren.lezberg on 4/24/2020.
 */

public without sharing class VirtualEventRegisterController extends PagesApi.DefaultTemplateController {
    public static List<Virtual_Meeting_Links__mdt> virtualMeetings = new List<Virtual_Meeting_Links__mdt>();

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
                    vmls = [SELECT Id, Registration_Open__c, Login_Background_Image__c, Login_Header_Image__c FROM Virtual_Meeting_Links__mdt WHERE Freeman_Event_Id__c = :eventId];
                }
                if(!vmls.isEmpty()){
                    if(vmls[0].Registration_Open__c) {
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

    @AuraEnabled
    public static EventRegInfo getEventRegInfo(String eventId){

        List<Virtual_Meeting_Links__mdt> vmls = new List<Virtual_Meeting_Links__mdt>();
        if(Test.isRunningTest()){
            System.debug('running test: ' + virtualMeetings);
            vmls = virtualMeetings;
        } else{
            vmls = [SELECT Id, Exhibit_Open__c, Donation_Link__c, Free_Ticket_Description__c, Donation_Ticket_Description__c, Reg_Logo_Image__c, Login_Header_Image__c FROM Virtual_Meeting_Links__mdt WHERE Freeman_Event_Id__c=: eventId];
        }


        if(!vmls.isEmpty()) {
            return new EventRegInfo(vmls[0].Reg_Logo_Image__c, vmls[0].Login_Header_Image__c, vmls[0].Donation_Link__c, vmls[0].Free_Ticket_Description__c, vmls[0].Donation_Ticket_Description__c, vmls[0].Exhibit_Open__c);
        }

        return new EventRegInfo(null, null,null, null, null, null);
    }

    @AuraEnabled
    public static Contact getCurrentContact(){
        return ECRMUtils.getCurrentLoginContact();
    }

    @AuraEnabled
    public static RegResponse registerUser(String contactString, String eventId){
        System.debug('registerUser: ' + contactString);

        Contact con = (Contact)JSON.deserialize(contactString, Contact.class);

        RegResponse regResp = new RegResponse();


        List<Virtual_Meeting_Links__mdt> vmls = new List<Virtual_Meeting_Links__mdt>();
        if(Test.isRunningTest()){
            System.debug('running test: ' + virtualMeetings);
            vmls = virtualMeetings;
        } else{
            vmls = [SELECT Event_Id__c FROM Virtual_Meeting_Links__mdt WHERE Freeman_Event_Id__c=: eventId];
        }

        Virtual_Meeting_Links__mdt vml = vmls[0];

        List<EventApi__Attendee__c> attendees = [SELECT Id FROM EventApi__Attendee__c WHERE EventApi__Event__c=:vml.Event_Id__c AND EventApi__Contact__c=: con.Id];

        if(attendees.isEmpty()) {



            //create attendee in SF
            EventApi__Attendee__c newAtt = new EventApi__Attendee__c();
            newAtt.EventApi__Contact__c = con.Id;
            newAtt.EventApi__Email__c = con.OrderApi__Preferred_Email__c;
            newAtt.EventApi__Event__c = vml.Event_Id__c;
            newAtt.EventApi__Status__c = 'Registered';


            //update contact
            Database.SaveResult saveResult = Database.update(con, false);

            System.debug('saveResult: ' + saveResult);

            
            //if errors exist
            if (!saveResult.isSuccess()) {
                regResp.success = false;
                regResp.redirectURL = null;
                for (Database.Error error : saveResult.getErrors()) {
                    System.debug('error: ' + error);
                    if (error instanceof Database.DuplicateError) {
                        regResp.message = 'It appears that we have duplicate records for this user. Your case has been logged. Someone from AACR will reach out to you shortly.';

                        List<ServiceNow_Incident_Type__mdt> incidentTypes = [SELECT Id, MasterLabel FROM ServiceNow_Incident_Type__mdt WHERE DeveloperName = 'Registration_Issue'];

                        if (!incidentTypes.isEmpty()) {
                            con = ECRMUtils.getCurrentLoginContact();
                            AACR_Error_Log__c regError = ErrorHelper.buildErrorLog(con, incidentTypes[0].Id, incidentTypes[0].MasterLabel, error.message);
                            insert regError;

                            ErrorHelper.sendServiceNowRequestEmail(con.Id, regError.Id, null);
                        }

                    } else {
                        regResp.message = 'An error occurred with your registration. Please refresh the page and try again.';
                        ErrorHelper.sendExceptionEmail('Event Registration', error.message, String.valueOf(error.getFields()));
                    }
                }

            } else {



                //insert attendee
                try {



                    insert newAtt;

                    regResp.success = true;
                    regResp.message = 'Success';
                    regResp.redirectURL = 'VirtualRegisterConfirmation?id=' + eventId;

                } catch (Exception e) {
                    System.debug('Could not insert attendee ' + e.getMessage());
                    regResp.success = false;
                    regResp.redirectURL = null;
                    regResp.message = 'An error occurred with your registration. Please refresh the page and try again. ';
                    ErrorHelper.sendExceptionEmail('Event Registration', e.getMessage(), e.getStackTraceString());

                }
            }
        } else {
            regResp.success = false;
            regResp.redirectURL = null;
            regResp.message = 'You have already been registered for this event. Please click the \'Return to Profile\' tab above to see your registration in My Content. ';
        }

        return regResp;

    }

    @AuraEnabled
    public static void freemanRegister(String contactString, String eventId){
        //insert attendee into Freeman
        FreemanIntegrationController.asyncCreateFreemanAttendee(contactString, eventId, false);
    }

    @AuraEnabled
    public static Map<String, String> getStates(String countryVal){
        return ECRMUtils.getDependentPicklistValues('Contact', 'MailingCountryCode', 'MailingStateCode', countryVal);
    }

    public class RegResponse {
        @AuraEnabled
        public Boolean success;

        @AuraEnabled
        public String message;

        @AuraEnabled
        public String redirectURL;

        public RegResponse(){}
    }


    public class EventRegInfo{
        @AuraEnabled
        public Map<String, String> countryMap;

        @AuraEnabled
        public Map<String, String> stateMap;

        @AuraEnabled
        public Contact con;

        @AuraEnabled
        public Boolean exhibitOpen;

        @AuraEnabled
        public String donationURL;

        @AuraEnabled
        public String regImgURL;

        @AuraEnabled
        public String headerImgURL;

        @AuraEnabled
        public String freeTicketText;

        @AuraEnabled
        public String donationTicketText;

        public EventRegInfo(String regUrl, String headerUrl, String donationURL, String freeTxt, String donationTxt, Boolean exhibitOpen){
            this.con = ECRMUtils.getCurrentLoginContact();

            String countryVal = this.con.Preferred_Address__c == 'Business'?this.con.MailingCountryCode:this.con.OtherCountryCode;
            if(countryVal == 'US' || countryVal == 'CA'){
                this.stateMap = ECRMUtils.getDependentPicklistValues('Contact', 'MailingCountryCode', 'MailingStateCode', countryVal);
            }

            this.regImgURL = regUrl;
            this.headerImgURL = headerUrl;
            this.donationURL = donationURL;
            this.freeTicketText = freeTxt;
            this.donationTicketText = donationTxt;
            this.exhibitOpen = exhibitOpen;
            this.countryMap = ECRMUtils.getCountryPicklistValues();
        }
    }
}