/**
 * Created by afaf.awad on 3/4/2021.
 */

public class Batch_EC_SendEmails implements Database.Batchable<sObject>, Database.AllowsCallouts{

    List<Id> partIds {get;set;}
    EC_Email__c email {get;set;}
    String emailBody {get;set;}
    Time_Slot__c timeSlot {get;set;}
    

        public Batch_EC_SendEmails(List<Id> participantIds, EC_Email__c ecEmail, String body, Time_Slot__c ts){
            partIds = participantIds;
            email = ecEmail;
            emailBody= body;
            timeSlot = ts;
        }

        public Database.QueryLocator start(Database.BatchableContext BC){
            String query = 'SELECT Contact__r.Email, Contact__r.FirstName, Contact__r.LastName FROM BR_Participation__c WHERE Id IN: partIds';
            System.debug('Query: ' + query);
            return Database.getQueryLocator(query);
        }

        public void execute(Database.BatchableContext BC, List<BR_Participation__c> scope){

            try {
                Map<String, String> emailMap = new Map<String, String>();
                for (BR_Participation__c part : scope) {
                    emailMap.put(part.Contact__r.Email, part.Contact__r.FirstName + ' ' + part.Contact__r.LastName);
                }

                PlatformEmailService.callSendGridAPI(emailMap
                        , email.Subject__c
                        , email.Exhibitor_Setting__r.Verified_Email__c
                        , email.Exhibitor_Setting__r.Sender_Name__c != null ? email.Exhibitor_Setting__r.Sender_Name__c : email.Exhibitor_Setting__r.Company__r.Name
                        , email.Exhibitor_Setting__r.Reply_To__c != null ? email.Exhibitor_Setting__r.Reply_To__c : email.Exhibitor_Setting__r.Verified_Email__c
                        , emailbody);

            }catch(Exception e) {
                System.debug('Error on Batch_EC_SendEmails Line number ====> '+ e.getLineNumber() + '--- Exception Message =====> ' + e.getMessage());
                throw new AACRCustomException(e.getMessage(), e.getStackTraceString(), 'Batch_EC_SendEmails');
            }

        }

        public void finish(Database.BatchableContext BC){
            System.debug('finishing Batch_SendEventReminders...');

            System.enqueueJob(new EC_QueueableStripeInvoice(partIds.size(), timeSlot));

        }

    }