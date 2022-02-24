/**
 *@Purpose      : Test class for DW_ForgotPasswordController
 *@Created Date : 27-09-2018
 *@Modified Date: 27-09-2018
 */
@isTest
public class DW_ForgotPasswordControllerTest {

    /**
     *@purpose   : build test data.
     */
    @testSetup
    private static void buildTestData(){ 
        // build Account record
        Account account = buildAccount();
        insert account;
        
        // Build Contact record
        Contact contact= buildContact(account.Id, '12345','test@gmail.com');
        insert contact;
        
        // Build User recod
        User user = buildUser(contact.Id, contact.email,'testecrm@gmail.com','Fonteva Customer Community Login User', 'Test', 'User', 'usertest', false);
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
     *@param     : accountId, memberId
     *@return    : Contact record
     */
    static Contact buildContact(Id accountId, String memberId, String emailAddress){
        Id recordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get( Label.Contact_Non_Member_Record_Type ).getRecordTypeId();
        
        // Creating Contact record
        return new Contact(LastName = 'Test contact',
                           Unverified_Email_Address__c ='',
                           Email = emailAddress,
                           FirstName ='Dream test',
                           AccountId = accountId,
                           RecordTypeId = recordTypeId,
                           iMIS_ID__c = memberId);
    }
    
    /**
     *@purpose   : Build User record
     *@param     : contactId,userName,profileName,firstName,lastName,nickName
     *@return    : user record
     */
    static User buildUser(Id contactId, String emailAddress, String username, String profileName, String firstName, 
                          String lastName, String nickName, Boolean activation){
        // Fetching profile record
        Profile profileRecord = [SELECT Id
                                 FROM Profile 
                                 WHERE Name =: profileName
								 LIMIT 1];
        System.debug('profileRecord==>'+profileRecord);
        // Create users record
        User userRecord = new User(alias = 'test',
                                   ContactId = contactId,
                                  // AccountId = contactRecord1.AccountId,
                                   ProfileId = profileRecord.Id, 
                                   email = emailAddress, 
                                   emailencodingkey = 'UTF-8',
                                   firstname = firstName,
                                   lastname = lastName, 
                                   CommunityNickname = nickName,
                                   languagelocalekey = 'en_US', 
                                   localesidkey = 'en_US', 
                                   timezonesidkey = 'America/Los_Angeles', 
                                   username = username,
                                   IsActive = activation);
        return userRecord;
    }
    
    /*
     *@Purpose : to test forgotPassword() using email address
     */
    static testMethod void testForgotPasswordForemail(){
        Test.startTest();
        
        Pagereference forgotPasswordPage = Page.DW_Forgot_Password;
        
        User user = [SELECT Id, ContactId, Username 
                     FROM User 
                     WHERE CommunityNickname =: 'usertest'];
        
//        System.runAs(user){
            // fetching contact
            Contact contactRecord = [SELECT Id, AACR_ID__c, Email FROM Contact WHERE LastName = 'Test contact'];
            
            DW_ForgotPasswordController forgotPasswordcon = new DW_ForgotPasswordController();
            forgotPasswordcon.emailAddress = contactRecord.Email;
            forgotPasswordPage.getParameters().put('emailAddress',contactRecord.Email);
            Test.setCurrentPage(forgotPasswordPage);
            
            DW_ForgotPasswordController.forgotPassword();
//        }
        Test.stopTest();
    }
     
    /*
     *@Purpose : to test forgotPassword() using email address
     */
    static testMethod void testForgotPasswordForemail2(){
        Test.startTest();
        
        Account account = [SELECT Id FROM Account];
        // Build Contact record
        //Contact contact= buildContact(account.Id, '112233','');
        //insert contact;
        List<Contact> contacts = [SELECT Id FROM Contact LIMIT 1];
        // Build User recod
        //User user = buildUser(contact.Id, 'dream2@gmail.com','testecrm12@gmail.com', 'Fonteva Customer Community Login User', 'Test', 'User', 'usertest1',false);
        //insert user;
        
        Pagereference forgotPasswordPage = Page.DW_Forgot_Password;
        
        User currentUser = [SELECT Id, ContactId, Username 
                            FROM User 
                            WHERE CommunityNickname =: 'usertest'];
        
//        System.runAs(currentUser){
            // fetching contact
            Contact contactRecord = [SELECT Id, AACR_ID__c, Email FROM Contact WHERE Id =: contacts[0].Id];
            
            DW_ForgotPasswordController forgotPasswordcon = new DW_ForgotPasswordController();
            forgotPasswordcon.emailAddress = contactRecord.Email;
            forgotPasswordPage.getParameters().put('emailAddress',contactRecord.Email);
            Test.setCurrentPage(forgotPasswordPage);
            
            DW_ForgotPasswordController.forgotPassword();

        forgotPasswordcon.emailAddress = 'testy.testerson@yopmail.com';
        forgotPasswordPage.getParameters().put('emailAddress','testy.testerson@yopmail.com');
        Test.setCurrentPage(forgotPasswordPage);

        DW_ForgotPasswordController.forgotPassword();
//        }
        Test.stopTest();
    }
 
    /*
     *@Purpose : to test forgotPassword() using Member Id
     */
    static testMethod void testForgotPasswordForMemberId(){
        Test.startTest();
        
        Account account = [SELECT Id FROM Account];
        // Build Contact record
        //Contact contact= buildContact(account.Id, '112233','');
        //insert contact;
       
        // Build User recod
        //User user = buildUser(contacts[0].Id, 'dream2@gmail.com','ecrmtest11@gmail.com','Fonteva Customer Community Login User', 'Test', 'User', 'usertest1',false);
        //insert user;
       
        Pagereference forgotPasswordPage = Page.DW_Forgot_Password;
        Test.setCurrentPage(forgotPasswordPage);
        
        User currentuser = [SELECT Id, ContactId, Username 
                            FROM User 
                            WHERE CommunityNickname =: 'usertest'];
        
//        System.runAs(currentuser){
            Contact contactRecord = [SELECT Id, AACR_ID__c FROM Contact WHERE AccountId =: account.Id LIMIT 1];
            
            DW_ForgotPasswordController forgotPasswordCon = new DW_ForgotPasswordController();
            forgotPasswordCon.emailAddress = 'test';
            DW_ForgotPasswordController.forgotPassword();  
           
            forgotPasswordCon.contactAACRID = '112233';
            forgotPasswordPage.getParameters().put('contactAACRID','112233');
            DW_ForgotPasswordController.forgotPassword(); 
//        }
        Test.stopTest();
    }


    /*
     *@Purpose : to test forgotPassword() using Member Id
     */
    static testMethod void testForgotPasswordForMemberId2(){
        Test.startTest();
        
        Account account = [SELECT Id FROM Account];
        // Build Contact record
        //Contact contact= buildContact(account.Id, '1122334455','testdream123@gmail.com');
        //insert contact;
        
        Pagereference forgotPasswordPage = Page.DW_Forgot_Password;
        
        User currentuser = [SELECT Id, ContactId, Username 
                            FROM User 
                            WHERE CommunityNickname =: 'usertest'];
        
//        System.runAs(currentuser){
            Contact contactRecord = [SELECT Id, AACR_ID__c FROM Contact WHERE AccountId =: account.Id LIMIT 1];
            
            DW_ForgotPasswordController forgotPasswordCon = new DW_ForgotPasswordController();
            forgotPasswordCon.contactAACRID = contactRecord.AACR_ID__c;
            forgotPasswordPage.getParameters().put('contactAACRID',contactRecord.AACR_ID__c);
            Test.setCurrentPage(forgotPasswordPage);
            
            DW_ForgotPasswordController.forgotPassword();

            forgotPasswordCon.contactAACRID = '67890';
            forgotPasswordPage.getParameters().put('contactAACRID','67890');
        Test.setCurrentPage(forgotPasswordPage);

        DW_ForgotPasswordController.forgotPassword();


//        }
        Test.stopTest();
    }


    @isTest
    public static void testGenerateTempPassword(){
        Test.startTest();

        String pass = DW_ForgotPasswordController.generateTemporaryPassword();

        System.assertNotEquals(null, pass);


        Test.stopTest();
    }

    /*
 *@Purpose : test encodeEmail()
 */
    static testMethod void testEncodeEmail(){
        Test.startTest();
        DW_ForgotPasswordController.encodeEmail('testcontact5@gmail.com');
        Test.stopTest();
    }
    /*
     *@Purpose : to test updateContact() 
     */
//    static testMethod void testUpdateContact(){
//         Account account = [SELECT Id FROM Account WHERE Name ='Test account'];
//        // Build Contact record
//        //Contact contact= buildContact(account.Id, '11224455','testcontact@gmail.com');
//        //insert contact;
//
//        Test.startTest();
//
//        Contact contactRecord = [SELECT Id, AACR_ID__c FROM Contact WHERE AccountId =: account.Id LIMIT 1];
//
//        DW_ForgotPasswordController forgotPasswordCon1 = new DW_ForgotPasswordController();
//        forgotPasswordCon1.contactAACRID = contactRecord.AACR_ID__c;
//        // test forgot password method
//        DW_ForgotPasswordController.forgotPassword();
//
//        // set valid email address field
//        forgotPasswordCon1.validEmailAddress = 'testcontact2@gmail.com';
//        // test updateContact() method
//        forgotPasswordCon1.updateContact();
//
//        DW_ForgotPasswordController forgotPasswordCon2 = new DW_ForgotPasswordController();
//        // set valid email address field
//        forgotPasswordCon2.validEmailAddress = '';
//        // test updateContact() method
//        forgotPasswordCon2.updateContact();
//
//        DW_ForgotPasswordController forgotPasswordCon3 = new DW_ForgotPasswordController();
//        forgotPasswordCon3.contactAACRID = '1234';
//        // set valid email address field
//        forgotPasswordCon3.validEmailAddress = 'testcontact5@gmail.com';
//        // test updateContact() method
//        forgotPasswordCon3.updateContact();
//
//        Test.stopTest();
//    }
    

    
    /*
     *@Purpose : test sendResetPasswordMail()
     */
    static testMethod void testSendResetPasswordMail1(){

        Test.startTest();

        Pagereference forgotPasswordPage = Page.DW_Forgot_Password;
        Test.setCurrentPage(forgotPasswordPage);

        Account acc = [SELECT Id FROM Account];

        // Build Contact record
        Contact contact= buildContact(acc.Id, '38457','testy.testerson@yopmail.com');
        contact.LastName = 'Test Contact 2';
        insert contact;

        // Build User record
        User user = buildUser(contact.Id, contact.email,'testy.testerson@yopmail.com.129837','Fonteva Customer Community Login User', 'Test2', 'User', 'usertest2', true);
        insert user;

        DW_ForgotPasswordController forgotPasswordCon = new DW_ForgotPasswordController();
        forgotPasswordCon.emailAddress = 'testy.testerson@yopmail.com';
        forgotPasswordPage.getParameters().put('emailAddress','testy.testerson@yopmail.com');
        Test.setCurrentPage(forgotPasswordPage);

        DW_ForgotPasswordController.forgotPassword();

        forgotPasswordCon.sendResetPasswordMail();

        forgotPasswordCon.emailAddress = null;
        forgotPasswordCon.contactAACRID = '38457';
        forgotPasswordPage.getParameters().put('emailAddress',null);
        forgotPasswordPage.getParameters().put('contactAACRID','38457');
        Test.setCurrentPage(forgotPasswordPage);

        forgotPasswordCon.sendResetPasswordMail();
//        }
        Test.stopTest();
    }
//
//    /*
//     *@Purpose : test sendResetPasswordMail()
//     */
//    static testMethod void testSendResetPasswordMail2(){
//
//        Test.startTest();
//
//        Pagereference forgotPasswordPage = Page.DW_Forgot_Password;
//        Test.setCurrentPage(forgotPasswordPage);
//
//        User currentuser = [SELECT Id, ContactId, Username
//                            FROM User
//                            WHERE CommunityNickname =: 'usertest'];
//
////        System.runAs(currentuser){
//        Contact contactRecord = [SELECT Id, AACR_ID__c, Email FROM Contact WHERE LastName ='Test contact'];
//        DW_ForgotPasswordController forgotPasswordCon = new DW_ForgotPasswordController();
//        forgotPasswordCon.contactAACRID = contactRecord.AACR_ID__c;
//        forgotPasswordPage.getParameters().put('contactAACRID',contactRecord.AACR_ID__c);
//        Test.setCurrentPage(forgotPasswordPage);
//
//        DW_ForgotPasswordController.forgotPassword();
//
//        forgotPasswordCon.sendResetPasswordMail();
////        }
//        Test.stopTest();
//    }
    
//    /*
//     *@Purpose : test to cover code
//     */
//    static testMethod void testForCodeCoverage(){
//        Test.startTest();
//
//        Account account = [SELECT Id FROM Account];
//
//
//        // Build Contact record
//        //Contact contact= buildContact(account.Id, '908070','testForgotPWController@example.com');
//       //insert contact;
//
//        DW_ForgotPasswordController forgotPasswordCon = new DW_ForgotPasswordController();
////        forgotPasswordCon.contactAACRID = '45781';
//        forgotPasswordCon.emailAddress = 'testercm@gmail.com';
//        DW_ForgotPasswordController.forgotPassword();
//
////        DW_ForgotPasswordController.validateContactAACRId('testecrm50@gmail.com','1234');
////        //DW_ForgotPasswordController.createCommunityUser(contact);
////        DW_ForgotPasswordController.validateUserName('test@dream.com');
//
//        Test.stopTest();
//    }
    
    /*
     *@Purpose : test validateUserName()
     */
//    static testMethod void testvalidateUserName(){
//        Test.startTest();
//
//        Account account = [SELECT Id FROM Account];
//        // Build Contact record
//        //Contact contact= buildContact(account.Id, '018271','testecrm102@gmail.com');
//        //insert contact;
//
//        List<Contact> contacts = [SELECT Email FROM Contact LIMIT 1];
//
//        DW_ForgotPasswordController.validateUserName(contacts[0].email);
//        Test.stopTest();
//    }
    /*
     *@Purpose : test getUserEmailofContact()
     */
//    static testMethod void testGetUserEmailofContact(){
//        Test.startTest();
//
//        Account account = [SELECT Id FROM Account];
//        // Build Contact record
//        //Contact contact= buildContact(account.Id, '80000','testecrm103@gmail.com');
//        //insert contact;
//        List<Contact> contacts = [SELECT Email, AACR_ID__c FROM Contact LIMIT 1];
//
//        DW_ForgotPasswordController forgotPasswordCon1 = new DW_ForgotPasswordController();
//        forgotPasswordCon1.getUserEmailofContact(contacts[0].email,'');
//
//        DW_ForgotPasswordController forgotPasswordCon2 = new DW_ForgotPasswordController();
//        forgotPasswordCon2.getUserEmailofContact('abc@test1.com','');
//
//        DW_ForgotPasswordController forgotPasswordCon3 = new DW_ForgotPasswordController();
//        forgotPasswordCon3.getUserEmailofContact('','345354');
//
//        DW_ForgotPasswordController forgotPasswordCon4 = new DW_ForgotPasswordController();
//        forgotPasswordCon4.getUserEmailofContact('',contacts[0].AACR_ID__c);
//        forgotPasswordCon4.sendResetPasswordMail();
//
//        Test.stopTest();
//    }
}