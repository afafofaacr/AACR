/**
 * Created by lauren.lezberg on 9/3/2019.
 */

/**
 * @purpose Error handler
 */
public without sharing class ErrorHelper {


    public static AACR_Error_Log__c buildErrorLog(Contact con, String incidentId, String incidentType, String description){
        AACR_Error_Log__c eLog = new AACR_Error_Log__c();
        eLog.Contact__c = con.Id;
        eLog.Contact_Name__c = con.Name;
        eLog.Contact_Phone__c = con.OrderApi__Preferred_Phone__c;
        eLog.Contact_Email__c = con.OrderApi__Preferred_Email__c;
        eLog.Affiliation__c = con.AccountId;
        eLog.Incident_Type__c = incidentType;
        eLog.Incident_Id__c = incidentId;
        eLog.Issue_Description__c = description;

        return eLog;

    }

    public static void sendExceptionEmail(String category,String errorMsg, String stackTraceString){


        //create error log
        AACR_Error_Log__c eLog = createSNErrorException(null, errorMsg, stackTraceString);

        List<Messaging.SingleEmailMessage> messages = new List<Messaging.SingleEmailMessage>();

        Messaging.SingleEmailMessage msg = new Messaging.SingleEmailMessage();
        msg.setSubject('Apex Error: ' + category);
        String body = '<p>User: ' + UserInfo.getUserId() + '</p>';
        body += '<p>Error Msg: ' + errorMsg + '</p>';
        body += '<p>Stack Trace: ' + stackTraceString + '</p>';
        body += '<p>Error Log Id: ' + eLog.Id + '</p>';
        msg.setHtmlBody(body);
        msg.setToAddresses(new List<String>{Label.Platform_Alert_Email});

        messages.add(msg);

        Messaging.sendEmail(messages);


    }

    /**
     * @purpose Creates exception error log and sends exception email
     *
     * @param category
     * @param errorMsg
     * @param stackTraceString
     */
    public static void sendExceptionEmail(String logId, String category,String errorMsg, String stackTraceString){
        User targetUser = [SELECT Id FROM User WHERE Email=:Label.Platform_Alert_Email LIMIT 1];

        List<Messaging.SingleEmailMessage> messages = new List<Messaging.SingleEmailMessage>();

        Messaging.SingleEmailMessage msg = new Messaging.SingleEmailMessage();
        msg.setSubject('Apex Error: ' + category);
        String body = '<p>User: ' + UserInfo.getUserId() + '</p>';
        body += '<p>Error Msg: ' + errorMsg + '</p>';
        body += '<p>Stack Trace: ' + stackTraceString + '</p>';
        body += '<p>Error Log Id: ' + logId + '</p>';
        msg.setHtmlBody(body);
//        msg.setToAddresses(new List<String>{Label.Platform_Alert_Email});
        msg.setTargetObjectId(targetUser.Id);
        msg.setTreatTargetObjectAsRecipient(true);
        msg.setSaveAsActivity(false);

        messages.add(msg);

        Messaging.sendEmail(messages);

     }

    public static void sendExceptionEmail(String recordId, String logId, String category,String errorMsg, String stackTraceString){
        User targetUser = [SELECT Id FROM User WHERE Email=:Label.Platform_Alert_Email LIMIT 1];

        List<Messaging.SingleEmailMessage> messages = new List<Messaging.SingleEmailMessage>();

        Messaging.SingleEmailMessage msg = new Messaging.SingleEmailMessage();
        msg.setSubject('Apex Error: ' + category);
        String body = '<p>User: ' + UserInfo.getUserId() + '</p>';
        body += '<p>RecordID: ' + recordId + '</p>';
        body += '<p>Error Msg: ' + errorMsg + '</p>';
        body += '<p>Stack Trace: ' + stackTraceString + '</p>';
        body += '<p>Error Log Id: ' + logId + '</p>';
        msg.setHtmlBody(body);
//        msg.setToAddresses(new List<String>{Label.Platform_Alert_Email});
        msg.setTargetObjectId(targetUser.Id);
        msg.setTreatTargetObjectAsRecipient(true);
        msg.setSaveAsActivity(false);

        messages.add(msg);

        Messaging.sendEmail(messages);

    }


    /**
     * @purpose Sends a request serviceNow Email with error log details
     * Update: 8-19-2021: No longer creating email to serviceNow. We are now calling serviceNow API and creating the case directly.
     *
     * @param contactId
     * @param logId
     * @param attachmentId
     */
    public static void sendServiceNowRequestEmail(Id contactId, Id logId, Id attachmentId) {

        try {
            ServiceNowIntegration.sendSNCase(logId, attachmentId);
        }catch(Exception e){
            System.debug('Error creating case in Service Now' + e.getMessage() + ' ' + e.getStackTraceString());
            ErrorHelper.createSNErrorException(contactId, e.getMessage(), e.getStackTraceString());
        }

//        try {
//            String incidentId = [SELECT Incident_Id__c FROM AACR_Error_Log__c WHERE Id = :logId].Incident_Id__c;
//            String recipientEmail = [SELECT Email_Recipient__c FROM ServiceNow_Incident_Type__mdt WHERE Id = :incidentId].Email_Recipient__c;
//            EmailTemplate et = [Select Id from EmailTemplate where Name = 'ServiceNow_Request_HTML'];
//
//            sendSNEmail(contactId, logId, attachmentId, new List<String>{recipientEmail.trim()}, et.Id);
//
//        } catch (Exception e) {
//            System.debug('Error sending email' + e.getMessage() + ' ' + e.getStackTraceString());
//            ErrorHelper.createSNErrorException(contactId, e.getMessage(), e.getStackTraceString());
//        }
    }

    /**
 * @purpose Sends a request serviceNow Email with error log details
 *
 * @param contactId
 * @param logId
 * @param attachmentId
 */
    public static void sendServiceNowRequestEmail(Id contactId, Id logId, Id attachmentId, String subject) {
        try {
            String incidentId = [SELECT Incident_Id__c FROM AACR_Error_Log__c WHERE Id = :logId].Incident_Id__c;
            String recipientEmail = [SELECT Email_Recipient__c FROM ServiceNow_Incident_Type__mdt WHERE Id = :incidentId].Email_Recipient__c;
            EmailTemplate et = [Select Id from EmailTemplate where Name = 'ServiceNow_Request_HTML'];

            sendSNEmail(contactId, logId, attachmentId, new List<String>{recipientEmail.trim()}, et.Id, subject);

        } catch (Exception e) {
            System.debug('Error sending email' + e.getMessage() + ' ' + e.getStackTraceString());
            ErrorHelper.createSNErrorException(contactId, e.getMessage(), e.getStackTraceString());
        }
    }

//    public static void sendServiceNowExceptionEmail(Id logId, Id userId, Id emailTemplateId, String toAddress){
//        EmailTemplate emailTemplate = [SELECT Id, HtmlValue, Body, Subject FROM EmailTemplate WHERE Id=:emailTemplateId];
//
//        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
//
//        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
//        Id targetId = UserInfo.getUserId();
//        System.debug('targetId: ' + targetId);
//
//        AACR_Error_Log__c log = [SELECT Issue_Description__c, URL__c, CreatedDate, Contact_Name__c, Contact_Email__c, Contact_Phone__c, Contact_Method__c, Contact__c, Contact__r.Name, Contact__r.AACR_ID__c, Contact__r.Member_Type__c, Affiliation__c, Incident_Type__c, Incident_Id__c, Name FROM AACR_Error_Log__c WHERE Id = :logId];
//
//        if (targetId != null) {
//
//            String plainBody = emailTemplate.Body;
//            plainBody = plainBody.replace('{!dateTime}', log.CreatedDate.format())
//                    .replace('{!userName}', log.Contact_Name__c != null ? log.Contact_Name__c: '')
//                    .replace('{!email}', log.Contact_Email__c!=null?log.Contact_Email__c:'')
//                    .replace('{!phone}', log.Contact_Phone__c != null ? log.Contact_Phone__c : '')
//                    .replace('{!contactMethod}', log.Contact_Method__c != null ? log.Contact_Method__c:'')
//                    .replace('{!aacrID}', log.Contact__c != null ? log.Contact__r.AACR_ID__c : '')
//                    .replace('{!memberType}', log.Contact__r.Member_Type__c  != null ? log.Contact__r.Member_Type__c : '')
//                    .replace('{!account}', log.Affiliation__c != null ? log.Affiliation__c : '')
//                    .replace('{!url}', log.URL__c!=null?log.URL__c:'')
//                    .replace('{!incidentType}', log.Incident_Type__c!=null?log.Incident_Type__c:'')
//                    .replace('{!description}', log.Issue_Description__c!=null?log.Issue_Description__c:'')
//                    .replace('{!logName}', log.Name!=null?log.Name:'');
//
//            email.setPlainTextBody(plainBody);
//            email.setToAddresses(new List<String>{toAddress});
////            email.setTargetObjectId(targetId);
//            email.setTemplateId(emailTemplate.Id);
//            email.setSubject(emailTemplate.Subject);
//            email.setSaveAsActivity(false);
//
//            emails.add(email);
//
//            if (!emails.isEmpty()) {
//                try {
//                    Messaging.sendEmail(emails);
//                } catch (EmailException ex) {
//                    System.debug('error sending email: ' + ex.getMessage());
//
//                }
//            }
//        }
//
//    }




    /**
     * Sends a ServiceNow email of specified type
     *
     * @param contactId
     * @param logId
     * @param attachmentId
     * @param to
     * @param emailTemplateId
     */
    @TestVisible
    private static void sendSNEmail(Id contactId, Id logId, Id attachmentId, List<String> to, Id emailTemplateId) {
        System.debug('sendSNEmail...');
        EmailTemplate emailTemplate = [SELECT Id, HtmlValue, Body, Subject FROM EmailTemplate WHERE Id=:emailTemplateId];

        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();

        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        Id targetId = UserInfo.getUserId();
        System.debug('targetId: ' + targetId);

        AACR_Error_Log__c log = [SELECT Issue_Description__c, URL__c, CreatedDate, Contact_Name__c, Contact_Email__c, Contact_Phone__c, Contact_Method__c, Contact__c, Contact__r.Name, Contact__r.AACR_ID__c, Contact__r.Member_Type__c, Affiliation__c, Incident_Type__c, Incident_Id__c, Name FROM AACR_Error_Log__c WHERE Id = :logId];

        String contactURL;
        if(contactId!=null){
            String url = System.URL.getOrgDomainURL().gethost();

            String rURL = url.removeEndIgnoreCase('.my.salesforce.com');

            url = rURL + '.lightning.force.com/lightning/r/Contact/' + contactId + '/view';

            contactURL = 'https://' + url;
        }

        if (targetId != null) {

            String plainBody = emailTemplate.Body;
            plainBody = plainBody.replace('{!dateTime}', log.CreatedDate.format())
                    .replace('{!userName}', log.Contact_Name__c != null ? log.Contact_Name__c: '')
                    .replace('{!email}', log.Contact_Email__c!=null?log.Contact_Email__c:'')
                    .replace('{!phone}', log.Contact_Phone__c != null ? log.Contact_Phone__c : '')
                    .replace('{!contactMethod}', log.Contact_Method__c != null ? log.Contact_Method__c:'')
                    .replace('{!aacrID}', log.Contact__c != null ? log.Contact__r.AACR_ID__c : '')
                    .replace('{!memberType}', log.Contact__r.Member_Type__c  != null ? log.Contact__r.Member_Type__c : '')
                    .replace('{!account}', log.Affiliation__c != null ? log.Affiliation__c : '')
                    .replace('{!url}', log.URL__c!=null?log.URL__c:'')
                    .replace('{!incidentType}', log.Incident_Type__c!=null?log.Incident_Type__c:'')
                    .replace('{!description}', log.Issue_Description__c!=null?log.Issue_Description__c:'')
                    .replace('{!logName}', log.Name!=null?log.Name:'')
                    .replace('{!contactURL}', contactId!=null?contactURL:'');

            email.setPlainTextBody(plainBody);
            email.setToAddresses(to);
//            email.setTargetObjectId(targetId);
            email.setTemplateId(emailTemplate.Id);
            email.setSubject(emailTemplate.Subject);
            email.setSaveAsActivity(false);

            if (attachmentId != null) {
                email.setEntityAttachments(new List<String>{
                        attachmentId
                });
            }

            emails.add(email);

            if (!emails.isEmpty()) {
                try {
                    Messaging.sendEmail(emails);
                } catch (EmailException ex) {
                    System.debug('error sending email: ' + ex.getMessage());
                }
            }
        }
    }

    /**
     *
     * Sends a ServiceNow email of specified type with custom subject
     *
     * @param contactId
     * @param logId
     * @param attachmentId
     * @param to
     * @param emailTemplateId
     * @param subject
     */
    @TestVisible
    private static void sendSNEmail(Id contactId, Id logId, Id attachmentId, List<String> to, Id emailTemplateId, String subject) {
        System.debug('sendSNEmail...');
        EmailTemplate emailTemplate = [SELECT Id, HtmlValue, Body, Subject FROM EmailTemplate WHERE Id=:emailTemplateId];

        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();

        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        Id targetId = UserInfo.getUserId();
        System.debug('targetId: ' + targetId);

        AACR_Error_Log__c log = [SELECT Issue_Description__c, URL__c, CreatedDate, Contact_Name__c, Contact_Email__c, Contact_Phone__c, Contact_Method__c, Contact__c, Contact__r.Name, Contact__r.AACR_ID__c, Contact__r.Member_Type__c, Affiliation__c, Incident_Type__c, Incident_Id__c, Name FROM AACR_Error_Log__c WHERE Id = :logId];

        String contactURL;
        if(contactId!=null){
            String url = System.URL.getOrgDomainURL().gethost();

            String rURL = url.removeEndIgnoreCase('.my.salesforce.com');

            url = rURL + '.lightning.force.com/lightning/r/Contact/' + contactId + '/view';

            contactURL = 'https://' + url;
        }

        if (targetId != null) {

            String plainBody = emailTemplate.Body;
            plainBody = plainBody.replace('{!dateTime}', log.CreatedDate.format())
                    .replace('{!userName}', log.Contact_Name__c != null ? log.Contact_Name__c: '')
                    .replace('{!email}', log.Contact_Email__c!=null?log.Contact_Email__c:'')
                    .replace('{!phone}', log.Contact_Phone__c != null ? log.Contact_Phone__c : '')
                    .replace('{!contactMethod}', log.Contact_Method__c != null ? log.Contact_Method__c:'')
                    .replace('{!aacrID}', log.Contact__c != null ? log.Contact__r.AACR_ID__c : '')
                    .replace('{!memberType}', log.Contact__r.Member_Type__c  != null ? log.Contact__r.Member_Type__c : '')
                    .replace('{!account}', log.Affiliation__c != null ? log.Affiliation__c : '')
                    .replace('{!url}', log.URL__c!=null?log.URL__c:'')
                    .replace('{!incidentType}', log.Incident_Type__c!=null?log.Incident_Type__c:'')
                    .replace('{!description}', log.Issue_Description__c!=null?log.Issue_Description__c:'')
                    .replace('{!logName}', log.Name!=null?log.Name:'')
                    .replace('{!contactURL}', contactId!=null?contactURL:'');

            email.setPlainTextBody(plainBody);
            email.setToAddresses(to);
//            email.setTargetObjectId(targetId);
            email.setTemplateId(emailTemplate.Id);
            email.setSubject(subject);
            email.setSaveAsActivity(false);

            if (attachmentId != null) {
                email.setEntityAttachments(new List<String>{
                        attachmentId
                });
            }

            emails.add(email);

            if (!emails.isEmpty()) {
                try {
                    Messaging.sendEmail(emails);
                } catch (EmailException ex) {
                    System.debug('error sending email: ' + ex.getMessage());
                }
            }
        }
    }


    /**
     * @purpose builds general error exception log
     *
     * @param errorMsg
     * @param stackTrace
     *
     * @return error log record
     */
    @TestVisible
    public static AACR_Error_Log__c buildErrorExceptionLog(String errorMsg, String stackTrace){
        Id recordTypeId = Schema.SObjectType.AACR_Error_Log__c.getRecordTypeInfosByName().get('Error Exception').getRecordTypeId();

        AACR_Error_Log__c newLog = new AACR_Error_Log__c();
        newLog.Issue_Description__c = 'Apex Error Exception';
        newLog.Error_Message__c = errorMsg;
        newLog.Stack_Trace__c = stackTrace;
        newLog.RecordTypeId = recordTypeId;

        return newLog;
    }

    /**
    * @purpose Creates a SN_Error_Log__c record with an exception record type and inserts into system
    *
    * @param contactId
    * @param errorMessage
    * @param stackTrace
    *
    * @return
    */
    private static AACR_Error_Log__c createSNErrorException(Id contactId, String errorMessage, String stackTrace) {
        Id recordTypeId = [Select Id From RecordType where sobjecttype = 'AACR_Error_Log__c' and Name = 'Error Exception'].Id;
        AACR_Error_Log__c newLog = new AACR_Error_Log__c();
        newLog.Issue_Type__c = 'Other';
        newLog.Issue_Description__c = 'Error Exception';
        newLog.Contact__c = contactId;
        newLog.Error_Message__c = errorMessage;
        newLog.Stack_Trace__c = stackTrace;
        newLog.RecordTypeId = recordTypeId;
        insert newLog;

        return newLog;
    }

    /**
      * @purpose Sends an exception ServiceNow email with error log details
      *
      * @param contactId
      * @param logId
      */
//    public static void sendServiceNowExceptionEmail(Id contactId, Id logId){
//        EmailTemplate et = [Select Id from EmailTemplate where Name = 'ServiceNow Exception'];
//        sendServiceNowEmail(contactId, logId, null, new List<String>{System.Label.ServiceNow_Recipient_Email}, et.Id);
//
//    }

/**
     * @purpose Creates an exception service now error log and sends exception email detailing error log
     *
     * @param contactId
     * @param errorMessage
     * @param stackTrace
     */
//    public static void createServiceNowError(Id contactId, String errorMessage, String stackTrace){
//        AACR_Error_Log__c newLog = createSNExceptionError(contactId, errorMessage, stackTrace);
//        sendServiceNowExceptionEmail(contactId, newLog.Id);
//    }


    /**
     * @purpose Creates an exception service now error log
     *
     * @param contactId
     * @param errorMessage
     * @param stackTrace
     *
     * @return SN_Error_Log__c
     */
//    public static AACR_Error_Log__c createSNExceptionError(Id contactId, String errorMessage, String stackTrace){
//        return createSNErrorException(contactId, errorMessage, stackTrace);
//    }

}