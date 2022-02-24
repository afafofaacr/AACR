/**
 *@Purpose      : Test class for DW_ECRMControllerCloneClone
 *@Created Date : 27-07-2018
 *@Modified Date: 19-09-2018
 */
@isTest
private class DW_ECRMControllerCloneCloneTest {
    
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
        
        //Build Item class
        List<OrderApi__Item_Class__c> itemClassList = buildItemClass();
        insert itemClassList;
        
        // Build Items
        List<OrderApi__Item__c> itemList = buildItems(itemClassList);
        insert itemList;
        
        OrderApi__Sales_Order__c salesOrder = buildSalesOrder(contact.Id);
        insert salesOrder;
        
        DW_Working_Group_Step_Config__c workingGrpSetting = buildWorkingGrpConfigSetting();
        insert workingGrpSetting;
        
        contact_last_accessed_step__c contactLastStep = buildContactLastStep( contact.Id, joinProcess.Id);
        insert contactLastStep;
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
     *@return    : user record
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
     *@return    : step recod
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
     *@return    : step recod
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
     *@purpose   : Build Item class records 
     *@parameter : -
     *@return    : itemClassList
     */
    private static List<OrderApi__Item_Class__c> buildItemClass(){
        List<OrderApi__Item_Class__c> itemClassList = new List<OrderApi__Item_Class__c>();
        
        itemClassList.add(new OrderApi__Item_Class__c(Name = 'Complimentary Journals'));
        itemClassList.add(new OrderApi__Item_Class__c(Name = 'Working Groups'));
        itemClassList.add(new OrderApi__Item_Class__c(Name = 'Journal Subscriptions'));
        itemClassList.add(new OrderApi__Item_Class__c(Name = 'Legacy Items'));
        itemClassList.add(new OrderApi__Item_Class__c(Name = 'Merchandise'));
        itemClassList.add(new OrderApi__Item_Class__c(Name = 'Individual Memberships'));
        
        return itemClassList;
    }
    
    /**
     *@purpose   : Build Item class records 
     *@parameter : -
     *@return    : itemClassList
     */
    private static List<OrderApi__Item__c> buildItems(List<OrderApi__Item_Class__c> itemClassList){
        List<OrderApi__Item__c> itemList = new List<OrderApi__Item__c>();
        
        for(Integer index = 0; index < itemClassList.size(); index++){
            itemList.add(new OrderApi__Item__c(Name = 'Test Item '+index,
                                               OrderApi__Item_Class__c = itemClassList[index].Id,
                                               OrderApi__Is_Active__c = true,
                                               OrderApi__Price__c = 50,
                                               Fon_Association_Journal_Type__c = 'Online Only'));
            
            itemList.add(new OrderApi__Item__c(Name = 'Test Item '+index,
                                               OrderApi__Item_Class__c = itemClassList[index].Id,
                                               OrderApi__Is_Active__c = true,
                                               OrderApi__Price__c = 60,
                                               Fon_Association_Journal_Type__c = 'Print & Online'));
            
            itemList.add(new OrderApi__Item__c(Name = 'Test Item '+index,
                                               OrderApi__Item_Class__c = itemClassList[index].Id,
                                               OrderApi__Is_Active__c = false,
                                               OrderApi__Price__c = 60,
                                               Fon_Association_Journal_Type__c = 'Online Only'));
            
            itemList.add(new OrderApi__Item__c(Name = 'Test Item '+index,
                                               OrderApi__Item_Class__c = itemClassList[index].Id,
                                               OrderApi__Is_Active__c = true,
                                               Fon_Association_Journal_Type__c = 'Print & Online'));
        }
        return itemList;
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
     *@Purpose : build Item Class Names Setting
     *@Param   : Name, itemClassName
     *@return  : Item Class Names Settings record
     */
    private static DW_Item_Class_Names_Setting__c buildItemClassSetting(String Name, String itemClassName){
        return new  DW_Item_Class_Names_Setting__c(Name = Name,
                                                   Class_Name__c = itemClassName);
        
    }
    
    /**
     *@Purpose : build ItemDTO records
     *@Param   : 
     *@return  : 
     */
    private static List<DW_ECRMDTO.ItemDTO> buildItemDTORecords(List<OrderApi__Item__c> itemList){
        List<DW_ECRMDTO.ItemDTO> itemDTOList = new List<DW_ECRMDTO.ItemDTO>();
        DW_ECRMDTO.ItemDTO itemDTO;     
        
        for(OrderApi__Item__c item : itemList){
            itemDTO = new DW_ECRMDTO.ItemDTO();
            
            itemDTO.Id = item.Id;
            itemDTO.name = item.Name;
            itemDTO.price = item.OrderApi__Price__c;
            itemDTO.type = item.Fon_Association_Journal_Type__c;
            
            itemDTOList.add(itemDTO);
        }
        return itemDTOList;
    }
    
    /**
     *@Purpose : getting items list
     *@param   : class Name
     *@return  : itemList
     */
    private static List<OrderApi__Item__c> getItems(Set<String> classNamesSet){
        List<OrderApi__Item__c> itemList = [SELECT Id, Name, OrderApi__Price__c, Fon_Association_Journal_Type__c
                                            FROM OrderApi__Item__c 
                                            WHERE OrderApi__Item_Class__r.Name IN : classNamesSet AND
                                                  OrderApi__Is_Active__c = true];
        return itemList;
    }
    
    /**
     *@Purpose : Build DW_Working_Group_Step_Config__c setting
     *@param   : -
     *@return  : DW_Working_Group_Step_Config__c record
     */
    static DW_Working_Group_Step_Config__c buildWorkingGrpConfigSetting(){
        joinapi__Step__c step = [SELECT Id, Name
                                 FROM joinapi__Step__c 
                                 WHERE joinapi__Page_Title__c = 'DW_QualifyingQuestions'];
        return new DW_Working_Group_Step_Config__c(Name = 'DW Working Group Step Config',
                                                   Step_Name__c = step.Name);
    }
    
    /**
     *@Purpose : Build Contact last step accessed record
     *@Param   : 
     *@return  : sales order rwecord
     */
    static contact_last_accessed_step__c buildContactLastStep(Id contactId, Id joinProcesId ){
        return new contact_last_accessed_step__c(Contact__c = contactId,
                                                 Join_Process__c = joinProcesId,
                                                 Step_Order__c = 2);
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
     *@Purpose : test getJournals() positively
     */
    private static testMethod void posTestGetJournals(){
        Test.startTest();
        
        User user = [SELECT Id, ContactId 
                     FROM User 
                     WHERE lastname =: 'Test User2'];
        
        System.runAs(user){
            
            DW_Item_Class_Names_Setting__c comlimentryJournals = buildItemClassSetting('Complimentary Journals','Complimentary Journals');
            insert comlimentryJournals;
            
            DW_Item_Class_Names_Setting__c journalsubscriptions = buildItemClassSetting('Journal Subscriptions','Journal Subscriptions');
            insert journalsubscriptions;
            
            DW_ECRMControllerClone ecrmCon = new DW_ECRMControllerClone();
            Set<String> itemClassNamesSet  = new Set<String>();
            itemClassNamesSet.add(comlimentryJournals.Class_Name__c);
            itemClassNamesSet.add(journalsubscriptions.Class_Name__c);
            
            List<OrderApi__Item__c> itemList = getItems(itemClassNamesSet);
            
            OrderApi__Sales_Order__c salesOrder =[SELECT Id FROM OrderApi__Sales_Order__c];
            joinapi__Step__c step = [SELECT Id, joinapi__Order__c, joinapi__Next_Step__c 
                                     FROM joinapi__Step__c 
                                     WHERE joinapi__Page_Title__c = 'DW_QualifyingQuestions'];
            
            OrderApi__Item__c item = [SELECT Id, OrderApi__Item_Class__c FROM OrderApi__Item__c WHERE OrderApi__Item_Class__r.Name =: 'Individual Memberships' LIMIT 1];
            OrderApi__Sales_Order_Line__c salesOrderLI = buildSalesOrderLI(salesOrder.Id, item.OrderApi__Item_Class__c, item.Id);
            insert salesOrderLI;
            
            DW_ECRMDTO.Response response = DW_ECRMControllerClone.getJournals(true, salesOrder.Id, step.Id);
        }
        Test.stopTest();
    }
    
    /**
     *@Purpose : test getWorkingGroups() positively
     */
    private static testMethod void posTestGetWorkingGroups(){
        Test.startTest();
        
        User user = [SELECT Id, ContactId 
                     FROM User 
                     WHERE lastname =: 'Test User2'];
        
        System.runAs(user){
            
            DW_Item_Class_Names_Setting__c workingGroups = buildItemClassSetting('Working Groups','Working Groups');
            insert workingGroups;
            
            Set<String> itemClassNamesSet  = new Set<String>();
            itemClassNamesSet.add(workingGroups.Class_Name__c);
            
            List<OrderApi__Item__c> itemList = getItems(itemClassNamesSet);
            
            OrderApi__Sales_Order__c salesOrder =[SELECT Id FROM OrderApi__Sales_Order__c];
            joinapi__Step__c step = [SELECT Id, joinapi__Order__c, joinapi__Next_Step__c 
                                     FROM joinapi__Step__c 
                                     WHERE joinapi__Page_Title__c = 'DW_QualifyingQuestions'];
            DW_ECRMDTO.Response response = DW_ECRMControllerClone.getWorkingGroups(true, salesOrder.Id, step.Id,'modify');
        }
        Test.stopTest();
    }
    
    /**
     *@Purpose : test getOptionalItems() positively
     */
    private static testMethod void posTestGetOptionalItems(){
        Test.startTest();
        
        User user = [SELECT Id, ContactId 
                     FROM User 
                     WHERE lastname =: 'Test User2'];
        
        System.runAs(user){
            DW_Item_Class_Names_Setting__c legacyItem = buildItemClassSetting('Legacy Items','Legacy Items');
            insert legacyItem;
            
            DW_Item_Class_Names_Setting__c merchandiseItem = buildItemClassSetting('Merchandise','Merchandise');
            insert merchandiseItem;
            
            Set<String> itemClassNamesSet  = new Set<String>();
            itemClassNamesSet.add(legacyItem.Class_Name__c);
            itemClassNamesSet.add(merchandiseItem.Class_Name__c);
            
            List<OrderApi__Item__c> itemList = getItems(itemClassNamesSet);
            joinapi__Step__c step = [SELECT Id, joinapi__Order__c, joinapi__Next_Step__c 
                                     FROM joinapi__Step__c 
                                     WHERE joinapi__Page_Title__c = 'DW_QualifyingQuestions'];
            
            DW_ECRMDTO.Response response = DW_ECRMControllerClone.getOptionalItems(step.Id);
        }
        Test.stopTest();
    }
    
    /**
     *@Purpose : test createSalesOrderLines() positively
     */
    private static testMethod void testCreateSalesOrdLinesForOptional(){
        Test.startTest();
        
        User user = [SELECT Id, ContactId 
                     FROM User 
                     WHERE lastname =: 'Test User2'];
        
        System.runAs(user){
            OrderApi__Sales_Order__c salesOrder = [SELECT Id FROM OrderApi__Sales_Order__c];
            String success = Label.DW_Optional_Items_Success_Msg;
            
            // Item class set
            Set<String> itemClassNamesSet  = new Set<String>();
            itemClassNamesSet.add('Merchandise');
            itemClassNamesSet.add('Legacy Items');
            
            List<OrderApi__Item__c> optionalItemList = getItems(itemClassNamesSet);
            
            joinapi__Step__c step = [SELECT Id 
                                     FROM joinapi__Step__c 
                                     WHERE joinapi__Page_Title__c = 'DW_QualifyingQuestions'];
            DW_ECRMDTO.Response response = DW_ECRMControllerClone.createSalesOrderLines(salesOrder.Id, buildItemDTORecords(optionalItemList), 'Optional Items', buildItemDTORecords(optionalItemList),
                                                                                   true, step.Id);
            
            List<OrderApi__Sales_Order_Line__c> salesOrderLineItemsList = [SELECT Id, OrderApi__Item__c, OrderApi__Quantity__c, OrderApi__Sales_Order__c 
                                                                           FROM OrderApi__Sales_Order_Line__c 
                                                                           WHERE OrderApi__Sales_Order__c =: salesOrder.Id];
            
            System.assertEquals(optionalItemList.size(), salesOrderLineItemsList.size());
        }
        Test.stopTest();    
    }
    
    /**
     *@Purpose : test createSalesOrderLines() for journals positively
     */
    private static testMethod void testCreateSalesOrdLinesForJournals(){
        Test.startTest();
        
        User user = [SELECT Id, ContactId 
                     FROM User 
                     WHERE lastname =: 'Test User2'];
        
        System.runAs(user){
            OrderApi__Sales_Order__c salesOrder = [SELECT Id FROM OrderApi__Sales_Order__c];
            
            String success = Label.DW_Journal_Success_Msg;
            
            // Item class set
            Set<String> itemClassNamesSet  = new Set<String>();
            itemClassNamesSet.add('Complimentary Journals');
            itemClassNamesSet.add('Journal Subscriptions');
            
            List<OrderApi__Item__c> journalItemList = getItems(itemClassNamesSet);
            joinapi__Step__c step = [SELECT Id
                                     FROM joinapi__Step__c 
                                     WHERE joinapi__Page_Title__c = 'DW_QualifyingQuestions'];
            DW_ECRMDTO.Response response = DW_ECRMControllerClone.createSalesOrderLines(salesOrder.Id, buildItemDTORecords(journalItemList), 'Journals', buildItemDTORecords(journalItemList),
                                                                                   true, step.Id);
            
            List<OrderApi__Sales_Order_Line__c> salesOrderLineItemsList = [SELECT Id, OrderApi__Item__c, OrderApi__Quantity__c, OrderApi__Sales_Order__c 
                                                                           FROM OrderApi__Sales_Order_Line__c 
                                                                           WHERE OrderApi__Sales_Order__c =: salesOrder.Id];
            
            System.assertEquals(journalItemList.size(), salesOrderLineItemsList.size());
        }
        Test.stopTest();    
    }
    
    /**
     *@Purpose : test createSalesOrderLines() for Working Group positively
     */
    private static testMethod void testCreateSalesOrdLinesForWorkingGrp(){
        Test.startTest();
        
        User user = [SELECT Id, ContactId 
                     FROM User 
                     WHERE lastname =: 'Test User2'];
        
        System.runAs(user){
            OrderApi__Sales_Order__c salesOrder = [SELECT Id FROM OrderApi__Sales_Order__c];
            
            String success = Label.DW_Working_Groups_Success_Msg;
            
            // Item class set
            Set<String> itemClassNamesSet  = new Set<String>();
            itemClassNamesSet.add('Working Groups');
            
            List<OrderApi__Item__c> workingGroupItemList = getItems(itemClassNamesSet);
            joinapi__Step__c step = [SELECT Id
                                     FROM joinapi__Step__c 
                                     WHERE joinapi__Page_Title__c = 'DW_QualifyingQuestions'];
            
            DW_ECRMDTO.Response response = DW_ECRMControllerClone.createSalesOrderLines(salesOrder.Id, buildItemDTORecords(workingGroupItemList), 'Working Groups',buildItemDTORecords(workingGroupItemList),
                                                                                   true, step.Id);
            
            List<OrderApi__Sales_Order_Line__c> salesOrderLineItemsList = [SELECT Id, OrderApi__Item__c, OrderApi__Quantity__c, OrderApi__Sales_Order__c 
                                                                           FROM OrderApi__Sales_Order_Line__c 
                                                                           WHERE OrderApi__Sales_Order__c =: salesOrder.Id];
            
            System.assertEquals(workingGroupItemList.size(), salesOrderLineItemsList.size());
        }
        Test.stopTest();
        
    }
    
    /**
     *@Purpose : test createSalesOrderLines() for Working Group positively
     */
    private static testMethod void testUpdateContactsJournalAddr(){
        Test.startTest();
        
        User user = [SELECT Id, ContactId 
                     FROM User 
                     WHERE lastname =: 'Test User2'];
        
        System.runAs(user){
            Contact contact = [SELECT Id FROM Contact WHERE Id =: user.ContactId];
            DW_ECRMControllerClone ecrmCon = new DW_ECRMControllerClone();
            ecrmCon.UserContactData = contact;
            //ecrmCon.updateContactsJournalAddr();
            DW_ECRMControllerClone.updateContactsJournalAddr();
        }
        Test.stopTest();
    }
      
    /**
     *@Purpose : test updateContactLastAccessedStep() 
     */
    private static testMethod void testUpdateContactLastAccessedStep(){
        Test.startTest();
        
        User user = [SELECT Id, ContactId 
                     FROM User 
                     WHERE lastname =: 'Test User2'];
        
        System.runAs(user){
            joinapi__Step__c step = [SELECT Id
                                     FROM joinapi__Step__c 
                                     WHERE joinapi__Page_Title__c = 'DW_QualifyingQuestions'];
            DW_ECRMDTO.Response response = DW_ECRMControllerClone.updateContactLastAccessedStep(step.Id);
        }
        Test.stopTest();
    }
}