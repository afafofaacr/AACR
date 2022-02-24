/**
 *@Purpose       : Test class for DW_JPMembershipController controller
 *@Created Date  : 03-09-2018
 *@Modified Date : 
 */
@isTest
public class DW_ProgressBarCtrlTest {
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
        
        // build Account record
        Account account = buildAccount();
        insert account;
        
        // Build Contact record
        Contact contact= buildContact(account.Id);
        insert contact;
        
        // Build User recod
        User user = buildUser(contact.Id);
        insert user;
        
        DW_ManagePagesWithSalesOrder__c managePagewithSO = buildManagePagesWithSalesOrder();
        insert managePagewithSO;
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
                                   CommunityNickname = 'JeelyDisuza',
                                   languagelocalekey = 'en_US', 
                                   localesidkey = 'en_US', 
                                   timezonesidkey = 'America/Los_Angeles', 
                                   username = 'test@testorg2.com');
        return userRecord;
    }
    
    /**
     *@purpose   : Build join process
     *@parameter : -
     *@return    : join process record
     */
    static joinapi__Join_Process__c buildJoinProcess(){
        return new joinapi__Join_Process__c(joinapi__Join_Process_Display_Name__c = 'CM-Custom JP',
                                            joinapi__Is_Published__c = true,
                                            joinapi__Landing_Url__c = '' );
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
     *@param     : -
     *@return    : -
     */ 
    static joinapi__Step__c buildStep(Id nextStepId, Id joinProcessId){
        return new joinapi__Step__c (joinapi__Page_Title__c = 'DW_workinggroups',
                                     joinapi__Next_Step__c = nextStepId,
                                     joinapi__Is_First_Step__c = true,
                                     joinapi__Order__c = 0,
                                     joinapi__Visual_Force_Page_API_Name__c ='DW_workinggroups',
                                     joinapi__Join_Process__c = joinProcessId,
                                     joinapi__Is_Custom_Page__c = true);
    }
    
    /**
     *@purpose   : Build step record
     *@param     : -
     *@return    : -
     */ 
    static joinapi__Step__c buildCurrentStep(Id nextStepId, Id joinProcessId){
        return new joinapi__Step__c (joinapi__Page_Title__c = 'DW_QualifyingQuestions',
                                     joinapi__Next_Step__c = nextStepId,
                                     joinapi__Order__c = 2,
                                     joinapi__Visual_Force_Page_API_Name__c ='DW_QualifyingQuestions',
                                     joinapi__Join_Process__c = joinProcessId,
                                     joinapi__Is_Custom_Page__c = true);
    }
    
    /**
     *@Purpose : build manage pages with sales order Setting
     *@Param   : -
     *@return  : DW_ManagePagesWithSalesOrder setting
     */
    private static DW_ManagePagesWithSalesOrder__c buildManagePagesWithSalesOrder(){
        return new  DW_ManagePagesWithSalesOrder__c(Name = 'Page Names',
                                                    Page_Name__c = 'DW_JournalSubscription,DW_WorkingGroups,DW_OptionalItem');
    }
    
    /**
     *@Purpose : to test getProgressBarDetails() positively
     */
    static testMethod void posTestGetProgressBarDetails(){
        Test.startTest();
        
        User user = [SELECT Id, ContactId 
                     FROM User 
                     WHERE lastname =: 'Test User2'];
        
        System.runAs(user){
            joinapi__Step__c step = [SELECT Name, joinapi__Next_Step__c, joinapi__Page_Title__c, joinapi__Order__c, 
                                            joinapi__Visual_Force_Page_API_Name__c 
									FROM joinapi__Step__c WHERE joinapi__Order__c =: 0];
            
            DW_ECRMDTO.Response response = DW_ProgressBarCtrl.getProgressBarDetails(step.Id, true);
        }
        Test.stopTest();
    }
    
    /**
     *@Purpose : to test getProgressBarDetails() negatively
     */
    static testMethod void negTestGetProgressBarDetails(){
        Test.startTest();
        
        User user = [SELECT Id, ContactId 
                     FROM User 
                     WHERE lastname =: 'Test User2'];
        
        System.runAs(user){
            joinapi__Step__c step = [SELECT Name, joinapi__Next_Step__c, joinapi__Page_Title__c, joinapi__Order__c, 
                                           joinapi__Visual_Force_Page_API_Name__c 
                                     FROM joinapi__Step__c WHERE joinapi__Order__c =: 2];
            
            DW_ECRMDTO.Response response = DW_ProgressBarCtrl.getProgressBarDetails(step.Id, true);
        }
        Test.stopTest();
    }
    
    /**
     *@Purpose : to test appendUrlParam()
     */
    static testMethod void testAppendUrlParam(){
        Test.startTest();
        DW_ProgressBarCtrl progressBarCtrl = new DW_ProgressBarCtrl();
        progressBarCtrl.appendUrlParam(
               'https://aacruatf-fontevacustomer-15e958fad93-15f4a97b013.cs97.force.com/DW_WorkingGroups?','isjoin','true');
        
        Test.stopTest();
    }

}