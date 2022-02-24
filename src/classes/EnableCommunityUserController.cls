/**
 * Created by afaf.awad on 8/4/2021.
 */

public without sharing class EnableCommunityUserController {

    @AuraEnabled
    public static void activateUser(String contactId){

        List<User> user = [SELECT Id FROM User WHERE ContactId =: contactId];
        if(user.isEmpty()){
            enableNewUser(contactId);
        }else {
            enableExistingUser(contactId);
        }
    }

    @Future
    public static void enableNewUser(String contactId){

        updateTestContact(contactId);

        Contact con = [SELECT FirstName, LastName, Email, AccountId FROM Contact WHERE Id =:contactId];
        Profile profileRecord = [SELECT Id FROM Profile WHERE Name = :'Fonteva Customer Community Login User' LIMIT 1];
        String username = con.Email.split('@').get(0);

        User user = new User(alias = con.FirstName.left(1) + (con.LastName.length() < 4 ? con.LastName : con.LastName.left(4)),
                    ContactId = con.Id,
                    LastName = con.LastName,
                    FirstName = con.FirstName,
                    ProfileId = profileRecord.Id,
                    Email = username + '@aacrtest.org',
                    EmailEncodingKey = 'UTF-8',
                    CommunityNickname = username.length() < 40 ? username : username.left(40),
                    LanguageLocaleKey = 'en_US',
                    LocaleSidKey = 'en_US',
                    TimeZoneSidKey = 'America/Los_Angeles',
                    Username = username + '@aacrtest.org',
                    isActive = true);

        try {
            insert user;
            System.setPassword(user.Id, 'Aacr1234');
        } catch (Exception e) {
            System.debug('could not create user: ' + e.getMessage());
            new AACRCustomException(contactId, e.getMessage(), e.getStackTraceString(), 'Enable Community User');
        }

    }

    @Future
    public static void enableExistingUser(String contactId){
        updateTestContact(contactId);
        User user = [SELECT Id, Email, IsActive  FROM User WHERE ContactId =: contactId LIMIT 1];
        user.IsActive = true;
        user.Email = user.Email.split('@').get(0) + '@aacrtest.org';

        try {
            update user;
            System.setPassword(user.Id, 'Aacr1234');
        } catch (Exception e) {
            System.debug('could not update user: ' + e.getMessage());
            new AACRCustomException(contactId, e.getMessage(), e.getStackTraceString(), 'Enable Community User');
        }

    }

    public static void updateTestContact(String contactId){
        Contact contact = [SELECT Id, Email, OrderApi__Personal_Email__c, OrderApi__Work_Email__c FROM Contact WHERE Id =: contactId];

        contact.Email = contact.Email.split('@').get(0) + '@aacrtest.org';
        contact.OrderApi__Personal_Email__c = contact.OrderApi__Personal_Email__c.split('@').get(0) + '@aacrtest.org';
        contact.OrderApi__Work_Email__c = contact.OrderApi__Work_Email__c.split('@').get(0) + '@aacrtest.org';

        try{
            update contact;
        }catch (Exception e){
            System.debug('could not update contact: ' + e.getMessage());
            new AACRCustomException(contactId, e.getMessage(), e.getStackTraceString(), 'Enable Community User');
        }
    }

}