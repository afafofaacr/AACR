/**
 * Created by lauren.lezberg on 2/18/2020.
 */

global class Batch_SpeakerInviteEmail implements Database.Batchable<sObject>, Database.Stateful{
    List<String> speakerIds {get;set;}
    String chairString {get;set;}
    String cochairString {get;set;}
    List<Session_Speaker__c> toUpdate {get;set;}

    global Batch_SpeakerInviteEmail(List<String> speakers, String eventId){
        speakerIds = new List<String>();
        speakerIds.addAll(speakers);
        toUpdate = new List<Session_Speaker__c>();
        //get chair and co-chair strings
        chairString = SpeakerInviteHelper.buildChairString(eventId);
//        cochairString = SpeakerInviteHelper.getCochairString(eventId);

    }

    global Database.QueryLocator start(Database.BatchableContext BC){
        System.debug('starting Batch_SpeakerInviteEmail...');
        String queryString = 'SELECT Id, Session__r.Event__r.Hide_Date_Time__c, Session__r.Event__r.Draft_Program__c, Session__r.Event__r.Signature_1__c, Session__r.Event__r.Signature_2__c, Session__r.Event__r.Signature_3__c, Session__r.Event__r.Signature_4__c, Session__r.Event__r.Signature_5__c, Session__r.Event__r.Signature_6__c, cc_assistant__c, Session__r.Event__r.Reply_To__c, Session__r.Event__r.Category__c, Session__r.Event__r.Virtual_Venue__c, Session__r.Event__r.Venue__c, Session__r.Event__r.Venue__r.Name, Session__r.Event__r.Venue__r.City__c, Session__r.Event__r.Venue__r.State__c, Speaker__c, Session__r.Date__c, Session__r.Start_Time__c, Session__r.End_Time__c, Assistant__c, Roles__c, Assistant__r.Email, Session__r.Name, Speaker__r.LastName, Speaker__r.FirstName, Speaker__r.Salutation, Speaker__r.Email, Session__r.Event__r.Name, Session__r.Event__r.Start_Date__c, Session__r.Event__r.End_Date__c, Session__r.Event__r.Invite_Message__c, Session__r.Event__r.Invite_Image_Id__c FROM Session_Speaker__c WHERE Id IN: speakerIds';
        System.debug('queryString: ' + queryString);
        return Database.getQueryLocator(queryString);
    }

    global void execute(Database.BatchableContext BC, List<Session_Speaker__c> scope){
        System.debug('executing Bath_SpeakerInviteEmail with ' + scope.size() + ' records.');
        System.debug('chairString in execute: ' + chairString);
        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
        OrgWideEmailAddress owa = [SELECT Id FROM OrgWideEmailAddress WHERE DisplayName='AACR Events'];
        EmailTemplate emailTemplate = [SELECT Id, HtmlValue, Body  FROM EmailTemplate WHERE Name='Speaker Invite Custom'];

        EmailTemplate virtualTemplate = [SELECT Id, HtmlValue, Body  FROM EmailTemplate WHERE Name='Speaker Invite Virtual'];

        for(Session_Speaker__c speaker : scope){
            Datetime sessionStartDate = Datetime.newInstance(speaker.Session__r.Date__c, speaker.Session__r.Start_Time__c);
            Datetime sessionEndDate = Datetime.newInstance(speaker.Session__r.Date__c, speaker.Session__r.End_Time__c);

            String speakerName = speaker.Speaker__r.Salutation!=null?speaker.Speaker__r.Salutation + ' ':'';
            speakerName += speaker.Speaker__r.FirstName + ' ' + speaker.Speaker__r.LastName;

            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();

            String body = emailTemplate.HtmlValue;
            if(speaker.Session__r.Event__r.Venue__c==null){
                System.debug('use virtual template...');
                body = virtualTemplate.HtmlValue;
            }

            String eventDates = '';
            if(!speaker.Session__r.Event__r.Hide_Date_Time__c){
                if(speaker.Session__r.Event__r.End_Date__c!=null){
                    eventDates = speaker.Session__r.Event__r.Start_Date__c.formatLong() + ' - ' +  speaker.Session__r.Event__r.End_Date__c.formatLong() + ',';
                }
            }

            body = body.replace('{!recipientName}', speakerName)
                    .replace('{!chairString}', chairString!=null?chairString:'')
//                    .replace('{!coChairs}', cochairString!=null?cochairString:'')
                    .replace('{!draftLink}', speaker.Session__r.Event__r.Draft_Program__c!=null?'A preliminary program of session topics can be found <a href=\"' + speaker.Session__r.Event__r.Draft_Program__c + '\" target="_blank">here</a>.':'')
                    .replace('{!signature1}', speaker.Session__r.Event__r.Signature_1__c!=null?speaker.Session__r.Event__r.Signature_1__c:'')
                    .replace('{!signature2}', speaker.Session__r.Event__r.Signature_2__c!=null?speaker.Session__r.Event__r.Signature_2__c:'')
                    .replace('{!signature3}', speaker.Session__r.Event__r.Signature_3__c!=null?speaker.Session__r.Event__r.Signature_3__c:'')
                    .replace('{!signature4}', speaker.Session__r.Event__r.Signature_4__c!=null?speaker.Session__r.Event__r.Signature_4__c:'')
                    .replace('{!signature5}', speaker.Session__r.Event__r.Signature_5__c!=null?speaker.Session__r.Event__r.Signature_5__c:'')
                    .replace('{!signature6}', speaker.Session__r.Event__r.Signature_6__c!=null?speaker.Session__r.Event__r.Signature_6__c:'')
                    .replace('{!eventDates}', eventDates)
                    .replace('{!sessionDate}', speaker.Session__r.Date__c.format())
                    .replace('{!venue}', speaker.Session__r.Event__r.Venue__c!=null?speaker.Session__r.Event__r.Venue__r.Name:'')
                    .replace('{!venueLocation}', speaker.Session__r.Event__r.Venue__c!=null?speaker.Session__r.Event__r.Venue__r.City__c + ', ' + speaker.Session__r.Event__r.Venue__r.State__c:'')
                    .replace('{!sessionTime}', sessionStartDate.format('hh:mm a') + ' - ' + sessionEndDate.format('hh:mm a'))
                    .replace('{!presentationName}', speaker.Session__r.Name)
                    .replace('{!eventName}', speaker.Session__r.Event__r.Name)
                    .replace('{!imgLocation}', SpeakerInviteHelper.getDocumentRelativeLink(speaker.Session__r.Event__r.Invite_Image_Id__c)!=null?SpeakerInviteHelper.getDocumentRelativeLink(speaker.Session__r.Event__r.Invite_Image_Id__c):'')
                    .replace('{!inviteMessage}', speaker.Session__r.Event__r.Invite_Message__c!=null?speaker.Session__r.Event__r.Invite_Message__c:'')
                    .replace('{!speakerId}', speaker.Id);
            email.setHtmlBody(body);
            email.setTargetObjectId(speaker.Speaker__c);

            if(speaker.Session__r.Event__r.Venue__c==null){
                email.setTemplateId(virtualTemplate.Id);
            } else {
                email.setTemplateId(emailTemplate.Id);
            }

            email.setOrgWideEmailAddressId(owa.Id);
            email.setWhatId(speaker.Session__r.Event__c);
            email.setSaveAsActivity(false);
            email.setSubject('You\'ve Been Invited to Speak at ' + speaker.Session__r.Event__r.Name);
//            email.setReplyTo(speaker.Session__r.Event__r.Reply_To__c);
//            email.setSenderDisplayName('American Association For Cancer Research');
            email.setToAddresses(new List<String>{speaker.Speaker__r.Email});
            if(speaker.cc_assistant__c && speaker.Assistant__c!=null) {
                email.setCcAddresses(new List<String>{
                        speaker.Assistant__r.Email
                });
            }
            emails.add(email);

            //set speaker status's
            speaker.Status__c = 'Invited';
            speaker.cc_assistant__c = false;
            toUpdate.add(speaker);
        }

        System.debug('emails to send: ' + emails.size());
        System.debug('contacts to update: ' + toUpdate.size());

        if (!emails.isEmpty()) {
            try {
                Messaging.sendEmail(emails);
            } catch (EmailException ex) {
                System.debug(ex.getMessage());
                throw new AACRCustomException(ex.getMessage(), ex.getStackTraceString(), 'Email: Speaker Invitations');
            }
        }
    }

    global void finish(Database.BatchableContext BC){
        System.debug('finishing Batch_SpeakerInviteEmail...');
        try {
            update toUpdate;
        } catch(Exception e){
            System.debug('Could not update speaker records with invited status: ' + e.getMessage());
            throw new AACRCustomException(e.getMessage(), e.getStackTraceString(), 'Batch: Speaker Invitations');
        }
    }
}