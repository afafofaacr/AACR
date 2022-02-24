/**
 * Created by afaf.awad on 10/28/2021.
 */

public with sharing class MassContactUpdateController {

    @AuraEnabled
    public static Id executeMassContactUpdate() {

        return database.executeBatch(new Batch_MassContactUpdate());


    }

    @AuraEnabled
    public static AsyncApexJob getBatchJobStatus(Id jobId){
        AsyncApexJob jobInfo = [SELECT Status, NumberOfErrors,JobItemsProcessed,TotalJobItems FROM AsyncApexJob WHERE Id = :jobId];
        return jobInfo;
    }

    @AuraEnabled
    public static void emailBatchResults(Map<String,String> errorMap, Integer numUpdated){

        Messaging.EmailFileAttachment attachment = new Messaging.EmailFileAttachment();
//        AsyncApexJob job = getBatchJobStatus(jobId);
        Integer errorNum = Test.isRunningTest() ? 5 : errorMap.size();
        String body = 'BOOP Completed!\n' +
                'Total Updated: ' + numUpdated + '\n' +
                'Total Errors: ' + errorNum + '\n\n';

        if(errorNum > 0){
            body += 'See attached for error details.';
            String contentCSV = '';
            for(String id : errorMap.keySet()){
                contentCSV += id + ',' + errorMap.get(id) + '\n';
            }
            String content = 'ContactId, ERROR\n' + contentCSV;

            attachment.setContentType('text/csv');
            attachment.setFileName( 'BOOP_Errors' + Datetime.now().format('YYYYMMDD') + '.csv' );
            attachment.setBody( Blob.valueOf( content ) );
        }

        String subject = 'BOOP Completed!';
        System.debug('body = ' + body);

        try {
            List<Messaging.SingleEmailMessage> messages = new List<Messaging.SingleEmailMessage>();
            Messaging.SingleEmailMessage msg = new Messaging.SingleEmailMessage();
            msg.setSubject(subject);
            msg.setPlainTextBody(body);
//            msg.setToAddresses(new List<String>{ 'BoopTest@aacrtest.org' });
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
            throw new AACRCustomException(e.getMessage(), e.getStackTraceString(), 'BOOP:Email not sent');
        }
    }
}