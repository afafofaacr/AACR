/**
 * Created by afaf.awad on 4/14/2021.
 */

public without sharing class CustomInvoiceController {

    public String soId {get;set;}
    public List<OrderApi__Sales_Order_Line__c> soLines {get;set;}

    public void getSalesInfo() {

        soId = ApexPages.currentPage().getParameters().get('soId');

        soLines = [SELECT Id, OrderApi__Sale_Price__c, OrderApi__List_Price__c, OrderApi__Line_Description__c, OrderApi__Quantity__c, OrderApi__Total__c,
                OrderApi__Sales_Order__r.OrderApi__Total__c, OrderApi__Sales_Order__r.OrderApi__Subtotal__c, OrderApi__Sales_Order__r.OrderApi__Date__c,
                OrderApi__Sales_Order__r.Name, OrderApi__Sales_Order__r.OrderApi__Contact__r.FirstName, OrderApi__Sales_Order__r.OrderApi__Contact__r.LastName
                FROM OrderApi__Sales_Order_Line__c WHERE OrderApi__Sales_Order__c =: soId];

    }

    @AuraEnabled
    public static Boolean emailReceipt(String salesOrderId){

        Member_Count__c memberCount  = [SELECT Count__c FROM Member_Count__c];

        OrderApi__Sales_Order__c salesOrder = [SELECT Id, OrderApi__Contact__c, OrderApi__Contact__r.FirstName, OrderApi__Contact__r.LastName,
                OrderApi__Contact__r.Salutation, OrderApi__Contact__r.DonorApi__Suffix__c,OrderApi__Contact__r.Member_Type__c, OrderApi__Contact__r.AACR_ID__c
        FROM OrderApi__Sales_Order__c WHERE Id =: salesOrderId];
        //get membership lines
        List<OrderApi__Sales_Order_Line__c> membershipLines = [SELECT Id, OrderApi__Item__r.Name
                                                                FROM OrderApi__Sales_Order_Line__c
                                                                WHERE OrderApi__Item_Class__r.Name='Individual Memberships'
                                                                AND OrderApi__Sales_Order__c=:salesOrder.Id];
//
//        PageReference pdf = Page.AACRCustomInvoice;
//        pdf.getParameters().put('soId', salesOrderId);
//
//        // the contents of the attachment from the pdf
//        Blob pdfbody;
//
//        try {
//            // returns the output of the page as a PDF
//            pdfbody = pdf.getContent();
//
//            // need to pass unit test -- current bug
//        } catch (VisualforceException e) {
//            pdfbody = Blob.valueOf('Something went wrong while creating your PDF. Please contact AACR (215)440-9300. ');
//        }

//        Messaging.EmailFileAttachment attach = new Messaging.EmailFileAttachment();
//        attach.setContentType('application/pdf');
//        attach.setFileName('Membership_Invoice.pdf');
//        attach.setInline(false);
//        attach.Body = pdfbody;

        String orgWideEmailId = [SELECT Id FROM OrgWideEmailAddress WHERE DisplayName = 'AACR Membership'].Id;
        EmailTemplate emailTemplate = [SELECT Id, HtmlValue, Body FROM EmailTemplate WHERE DeveloperName = 'Member_Welcome_Email_Transfer'];

        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        String body = emailTemplate.HtmlValue;
        body = body.replace('{!SalesOrderId}', salesOrderId)
                .replace('{!Contact.Salutation}', String.isBlank(salesOrder.OrderApi__Contact__r.Salutation) ? '' : salesOrder.OrderApi__Contact__r.Salutation)
                .replace('{!Contact.FirstName}', salesOrder.OrderApi__Contact__r.FirstName)
                .replace('{!Contact.LastName}', salesOrder.OrderApi__Contact__r.LastName)
                .replace('{!Contact.AACR_ID__c}', salesOrder.OrderApi__Contact__r.AACR_ID__c)
                .replace('{!Contact.DonorApi__Suffix__c}', String.isBlank(salesOrder.OrderApi__Contact__r.DonorApi__Suffix__c) ? '' : salesOrder.OrderApi__Contact__r.DonorApi__Suffix__c)
                .replace('{!Contact.Member_Type__c}', membershipLines.isEmpty()?salesOrder.OrderApi__Contact__r.Member_Type__c:membershipLines[0].OrderApi__Item__r.Name.remove('ship'))
                .replace('{!$Setup.Member_Count__c.Count__c}', memberCount.Count__c);

        mail.setTargetObjectId(salesOrder.OrderApi__Contact__c);
        mail.setOrgWideEmailAddressId(orgWideEmailId);
        mail.setTreatTargetObjectAsRecipient(true);
        mail.setUseSignature(false);
        mail.setSubject('Welcome to the AACR!');
        mail.setHtmlBody(body);
//        mail.setFileAttachments(new Messaging.EmailFileAttachment[]{
//                attach
//        });

        try {
            Messaging.sendEmail(new Messaging.SingleEmailMessage[]{
                    mail
            });
            return true;
        }catch (EmailException e){
            System.debug('error occurred: ' + e.getMessage());
            return false;
        }

    }

}