/**
 * Created by afaf.awad on 3/1/2021.
 */

public with sharing class EC_ReviewEmailController {

    @AuraEnabled
    public static String getOrderForApproval() {
        return [SELECT Id FROM Join_Process__mdt WHERE DeveloperName = 'EC_Approve_Order'].Id;
    }

    @AuraEnabled
    public static String getPreviousStep(String stepId) {
        return EC_Helper.getPreviousStep(stepId, 'EC_Approve_Order');

    }

    @AuraEnabled
    public static EC_Email__c getEmailRecord(String orderId) {
        return EC_Helper.getEmailRecordFromOrder(orderId);
    }

    @AuraEnabled
    public static EmailReview getEmailReview(String orderId) {

        List<User> users = [
                Select Id, Name, Profile.UserLicense.Name
                From User
                WHERE (Profile.UserLicense.Name = 'Salesforce' OR Profile.UserLicense.Name = 'Salesforce Platform')
                AND IsActive = TRUE
                ORDER BY Name
        ];

        EC_Email__c email = EC_Helper.getEmailRecordFromOrder(orderId);

        return new EmailReview(email, users);
    }

    @AuraEnabled
    public static Boolean sendTestEmail(String emailId, String usersJson) {
        List<String> userList = (List<String>) JSON.deserialize(usersJson, List<String>.class);

        EC_Email__c email = EC_Helper.getEmailRecord(emailId);
        String emailbody = EC_Helper.buildEmailTemplate(emailId);
        List<User> users = [SELECT Id, Email, Name FROM User WHERE Id IN:userList];

        Map<String, String> emailMap = new Map<String, String>();
        for (User u : users) {
            emailMap.put(u.Email, u.Name);
        }

        return PlatformEmailService.callSendGridAPI(emailMap
                , email.Subject__c
                , email.Exhibitor_Setting__r.Verified_Email__c
                , email.Exhibitor_Setting__r.Sender_Name__c != null ? email.Exhibitor_Setting__r.Sender_Name__c : email.Exhibitor_Setting__r.Company__r.Name
                , email.Exhibitor_Setting__r.Reply_To__c != null ? email.Exhibitor_Setting__r.Reply_To__c : email.Exhibitor_Setting__r.Verified_Email__c
                , emailbody);
    }

    @AuraEnabled
    public static ApproveResponse approveRejectOrder(String orderId, String decision) {
        EC_Email__c email = EC_Helper.getEmailRecordFromOrder(orderId);
        System.debug('email : ' +  email);

        if ( decision == 'Approve' ) {
            if(String.isBlank(email.Exhibitor_Setting__r.Verified_Domain__c)){
                return new ApproveResponse(false, 'Exhibitor Setting must have a verified domain before their order can be approved.');
            }else {
                return new ApproveResponse(approveOrder(email), 'An error occurred sending email to exhibitor.'); //message is only used if returned false
            }
        } else {
            return new ApproveResponse(rejectOrder(email),'An error occurred sending email to exhibitor.'); //message is only used if returned false
        }

    }

    public static Boolean approveOrder(EC_Email__c email) {
        String userId = UserInfo.getUserId();
        User user = [Select Email, Name From User where Id =: userId limit 1];
        Time_Slot__c timeSlot = [SELECT Id, Status__c, Start_Time__c FROM Time_Slot__c WHERE EC_Order__c = :email.EC_Order__c];
        timeSlot.Status__c = 'Scheduled';
        EC_Order__c order = new EC_Order__c(Id = email.EC_Order__c
                , Status__c = 'Approved'
                , Approval_Date__c = Date.today()
                , Approved_By__c = userId);


        try {
            EmailTemplate emailTemplate = [SELECT Id, HtmlValue, Body FROM EmailTemplate WHERE Name = 'Exhibitor Approve Order Email'];

            String body = emailTemplate.HtmlValue;
            String name = email.EC_Order__r.Requested_By__r.FirstName + ' ' + email.EC_Order__r.Requested_By__r.LastName;
            Datetime startDateTime = Datetime.newInstance(Date.today(), timeSlot.Start_Time__c);

            System.debug('Is Comments Blank?? ' + email.Comments__c);

            body = emailTemplate.HtmlValue.replace('{!Name}', name)
                    .replace('{!EC_Email__c.Comments__c}', String.isBlank(email.Comments__c) ? '' : email.Comments__c)
                    .replace('{!EC_Order__c.Order_Name__c}', email.EC_Order__r.Order_Name__c)
                    .replace('{!EC_Order__c.Name}', email.EC_Order__r.Name)
                    .replace('{!EC_Order__c.Id}', email.EC_Order__c)
                    .replace('{!EC_Order__c.Status}', email.EC_Order__r.Status__c)
                    .replace('{!StartTime}',startDateTime.format('h:mm a'));
//            System.debug('approve email template body: ' + body);
            Map<String, String> emailMap = new Map<String, String>();
            emailMap.put(email.EC_Order__r.Requested_By__r.Email, name);

            Boolean success = PlatformEmailService.callSendGridAPI(emailMap, 'Your order is approved.', user.Email, user.Name, user.Email, body);

            update timeSlot;
            update order;

            return success;

        } catch (Exception e) {
            System.debug('Could not send approved email: ' + e.getMessage());
            return null;

        }
    }

    public static Boolean rejectOrder(EC_Email__c email) {
        System.debug('rejecting order...');
        EC_Order__c order = new EC_Order__c(Id = email.EC_Order__c, Status__c = 'Rejected');
        String userId = UserInfo.getUserId();
        User user = [Select Email, Name From User where Id =: userId limit 1];

//        Time_Slot__c timeSlot = [SELECT Id, Status__c FROM Time_Slot__c WHERE EC_Order__c =: email.EC_Order__c];
//        timeSlot.Status__c = '';
        try {
            EmailTemplate emailTemplate = [SELECT Id, HtmlValue, Body FROM EmailTemplate WHERE Name = 'Exhibitor Reject Order Email'];

            String body = emailTemplate.HtmlValue;
            String name = email.EC_Order__r.Requested_By__r.FirstName + ' ' + email.EC_Order__r.Requested_By__r.LastName;

            System.debug('Is Comments Blank?? ' + email.Comments__c);
            body = emailTemplate.HtmlValue.replace('{!Name}', name)
                    .replace('{!EC_Order__c.Order_Name__c}', email.EC_Order__r.Order_Name__c)
                    .replace('{!EC_Order__c.Name}', email.EC_Order__r.Name)
                    .replace('{!EC_Email__c.Comments__c}', String.isBlank(email.Comments__c) ? '' : email.Comments__c)
                    .replace('{!EC_Order__c.Id}', email.EC_Order__c)
                    .replace('{!EC_Order__c.Status}', email.EC_Order__r.Status__c);
            System.debug('approve email template body: ' + body);

            Map<String, String> emailMap = new Map<String, String>();
            emailMap.put(email.EC_Order__r.Requested_By__r.Email, name);

            Boolean success = PlatformEmailService.callSendGridAPI(emailMap, 'Your order has been rejected', user.Email, user.Name, user.Email, body);

            //            update timeSlot;
            update order;
            return success;

        } catch (Exception e) {
            System.debug('Could not send reject email: ' + e.getMessage());
            return null;

        }
    }

    public class EmailReview {
        @AuraEnabled
        public EC_Email__c email;
        @AuraEnabled
        public List<User> users;

        public EmailReview(EC_Email__c emailRec, List<User> users) {
            this.email = emailRec;
            this.users = users;
        }
    }

    public class ApproveResponse{
        @AuraEnabled
        public Boolean isSuccess;
        @AuraEnabled
        public String message;

        public ApproveResponse(Boolean isSuccess, String message){
            this.isSuccess = isSuccess;
            this.message = message;
        }
    }

}