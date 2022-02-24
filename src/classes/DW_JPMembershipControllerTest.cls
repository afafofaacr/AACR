/**
 *@Purpose       : Test class for DW_JPMembershipController controller
 *@Created Date  : 21-08-2018
 *@Modified Date : 
 */
@isTest
public class DW_JPMembershipControllerTest {

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
        
        OrderApi__Item_Class__c itemClass = buildItemClass();
        insert itemClass;
        
        OrderApi__Item__c item = buildItem('Active', itemClass.Id);
        insert item;
        
        // build Account record
        Account account = buildAccount('Test Account1');
        insert account;
        
        // Build Contact records
        List<Contact> contactList = buildContacts(account.Id, item.Id);
        insert contactList;

        OrderApi__Sales_Order__c salesOrder = buildSalesOrder(contactList[0].Id);
        insert salesOrder;
        
        OrderApi__Sales_Order_Line__c salesOrderLI = buildSalesOrderLI(salesOrder.Id, itemClass.Id, item.Id);
        insert salesOrderLI;
       
        // Build User recod
        User user = buildUser(contactList[0].Id);
        insert user;
        
        OrderApi__Subscription_Plan__c subPlan = buildsubPlan();
        insert subPlan;
        
        OrderApi__Subscription__c subscription = buildSubscription(contactList[0].Id, subPlan.Id, item.Id, itemClass.Id );
        insert subscription;
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
    static List<Contact> buildContacts(Id accountId, Id itemId){
        Id recordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Contact Default').getRecordTypeId();
        List<Contact> contactList = new List<Contact>();
        
        for(Integer index = 0; index < 5 ; index++){
            contactList.add(new Contact(LastName = 'Test contact',
                        AccountId = accountId,
                        RecordTypeId = recordTypeId,
                        Email = 'con@test.com',
                        iMIS_ID__c ='',
                        Membership_Id__c = itemId,
                        Membership_Status__c = 'Current'));
        }
        for(Integer index = 0; index < 5 ; index++){
            contactList.add(new Contact(LastName = 'Disuza Test',
                        AccountId = accountId,
                        RecordTypeId = recordTypeId,
                        Email = 'con@test.com',
                        iMIS_ID__c ='',
                        Membership_Id__c = itemId
                        ));
        }
        // Creating Contact record
        return contactList;
    }
    
    /**
     *@purpose   : Build subscription plan
     *@parameter : -
     *@return    : -
     */
    static OrderApi__Subscription_Plan__c buildsubPlan(){
        return new OrderApi__Subscription_Plan__c(Name = '2 Year Term');
    }
    
    /**
     *@purpose   : Build OrderApi__Subscription__c record
     *@param     : -
     *@return    : -
     */
    static OrderApi__Subscription__c buildSubscription(Id contactId, Id subPlanId,Id itemId, Id itemclassId){
        return new OrderApi__Subscription__c(OrderApi__Contact__c = contactId,
                                             OrderApi__Subscription_Plan__c = subPlanId,
                                             OrderApi__Item__c = itemId,
                                             OrderApi__Is_Active__c =false,
                                             OrderApi__Item_Class__c = itemclassId,
                                             OrderApi__Current_Term_Start_Date__c = system.today());
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
     *@purpose   : Build Item class record 
     *@parameter : -
     *@return    : Itesm class record
     */
    private static OrderApi__Item_Class__c buildItemClass(){
        return new OrderApi__Item_Class__c(Name = 'Individual Memberships',
                                           Is_Membership__c =  false);
    }
    
    /**
     *@purpose   : Build Item record
     *@parameter : -
     *@return    : Item record
     */
    private static OrderApi__Item__c buildItem(String itemName, Id itemClassId){
        return  new OrderApi__Item__c(Name = itemName,
                                      OrderApi__Item_Class__c = itemClassId,
                                      OrderApi__Is_Active__c = true,
                                      Is_Active_Membership_Type__c =true,
                                      OrderApi__Price__c = 50,
                                      Fon_Association_Journal_Type__c = 'Online Only',
                                      Eligible_Nominator_Membership__c = true);
    }
    
    /**
     *@purpose   : Build Attachment record
     *@parameter : -
     *@return    : -
     */
    private static List<Attachment> buildAttchments(){
        List<Attachment> attchmentList = new List<Attachment>();
        Contact contact = [SELECT Id FROM Contact LIMIt 1];
        Blob bodyBlob=Blob.valueOf('Unit Test Attachment Body');
        
        Attachment attach1=new Attachment(); 
        attach1.Name='Unit Test Attachment'; 
        attach1.body=bodyBlob; 
        attach1.parentId=contact.Id; 
        attach1.ContentType = 'application/msword'; 
        attach1.IsPrivate = false; 
        attach1.Description = 'Test'; 
        attchmentList.add(attach1);
        
        Attachment attach2=new Attachment(); 
        attach2.Name='Unit Test Attachment'; 
        attach2.body=bodyBlob; 
        attach2.parentId=contact.Id; 
        attach2.ContentType = 'application/msword'; 
        attach2.IsPrivate = false; 
        attach2.Description = 'Test'; 
        attchmentList.add(attach2);
        
        return attchmentList;
    } 
        
    
    /**
     *@purpose   : Build Attachment_x record
     *@parameter : -
     *@return    : list of Attachment_x
     */
    static List<DW_JPMembershipController.Attachment_x> buildAttachments(){
        List<DW_JPMembershipController.Attachment_x> attachmentList = new List<DW_JPMembershipController.Attachment_x>();
        DW_JPMembershipController.Attachment_x attch;
        List<Attachment> attchmentList = buildAttchments();
        insert attchmentList;
        
        for(Attachment attchment : attchmentList){
            attch = new DW_JPMembershipController.Attachment_x(attchment.Id, attchment.Name);
            attch.body ='Test attch body';
            attachmentList.add(attch);
        }
        return attachmentList;
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
     *@Purpose : Build sales order
     *@Param   : contactId
     *@return  : sales order rwecord
     */
    static OrderApi__Sales_Order__c buildSalesOrder(Id contactId){
        return new OrderApi__Sales_Order__c(OrderApi__Contact__c = contactId);
    }
    
    /**
     *@purpose   : Build sales order Line items
     *@parameter : sales Order Id, item id, item class
     *@return    : sales Order line item record
     */
    static OrderApi__Sales_Order_Line__c buildSalesOrderLI(Id salesOrderId, Id itemClassId, Id itemId){
        return new OrderApi__Sales_Order_Line__c(OrderApi__Item_Class__c = itemClassId,
                                                 OrderApi__Item__c = itemId,
                                                 OrderApi__Sales_Order__c = salesOrderId);
    }
    
    /**
     *@Purpose : to test doInit()
     */
    static testMethod void testDoInit(){
        Test.startTest();
        
        User user = [SELECT Id, ContactId 
                     FROM User 
                     WHERE lastname =: 'Test User2'];
        
        
        System.runAs(user){
            DW_JPMembershipController jpMembershipcon = new DW_JPMembershipController();
            joinapi__Step__c step1 = [SELECT Id, joinapi__Order__c, joinapi__Next_Step__c 
                                      FROM joinapi__Step__c 
                                      WHERE joinapi__Page_Title__c = 'DW_QualifyingQuestions']; 
            Response response1 = DW_JPMembershipController.doInit(step1.Id);
            
            OrderApi__Sales_Order__c salesOrder = [SELECT Id FROM OrderApi__Sales_Order__c];
            OrderApi__Item_Class__c itemClass = [SELECT Id FROM OrderApi__Item_Class__c];
            OrderApi__Item__c item = [SELECT Id, Name FROM OrderApi__Item__c];
            item.Name = 'Student';
            update item;
            
            OrderApi__Sales_Order_Line__c salesOrderLI1 = buildSalesOrderLI(salesOrder.Id,itemClass.Id,item.Id);
            insert salesOrderLI1;
            Response response2 = DW_JPMembershipController.doInit(step1.Id);
            
            item.Name = 'Affiliate';
            update item;
            
            OrderApi__Sales_Order_Line__c salesOrderLI2 = buildSalesOrderLI(salesOrder.Id,itemClass.Id,item.Id);
            insert salesOrderLI2;
            Response response3 = DW_JPMembershipController.doInit(step1.Id);
        }
        Test.stopTest(); 
    }
    
    /**
     *@Purpose : to test verifyNominators() positively
     */
    static testMethod void posTestVerifyNominators(){
        Test.startTest();
        
        List<Contact> contactList = [SELECT Id,Name, Email,AACR_ID__c, Membership_Id__c, Membership_Status__c, iMIS_ID__c, AccountId 
                                     FROM Contact 
                                     WHERE LastName = 'Test contact'];
        
        OrderApi__Subscription__c subscription = [SELECT Id,OrderApi__Contact__c 
                                                  FROM OrderApi__Subscription__c];
        
        List<String> contactIdList = new List<String>();
        for(Contact contact : contactList){
            contactIdList.add(contact.Id);
        }
        
        Response response1 = DW_JPMembershipController.verifyNominators(contactList[0].Id ,contactList[0].AACR_ID__c, contactList[0].Email, contactIdList);
        
        Test.stopTest();
    }
    
    /**
     *@Purpose : to test verifyNominators() negatively
     */
    static testMethod void negTestVerifyNominators(){
        Test.startTest();
        
        List<Contact> contactList = [SELECT Id,Name, Email,AACR_ID__c, Membership_Id__c, Membership_Status__c, iMIS_ID__c, AccountId 
                                     FROM Contact 
                                     WHERE LastName = 'Disuza Test'];
     
        OrderApi__Subscription__c subscription = [SELECT Id,OrderApi__Contact__c 
                                                  FROM OrderApi__Subscription__c];
        
        List<String> contactIdList = new List<String>();
        for(Contact contact : contactList){
            contactIdList.add(contact.Id);
        }
        
        //DW_JPMembershipController.verifyNominators(contactList[0].Id ,contactList[0].AACR_ID__c, contactList[0].Email, contactIdList);
        Response response1 = DW_JPMembershipController.verifyNominators(contactList[0].Id ,contactList[0].AACR_ID__c, contactList[0].Email, null);
       // System.assertEquals(response1.message, 'Please enter member# or email');
        
        Response response2 = DW_JPMembershipController.verifyNominators(NULL,'','', null);
        System.assertEquals(response2.message, 'Please provide contact id');
        
        Test.stopTest();
    }
    
    /**
     *@Purpose : to test nextStep() positively
     */
    static testMethod void posTestNextStep(){
        Test.startTest();
         
        List<Contact> contactList = [SELECT Id,Name, Email,AACR_ID__c, Membership_Id__c, Membership_Status__c, iMIS_ID__c, AccountId 
                                     FROM Contact 
                                     WHERE LastName = 'Test contact'];
        
        List<DW_JPMembershipController.Attachment_x> attachmentList = buildAttachments();
        
        joinapi__Step__c step1 = [SELECT Id, joinapi__Order__c, joinapi__Next_Step__c 
                                  FROM joinapi__Step__c 
                                  WHERE joinapi__Page_Title__c = 'DW_QualifyingQuestions'];
        
        List<String> nominatorIdList = new List<String>();
        for(Contact contact : contactList){
            nominatorIdList.add(contact.Id);
        }
        
        List<String> attchmentIdsList = new List<String>();
        for(DW_JPMembershipController.Attachment_x attchment : attachmentList){
            attchmentIdsList.add(attchment.id);
        }
        
        DW_JPMembershipController.nextStep(contactList[0].Id, step1.Id, attachmentList, nominatorIdList, attchmentIdsList);
        Test.stopTest();
    }
    
    /**
     *@Purpose : to test nextStep() negatively
     */
    static testMethod void negTestNextStep(){
        Test.startTest();
        
        OrderApi__Item__c item = [SELECT Id, Is_Active_Membership_Type__c FROM OrderApi__Item__c];
        item.Is_Active_Membership_Type__c = false;
        update item;
        
        List<Contact> contactList = [SELECT Id,Name, Email,AACR_ID__c, Membership_Id__c, Membership_Status__c, iMIS_ID__c, AccountId 
                                     FROM Contact 
                                     WHERE LastName = 'Test contact' LIMIT 2];
        
        List<DW_JPMembershipController.Attachment_x> attachmentList = buildAttachments();
        
        joinapi__Step__c step1 = [SELECT Id, joinapi__Order__c, joinapi__Next_Step__c,joinapi__Join_Process__c
                                  FROM joinapi__Step__c 
                                  WHERE joinapi__Page_Title__c = 'DW_QualifyingQuestions'];
        
        List<String> nominatorIdList = new List<String>();
        for(Contact contact : contactList){
            nominatorIdList.add(contact.Id);
        }
         
        List<String> attchmentIdsList = new List<String>();
        for(DW_JPMembershipController.Attachment_x attchment : attachmentList){
            attchmentIdsList.add(attchment.id);
        }
        
        DW_JPMembershipController.nextStep(contactList[0].Id, step1.Id, attachmentList, nominatorIdList, attchmentIdsList);
        DW_JPMembershipController.nextStep(NULL, step1.Id, attachmentList, nominatorIdList, attchmentIdsList);
        
        Test.stopTest();
    }
    
    /**
     *@Purpose : to test previousStep(), cancelStep()
     */
    static testMethod void testSteps(){
        Test.startTest();
        
        joinapi__Step__c step1 = [SELECT Id, joinapi__Order__c, joinapi__Next_Step__c ,joinapi__Visual_Force_Page_API_Name__c,joinapi__Join_Process__c
                                  FROM joinapi__Step__c
                                  WHERE joinapi__Page_Title__c = 'DW_JPMembership'];
        
        PageReference jPMembership = Page.DW_JPMembership;
        Test.setCurrentPage(jPMembership);
        
        // Put Id into the current page Parameters
        ApexPages.currentPage().getParameters().put('id',step1.Id);
        ApexPages.currentPage().getParameters().put('isJoin','true');
        String id = ApexPages.currentPage().getParameters().get('id');
        
        DW_JPMembershipController jpMembershipcon = new DW_JPMembershipController();
        jpMembershipcon.cancelPreview();
        jpMembershipcon.getIsPreviewMode();
        jpMembershipcon.previousStep();
        jpMembershipcon.cancelStep();
        
        Test.stopTest();
    }
    
    /**
     *@Purpose : to test deleteAttachment
     */
    static testMethod void testDeleteAttachment(){
        Test.startTest();
        
        User user = [SELECT Id, ContactId 
                     FROM User 
                     WHERE lastname =: 'Test User2'];
        
        
        System.runAs(user){
            Contact contact = [SELECT Id FROM Contact WHERE LastName = 'Test contact' LIMIT 1];
            List<DW_JPMembershipController.Attachment_x> attachmentList = buildAttachments();
            
            DW_JPMembershipController.deleteAttachment(contact.Id, attachmentList[0].Id);
        }
        Test.stopTest();
    }
}