/**
 * Created by afaf.awad on 9/30/2020.
 */

global class Batch_SendEmailByContact implements Database.Batchable<sObject>, Database.Stateful{

        String whereClause {get;set;}
        String emailTem {get;set;}
    String emailSubject{get;set;}

        global Batch_SendEmailByContact(String subjectString, String template, String whereClauseString){
            emailSubject =subjectString;
          whereClause = whereClauseString;
            emailTem = template;
        }

        global Database.QueryLocator start(Database.BatchableContext BC){
            System.debug('starting Batch_SendEmailByContact...');
            String queryString = 'Select Id, Name, Email FROM Contact ' + whereClause;
            System.debug('queryString: ' + queryString);
            return Database.getQueryLocator(queryString);

        }

        global void execute(Database.BatchableContext BC, List<Contact> scope){
            System.debug('executing Batch_EmailEvent with ' + scope.size() + ' records.');
            List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
            EmailTemplate emailTemplate = [SELECT Id, HtmlValue, Body  FROM EmailTemplate WHERE Name =: emailTem];
            OrgWideEmailAddress outgoingEmail = [SELECT Id FROM OrgWideEmailAddress WHERE DisplayName = 'AACR Events' ];

            for(Contact con : scope){

                Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();

                String body = emailTemplate.HtmlValue;

                email.setHtmlBody(body);
                email.setSubject(emailSubject);
                email.setTargetObjectId(con.Id);
                email.setTemplateId(emailTemplate.Id);
                email.setWhatId(con.Id);
                email.setSaveAsActivity(false);
//                email.setSenderDisplayName('American Association For Cancer Research');
                email.setOrgWideEmailAddressId(outgoingEmail.Id);
                email.setToAddresses(new List<String>{con.Email});
                emails.add(email);
            }

            System.debug('emails to send: ' + emails.size());

            if (!emails.isEmpty()) {
                try {
                    Messaging.sendEmail(emails);
                } catch (EmailException ex) {
                    System.debug(ex.getMessage());
                    throw new AACRCustomException(ex.getMessage(), ex.getStackTraceString(), 'Email: ' + emailTem);
                }
            }
        }

        global void finish(Database.BatchableContext BC){

        }

    }