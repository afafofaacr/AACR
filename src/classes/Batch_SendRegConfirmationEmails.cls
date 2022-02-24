/**
 * Created by lauren.lezberg on 5/21/2020.
 */

global class Batch_SendRegConfirmationEmails implements Database.Batchable<sObject>, Database.Stateful{
//    public List<Id> attendees = new List<Id>();
    public String templateId;
    public Id eventId;
    public String taskSubject;

    public Batch_SendRegConfirmationEmails(Id evtId, String subj, String tempId) {
        this.eventId = evtId;
        this.taskSubject = subj;
        this.templateId = tempId;

    }

    global Database.Querylocator start(Database.BatchableContext bc) {
        String queryString = 'SELECT Id FROM Contact WHERE Id IN (SELECT EventApi__Contact__c FROM EventApi__Attendee__c WHERE EventApi__Event__c=: eventId)' ;
        System.debug('queryString: ' + queryString);

        return Database.getQueryLocator(queryString);
    }

    global void execute(Database.BatchableContext bc, List<Contact> scope) {
        Set<Id> contactIds = new Set<Id>();
        for(Contact con : scope){
            contactIds.add(con.Id);
        }

        Set<Id> contactsWithTask = new Set<Id>();
        List<Task> emailTasks = [SELECT WhoId FROM Task WHERE Subject=: taskSubject AND WhoId IN: contactIds];
        for(Task t : emailTasks){
            contactsWithTask.add(t.WhoId);
        }
        System.debug('execute method....');

        Set<Id> contactsWithoutTask = new Set<Id>();
        for(Contact con: scope){
            if(!contactsWithTask.contains(con.Id)) {
                contactsWithoutTask.add(con.Id);
            }
        }

        List<Task> contactTasks = new List<Task>();
        List<User> users = [SELECT Id, ContactId FROM User WHERE ContactId IN: contactsWithoutTask];
        List<Id> recipientIds = new List<Id>();
        for(User u: users){
            recipientIds.add(u.Id);
            Task t = new Task();
            t.Subject = 'Mass Email: Custom HTML for VAMII 2020 registration confirmation email';
            t.WhoId = u.ContactId;
            t.Status = 'Completed';
            t.Priority = 'Normal';
            contactTasks.add(t);
        }
        System.debug('recipientIds: ' + recipientIds);

        if(!recipientIds.isEmpty()) {
            List<Messaging.MassEmailMessage> messages = new List<Messaging.MassEmailMessage>();

            Messaging.MassEmailMessage email = new Messaging.MassEmailMessage();
            email.setSaveAsActivity(false);
            email.setTargetObjectIds(recipientIds);
            email.setTemplateId(templateId);
            email.setSenderDisplayName('American Association for Cancer Research');
            email.setReplyTo('myaacr@aacr.org');

            messages.add(email);


            try {
                List<Messaging.SendEmailResult> resultMail = Messaging.sendEmail(messages);

                insert contactTasks;

                for (Messaging.SendEmailResult result : resultMail) {
                    if (!result.isSuccess()) {
                        System.debug('errors: ' + result.getErrors());
                    }
                }

            } catch (exception e) {
                System.debug('Could not send emails: ' + e.getMessage());

            }
        } 
    }

//    global void execute(Database.BatchableContext bc, List<EventApi__Attendee__c> scope) {
//
//        Set<Id> contactsWithTask = new Set<Id>();
//        List<Task> emailTasks = [SELECT WhoId FROM Task WHERE Subject=: taskSubject];
//        for(Task t : emailTasks){
//            contactsWithTask.add(t.WhoId);
//        }
//        System.debug('execute method....');
//
//        List<Id> recipientIds = new List<Id>();
//        for(EventApi__Attendee__c att : scope){
//            if(!contactsWithTask.contains(att.EventApi__Contact__c)) {
//                recipientIds.add(att.EventApi__Contact__c);
//            }
//        }
//        System.debug('recipientIds: ' + recipientIds);
//
//        List<Messaging.MassEmailMessage> messages = new List<Messaging.MassEmailMessage>();
//
//        Messaging.MassEmailMessage email = new Messaging.MassEmailMessage();
//        email.setTargetObjectIds(recipientIds);
//        email.setTemplateId(templateId);
//        email.setSenderDisplayName('American Association for Cancer Research');
//        email.setReplyTo('myaacr@aacr.org');
//
//        messages.add(email);
//
//
//        try {
//            List<Messaging.SendEmailResult> resultMail = Messaging.sendEmail(messages);
//
//            for (Messaging.SendEmailResult result : resultMail) {
//                if (!result.isSuccess()) {
//                    System.debug('errors: ' + result.getErrors());
//                }
//            }
//
//        } catch (exception e) {
//            System.debug('Could not send emails: ' + e.getMessage());
//
//        }
//    }

    global void finish(Database.BatchableContext BC) {
        AsyncApexJob a = [
                SELECT Id, Status, NumberOfErrors, JobItemsProcessed,
                        TotalJobItems, CreatedBy.Email
                FROM AsyncApexJob
                WHERE Id =
                        :BC.getJobId()
        ];
        System.debug('job summary: ' + a);

        if (a.NumberOfErrors > 0) {
            String body = '<p>Job Summary: ' + a + '</p>';
            body += '<br/> <p>OrgId: ' + UserInfo.getOrganizationId() + '</p>';
            List<Messaging.SingleEmailMessage> errorMessages = new List<Messaging.SingleEmailMessage>();

            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            email.setHtmlBody(body);
            email.setToAddresses(new List<String>{
                    'platformalert@aacr.org'
            });
            email.setSubject('Batch_SendSingleEmailMessages Exception');
            email.setSenderDisplayName('American Association for Cancer Research');
            errorMessages.add(email);

            Messaging.sendEmail(errorMessages);

        }
    }

//    public Batch_SendRegConfirmationEmails(List<Id> attendeeIds, String tempId) {
//        attendees.addAll(attendeeIds);
//        templateId = tempId;
//    }
//
//    global Database.Querylocator start(Database.BatchableContext bc) {
//        System.debug('attendees : ' + attendees);
//        System.debug('templateId : ' + templateId);
//        String queryString = 'SELECT Id FROM Contact WHERE Id IN: attendees ' ;
//        System.debug('queryString: ' + queryString);
//
//        return Database.getQueryLocator(queryString);
//    }
//
//    global void execute(Database.BatchableContext bc, List<sObject> scope) {
//        System.debug('execute method....');
//
//        List<Id> recipientIds = new List<Id>();
//        for(sObject att : scope){
//            recipientIds.add(att.Id);
//        }
//        System.debug('recipientIds: ' + recipientIds);
//
//        List<Messaging.MassEmailMessage> messages = new List<Messaging.MassEmailMessage>();
//
//        Messaging.MassEmailMessage email = new Messaging.MassEmailMessage();
//        email.setTargetObjectIds(recipientIds);
//        email.setTemplateId(templateId);
//        email.setSenderDisplayName('American Association for Cancer Research');
//        email.setReplyTo('myaacr@aacr.org');
//
//        messages.add(email);
//
//
//        try {
//            List<Messaging.SendEmailResult> resultMail = Messaging.sendEmail(messages);
//
//            for (Messaging.SendEmailResult result : resultMail) {
//                if (!result.isSuccess()) {
//                    System.debug('errors: ' + result.getErrors());
//                }
//            }
//
//        } catch (exception e) {
//            System.debug('Could not send emails: ' + e.getMessage());
//
//        }
//    }
//
//    global void finish(Database.BatchableContext BC) {
//        AsyncApexJob a = [
//                SELECT Id, Status, NumberOfErrors, JobItemsProcessed,
//                        TotalJobItems, CreatedBy.Email
//                FROM AsyncApexJob
//                WHERE Id =
//                        :BC.getJobId()
//        ];
//        System.debug('job summary: ' + a);
//
//        if (a.NumberOfErrors > 0) {
//            String body = '<p>Job Summary: ' + a + '</p>';
//            body += '<br/> <p>OrgId: ' + UserInfo.getOrganizationId() + '</p>';
//            List<Messaging.SingleEmailMessage> errorMessages = new List<Messaging.SingleEmailMessage>();
//
//            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
//            email.setHtmlBody(body);
//            email.setToAddresses(new List<String>{
//                    'platformalert@aacr.org'
//            });
//            email.setSubject('Batch_SendSingleEmailMessages Exception');
//            email.setSenderDisplayName('American Association for Cancer Research');
//            errorMessages.add(email);
//
//            Messaging.sendEmail(errorMessages);
//
//        }
//    }

}