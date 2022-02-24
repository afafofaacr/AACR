/**
 *@Purpose      : Test class for DW_VerifyEmailController
 *@Created Date : 22-10-2018
 *@Modified Date: 22-10-2018
 */
@isTest
public class DW_VerifyEmailControllerTest {
	
    /**
     *@purpose   : build test data.
     */
    @testSetup
    private static void buildTestData(){ 
        // build Account record
        Account account = buildAccount('Test Account1');
        insert account;
        System.assertEquals(1, [SELECT ID FROM Account].size());
        
        // Build Contact record
        Contact contact= buildContact(account.Id);
        insert contact;
		System.assertEquals(1, [SELECT ID FROM Contact].size());
        
        // Build User recod
        User user = buildUser(contact.Id);
        insert user;
    }
    
    @isTest
    public static void updateContactEmailAddressMethodTest(){
      
        Contact contact = [SELECT ID, Email FROM Contact Limit 1];
        
        PageReference pageRef = Page.DW_VerifyEmail;
        Test.setCurrentPage(pageRef);
        
        ApexPages.currentPage().getParameters().put('id',contact.id);
        ApexPages.currentPage().getParameters().put('email',contact.Email);
        
        DW_VerifyEmailController verifyEmailController = new DW_VerifyEmailController();
        verifyEmailController.updateContactEmailAddress();
		
		// Negative Testing        
         ApexPages.currentPage().getParameters().put('id',Null);
        ApexPages.currentPage().getParameters().put('email',Null);
 
        verifyEmailController.updateContactEmailAddress();

        
    }
    
    @isTest
    public static void createCommunityUserMethodTest(){
      
        Contact contact = [SELECT ID, FirstName, LastName, Email FROM Contact Limit 1];
        
        User userRecord = [SELECT ID 
                           FROM USER 
                           WHERE email = 'test@testorg.com'];
    
        DW_VerifyEmailController verifyEmailController = new DW_VerifyEmailController();
        verifyEmailController.createCommunityUser(contact);
        
        
        contact.Email = 'TestEmailAddress@username.com';
        contact.FirstName = 'TestFirstName';
        contact.LastName = 'TestLastName';
        verifyEmailController.createCommunityUser(contact); 
        
       // Negative Testing ----
        contact.Id = null;
        verifyEmailController.createCommunityUser(contact);
    }
        
    
    /**
     *@purpose   : build Account record
     *@param     : accountName
     *@return    : Account record
     */
    static Account buildAccount(String accountName){
        Id recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Active Account').getRecordTypeId();
        
        return new Account(RecordTypeId = recordTypeId,
                           Name = accountName);
    }
    
    /**
     *@purpose   : Build Contact record
     *@param     : accountId
     *@return    : Contact record
     */
    static Contact buildContact(Id accountId){
        Id recordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get( System.Label.Contact_Non_Member_Record_Type ).getRecordTypeId();
        
        // Creating Contact record
        return new Contact(FirstName = 'Test FName',
            			   LastName = 'Test LName',
                           AccountId = accountId,
                           email = 'test@test.com',
                           RecordTypeId = recordTypeId,
                           Phone ='9878986789',
                           Fax = 'fax');
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
                                   CommunityNickname = 'Test FNameT',
                                   languagelocalekey = 'en_US', 
                                   localesidkey = 'en_US', 
                                   timezonesidkey = 'America/Los_Angeles', 
                                   username = System.now().millisecond() + 'test@testorg2.com');
        return userRecord;
    }
    
}