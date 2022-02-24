/**
 * Created by afaf.awad on 9/15/2020.
 */

public without sharing class VolunteerFormController {

    @AuraEnabled
    public static DefaultData getDefaultData(String recordType) {
        DefaultData data = new DefaultData();
        data.countries = ECRMUtils.getCountryPicklistValues();
        data.states = ECRMUtils.getStatePicklistValues();
        data.recordTypeId = [SELECT Id FROM RecordType WHERE Name =: recordType AND SobjectType = 'Contact'].Id;
        data.domains = getForceSiteDomain();
        data.stakeholderOptions = ECRMUtils.getPicklistValues('Contact','Secondary_Stakeholder__c');

        return data;

    }

    @AuraEnabled
    public static RegResponse saveVolunteer(String contactString) {

        Contact con = (Contact) JSON.deserialize(contactString, Contact.class);

        RegResponse regResp = new RegResponse();

        //update contact
        Database.DMLOptions dml = new Database.DMLOptions();
            Database.SaveResult saveResult = Database.insert(con, dml);

        //if errors exist
            if ( !saveResult.isSuccess() ) {
                regResp.success = false;

                for (Database.Error error : saveResult.getErrors()) {

                    regResp.message = error.message;
                    regResp.success = false;

//                    if ( error instanceof Database.DuplicateError ) {
//                        regResp.message = 'It appears that we have your information already. Your case has been logged. Someone from AACR will reach out to you shortly.';

//                        List<ServiceNow_Incident_Type__mdt> incidentTypes = [SELECT Id, MasterLabel FROM ServiceNow_Incident_Type__mdt WHERE DeveloperName = 'Registration_Issue'];
//                        if ( !incidentTypes.isEmpty() ) {
//                            con = ECRMUtils.getCurrentLoginContact();
//                            AACR_Error_Log__c regError = ErrorHelper.buildErrorLog(con, incidentTypes[0].Id, incidentTypes[0].MasterLabel, error.message);
//                            insert regError;
//
//                            ErrorHelper.sendServiceNowRequestEmail(con.Id, regError.Id, null);
//                        }
//                    } else {
//                        regResp.message = error.message;
//                    }
                }
            }
        else {
            regResp.success = true;
            regResp.message = 'Contact created: ' + con.Id;
            emailRegistration(con);

        }

        return regResp;

    }


    @AuraEnabled
    public static String getForceSiteDomain() {

        List<Site> siteList = [
                SELECT GuestUserId, Name,MasterLabel, Subdomain,
                        OptionsRequireHttps, UrlPathPrefix
                FROM Site
                WHERE Status = 'Active' AND SiteType='Visualforce'
                LIMIT 1];

        List<String> siteFullUrlList = new List<String>();
        /** We can get instance of the org from organization object **/
        Organization org = [SELECT InstanceName,Name, IsSandbox, OrganizationType FROM Organization];
        if ( siteList != null && siteList.size() != 0 ) {
            for (Site s : siteList) {
                if ( s.Subdomain != null ) {
//                    String httpStr = 'http://';
//                    if ( s.OptionsRequireHttps == true ) {
//                        httpStr = 'https://';
//                    }
                    String siteFullUrl='';
                    if(org.IsSandbox == true) {
                        siteFullUrl = UserInfo.getUserName().substringAfterLast('.')+'-';
                    }
                    siteFullUrl += s.Subdomain + '.';
                    siteFullUrl += (org.IsSandbox ? (org.InstanceName.toLowerCase() + '.') : '');
                    siteFullUrl += org.IsSandbox ? 'force.com' : 'secure.force.com';
                    if ( s.UrlPathPrefix != null ) {
                        siteFullUrl += '/' + s.UrlPathPrefix;
                    }
                    System.debug(siteFullUrl);
                    siteFullUrlList.add(siteFullUrl);
                }
            }

        }

        return siteFullUrlList[0];
    }

    /**
     * Returns site key for recaptcha
     *
     * @return Site key
     */
    @AuraEnabled
    public static String getSiteKey() {
        String siteKey = '';

        BrEvents_Settings__c setting = BrEvents_Settings__c.getValues('recaptcha_key');

        if ( setting != null ) {
            siteKey = setting.Value__c;

        }

        if ( Test.isRunningTest() ) {
            return '1234';
        } else {
            return siteKey;
        }
    }

    @AuraEnabled
    public static list<String> getStakeholderOptions(){
       return ECRMUtils.getPicklistValues('Contact','Secondary_Stakeholder__c');
    }


    @AuraEnabled
    public static void emailRegistration(Contact contact) {

        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
        EmailTemplate emailTemplate = [SELECT Id, HtmlValue, Body FROM EmailTemplate WHERE Name = 'VAMII Registration Confirmation Email'];
        OrgWideEmailAddress outgoingEmail = [SELECT Id FROM OrgWideEmailAddress WHERE DisplayName = 'AACR Events' ];
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();

            String body = emailTemplate.HtmlValue;
//            body = emailTemplate.HtmlValue.replace('{!EventApi__Attendee__c.EventApi__Event__c}', attendee.EventApi__Event__r.Name)
//                    .replace('{!Contact.Email}', attendee.EventApi__Contact__r.Email)
//                    .replace('{!EventApi__Attendee__c.EventApi__Full_Name__c}', attendee.EventApi__Full_Name__c);
            email.setHtmlBody(body);
            email.setSubject('You are registered for Virtual Patient Advocate Forum');
            email.setTargetObjectId(contact.Id);
            email.setTemplateId(emailTemplate.Id);
            email.setWhatId(contact.Id);
            email.setSaveAsActivity(false);
            email.setOrgWideEmailAddressId(outgoingEmail.Id);
//            email.setSenderDisplayName('American Association For Cancer Research');
            email.setToAddresses(new List<String>{
                    contact.Email
            });
            emails.add(email);

            try {
                Messaging.sendEmail(emails);
            } catch (EmailException ex) {
                System.debug(ex.getMessage());
//                throw new AACRCustomException(ex.getMessage(), ex.getStackTraceString(), 'Email: Virtual_Patient_Advocate_Forum');
            }


        }

    public class RegResponse {
        @AuraEnabled
        public Boolean success;

        @AuraEnabled
        public String message;

        public RegResponse() {
        }
    }

    public class DefaultData {
        @AuraEnabled public Map<string, string> countries { get; set; }
        @AuraEnabled public Map<string, string> states { get; set; }
        @AuraEnabled public String recordTypeId { get; set; }
        @AuraEnabled public String domains {get; set; }
        @AuraEnabled public List<String> stakeholderOptions {get; set;}
    }


}