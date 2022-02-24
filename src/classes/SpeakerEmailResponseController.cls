/**
 * Created by lauren.lezberg on 2/14/2020.
 */

public without sharing class SpeakerEmailResponseController {


    /**
     * @purpose Set speaker email response based on url header response
     *
     * @param accepted
     * @param speakerId
     *
     * @return List of urls for survey and disclosures
     */
    @AuraEnabled
    public static SpeakerResponseInfo setSpeakerResponse(Boolean accepted, String speakerId){
        System.debug('setting speaker response to ' + accepted + ' for speaker ' + speakerId);

        Boolean sendEmail = false;
        //get speaker
        Session_Speaker__c speaker = [SELECT Id, Status__c, Speaker__c, Session__r.Event__r.Disclosure_Link__c, Assistant__r.Name FROM Session_Speaker__c WHERE Id=: speakerId LIMIT 1];
        //set status

        if(accepted){
            if(speaker.Status__c!='Accepted') {
                sendEmail = true;
                speaker.Status__c = 'Accepted';
            }
        } else {
            speaker.Status__c = 'Declined';
        }

        if(sendEmail || !accepted){
            //set reply date
            speaker.Reply_Date__c = System.today();
        }


        try {
            //update speaker status and reply date
            update speaker;

            if (sendEmail) {
                //send confirmation email
                sendConfirmationEmail(speaker.Id);

            }

            //get survey and disclosure links
            return new SpeakerResponseInfo(speaker.Session__r.Event__r.Disclosure_Link__c,speaker.Speaker__c, speaker.Assistant__r.Name );

        } catch(Exception e){
            System.debug('Could not update speaker and send confirmation: ' + e.getMessage() + e.getStackTraceString());
            new AACRCustomException(e.getMessage(), e.getStackTraceString(), 'Speaker Response');
        }

        return null;
    }

    public class SpeakerResponseInfo{
        @AuraEnabled
        public String disclosureLink;

        @AuraEnabled
        public STring contactId;

        @AuraEnabled
        public String assistant;

        public SpeakerResponseInfo(String link, string id, String assistantName){
            this.disclosureLink = link!=null?link:'';
            this.contactId = id;
            this.assistant = assistantName;
        }

    }


    /**
     * @purpose Send speaker confirmation email
     *
     * @param speakerId
     */
    private static void sendConfirmationEmail(Id speakerId){
        System.debug('sending confirmation email to speaker: ' + speakerId);
        //get org wide email address
//        String orgWideEmailId = BrEventsHelper.getConfigValue('org wide email id');
//        List<OrgWideEmailAddress> emailAddresses = [
//                SELECT Id, Address
//                FROM OrgWideEmailAddress
//                WHERE Id = :orgWideEmailId
//        ];
        //get speaker
        Session_Speaker__c speaker = [SELECT Id,Speaker__r.Email, Session__r.Event__r.Start_Date__c, Session__r.Event__r.End_Date__c, Session__r.Event__c,
                                        Session__r.Event__r.Name, Status__c,Speaker__r.Salutation, Speaker__r.LastName, Speaker__r.FirstName,
                                        Session__r.Event__r.Disclosure_Link__c, Session__r.Event__r.Draft_Program__c, Session__r.Event__r.Portal_Event_Link__c
                                        FROM Session_Speaker__c WHERE Id=: speakerId LIMIT 1];
        System.debug('speaker: ' + speaker);

        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
        EmailTemplate emailTemplate = [SELECT Id, HtmlValue, Body  FROM EmailTemplate WHERE Name='Speaker Confirmation'];

        //build email message
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        String body = emailTemplate.HtmlValue;
        body = emailTemplate.HtmlValue.replace('{!recipientName}', speaker.Speaker__r.Salutation!=null?speaker.Speaker__r.Salutation + ' ' + speaker.Speaker__r.FirstName + ' ' + speaker.Speaker__r.LastName:speaker.Speaker__r.FirstName + ' ' +speaker.Speaker__r.LastName)
//                .replace('{!eventDates}', speaker.Session__r.Event__r.Start_Date__c.format() + ' - ' + speaker.Session__r.Event__r.End_Date__c.format())
                .replace('{!portalLink}', 'https://' + speaker.Session__r.Event__r.Portal_Event_Link__c)
                .replace('{!draftLink}', speaker.Session__r.Event__r.Draft_Program__c!=null?speaker.Session__r.Event__r.Draft_Program__c:'')
                .replace('{!eventName}', speaker.Session__r.Event__r.Name)
                .replace('{!disclosureLink}', speaker.Session__r.Event__r.Disclosure_Link__c!=null?speaker.Session__r.Event__r.Disclosure_Link__c:'');
        email.setHtmlBody(body);
        email.setSenderDisplayName('American Association for Cancer Research');
        email.setTargetObjectId(speaker.Speaker__c);
        email.setTemplateId(emailTemplate.Id);
        email.setWhatId(speaker.Session__r.Event__c);
        email.setSaveAsActivity(false);
        email.setToAddresses(new List<String>{
                speaker.Speaker__r.Email
        });
        email.setSubject('Thank You for Agreeing to Participate in ' + speaker.Session__r.Event__r.Name);
//        email.setOrgWideEmailAddressId(emailAddresses[0].Id);
        emails.add(email);

        if (!emails.isEmpty()) {
            try {
                Messaging.sendEmail(emails);
            } catch (EmailException ex) {
                System.debug('Error sending confirmation email: ' + ex.getMessage());
                throw new AACRCustomException(ex.getMessage(), ex.getStackTraceString(), 'Speaker Invitations');
            }
        }
    }
}