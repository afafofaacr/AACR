/**
 *@Purpose       : Test class for DW_MarketingPreferencesController controller
 *@Created Date  : 20-08-2018
 *@Modified Date : 
 */
@isTest
private class DW_MarketingPreferencesControllerTest {
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
                           AACR_Announcements__c = 'Yes',
                           Conferences_Workshops__c ='Yes',
                           AACR_Foundation__c ='Yes',
                           Membership_Information__c ='Yes',
                           Annual_Meeting__c ='Yes',
                           Minorities_in_Cancer_Research__c ='Yes',
                           Awards_Grants__c ='Yes',
                           Molecular_Epidemiology__c ='Yes',
                           Cancer_Immunology_Group__c ='Yes',
                           Stand_Up_2_Cancer__c ='Yes',
                           Cancer_Policy_Advocacy__c ='Yes',
                           Survivor_Advocacy__c ='Yes',
                           Cancer_Today_Magazine__c ='Yes',
                           Tumor_Microenvironment__c ='Yes',
                           Chemistry_in_Cancer_Research__c ='Yes',
                           Women_in_Cancer_Research__c ='Yes');
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
                                   lastname = 'Test User2', 
                                   CommunityNickname = 'test user2',
                                   languagelocalekey = 'en_US', 
                                   localesidkey = 'en_US', 
                                   timezonesidkey = 'America/Los_Angeles', 
                                   username = System.now().millisecond() + 'test@testorg2.com');
        return userRecord;
    }
    
    /**
     *@purpose : to test test Contacts Marketing Preferences positively
     */
    static testMethod void posTestContactsMarketingPref(){
        Test.startTest();
        
        User user = [SELECT Id, ContactId 
                     FROM User 
                     WHERE lastname =: 'Test User2'];
        
        System.runAs(user){
            
            Contact contact = [SELECT Id, AACR_Announcements__c, Conferences_Workshops__c, AACR_Foundation__c, Membership_Information__c, Annual_Meeting__c,
                                      Minorities_in_Cancer_Research__c, Awards_Grants__c, Molecular_Epidemiology__c, Cancer_Immunology_Group__c, 
                                      Stand_Up_2_Cancer__c, Cancer_Policy_Advocacy__c, Survivor_Advocacy__c,
                                      Cancer_Today_Magazine__c, Tumor_Microenvironment__c, Chemistry_in_Cancer_Research__c, Women_in_Cancer_Research__c,
                                      Preferred_Address__c
                               FROM Contact
                               WHERE Id =: user.contactId];
            
            DW_MarketingPreferencesController marketingPrefCon = new DW_MarketingPreferencesController();
            
            marketingPrefCon.contact = contact;
            marketingPrefCon.contact.AACR_Announcements__c = 'false';
            marketingPrefCon.contact.Conferences_Workshops__c = 'false';
            marketingPrefCon.contact.AACR_Foundation__c = 'false';
            marketingPrefCon.contact.Membership_Information__c = 'false';
            marketingPrefCon.contact.Minorities_in_Cancer_Research__c = 'false';
            marketingPrefCon.contact.Awards_Grants__c = 'false';
            marketingPrefCon.contact.Molecular_Epidemiology__c = 'false';
            
            marketingPrefCon.saveContact();   
            
            Contact updatedContact = [SELECT Id, AACR_Announcements__c, Conferences_Workshops__c, AACR_Foundation__c, Membership_Information__c, Annual_Meeting__c,
                                      Minorities_in_Cancer_Research__c, Awards_Grants__c, Molecular_Epidemiology__c, Cancer_Immunology_Group__c, 
                                      Stand_Up_2_Cancer__c, Cancer_Policy_Advocacy__c, Survivor_Advocacy__c,
                                      Cancer_Today_Magazine__c, Tumor_Microenvironment__c, Chemistry_in_Cancer_Research__c, Women_in_Cancer_Research__c,
                                      Preferred_Address__c
                               FROM Contact
                               WHERE Id =: contact.Id];
            
            system.assertEquals( marketingPrefCon.contact.AACR_Announcements__c , updatedContact.AACR_Announcements__c);
            system.assertEquals( marketingPrefCon.contact.Conferences_Workshops__c , updatedContact.Conferences_Workshops__c);
            system.assertEquals( marketingPrefCon.contact.AACR_Foundation__c , updatedContact.AACR_Foundation__c);
            system.assertEquals( marketingPrefCon.contact.Membership_Information__c , updatedContact.Membership_Information__c);
            system.assertEquals( marketingPrefCon.contact.Annual_Meeting__c , updatedContact.Annual_Meeting__c);
            system.assertEquals( marketingPrefCon.contact.Minorities_in_Cancer_Research__c , updatedContact.Minorities_in_Cancer_Research__c);
            system.assertEquals( marketingPrefCon.contact.Awards_Grants__c , updatedContact.Awards_Grants__c);
            system.assertEquals( marketingPrefCon.contact.Molecular_Epidemiology__c , updatedContact.Molecular_Epidemiology__c);
            system.assertEquals(contact.Cancer_Immunology_Group__c , updatedContact.Cancer_Immunology_Group__c);
            system.assertEquals(contact.Stand_Up_2_Cancer__c , updatedContact.Stand_Up_2_Cancer__c);
            
            marketingPrefCon.cancelContact();
        }
        Test.stopTest();
    }
    
    /**
     *@purpose : to test test Contacts Communication Preferences negatively
     */
    static testMethod void negTestContactsMarketingPref(){
        Test.startTest();
        
        User user = [SELECT Id, ContactId 
                     FROM User 
                     WHERE lastname =: 'Test User2'];
        
        DW_MarketingPreferencesController marketingPrefCon = new DW_MarketingPreferencesController();
        marketingPrefCon.saveContact();
        marketingPrefCon.cancelContact();
        
        Test.stopTest();
    }
}