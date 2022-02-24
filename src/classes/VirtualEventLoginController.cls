/**
 * Created by lauren.lezberg on 4/23/2020.
 */

global class VirtualEventLoginController extends PagesApi.DefaultTemplateController {
    public static List<Virtual_Meeting_Links__mdt> virtualMeetings = new List<Virtual_Meeting_Links__mdt>();
    public static List<Branded_Login_Settings__mdt> bls = new List<Branded_Login_Settings__mdt>();
//    public static List<Virtual_Meeting_Sponsor__mdt> virtualSponsors = new List<Virtual_Meeting_Sponsor__mdt>();


//    public String sponsorHTML                   {get;set;}

    public String username { get; set; }
    public String password { get; set; }
    public String intType { get; set; }
    public String intSys { get; set; }
    public String eventId { get; set; }
//    public Boolean registrationOpen { get; set; }
    public String backgroundImg { get; set; }
    public String headerImg { get; set; }
    public String errorMsg { get; set; }
    public Boolean exhibitOpen { get; set; }
    public Boolean customReg { get; set; }

    public String redirectURL { get; set; }
    public String newRegJoinId { get; set; }
    public String startURL { get; set; }
    public Boolean preVerify {get;set;}

    public PagesApi__Site__c siteConfig { get; private set; }


    public VirtualEventLoginController() {
        intSys = ApexPages.currentPage().getParameters().get('system');
        intType = ApexPages.currentPage().getParameters().get('type');
        siteConfig = getSite();
    }

    global PageReference checkIsActive() {
        customReg = false;
        preVerify = false;
        eventId = ApexPages.currentPage().getParameters().get('id');
        startURL = ApexPages.currentPage().getParameters().get('startURL');
        if (eventId != null) {
            BR_Event__c evt = [SELECT Event_Stage__c, Registration_Form__c, Pre_verify_myAACR_Info__c FROM BR_Event__c WHERE Id = :eventId];
            List<Virtual_Event_Details__c> ved = [SELECT Exhibit_Open__c FROM Virtual_Event_Details__c WHERE Event__c = :eventId];
            if (!ved.isEmpty()) {
                preVerify = evt.Pre_verify_myAACR_Info__c;
                exhibitOpen = ved[0].Exhibit_Open__c;
                if (evt.Registration_Form__c == 'Custom') {
                    customReg = true;
                }
                //check if user is already authenticated
                if (!this.getIsAuthenticated()) {
                    //not for in person events
                    if (evt.Event_Stage__c != 'In Person') {

                        List<Branded_Login_Settings__mdt> loginSettings = [SELECT Is_Active__c, Header_Image_URL__c, Background_Image_URL__c FROM Branded_Login_Settings__mdt WHERE Live_Event_Id__c = :eventId];
                        if (Test.isRunningTest()) {
                            loginSettings = bls;
                        }

                        if (!loginSettings.isEmpty()) {
                            //check is page is active

                            backgroundImg = loginSettings[0].Background_Image_URL__c;
                            headerImg = loginSettings[0].Header_Image_URL__c;
                            
                            redirectURL = startURL;

                            if (!loginSettings[0].Is_Active__c) {
                                errorMsg = 'This event is no longer active. To login to myAACR, click the link below.';
                            }
                            return null;
                        }

                    } else {
                        //In person event, clear event id so they are redirected to regular login screen
                        eventId = null;
                    }
                } else {
                    return buildLoginRedirect(UserInfo.getUserId());
                }
            } else {
                //In person event, clear event id so they are redirected to regular login screen
                eventId = null;
            }
        }
        return buildLoginRedirect(null);
    }

    public PageReference goToStandardLogin() {
        return new PageReference('/DW_aacr_custom_login');
    }

    public PageReference buildLoginRedirect(String userId) {
        PageReference redirectUrlObj = null;
        System.debug('buildLoginRedirect with user: ' + userId);
        System.debug('eventId: ' + eventId);
        System.debug('startURL: ' + startURL);
        System.debug('exhibitOpen: ' + exhibitOpen);
        System.debug('customReg: ' + customReg);
        System.debug('preVerify: ' + preVerify);



        /** CHECK FOR STARTURL PARAM **/
        if (String.isNotEmpty(startURL)) {
            redirectUrlObj = new PageReference(startURL);
        } else {
            /** CHECK FOR EVENTID OTHERWISE REDIRECT TO REGULAR LOGIN **/
            if (eventId != null) {
                /** SET DEFAULT LOGIN REDIRECT -- EVENT LANDING PAGE **/
                redirectUrlObj = new PageReference('/LiveEventsList?ac__id=' + eventId);
                /** CHECK IF USER ID PROVIDED **/
                if (userId != null) {
                    /** CHECK FOR TICKETS **/
                    List<BR_Participation__c> tickets = [SELECT Id FROM BR_Participation__c WHERE User__c = :userId AND BR_Event__c = :eventId AND Participate__c = 'Yes'];
                    /** REGISTERED FOR EVENT ALREADY**/
                    if (!tickets.isEmpty()) {
                        if (exhibitOpen) {
                            String meetingURL = BrEventsItemController.goToVirtualMeeting(eventId);
                            redirectUrlObj = new PageReference(meetingURL);
                        }
                    } else {/** NOT REGISTERED FOR EVENT YET**/

                        if (customReg) {
                            if(preVerify){
                                redirectUrlObj = new PageReference('/myAACRVerifyInfo?eventId=' + eventId);
                            } else {
                                redirectUrlObj = new PageReference('/CustomRegistrationRedirect?id=' + eventId);
                            }
                        }
                    }
                }
            } else {
                redirectUrlObj = new PageReference('/DW_aacr_custom_login');
            }
        }

        System.debug('redirectURL: ' + redirectUrlObj.getUrl());
//        redirectURL = redirectUrlObj.getUrl();
        return redirectUrlObj;
    }

    public PageReference login() {
        PageReference redirect;
        Boolean formIsValid = String.isNotEmpty(username) && String.isNotEmpty(password);
        if (!formIsValid) {
            if (String.isEmpty(username)) {
                Framework.Message.addMessage(Label.CPBase.Login_Username_Required_Message, Framework.Message.Severity.Danger, false);
            }
            if (String.isEmpty(password)) {
                Framework.Message.addMessage(Label.CPBase.Login_Password_Required_Message, Framework.Message.Severity.Danger, false);
            }
        } else {
            if (siteConfig != null) {
                if (intSys == '' || intSys == null) {
                    try {
                        List<User> users = [SELECT Id, ContactId FROM User WHERE Username = :username AND IsActive = true ORDER BY LastLoginDate DESC];
                        System.debug('users: ' + users);
                        //look for user
                        if (!users.isEmpty()) {
                            redirect = buildLoginRedirect(users[0].Id);
                        } else {
                            redirect = new PageReference('/DW_aacr_custom_login');
                        }
                        redirect.setRedirect(true);
                        System.debug('built login url: ' + redirect.getUrl());
                        String redirectURL = redirect.getUrl();
                        redirect = Site.login(username, password, redirectURL);
                        System.debug('redirect==>' + redirect);
                        if (redirect == null) {
                            System.debug('MSG==>' + System.Label.CPBase.Invalid_Username_Password);
                            System.debug('MSG==>' + Framework.Message.Severity.Danger);
                            Framework.Message.addMessage(System.Label.CPBase.Invalid_Username_Password, Framework.Message.Severity.Danger, false);
                        } else {
                            return redirect;
                        }
                    } catch (Exception ex) {
                        Framework.Message.addMessage(System.Label.CPBase.Invalid_Username_Password, Framework.Message.Severity.Danger, false);
                    }
                }
            } else {
                Framework.Message.addMessage('Invalid site configuration!', Framework.Message.Severity.Danger, false);
            }
        }

        return redirect;
    }


}