/**
 * Created by afaf.awad on 2/15/2021.
 */

public without sharing class EC_OrderEmailController {

    @AuraEnabled
    public static EC_Email__c getEmailRecord(String orderId, String stepId){
        JP_Helper.upsertLastAccessedStep(stepId);

        try {
            EC_Email__c emailRec = EC_Helper.getEmailRecordFromOrder(orderId);
            return emailRec;

        }catch(Exception e) {
            Contact con = ECRMUtils.getCurrentLoginContact();
            EC_Email__c newEmail = new EC_Email__c(EC_Order__c = orderId, Exhibitor_Setting__c = EC_Helper.getExhibitorSetting(con.AccountId).Id);
            insert newEmail;
            return newEmail;
        }

    }

//    @AuraEnabled
//    public static Boolean updateEmailRecord(String emailId, String emailBody){
//        EC_Email__c ecEmail = new EC_Email__c();
//        ecEmail.Id = emailId;
////        ecEmail.Template_Body__c = emailBody;
//
//        try{
//            update ecEmail;
//            return true;
//        } catch(Exception e){
//            System.debug('Could not update email template: ' + e.getMessage());
//            return false;
//        }
//    }

    @AuraEnabled
    public static Boolean sendTestEmail(String testEmail, String emailId){

        EC_Email__c email = EC_Helper.getEmailRecord(emailId);
        String emailbody = EC_Helper.buildEmailTemplate(emailId);

        Map<String,String> emailMap = new Map<String, String>();
        emailMap.put(testEmail, 'AACR Test Email');

            return PlatformEmailService.callSendGridAPI(emailMap
                    , email.Subject__c
                    , testEmail
                    , email.Exhibitor_Setting__r.Sender_Name__c != null ? email.Exhibitor_Setting__r.Sender_Name__c : email.Exhibitor_Setting__r.Company__r.Name
                    , email.Exhibitor_Setting__r.Reply_To__c != null ? email.Exhibitor_Setting__r.Reply_To__c : testEmail
                    , emailbody);

    }

//    @AuraEnabled
//    public static String buildEmailTemplate(String emailId){
//
//        return EC_Helper.buildEmailTemplate((emailId));
//
//    }

}