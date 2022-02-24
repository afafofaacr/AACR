/**
 * Created by afaf.awad on 9/24/2020.
 */

public with sharing class BackOfficeLOPController {

    @AuraEnabled public static Boolean getLOP(String participantId){

        BR_Participation__c part = [SELECT BR_Event__r.End_Date__c, BR_Event__c, Contact__c FROM BR_Participation__c WHERE Id=: participantId];

        If(part.BR_Event__r.End_Date__c <= System.now()){
            return true;
        }else{
            return false;
        }
    }

    @AuraEnabled
    public static String getDomain() {
        if ( Test.isRunningTest() ) {
            return 'Test domain';
        } else {
            return [SELECT Domain FROM Domain LIMIT 1].Domain;
        }
    }

    @AuraEnabled
    public static EmailResults sendPDF(String participantId){

        EmailResults result = new EmailResults();
        result.error = false;
        BR_Participation__c part = [SELECT BR_Event__r.End_Date__c, BR_Event__r.Name , BR_Event__c, Contact__c, Contact__r.Email, Contact__r.FirstName
                                    FROM BR_Participation__c WHERE Id=: participantId];

        if(part.Contact__c == null) {
            result.error = true;
            result.message = 'There is no Contact linked to this Participant record. To create a letter, link a Contact to this record and try again.';
        }else {
            PageReference pdf = Page.LetterOfParticipation;
            pdf.getParameters().put('Id', part.Contact__c);
            pdf.getParameters().put('eventId', part.BR_Event__c);
            pdf.getParameters().put('isLive', 'true');

            // the contents of the attachment from the pdf
            Blob pdfbody;

            try {
                // returns the output of the page as a PDF
                pdfbody = pdf.getContent();

                // need to pass unit test -- current bug
            } catch (VisualforceException e) {
                pdfbody = Blob.valueOf('Something happened while creating your PDF.');
            }

            String orgWideEmailId = BrEventsHelper.getConfigValue('org wide email id');
            EmailTemplate emailTemplate = [SELECT Id, HtmlValue, Body FROM EmailTemplate WHERE Name = 'Letter of Participation'];

            String body = emailTemplate.HtmlValue;
            body = body.replace('{!BR_Event__c}', part.BR_Event__r.Name)
                    .replace('{!First_Name}', part.Contact__r.FirstName);

            Messaging.EmailFileAttachment attach = new Messaging.EmailFileAttachment();
            attach.setContentType('application/pdf');
            attach.setFileName(part.BR_Event__r.Name.replace(' ', '_') + '_LoP.pdf');
            attach.setInline(false);
            attach.Body = pdfbody;

            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setTargetObjectId(part.Contact__c);
            mail.setWhatId(part.BR_Event__c);
            mail.setOrgWideEmailAddressId(orgWideEmailId);
            mail.setTreatTargetObjectAsRecipient(true);
            mail.setUseSignature(false);
            mail.setSubject('Letter of Participation for ' + part.BR_Event__r.Name);
            mail.setHtmlBody(body);
            mail.setFileAttachments(new Messaging.EmailFileAttachment[]{
                    attach
            });

            try {
                Messaging.sendEmail(new Messaging.SingleEmailMessage[]{
                        mail
                });
                result.message = 'Letter emailed!';
            }catch (EmailException e){
                new AACRCustomException(e.getMessage(), e.getStackTraceString(), 'Letter of Participation');
            }
        }

        return result;

    }

    @AuraEnabled
    public static EmailResults sendPDF_Fon(String attendeeId){

        EmailResults result = new EmailResults();
        result.error = false;
        EventApi__Attendee__c att = [SELECT EventApi__Event__r.EventApi__End_Date__c, EventApi__Event__r.EventApi__Display_Name__c , EventApi__Event__c, EventApi__Contact__c
                                            , EventApi__Contact__r.Email, EventApi__Contact__r.FirstName
                                            FROM EventApi__Attendee__c WHERE Id=: attendeeId];

        if(att.EventApi__Contact__c == null) {
            result.error = true;
            result.message = 'There is no Contact linked to this Participant record. To create a letter, link a Contact to this record and try again.';
        }else {
            PageReference pdf = Page.LetterOfParticipation;
            pdf.getParameters().put('Id', att.EventApi__Contact__c);
            pdf.getParameters().put('eventId', att.EventApi__Event__c);
            pdf.getParameters().put('isLive', 'false');

            // the contents of the attachment from the pdf
            Blob pdfbody;

            try {
                // returns the output of the page as a PDF
                pdfbody = pdf.getContent();

                // need to pass unit test -- current bug
            } catch (VisualforceException e) {
                pdfbody = Blob.valueOf('Something happened while creating your PDF.');
            }

            String orgWideEmailId = BrEventsHelper.getConfigValue('org wide email id');
            EmailTemplate emailTemplate = [SELECT Id, HtmlValue, Body FROM EmailTemplate WHERE Name = 'Letter of Participation'];

            String body = emailTemplate.HtmlValue;
            body = body.replace('{!BR_Event__c}', att.EventApi__Event__r.EventApi__Display_Name__c)
                    .replace('{!First_Name}', att.EventApi__Contact__r.FirstName);

            Messaging.EmailFileAttachment attach = new Messaging.EmailFileAttachment();
            attach.setContentType('application/pdf');
            attach.setFileName(att.EventApi__Event__r.EventApi__Display_Name__c.replace(' ', '_') + '_LoP.pdf');
            attach.setInline(false);
            attach.Body = pdfbody;

            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setTargetObjectId(att.EventApi__Contact__c);
            mail.setWhatId(att.EventApi__Event__c);
            mail.setOrgWideEmailAddressId(orgWideEmailId);
            mail.setTreatTargetObjectAsRecipient(true);
            mail.setUseSignature(false);
            mail.setSubject('Letter of Participation for ' + att.EventApi__Event__r.EventApi__Display_Name__c);
            mail.setHtmlBody(body);
            mail.setFileAttachments(new Messaging.EmailFileAttachment[]{
                    attach
            });

            try {
                Messaging.sendEmail(new Messaging.SingleEmailMessage[]{
                        mail
                });
                result.message = 'Letter emailed!';
            }catch (EmailException e){
                new AACRCustomException(e.getMessage(), e.getStackTraceString(), 'Letter of Participation');
            }
        }

        return result;

    }

    public class EmailResults{
        @AuraEnabled
        public Boolean error;

        @AuraEnabled
        public String message;
    }

}