/**
 * Created by afaf.awad on 1/21/2021.
 */

global class Batch_ProcessMassRegistration implements Database.Batchable<sObject>, Database.AllowsCallouts {

        List<User> conDidNotRegister = new List<User>();
        Integer recordsProcessed = 0;
        String eventId {get;set;}
        List<String> contacts {get;set;}
        Map<String,String> compCodeMap {get;set;}
        Boolean bypassEmail {get;set;}

        global Batch_ProcessMassRegistration(String event, List<String> contactIds, Map<String,String> compIdMap, Boolean noEmail){
            eventId = event;
            contacts = contactIds;
            compCodeMap = compIdMap;
            bypassEmail = noEmail;

        }

        global Database.QueryLocator start(Database.BatchableContext BC){
            String query = 'Select Id, ContactId, Contact.FirstName, Contact.LastName, Contact.Email, Contact.AACR_ID__c FROM User WHERE ContactId IN: contacts';
            return Database.getQueryLocator(query);
        }

        global void execute(Database.BatchableContext BC, List<User> scope){
            System.debug('executing batch with ' + scope.size() + ' records.');
            List<BR_Participation__c> participations = new List<BR_Participation__c>();

            for(User u: scope){
                    BR_Participation__c part = new BR_Participation__c();
                    part.Contact__c = u.ContactId;
                    part.User__c = u.Id;
                    part.BR_Event__c = eventId;
                    part.Participate__c = 'Yes';
                    part.Registration_Date__c = Date.today();
//                    part.Source_Code__c = compCodeMap.get(u.Contact.AACR_ID__c);
                    part.Bypass_Confirmation__c = bypassEmail;
                    part.Via_Mass_Reg__c = true;
                    participations.add(part);
                }
            

            try {
                insert participations;
                recordsProcessed = recordsProcessed + participations.size();
            }catch(Exception e){
                conDidNotRegister.addAll(scope);
                System.debug('Error Message : ' + e.getMessage());
            throw new AACRCustomException(e.getMessage(),  e.getStackTraceString() , 'Batch_ProcessMassRegistration');
            }

        }

        global void finish(Database.BatchableContext BC){
            System.debug('finishing Batch_ProcessMassRegistration...');

            BrEventsMassRegistrationController.sendRecordErrors_Contacts(conDidNotRegister, recordsProcessed, bc.getJobId());

        }

}