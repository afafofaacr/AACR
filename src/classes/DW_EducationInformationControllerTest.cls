/**
 *@Purpose      : Test class for DW_EducationInformationController
 *@Created Date : 03-10-2018
 *@Modified Date: 03-10-2018
 */
@isTest
public class DW_EducationInformationControllerTest {

    /**
     *@purpose   : build test data.
     */
    @testSetup
    private static void buildTestData(){ 
        
        // build Account record
        Account account = buildAccount('Test Account1');
        insert account;
        
        // Build Contact record
        Contact contact= buildContact(account.Id);
        insert contact;
        
        // Build User recod
        User user = buildUser(contact.Id);
        insert user;

        // Building education records
        List<Education__c> educationList = buildEducation(contact.Id);
        insert educationList;
        
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
                           Phone ='9878986789',
                           Fax = 'fax');
    }
    
    /**
     *@purpose   : Build User record
     *@param     : contactId
     *@return    : User record
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
     *@purpose   : Build eduction records
     *@param     : ContactId 
     *@return    : Education List
     */
    static List<Education__c> buildEducation(Id contactId){
        List<Education__c> eductionList = new List<Education__c>();
        
        for(Integer index = 0; index < 5; index++){
           eductionList.add(new Education__c(Education_Related_to_Contact__c = contactId,
                                             Name = 'Engineering',
                                             Current_Education_Status__c = 'Graduate Student',
                                             Date_of_Expected_Graduation__c = System.today(),
                                             Degree__c = 'BE',
                                             Degree_Completion_Year__c = '2020'));
        }
        return eductionList;
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
     *@return    : step record
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
        return new joinapi__Step__c (joinapi__Page_Title__c = 'DW_WorkingGroups',
                                     joinapi__Next_Step__c = nextStepId,
                                     joinapi__Is_First_Step__c = true,
                                     joinapi__Order__c = 1,
                                     joinapi__Visual_Force_Page_API_Name__c ='DW_WorkingGroups',
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
                                     joinapi__Order__c = 2,
                                     joinapi__Visual_Force_Page_API_Name__c ='DW_QualifyingQuestions',
                                     joinapi__Join_Process__c = joinProcessId,
                                     joinapi__Is_Custom_Page__c = true);
    }
    
    /**
     *@purpose   : Build step record
     *@param     : nextStepId, joinProcessId
     *@return    : step record
     */ 
    static joinapi__Step__c buildNextStep(Id nextStepId, Id joinProcessId){
        return new joinapi__Step__c (joinapi__Page_Title__c = 'DW_JPMembership',
                                     joinapi__Order__c = 4,
                                     joinapi__Next_Step__c = nextStepId,
                                     joinapi__Visual_Force_Page_API_Name__c ='DW_JPMembership',
                                     joinapi__Join_Process__c = joinProcessId,
                                     joinapi__Is_Custom_Page__c = true
                                   );
    }
       
    /**
     *@purpose   : Build step record
     *@param     : nextStepId, joinProcessId
     *@return    : step record
     */ 
    static joinapi__Step__c buildFirstStep(Id nextStepId, Id joinProcessId){
        return new joinapi__Step__c (joinapi__Page_Title__c = 'DW_JournalSubscription',
                                     joinapi__Next_Step__c = nextStepId,
                                     joinapi__Order__c = 5,
                                     joinapi__Visual_Force_Page_API_Name__c ='DW_JournalSubscription',
                                     joinapi__Join_Process__c = joinProcessId,
                                     joinapi__Is_Custom_Page__c = true);
    }
    
    /**
     *@purpose   : Build EducationInfoDTO record
     *@param     : 
     *@return    : EducationInfoDTO serialize string
     */ 
    static String buildEducationInfoDTO(){
        
        List<String> deletedEducationIdList = new List<String>();
        for(Education__c eductaion : [SELECT Id FROM Education__c WHERE Name = 'Engineering']){
            deletedEducationIdList.add(eductaion.Id);
        }
        
        Contact contact = [SELECT Id FROM Contact WHERE LastName =: 'Test contact'];
        List<Education__c> eductionList = buildEducation(contact.Id);
        insert eductionList; 
        
        DW_ECRMDTO.EducationInfoDTO educationInfo = new DW_ECRMDTO.EducationInfoDTO();
        educationInfo.Educations = eductionList;
        educationInfo.DeletedEducationIdList = deletedEducationIdList;
        
        return JSON.serialize(educationInfo);
    }
    
    /**
     *@Purpose : test getEducationInformation() positively
     */
    static testMethod void testGetEducationInfo(){
        Test.startTest();
        
        User user = [SELECT Id, ContactId 
                     FROM User 
                     WHERE lastname =: 'Test User2'];
        
        System.runAs(user){
            DW_EducationInformationController eductionCon = new DW_EducationInformationController();
            // fetching step record
            joinapi__Step__c step = [SELECT Id, joinapi__Order__c, joinapi__Next_Step__c 
                                     FROM joinapi__Step__c 
                                     WHERE joinapi__Page_Title__c = 'DW_QualifyingQuestions'];
            
            DW_ECRMDTO.Response response = DW_EducationInformationController.getEducationInformation(step.Id);
            System.assertEquals('User Contact Data & Page Metadata', response.message);
            System.assertEquals(true, response.isSuccess);
            System.debug('response1==>'+response);
            
        }
        Test.stopTest();
    }
    
    /**
     *@Purpose : test saveEducationInformation() positively
     */
    private static testMethod void testSaveEducationInformation(){
        Test.startTest();
        
        User user = [SELECT Id, ContactId 
                     FROM User 
                     WHERE lastname =: 'Test User2'];
        
        System.runAs(user){
            
            String educationString = buildEducationInfoDTO();
            // fetching step record
            joinapi__Step__c step = [SELECT Id, joinapi__Order__c, joinapi__Next_Step__c 
                                     FROM joinapi__Step__c 
                                     WHERE joinapi__Page_Title__c = 'DW_QualifyingQuestions'];
            
            DW_ECRMDTO.Response response = DW_EducationInformationController.saveEducationInformation(educationString, step.Id);
            System.assertEquals('User education information updated successfully', response.message);
            System.assertEquals(true, response.isSuccess);
        }
        Test.stopTest();
    }
}