/**
 * Created by afaf.awad on 7/13/2021.
 */

public with sharing class MassUpdateUserPasswordController {

    @AuraEnabled
    public static fileData validateData(String fileData, List<String> fields, String idField) {

        Boolean validated = true;
        List<String> idStrings = new List<String>();
        try {
            String[] fileLines = new String[]{};
            fileLines = fileData.unescapeCsv().split('\n');
            for (Integer i = 1, j = fileLines.size(); i < j; i++) {
                String[] inputvalues = new String[]{};
                inputvalues = fileLines[i].split(',(?=(?:[^\"]*\"[^\"]*\")*[^\"]*$)');
                System.debug('inputvalues ::: ' + inputvalues);
                integer rowsize = inputvalues.size();
                for (integer m = 0; m < rowsize; m++) {
                    if ( fields.get(m) == idField ) {
                        if ( String.isNotBlank(inputvalues[m]) ) {
                            System.debug('inputValue ' + m + ' = ' + inputvalues[m]);
                            if( inputvalues[m] instanceof Id) {
                                System.debug('Validate Id: ' + inputvalues[m] );
                                idStrings.add(inputvalues[m].deleteWhitespace());
                            }else {
                                validated = false;
                                break;
                            }
                        }else {
                            validated = false;
                            break;
                        }
                    }
                }
            }
        } catch (Exception e) {
            System.debug('exception' + e);
            throw new AACRCustomException(e.getMessage(), e.getStackTraceString(), 'DimensionTagBulkImportController');
        }

        System.debug('validated = ' + validated);
        return new fileData(validated,idStrings);
    }

    @AuraEnabled
    public static AsyncApexJob getBatchJobStatus(Id jobId){
        try {
            return [SELECT Status, NumberOfErrors,JobItemsProcessed,TotalJobItems FROM AsyncApexJob WHERE Id = :jobId];
        }catch(Exception e) {
            System.debug('exception' + e);
            return null;
        }
    }

    @AuraEnabled
    public static Id callBatch_UpdatePasswords(String idListString, String password){
        List<String> userIds = (List<String>) JSON.deserialize(idListString, List<String>.class);

        return Database.executeBatch(new Batch_UpdatePasswords(password, userIds));
    }

    public static void sendRecordErrors(Map<Id,String> userMap, Integer numProcessed, Id jobId){
        Messaging.EmailFileAttachment attachment = new Messaging.EmailFileAttachment();
        AsyncApexJob job = getBatchJobStatus(jobId);
        Integer errorNum = Test.isRunningTest() ? 5 : job.NumberOfErrors;
        System.debug('users to process = ' + userMap);

        List<User> users = [SELECT Id, FirstName, LastName, Email, Username FROM User WHERE Id IN: userMap.keySet()];
        if(!users.isEmpty()) {
            String body = 'Your batch job has completed with ' + errorNum + ' processing errors.' +
                    '\nSee attached file for Users that did not update.';

                String contentCSV = '';
                for (User u : users) {
                    contentCSV += u.Id + ',' + u.FirstName + ',' + u.LastName + ',' + u.Email + ',' + u.Username + ',' + userMap.get(u.Id) +  '\n';
                }
                String content = 'UserId, FirstName, LastName, Email, Username, Error\n' + contentCSV;

                attachment.setContentType('text/csv');
                attachment.setFileName('UsersDidNotUpdate' + Datetime.now().format('YYYYMMDD') + '.csv');
                attachment.setBody(Blob.valueOf(content));

            String subject = 'Batch Job Complete - Enable Users : ' + numProcessed + ' records processed. ';
            emailBatchCompleteStatus(subject,body,attachment);
        }
    }


    public static void emailBatchCompleteStatus(String subject, String body, Messaging.EmailFileAttachment attachment ){

        System.debug('attachment = ' + attachment);
        try {
            List<Messaging.SingleEmailMessage> messages = new List<Messaging.SingleEmailMessage>();
            Messaging.SingleEmailMessage msg = new Messaging.SingleEmailMessage();

            msg.setSubject(subject);
            msg.setHtmlBody(body);
            msg.setToAddresses(new List<String>{ 'platformalert@yopmail.com' });
//            msg.setTargetObjectId(UserInfo.getUserId());
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

    public class fileData{
        @AuraEnabled
        public Boolean validated;
        @AuraEnabled
        public List<String> recordIds;

        public fileData(Boolean validate, List<String> recordIds){
            this.validated = validate;
            this.recordIds = recordIds;
        }
    }
}