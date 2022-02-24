/**
 * Created by afaf.awad on 12/14/2020.
 */

public with sharing class BatchUpdateMembershipHelper {
    @AuraEnabled
    public static Boolean validateData(String fileData, List<String> fields, String aacrField) {

        Boolean validated = true;
        List<String> aacrIds = new List<String>();
        try {
            String[] fileLines = new String[]{
            };
            fileLines = fileData.split('\n');
            for (Integer i = 1, j = fileLines.size(); i < j; i++) {
                if ( validated == true ) {
                    String[] inputvalues = new String[]{};
                    inputvalues = fileLines[i].split(',');
                    integer rowsize = inputvalues.size();
//                    System.debug('rowsize: ' + rowsize);
//                    System.debug('inputvalues: ' + inputvalues);
                    for (integer m = 0; m < rowsize; m++) {
                        if ( fields.get(m) == aacrField ) {
                            if ( String.isNotBlank(inputvalues[m]) ) {
                                String aId = inputvalues[m];
//                                System.debug('aID == ' + aId);
                                aacrIds.add(aId.deleteWhitespace());
                            }else {
                                validated = false;
                            }
                        }
                    }
                }else {
                    break;
                }
            }
        } catch (Exception e) {
            System.debug('exception' + e);
//            throw new AACRCustomException(e.getMessage(), e.getStackTraceString(), 'Mass Registration');
        }
        System.debug('validated = ' + validated);
        return validated;
    }


    @AuraEnabled
    public static Id processData(String fileData, List<String> fields, String aacrField, Boolean isRenew) {

        Set<String> aacrIds = new Set<String>();
        Id batchId;

        try {
            if ( fileData != null ) {
                String[] fileLines = new String[]{
                };
                fileLines = fileData.split('\n');
                for (Integer i = 1, j = fileLines.size(); i < j; i++) {
                    String[] inputvalues = new String[]{
                    };
                    inputvalues = fileLines[i].split(',');
                    System.debug('inputvalues ::: ' + inputvalues);
                    integer rowsize = inputvalues.size();
                    System.debug('rowsize::' + rowsize);

                    for (integer l = 0; l < rowsize; l++) {
                        if ( fields.get(l) == aacrField ) {
                            if ( String.isNotBlank(inputvalues[l]) ) {
                                aacrIds.add(inputvalues[l].deleteWhitespace());
                            }
                        }
                    }
                }

                Renewal_Settings__c renew = Renewal_Settings__c.getInstance();
                Date renewDate = Date.newInstance(Integer.valueOf(String.valueOf(renew.Term_Year__c)) - 1, 12, 31);

                List<OrderApi__Subscription_Plan__c> subPlans = [SELECT Id FROM OrderApi__Subscription_Plan__c WHERE (Show_In_Portal__c = true OR OrderApi__Advanced_Calendar_Days__c = 365) AND OrderApi__Is_Active__c = true AND OrderApi__Type__c = 'Calendar' ORDER BY OrderApi__Advanced_Calendar_Days__c];
                OrderApi__Item_Class__c itemClass = [SELECT Id FROM OrderApi__Item_Class__c WHERE Name = 'Individual Memberships'];

                if(isRenew) {
                    batchId = Database.executeBatch(new Batch_RenewSubscriptions(aacrIds, renewDate, subPlans[0].Id, itemClass.Id));
                }else{
                    batchId = Database.executeBatch(new Batch_SuspendPriorMembers(aacrIds, renewDate));
                }
            }
        } catch (Exception e) {
            System.debug('exception' + e);
//            throw new AACRCustomException(e.getMessage(),  e.getStackTraceString() , 'Renew Subscriptions');
        }
        return batchId;
    }

    @AuraEnabled
    public static AsyncApexJob getBatchJobStatus(Id jobId){
        try {
            return [SELECT Status, NumberOfErrors,JobItemsProcessed,TotalJobItems FROM AsyncApexJob WHERE Id = :jobId];
        }catch(Exception e) {
            System.debug('exception' + e);
//            throw new AACRCustomException(e.getMessage(),  e.getStackTraceString() , 'Renew Subscriptions');
            return null;
        }
    }

    public static void sendRecordErrors_Subscriptions(List<OrderApi__Subscription__c> subs, Integer numProcessed, Id jobId){
        Messaging.EmailFileAttachment attachment = new Messaging.EmailFileAttachment();
        AsyncApexJob job = getBatchJobStatus(jobId);
        Integer errorNum = Test.isRunningTest() ? 5 : job.NumberOfErrors;
        System.debug('numProcessed = ' + numProcessed);
        String body = 'Your batch job has completed with ' + errorNum + ' errors. ';

        if ( errorNum > 0) {
                body += 'Check PlatformAlert for error details. ';
            }

        if(!subs.isEmpty()) {
            body += '\nSee attached file for Subscriptions that did not update.';

            String contentCSV = '';
            for(OrderApi__Subscription__c s : subs){
                contentCSV += s.Id + ',' + s.OrderApi__Contact__r.AACR_ID__c + ',' + s.OrderApi__Contact__r.FirstName + ',' + s.OrderApi__Contact__r.LastName + ',' + s.OrderApi__Current_Term_End_Date__c + '\n';
            }
            String content = 'SubscriptionId, AACRID, FirstName, LastName, Current Term End Date\n' + contentCSV;

            attachment.setContentType('text/csv');
            attachment.setFileName( 'SubscriptionsNotUpdated_' + Datetime.now().format('YYYYMMDD') + '.csv' );
            attachment.setBody( Blob.valueOf( content ) );

        }

        String subject = 'Batch Subscription Renewal Completed: ' + numProcessed + ' records processed. ';
        emailBatchCompleteStatus(subject,body,attachment);

    }

    public static void sendRecordErrors_Contacts(List<Contact> contacts, Integer numProcessed, Id jobId){
        Messaging.EmailFileAttachment attachment = new Messaging.EmailFileAttachment();
        AsyncApexJob job = getBatchJobStatus(jobId);
        Integer errorNum = Test.isRunningTest() ? 5 : job.NumberOfErrors;
        String body = 'Your batch job has completed with ' + errorNum + ' errors. ';

        if(errorNum > 0){
            body += 'Check PlatformAlert for error details. ';
        }

        if(!contacts.isEmpty()) {
            body += '\nSee attached file for Subscriptions that did not update.';

            String contentCSV = '';
            for(Contact con : contacts){
                contentCSV += con.Id + ',' + con.AACR_ID__c + ',' + con.FirstName + ',' + con.LastName + ',' + con.Membership_Status__c + ',' + con.Paid_thru_date__c + '\n';
            }
            String content = 'ContactId, AACRID, FirstName, LastName, MembershipStatus, PaidThruDate\n' + contentCSV;

            attachment.setContentType('text/csv');
            attachment.setFileName( 'PriorMembersNotUpdated_' + Datetime.now().format('YYYYMMDD') + '.csv' );
            attachment.setBody( Blob.valueOf( content ) );
        }

        String subject = 'Batch Update Prior Members Completed: ' + numProcessed + ' records processed. ';
        emailBatchCompleteStatus(subject,body,attachment);

    }

    public static void emailBatchCompleteStatus(String subject, String body, Messaging.EmailFileAttachment attachment ){

        System.debug('attachment = ' + attachment);
        try {
            List<Messaging.SingleEmailMessage> messages = new List<Messaging.SingleEmailMessage>();
            Messaging.SingleEmailMessage msg = new Messaging.SingleEmailMessage();

            msg.setSubject(subject);
            msg.setHtmlBody(body);
//            msg.setToAddresses(new List<String>{ 'platformalert@yopmail.com' });
            msg.setTargetObjectId(UserInfo.getUserId());
            msg.setTreatTargetObjectAsRecipient(true);
            msg.setSaveAsActivity(false);
            if(attachment.getBody() != null) {
                msg.setFileAttachments(new Messaging.EmailFileAttachment[]{
                        attachment
                });
            }

            messages.add(msg);
            Messaging.sendEmail(messages);

        } catch (AACRCustomException e) {
            System.debug('Exception sending email :::' + e.getMessage() + '\t' + e.getStackTraceString());
            throw new AACRCustomException(e.getMessage(), e.getStackTraceString(), 'Email not sent');
        }
    }

}