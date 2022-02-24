/**
 *@Purpose       : Test class for DW_aacrCustomLoginController controller
 *@Created Date  : 31-08-2018
 *@Modified Date : 25-10-2018
 */
@isTest
public class DW_aacrCustomLoginControllerTest {

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
        
        joinapi__Join_Process__c joinProcess =  buildJoinProcess();
        insert joinProcess;
        
        // Build User recod
        User user = buildUser(contact.Id, 'test@testorg2.com', 'Fonteva Customer Community Login User', 'Test', 'User', 'usertest');
        insert user;

        //buildContact2
        Contact contact2= buildContact(account.Id);
        contact2.LastName = 'Test Contact 2';
        insert contact2;

        //build user with bad email address
        User userBadEmail = buildUser(contact2.Id, 'test2@testorg2.com', 'Fonteva Customer Community Login User', 'Test', 'User2', 'usertest2');
        userBadEmail.Email = 'email@example.com';
        userBadEmail.Bad_Email_Address__c = true;
        userBadEmail.UserRoleId = null;
        insert userBadEmail;
      
        joinapi__Step__c step = buildPreviousStep();
        insert step;
        
        joinapi__Step__c firstStep = buildStep(step.Id, joinProcess.Id);
        insert firstStep;
        
        joinapi__Step__c secoundStep = buildCurrentStep(firstStep.Id, joinProcess.Id);
        insert secoundStep;
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
                           RecordTypeId = recordTypeId
                           );
    }
    
    /**
     *@purpose   : Build User record
     *@param     : contactId
     *@return    : -
     */
    static User buildUser(Id contactId, String userName, String profileName, String firstName, String lastName, String nickName){
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
                                   email = 'test@testorg.com', 
                                   emailencodingkey = 'UTF-8',
                                   firstname = firstName,
                                   lastname = lastName, 
                                   CommunityNickname = nickName,
                                   languagelocalekey = 'en_US', 
                                   localesidkey = 'en_US', 
                                   timezonesidkey = 'America/Los_Angeles', 
                                   isActive = true,
                                   username = userName);
        return userRecord;
    }
    
    /**
     *@purpose   : Build join process
     *@parameter : -
     *@return    : join process record
     */
    static joinapi__Join_Process__c buildJoinProcess(){
        return new joinapi__Join_Process__c(joinapi__Join_Process_Display_Name__c = 'AACR Membership Join Process',
                                            joinapi__Is_Published__c = true,
                                            joinapi__Landing_Url__c = '' );
    }
    
    /**
     *@Purpose : Build sales order
     *@Param   : contactId
     *@return  :
     */
    static OrderApi__Sales_Order__c buildSalesOrder(Id contactId){
        return new OrderApi__Sales_Order__c(OrderApi__Contact__c = contactId);
    }
    
    /**
     *@purpose   : Build Item class record 
     *@parameter : -
     *@return    : Itesm class record
     */
    private static OrderApi__Item_Class__c buildItemClass(String itemClassName){
        return new OrderApi__Item_Class__c(Name = itemClassName,
                                           Is_Membership__c =  false);
    }
    
    /**
     *@purpose   : Build Item  record 
     *@parameter : -
     *@return    : item record
     */    
    private static OrderApi__Item__c buildItem(Id itemClassId){
        return new OrderApi__Item__c(OrderApi__Item_Class__c = itemClassId,
                                     Name = 'Test Item');
    }
    
    /**
     *@Purpose : Build sales order LI
     *@Param   : salesOrderId
     *@return  :
     */
    static OrderApi__Sales_Order_Line__c buildSalesOrderLI(Id salesOrderId, Id itemId){
        return new OrderApi__Sales_Order_Line__c(OrderApi__Sales_Order__c = salesOrderId,
                                                 OrderApi__Item__c = itemId
                                                 );
    }
    
    /**
     *@Purpose : Build Community User DTO
     *@Param   : -
     *@return  : CommunityUserDTO record
     */
    static DW_aacrCustomLoginController.CommunityUserDTO buildCommunityUserDTO(){
        DW_aacrCustomLoginController.CommunityUserDTO userDTO = new DW_aacrCustomLoginController.CommunityUserDTO();
        userDTO.Firstname = 'Jeely';
        userDTO.Lastname ='Disuza';
        userDTO.Email = 'disuzajelly@gmail.com';
        userDTO.Password = 'test@gmail.com';
        return userDTO;
    }
    
    /**
     *@purpose   : Build previous step record
     *@param     : -
     *@return    : -
     */ 
    static joinapi__Step__c buildPreviousStep(){
       return new joinapi__Step__c (joinapi__Page_Title__c = 'DW_CommunicationPreferences',
                                    joinapi__Order__c = 3,
                                    joinapi__Visual_Force_Page_API_Name__c ='DW_CommunicationPreferences',
                                    joinapi__Is_Custom_Page__c = true);
    }
    
     /**
     *@purpose   : Build step record
     *@param     : nextStepId, joinProcessId
     *@return    : step record
     */ 
    static joinapi__Step__c buildStep(Id nextStepId, Id joinProcessId){
        return new joinapi__Step__c (joinapi__Page_Title__c = 'DW_workinggroups',
                                     joinapi__Next_Step__c = nextStepId,
                                     joinapi__Is_First_Step__c = true,
                                     joinapi__Order__c = 1,
                                     joinapi__Visual_Force_Page_API_Name__c ='DW_workinggroups',
                                     joinapi__Join_Process__c = joinProcessId,
                                     joinapi__Is_Custom_Page__c = true);
    }
    
    /**
     *@purpose   : Build step record
     *@param     : nextStepId, joinProcessId
     *@return    : step record
     */ 
    static joinapi__Step__c buildCurrentStep(Id nextStepId, Id joinProcessId){
        return new joinapi__Step__c (joinapi__Page_Title__c = 'DW_QualifyingQuestions',
                                     joinapi__Next_Step__c = nextStepId,
                                     joinapi__Order__c = 1,
                                     joinapi__Visual_Force_Page_API_Name__c ='DW_QualifyingQuestions',
                                     joinapi__Join_Process__c = joinProcessId,
                                     joinapi__Is_Custom_Page__c = true);
    }
    
    /**
     *@purpose : to test updateSO()
     */
    private static testMethod void testUpdateSO(){
        PageReference pageRef = Page.DW_aacr_custom_login;
        Test.setCurrentPage(pageRef);

        Test.startTest();
        
         // build Account record
        Account account = buildAccount();
        insert account;
        
        // Build Contact record
        Contact contactRecord = buildContact(account.Id);
        insert contactRecord;
        
        // Build User recod
        User fontevaUser = buildUser(contactRecord.Id, 'mem2@fon.com', 'Fonteva Customer Community Login User', 'Fonteva ', 'Membernation',
                                     'JeelyDev');
        insert fontevaUser;
        
        System.runAs(fontevaUser){
            Contact contact = [SELECT Id FROM Contact LIMIT 1];
            
            OrderApi__Sales_Order__c salesOrder = buildSalesOrder(contact.Id);
            insert salesOrder;
            
            OrderApi__Item_Class__c itemClass = buildItemClass('Working Groups');
            insert itemClass;
            
            OrderApi__Item__c item =  buildItem(itemClass.Id);
            insert item;
            
            OrderApi__Sales_Order_Line__c  salesOrderLI = buildSalesOrderLI(salesOrder.Id, item.Id);
            insert salesOrderLI;
          
            DW_aacrCustomLoginController customLoginCon = new DW_aacrCustomLoginController();
            customLoginCon.updateSO('test@testorg2.com');
        }
        Test.stopTest();
    }


    private static testMethod void test_updateUserEmailSuccess(){
        PageReference pageRef = Page.DW_aacr_custom_login;
        Test.setCurrentPage(pageRef);

        User u = [SELECT Id, FirstName, LastName, Email, Username FROM User WHERE Username='test2@testorg2.com'];

        Test.startTest();

        Test.setMock(HttpCalloutMock.class, new SuccessMockHttpResponseGenerator());

        System.RunAs(u)

        {
            DW_aacrCustomLoginController ctrl = new DW_aacrCustomLoginController();
            ctrl.username = u.Username;
            ctrl.objUserDTO.FirstName = u.FirstName;
            ctrl.objUserDTO.LastName = u.LastName;
            ctrl.objUserDTO.Email = u.Email;

            ctrl.updateUserEmail();

        }

        Test.stopTest();
    }

    private static testMethod void test_updateUserEmailFail(){
        PageReference pageRef = Page.DW_aacr_custom_login;
        Test.setCurrentPage(pageRef);

        User u = [SELECT Id, FirstName, LastName, Email, Username FROM User WHERE Username='test2@testorg2.com'];

        Test.startTest();

        Test.setMock(HttpCalloutMock.class, new FailureMockHttpResponseGenerator());
        System.RunAs(u)

        {
            DW_aacrCustomLoginController ctrl = new DW_aacrCustomLoginController();
            ctrl.username = u.Username;
            ctrl.objUserDTO.FirstName = u.FirstName;
            ctrl.objUserDTO.LastName = u.LastName;
            ctrl.objUserDTO.Email = u.Email;

            ctrl.updateUserEmail();
        }

        Test.stopTest();
    }
        
    /**
     *@purpose : to test buildLoginRedirect()
     */
    private static testMethod void testBuildLoginRedirect(){
        PageReference pageRef = Page.DW_aacr_custom_login;
        Test.setCurrentPage(pageRef);

        Test.startTest();
        DW_aacrCustomLoginController customLoginCon = new DW_aacrCustomLoginController();
        customLoginCon.buildLoginRedirect();
        customLoginCon.resetUsername = 'Test user2';
        //customLoginCon.joinProcessURL ='https://aacruatf-fontevacustomer-15e958fad93-15f4a97b013.cs97.force.com';
        Test.stopTest();
    }

    /**
     *@purpose : to test all 
     */
    private static testMethod void testLoginSocialSites(){
        PageReference pageRef = Page.DW_aacr_custom_login;
        Test.setCurrentPage(pageRef);

        Test.startTest();
        
        Pagereference currentPage1 = Page.DW_aacr_custom_login;
        Test.setCurrentPage(currentPage1);
        currentPage1.getParameters().put('system','compusystems');
        currentPage1.getParameters().put('type','');
        
        DW_aacrCustomLoginController customLoginCon1 = new DW_aacrCustomLoginController();
        customLoginCon1.username = 'test@testorg2.com';
        customLoginCon1.password = 'TestUser@1234';
        customLoginCon1.loginLinkedIn();
        customLoginCon1.loginTwitter();
        customLoginCon1.loginGoogle();
        customLoginCon1.checkSession();
        customLoginCon1.login();
        
        Pagereference currentPage2 = Page.DW_aacr_custom_login;
        Test.setCurrentPage(currentPage2);
        currentPage2.getParameters().put('system','');
        currentPage2.getParameters().put('type','');
        
        DW_aacrCustomLoginController customLoginCon2 = new DW_aacrCustomLoginController();
        customLoginCon2.username = 'test@testorg2.com';
        customLoginCon2.password = 'TestUser@1234';
        customLoginCon2.login();
        customLoginCon2.loginLinkedIn();
        customLoginCon2.loginTwitter();
        customLoginCon2.loginGoogle();
        customLoginCon2.checkSession();
        
        
        Pagereference currentPage3 = Page.DW_aacr_custom_login;
        Test.setCurrentPage(currentPage3);
        currentPage3.getParameters().put('system','compusystems');
        currentPage3.getParameters().put('type','manage');
        
        DW_aacrCustomLoginController customLoginCon3 = new DW_aacrCustomLoginController();
        customLoginCon3.username = 'test@testorg2.com';
        customLoginCon3.password = 'TestUser@1234';
        customLoginCon3.login();
        customLoginCon3.loginLinkedIn();
        customLoginCon3.loginTwitter();
        customLoginCon3.loginGoogle();
        customLoginCon3.checkSession();
       
        
        Pagereference currentPage4 = Page.DW_aacr_custom_login;
        Test.setCurrentPage(currentPage4);
        currentPage4.getParameters().put('system','CMR');
        
        DW_aacrCustomLoginController customLoginCon4 = new DW_aacrCustomLoginController();
        customLoginCon4.username = 'test@testorg2.com';
        customLoginCon4.password = 'TestUser@1234';
        customLoginCon4.loginLinkedIn();
        customLoginCon4.loginTwitter();
        customLoginCon4.loginGoogle();
        customLoginCon4.checkSession();
        customLoginCon3.login();
        
        Test.stopTest();
    }
    
    /**
     *@purpose : to test createECRMCommunityUser()
     */
    private static testMethod void testCreateECRMCommunityUser(){
        PageReference pageRef = Page.DW_aacr_custom_login;
        Test.setCurrentPage(pageRef);

        Test.startTest();
        
        User user = [SELECT Id, ContactId 
                     FROM User 
                     WHERE Name =: 'Test User' LIMIT 1];
        
        // build Account record
        Account account = buildAccount();
        insert account;
        
        // Build Contact record
        Contact contact= buildContact(account.Id);
        insert contact;
        
        joinapi__Join_Process__c joinProcess =  buildJoinProcess();
        insert joinProcess;
       
        // Build User recod
        User fontevaUser = buildUser(contact.Id, 'mem@fon.com', 'Fonteva Customer Community Login User', 'Fonteva ', 'Membernation',
                                     'JeelyD');
        insert fontevaUser;
        
        System.runAs(fontevaUser){
            
            DW_aacrCustomLoginController customLoginCon = new DW_aacrCustomLoginController();
            String ownerName = Label.DW_Account_Owner_Name;
            customLoginCon.objUserDTO = buildCommunityUserDTO();
            customLoginCon.createECRMCommunityUser();
            customLoginCon.isUserExists('test@testorg2.com');
        }
        Test.stopTest();
    }

    /**
     *@purpose : to test login()
     */
    private static testMethod void testLogin(){
        PageReference pageRef = Page.DW_aacr_custom_login;
        Test.setCurrentPage(pageRef);

        Test.startTest();
        DW_aacrCustomLoginController customLoginCon = new DW_aacrCustomLoginController();
        customLoginCon.username = 'test@testorg2.com';
        customLoginCon.password = 'TestUser@1234';
        customLoginCon.login();
        Test.stopTest();
    }
    
    /**
     *@purpose : to test login()
     */
    private static testMethod void testLoginException(){
        PageReference pageRef = Page.DW_aacr_custom_login;
        Test.setCurrentPage(pageRef);

        Test.startTest();
        DW_aacrCustomLoginController customLoginCon = new DW_aacrCustomLoginController();
        customLoginCon.username = 'TestUser';
        customLoginCon.password = 'TestUser@1234';
        customLoginCon.login();
        Test.stopTest();
    }
    
    /**
     *@purpose : to test displayMessage()
     */
    private static testMethod void testToCoverCode(){
        PageReference pageRef = Page.DW_aacr_custom_login;
        Test.setCurrentPage(pageRef);

        Test.startTest();
        
        DW_aacrCustomLoginController customLoginCon = new DW_aacrCustomLoginController();
        customLoginCon.errorMsg = 'Error';
        customLoginCon.showModel = true;
        customLoginCon.createContactFromDTO();
        customLoginCon.getFormattedNickName(NULL,NULL);
        customLoginCon.createCommunityUserNickName(NULL,NULL);
        customLoginCon.isUserExists('test@user123.com');
        DW_aacrCustomLoginController.getRecordTypeIdFromSObjectName('','');
        ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.FATAL, 'Error Occured');
        customLoginCon.displayMessage(msg.getSeverity(), msg.getSummary());
        
        Test.stopTest();
    }

    /**
     *@purpose : to test maintenance mode()
     */
    private static testMethod void testMaintenanceMessage(){
        PageReference pageRef = Page.DW_aacr_custom_login;
        Test.setCurrentPage(pageRef);

        Test.startTest();

        DW_aacrCustomLoginController customLoginCon = new DW_aacrCustomLoginController();

        Test.stopTest();

        System.assert(customLoginCon.maintenanceMessage==null, 'Site should not be in maintenance mode.');
    }


    public class SuccessMockHTTPResponseGenerator implements HttpCalloutMock{
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/x-www-form-urlencoded');
            res.setBody('{"email" : {"status": "valid"}}');
            res.setStatusCode(200);
            return res;
        }
    }


    public class FailureMockHTTPResponseGenerator implements HttpCalloutMock{
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/x-www-form-urlencoded');
            res.setBody('{"email" : {"status": "invalid"}}');
            res.setStatusCode(402);
            return res;
        }
    }
   
}