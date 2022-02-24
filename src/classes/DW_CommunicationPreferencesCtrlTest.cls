/**
 *@Purpose       : Test class for DW_CommunicationPreferencesCtrl controller
 *@Created Date  : 21-08-2018
 *@Modified Date : 
 */
@isTest
public class DW_CommunicationPreferencesCtrlTest {
    /**
     *@purpose   : build test data.
     */
    @testSetup
    private static void buildTestData(){ 
        
        // build Account record
        Account account = buildAccount();
        insert account;
        
        // Build Contact record
        Contact contact= buildContact(account.Id);
        insert contact;
        
        // Build User recod
        User user = buildUser(contact.Id);
        insert user;
       
    }
    
    /**
     *@purpose   : build Account record
     *@param     : -
     *@return    : Account record
     */
    static Account buildAccount(){
        Id recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Active Account').getRecordTypeId();
        
        return new Account(RecordTypeId = recordTypeId,
                           Name = 'Test account');
    }
    
    /**
     *@purpose   : Build Contact record
     *@param     : accountId
     *@return    : Contact record
     */
    static Contact buildContact(Id accountId){
        Id recordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get( Label.Contact_Non_Member_Record_Type ).getRecordTypeId();
        
        // Creating Contact record
        return new Contact(LastName = 'Test contact',
                           AccountId = accountId,
                           RecordTypeId = recordTypeId,
                           Nickname__c ='Test contact nick',
                           Maiden_Name__c ='Test contact maiden',
                           Formerly_Known_As__c ='XYZ',
                           CEO_Preference__c ='CEO Prf',
                           Preferred_Address__c ='Business',
                           OrderApi__Preferred_Phone_Type__c ='Mobile',
                           OrderApi__Preferred_Email_Type__c ='Personal',
                           Email ='con@test.com',
                            Birthdate = Date.newInstance(1985, 12, 10),
                           Do_Not_Display_in_Directory__c = true,
                           Foundation_Do_Not_Solicit__c = true);
        
    }
    
    /**
     *@purpose   : Build User record
     *@param     : contactId
     *@return    : -
     */
    static User buildUser(Id contactId){
        // Fetching profile record
        Profile profileRecord = [SELECT Id
                                 FROM Profile 
                                 WHERE Name =: 'Fonteva Customer Community Login User'
								 LIMIT 1];
        
        // Create users record
        User userRecord = new User(alias = 'test',
                                   ContactId = contactId,
                                  // AccountId = contactRecord1.AccountId,
                                   ProfileId = profileRecord.Id, 
                                   email = 'test@testorg.com', 
                                   emailencodingkey = 'UTF-8', 
                                   lastname = 'Test User1', 
                                   CommunityNickname = 'test user1',
                                   languagelocalekey = 'en_US', 
                                   localesidkey = 'en_US', 
                                   timezonesidkey = 'America/Los_Angeles', 
                                   username = System.now().millisecond() + 'test@testorg1.com');
        return userRecord;
    }
    
    /**
     *@purpose : to test test Contacts Communication Preferences positively
     */
    static testMethod void posTestContactsCommuPref(){
        Test.startTest();
        
        User user = [SELECT Id, ContactId 
                     FROM User 
                     WHERE lastname =: 'Test User1'];
        
        System.runAs(user){
             Contact contact = [SELECT Id, Nickname__c, Maiden_Name__c, Formerly_Known_As__c, Do_Not_Display_in_Directory__c, OrderApi__Preferred_Phone_Type__c, 
                                  OrderApi__Preferred_Email_Type__c, Birthdate
                                FROM Contact 
                                WHERE Id =: user.ContactId];
        
            DW_CommunicationPreferencesCtrl communPrefCon = new DW_CommunicationPreferencesCtrl();
            
            communPrefCon.contact = contact;
            
            communPrefCon.contact.Nickname__c = 'Disuza';
            communPrefCon.contact.Maiden_Name__c ='Test Maiden';
            communPrefCon.contact.Formerly_Known_As__c = 'Test';
            communPrefCon.contact.Do_Not_Display_in_Directory__c = false;
            communPrefCon.contact.Foundation_Do_Not_Solicit__c = false;
            
            communPrefCon.saveContact();
            
            Contact updatedContact = [SELECT Id, Nickname__c, Maiden_Name__c,Formerly_Known_As__c, Do_Not_Display_in_Directory__c, Foundation_Do_Not_Solicit__c,
                                      OrderApi__Preferred_Phone_Type__c, OrderApi__Preferred_Email_Type__c
                                      FROM Contact 
                                      WHERE Id =: contact.Id]; 
            
            System.assertEquals(communPrefCon.contact.Nickname__c, updatedContact.Nickname__c);
            System.assertEquals(communPrefCon.contact.Maiden_Name__c, updatedContact.Maiden_Name__c);
            System.assertEquals(communPrefCon.contact.Formerly_Known_As__c, updatedContact.Formerly_Known_As__c);
            System.assertEquals(communPrefCon.contact.Do_Not_Display_in_Directory__c, updatedContact.Do_Not_Display_in_Directory__c);
            System.assertEquals(communPrefCon.contact.Foundation_Do_Not_Solicit__c, updatedContact.Foundation_Do_Not_Solicit__c);
            System.assertEquals(contact.OrderApi__Preferred_Phone_Type__c, updatedContact.OrderApi__Preferred_Phone_Type__c);
            System.assertEquals(contact.OrderApi__Preferred_Email_Type__c, updatedContact.OrderApi__Preferred_Email_Type__c);
            
            communPrefCon.cancelContact();
        } 
        
        Test.stopTest();
    }
    
    /**
     *@purpose : to test test Contacts Communication Preferences negatively
     */
    static testMethod void negTestContactsCommuPref(){
        Test.startTest();
        
        User user = [SELECT Id, ContactId 
                     FROM User 
                     WHERE lastname =: 'Test User1'];
        
        DW_CommunicationPreferencesCtrl communPrefCon = new DW_CommunicationPreferencesCtrl();
        communPrefCon.saveContact();
        communPrefCon.cancelContact();

        Test.stopTest();
    }
}