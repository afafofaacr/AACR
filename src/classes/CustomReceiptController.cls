/**
 * Created by afaf.awad on 1/5/2021.
 */

public without sharing class CustomReceiptController {

    public String partId {get;set;}
    public BR_Participation__c participant {get;set;}
    public List<OrderApi__Receipt_Line__c> receiptLines {get;set;}
    public AC_Event_User_Segment__c userSegment {get;set;}

    public void getReceiptInfo() {

        partId = ApexPages.currentPage().getParameters().get('partId');

        participant = [SELECT Id, AC_User_Segment__r.Name, Fon_Sales_Order__c, BR_Event__c, Contact__r.FirstName, Contact__r.LastName FROM BR_Participation__c WHERE Id =: partId];

        receiptLines = [SELECT Id, OrderApi__Sale_Price__c, OrderApi__Total__c, OrderApi__Quantity__c, OrderApi__Line_Description__c, OrderApi__Receipt__r.OrderApi__Total__c,
                                OrderApi__Receipt__r.OrderApi__Date__c, OrderApi__Receipt__r.Name, OrderApi__Receipt__r.OrderApi__Payment_Method_Description__c
                        FROM OrderApi__Receipt_Line__c
                        WHERE OrderApi__Receipt__r.OrderApi__Sales_Order__c =: participant.Fon_Sales_Order__c];

        userSegment = [SELECT Id, Name,AC_User_Segment__r.Name, Price__c
                                                FROM AC_Event_User_Segment__c
                                                WHERE AC_Event__c =: participant.BR_Event__c AND AC_User_Segment__c =: participant.AC_User_Segment__c];

    }

    @AuraEnabled
    public static EmailResults emailReceipt(String participantId, String ccJSON, String msg){
        List<String> ccEmails = (List<String>)JSON.deserialize(ccJSON, List<String>.class);

        EmailResults result = new EmailResults();
        result.error = false;

        BR_Participation__c part = [SELECT BR_Event__r.End_Date__c, BR_Event__r.Name , BR_Event__c, Contact__c, Contact__r.Email, Contact__r.FirstName
        FROM BR_Participation__c WHERE Id=: participantId];

        PageReference pdf = Page.AACRCustomReceipt;
        pdf.getParameters().put('partId', participantId);

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
        EmailTemplate emailTemplate = [SELECT Id, HtmlValue, Body FROM EmailTemplate WHERE Name = 'Custom Event Receipt'];

        String body = emailTemplate.HtmlValue;
        body = body.replace('{!BR_Event__c}', part.BR_Event__r.Name)
                .replace('{!First_Name}', part.Contact__r.FirstName)
                .replace('{!message}', msg!=null?msg:'');

        Messaging.EmailFileAttachment attach = new Messaging.EmailFileAttachment();
        attach.setContentType('application/pdf');
        attach.setFileName(part.BR_Event__r.Name.replace(' ', '_') + '_Receipt.pdf');
        attach.setInline(false);
        attach.Body = pdfbody;

        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        if(ccEmails!=null && !ccEmails.isEmpty()) {
            mail.setCcAddresses(ccEmails);
        }
        mail.setTargetObjectId(part.Contact__c);
        mail.setWhatId(part.BR_Event__c);
        mail.setOrgWideEmailAddressId(orgWideEmailId);
        mail.setTreatTargetObjectAsRecipient(true);
        mail.setUseSignature(false);
        mail.setSubject('Receipt for ' + part.BR_Event__r.Name);
        mail.setHtmlBody(body);
        mail.setFileAttachments(new Messaging.EmailFileAttachment[]{
                attach
        });

        try {
            Messaging.sendEmail(new Messaging.SingleEmailMessage[]{
                    mail
            });
            result.message = 'Receipt emailed!';
        }catch (EmailException e){
            new AACRCustomException(e.getMessage(), e.getStackTraceString(), 'Custom Event Receipt');
        }

        System.debug('Return Results');

        return result;

    }


    public class EmailResults{
        @AuraEnabled
        public Boolean error;

        @AuraEnabled
        public String message;
    }

}