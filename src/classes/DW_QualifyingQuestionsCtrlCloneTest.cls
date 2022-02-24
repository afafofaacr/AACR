/**
 *@Purpose       : Test class for DW_QualifyingQuestionsControllerClone controller
 *@Created Date  : 21-08-2018
 *@Modified Date : 
 */
@isTest
public class DW_QualifyingQuestionsCtrlCloneTest {
    
    /**
     *@purpose   : build test data.
     */
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
        
        List<Education__c> educationList = buildEducations(contact.Id);
        insert educationList;
        
        // build Account record
        Account account2 = buildAccount('Test Account2');
        insert account2;
        
        // Build Contact record
        Contact contact2 = buildContact(account2.Id);
        insert contact2;
        
        List<Education__c> deletedEducationList = buildEducations(contact2.Id);
        insert deletedEducationList;
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
     *@purpose   : Build step record
     *@param     : -
     *@return    : -
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
     *@param     : -
     *@return    : -
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
     *@purpose   : Build next step record
     *@param     : -
     *@return    : -
     */ 
    static joinapi__Step__c buildNextStep(Id nextStepId, Id joinProcessId){
        return new joinapi__Step__c (joinapi__Page_Title__c = 'DW_JPMembership',
                                     joinapi__Order__c = 1,
                                     joinapi__Next_Step__c = nextStepId,
                                     joinapi__Visual_Force_Page_API_Name__c ='DW_JPMembership',
                                     joinapi__Join_Process__c = joinProcessId,
                                     joinapi__Is_Custom_Page__c = true
                                   );
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
    static joinapi__Step__c buildFirstStep(Id nextStepId, Id joinProcessId){
        return new joinapi__Step__c (joinapi__Page_Title__c = 'DW_JournalSubscription',
                                     joinapi__Next_Step__c = nextStepId,
                                     joinapi__Order__c = 1,
                                     joinapi__Visual_Force_Page_API_Name__c ='DW_JournalSubscription',
                                     joinapi__Join_Process__c = joinProcessId,
                                     joinapi__Is_Custom_Page__c = true);
    }
    
    /**
     *@purpose   : build Account record
     *@param     : -
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
                                   CommunityNickname = 'test user2',
                                   languagelocalekey = 'en_US', 
                                   localesidkey = 'en_US', 
                                   timezonesidkey = 'America/Los_Angeles', 
                                   username = System.now().millisecond() + 'test@testorg2.com');
        return userRecord;
    }
    
    /**
     *@purpose   : Build educations records
     *@param     : -
     *@return    : educationList
     */   
    static List<Education__c> buildEducations(Id contactId){
        List<Education__c> educationList = new List<Education__c>();
        
        for(Integer index = 0; index < 10 ; index++){
            educationList.add(new Education__c(Name ='Test Education',
                                               Degree__c = 'AAS',
                                               Education_Related_to_Contact__c = contactId,
                                               Degree_Completion_Year__c ='2000',
                                               Date_of_Expected_Graduation__c = system.today()));
        }
        
        return educationList;
    }
    
    /**
     *@purpose   : Build UserContactData
     *@param     : -
     *@return    : 
     */ 
    static DW_DTO.UserContactData userContactData( List<Education__c> educationList,Contact contact, List<string> deletedEductionIdList ){
        System.debug('contact==>'+contact);
        DW_DTO.UserContactData userData = new DW_DTO.UserContactData();
        userData.Contact = contact;
        userData.Educations = educationList;
        userData.DeletedEducationIdList = deletedEductionIdList;
        return userData;
    }
    
    /**
     *@purpose : to test  getQualifyingQuestionsData()
     */
    static testMethod void testgetQualifyingQuestionsData(){
        Test.startTest();
        
        User user = [SELECT Id, ContactId 
                     FROM User 
                     WHERE lastname =: 'Test User2'];
        
        System.runAs(user){
            Account account1 = [SELECT Id FROM Account WHERE Name =: 'Test Account1'];
            Account account2 = [SELECT Id FROM Account WHERE Name =:'Test Account2']; 
            // Build Contact record
            Contact contact = [SELECT Id, Name,LastName, Phone ,Fax,
                                      Additional_Research_Areas__c, Specific_Research_Areas__c , Other_Research_Areas__c , Primary_Research_Area_of_Expertise__c 
                               FROM Contact 
                               WHERE AccountId =: account1.Id]; 
            
            Contact contact2 = [SELECT Id FROM Contact WHERE AccountId =: account2.Id];
            
            List<Education__c> educationList = [SELECT Id,Name,Degree__c, Education_Related_to_Contact__c,
                                                       Degree_Completion_Year__c ,
                                                       Date_of_Expected_Graduation__c FROM Education__c WHERE Education_Related_to_Contact__c =: contact.Id];
            
            List<Education__c> deletedEductionList = [SELECT Id FROM Education__c WHERE Education_Related_to_Contact__c =: contact2.Id];
            
            List<String> deletedEductionIdList = new List<string>();
            for(Education__c education : deletedEductionList){
                deletedEductionIdList.add(education.Id);
            }   
        
            DW_DTO.UserContactData userContactData = userContactData(educationList, contact, deletedEductionIdList);
            
            DW_QualifyingQuestionsControllerClone qualQuesCon = new DW_QualifyingQuestionsControllerClone();
            
            joinapi__Step__c step1 = [SELECT Id FROM joinapi__Step__c WHERE joinapi__Page_Title__c = 'DW_JPMembership'];
           
            DW_DTOClone.Response response = DW_QualifyingQuestionsControllerClone.getQualifyingQuestionsData(step1.Id);
        }
        
        Test.stopTest();
    }
    
    /**
     *@purpose : to test  saveUserContactData()
     */
    static testMethod void testSaveUserContactData(){
        Test.startTest();
       
        Account account1 = [SELECT Id FROM Account WHERE Name =: 'Test Account1'];
        
        // Build Contact record
        Contact contact = [SELECT Id, Name,LastName, Phone ,
                                  Fax, Additional_Research_Areas__c, Specific_Research_Areas__c , Other_Research_Areas__c , Primary_Research_Area_of_Expertise__c 
                           FROM Contact 
                           WHERE AccountId =: account1.Id]; 
        
        Account account2 = [SELECT Id FROM Account WHERE Name =:'Test Account2'];
        Contact contact2 = [SELECT Id FROM Contact WHERE AccountId =: account2.Id];
        
        List<Education__c> educationList = [SELECT Id FROM Education__c WHERE Education_Related_to_Contact__c =: contact.Id];
        
        List<Education__c> deletedEductionList = [SELECT Id FROM Education__c WHERE Education_Related_to_Contact__c =: contact2.Id];
        
        List<String> deletedEductionIdList = new List<string>();
        for(Education__c education : deletedEductionList){
            deletedEductionIdList.add(education.Id);
        }  
        
        joinapi__Step__c step = [SELECT Id FROM joinapi__Step__c WHERE joinapi__Order__c =: 3];
        DW_DTO.UserContactData userContactData = userContactData(educationList, contact, deletedEductionIdList);
        DW_DTOClone.Response response = DW_QualifyingQuestionsControllerClone.saveUserContactData(JSON.serialize(userContactData), step.Id);
        System.assertEquals(response.Success, true);
        System.assertEquals(response.Message, 'User contact data updated successfully');
        
        DW_MetadataDTO.QualifyingQuestionsPageDTO quilifyQues = new DW_MetadataDTO.QualifyingQuestionsPageDTO();
        quilifyQues.NextStepURL = 'next step';
        
        Test.stopTest();
    }
    
}