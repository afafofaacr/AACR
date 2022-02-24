/**
 *@Purpose       : Test class for DW_JPMembershipCtrl controller
 *@Created Date  : 23-08-2018
 *@Modified Date : 
 */
@isTest
public class DW_JPMembershipCtrlTest {

    @testSetup
    private static void buildTestData(){ 
        
        joinapi__Join_Process__c joinProcess =  buildJoinProcess();
        insert joinProcess;
        
        joinapi__Step__c step = buildPreviousStep();
        insert step;
        
        joinapi__Step__c firstStep = buildStep(step.Id, joinProcess.Id);
        insert firstStep;
        
        joinapi__Step__c secoundStep = buildCurrentStep(firstStep.Id, joinProcess.Id);
        insert secoundStep;
        
        joinapi__Step__c thirdStep = buildNextStep(secoundStep.Id, joinProcess.Id);
        insert thirdStep;
        
        joinapi__Step__c forthStep = buildFirstStep(thirdStep.Id, joinProcess.Id);
        insert forthStep;
        
         // build Account record
        Account account = buildAccount('Test Account1');
        insert account;
        
        // Build Contact record
        Contact contact= buildContact(account.Id);
        insert contact;
        
        // Build User recod
        User user = buildUser(contact.Id);
        insert user;
        
        OrderApi__Item_Class__c itemClass = buildItemClass();
        insert itemClass;
        
        OrderApi__Item__c item = buildItem(itemClass.Id);
        insert item;
        
        joinapi__Step_Condition__c stepCondition = buildStepCondition(item.Id, firstStep.Id);
        insert stepCondition;
    }
    
    /**
     *@purpose   : Build join process
     *@parameter : -
     *@return    : join process record
     */
    static joinapi__Join_Process__c buildJoinProcess(){
        return new joinapi__Join_Process__c(joinapi__Join_Process_Display_Name__c = 'CM-Custom JP',
                                            joinapi__Is_Published__c = true,
                                            joinapi__Landing_Url__c = ''
                                            );
    }
    
    /**
     *@purpose   : Build step record
     *@param     : -
     *@return    : step record
     */ 
    static joinapi__Step__c buildStep(Id nextStepId, Id joinProcessId){
        return new joinapi__Step__c (joinapi__Page_Title__c = 'DW_workinggroups',
                                     joinapi__Next_Step__c = nextStepId,
                                     joinapi__Is_First_Step__c = true,
                                     joinapi__Order__c = 1,
                                     joinapi__Visual_Force_Page_API_Name__c ='DW_workinggroups',
                                     joinapi__Join_Process__c = joinProcessId,
                                     joinapi__Is_Custom_Page__c = true,
                                     joinapi__Is_Authentication_Step__c = true);
                                     
    }
    
     /**
     *@purpose   : Build step record
     *@param     : -
     *@return    : step record
     */ 
    static joinapi__Step__c buildCurrentStep(Id nextStepId, Id joinProcessId){
        return new joinapi__Step__c (joinapi__Page_Title__c = 'DW_QualifyingQuestions',
                                     joinapi__Next_Step__c = nextStepId,
                                     joinapi__Order__c = 1,
                                     joinapi__Visual_Force_Page_API_Name__c ='DW_QualifyingQuestions',
                                     joinapi__Join_Process__c = joinProcessId,
                                     joinapi__Is_Custom_Page__c = true,
                                     joinapi__Is_Authentication_Step__c = true);
                                     
    }
    
    /**
     *@purpose   : Build next step record
     *@param     : -
     *@return    : step record
     */ 
    static joinapi__Step__c buildNextStep(Id nextStepId, Id joinProcessId){
        return new joinapi__Step__c (joinapi__Page_Title__c = 'DW_JPMembership',
                                     joinapi__Order__c = 1,
                                     joinapi__Next_Step__c = nextStepId,
                                     joinapi__Visual_Force_Page_API_Name__c ='DW_JPMembership',
                                     joinapi__Join_Process__c = joinProcessId,
                                     joinapi__Is_Custom_Page__c = true,
                                     joinapi__Is_Authentication_Step__c = true);
                                    
                                 
    }
    
    /**
     *@purpose   : Build previous step record
     *@param     : -
     *@return    : step record
     */ 
    static joinapi__Step__c buildPreviousStep(){
       return new joinapi__Step__c (joinapi__Page_Title__c = 'DW_CommunicationPreferences',
                                    joinapi__Order__c = 3,
                                    joinapi__Visual_Force_Page_API_Name__c ='DW_CommunicationPreferences',
                                    joinapi__Is_Custom_Page__c = true,
                                    joinapi__Is_Authentication_Step__c = true);
                                   
    }
    
    /**
     *@purpose   : Build step record
     *@param     : nextStepId, joinProcessId
     *@return    : step record
     */ 
    static joinapi__Step__c buildFirstStep(Id nextStepId, Id joinProcessId){
        return new joinapi__Step__c (joinapi__Page_Title__c = 'DW_JournalSubscription',
                                     joinapi__Next_Step__c = nextStepId,
                                     joinapi__Order__c = 1,
                                     joinapi__Visual_Force_Page_API_Name__c ='DW_JournalSubscription',
                                     joinapi__Join_Process__c = joinProcessId,
                                     joinapi__Is_Custom_Page__c = true,
                                     joinapi__Is_Authentication_Step__c = true);
                                    
                                    
    }
    
    /**
     *@purpose   : Build step condition record
     *@param     : itemId, stepId
     *@return    : step condition record
     */ 
    static joinapi__Step_Condition__c buildStepCondition(Id itemId, Id stepId){
        return new joinapi__Step_Condition__c(joinapi__Is_Published__c = true,
                                              joinapi__Is_Marketing_Item__c = true,
                                              joinapi__Item__c = itemId,
                                              joinapi__Next_Step__c = stepId);
    }
    
    /**
     *@purpose   : Build Item class record 
     *@parameter : -
     *@return    : Itesm class record
     */
    private static OrderApi__Item_Class__c buildItemClass(){
        return new OrderApi__Item_Class__c(Name = 'Complimentary Journals',
                                           Is_Membership__c =  false);
    }
    
    /**
     *@purpose   : Build Item record
     *@parameter : itemClassId
     *@return    : Item record
     */
    private static OrderApi__Item__c buildItem(Id itemClassId){
        return  new OrderApi__Item__c(Name = 'Test Item ',
                                      OrderApi__Item_Class__c = itemClassId,
                                      OrderApi__Is_Active__c = true,
                                      Is_Active_Membership_Type__c =true,
                                      OrderApi__Price__c = 50,
                                      Fon_Association_Journal_Type__c = 'Online Only',
                                      Eligible_Nominator_Membership__c = true);
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
        Id recordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get( Label.Contact_Non_Member_Record_Type ).getRecordTypeId();
        
        // Creating Contact record
        return new Contact(LastName = 'Test contact',
                           AccountId = accountId,
                           RecordTypeId = recordTypeId,
                           is_affiliated_with_self__c = false,
                           OtherStreet = 'city galaxy street',
                           MailingStreet ='Test mailing street');
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
     *@Purpose : to test DW_JPMembershipCtrl()
     */
    static testMethod void testDWJPMembershipCtrl(){
        Test.startTest();
        
        User user = [SELECT Id, ContactId 
                     FROM User 
                     WHERE lastname =: 'Test User2'];
        
        System.runAs(user){
            DW_JPMembershipCtrl jpMembershipctrl = new DW_JPMembershipCtrl();
        }
        
        Test.stopTest();
    }
    
    /**
     *@Purpose : to test nextStep(), previousStep(), cancelStep()
     */
    static testMethod void testSteps(){
        Test.startTest();
        
        joinapi__Step__c step1 = [SELECT Id, joinapi__Order__c, joinapi__Next_Step__c ,joinapi__Visual_Force_Page_API_Name__c,joinapi__Join_Process__c
                                  FROM joinapi__Step__c
                                  WHERE joinapi__Page_Title__c = 'DW_JPMembership'];
        
        Contact contact = [SELECT Id 
                           FROM Contact 
                           WHERE LastName = 'Test contact'];
        
        
            
        PageReference jPAddMembership = Page.DW_jpaddrmembership;
        Test.setCurrentPage(jPAddMembership);
        
        // Put Id into the current page Parameters
        ApexPages.currentPage().getParameters().put('id',step1.Id);
        String id = ApexPages.currentPage().getParameters().get('id');
        DW_JPMembershipCtrl jpMembershipctrl = new DW_JPMembershipCtrl();
        jpMembershipctrl.UserContactData = contact;
        
        jpMembershipctrl.nextStep();
        jpMembershipctrl.previousStep();
        jpMembershipctrl.cancelStep();
        
        Test.stopTest();
    }
        
    /**
     *@Purpose : to test getAddressoptions
     */  
    static testMethod void testGetAddressoptions(){
        Test.startTest();
        
        DW_JPMembershipCtrl jpMembershipctrl = new DW_JPMembershipCtrl();
        List<SelectOption> options = jpMembershipctrl.getAddressoptions();
       
        Test.stopTest();
    }
    
    /**
     *@Purpose : to test saveAccount()
     */ 
    static testMethod void testSaveAccount(){
        Test.startTest();
        
        DW_JPMembershipCtrl jpMembershipctrl = new DW_JPMembershipCtrl();
       
        PageReference jPAddMembership = Page.DW_jpaddrmembership;
        Test.setCurrentPage(jPAddMembership);
        
        // Put Id into the current page Parameters
        ApexPages.currentPage().getParameters().put('contactFieldApiName','Preferred_Address__c');
        ApexPages.currentPage().getParameters().put('contactFieldValue','Preferred Address');
        
        DW_JPMembershipCtrl.saveAccount('Test Account');
        
        jpMembershipctrl.updateContactField();
        jpMembershipctrl.getIsPreviewMode();
        jpMembershipctrl.cancelPreview();
        jpMembershipctrl.getConObj();
       
        Test.stopTest();
    }
}