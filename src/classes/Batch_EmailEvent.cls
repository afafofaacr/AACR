/**
 * Created by afaf.awad on 9/2/2020.
 */

global class Batch_EmailEvent implements Database.Batchable<sObject>, Database.Stateful{

    String eventId;
//    String templateName;

    global Batch_EmailEvent(String event ){
        this.eventId = event;
//        this.templateName = template;
    }

    global Database.QueryLocator start(Database.BatchableContext BC){
        String queryString = 'SELECT Id, BR_Event__c, Contact__r.Name, Contact__r.Email, Contact__c FROM BR_Participation__c WHERE Contact__r.IsEmailBounced = FALSE AND Participate__c = \'Yes\' AND BR_Event__c =: eventId';
        System.debug('queryString: ' + queryString);
        return Database.getQueryLocator(queryString);
    }


    global void execute(Database.BatchableContext BC, List<BR_Participation__c> scope){
        System.debug('executing Batch_EmailEvent with ' + scope.size() + ' records.');
        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
        EmailTemplate emailTemplate = [SELECT Id, HtmlValue, Body  FROM EmailTemplate WHERE Name = 'AM21 ATC Email'];

        for(BR_Participation__c part : scope){

            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();

            String body = emailTemplate.HtmlValue;
            body = emailTemplate.HtmlValue.replace('{!Contact.Name}', part.Contact__r.Name)
                    .replace('{!BR_Event__c.Id}',part.BR_Event__c);

//            body = emailTemplate.HtmlValue.replace('{!EventApi__Attendee__c.EventApi__Event__c}', attendee.EventApi__Event__r.Name)
//                    .replace('{!Contact.Email}',attendee.EventApi__Contact__r.Email)
//                    .replace('{!EventApi__Attendee__c.EventApi__Full_Name__c}', attendee.EventApi__Full_Name__c);

            email.setHtmlBody(body);
            email.setSubject('Calendar Item Now Available');
            email.setTargetObjectId(part.Contact__c);
            email.setTemplateId(emailTemplate.Id);
            email.setWhatId(part.Id);
            email.setSaveAsActivity(false);
            email.setSenderDisplayName('American Association For Cancer Research');
            email.setToAddresses(new List<String>{part.Contact__r.Email});
            emails.add(email);
        }

        System.debug('emails to send: ' + emails.size());

        if (!emails.isEmpty()) {
            try {
                Messaging.sendEmail(emails);
            } catch (EmailException ex) {
                System.debug(ex.getMessage());
                throw new AACRCustomException(ex.getMessage(), ex.getStackTraceString(), 'Email: Calendar Item Now Available');
            }
        }
    }


    global void finish(Database.BatchableContext BC){
        System.debug('finishing Batch_EmailEvent...');

    }

}