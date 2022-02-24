/**
 *@Purpose       : Test class for DW_CommitteeAutomationTrigger 
 *@Created Date  : 30-08-2018
 *@Modified Date : 
 */
@isTest
public class DW_CommitteeAutomationTriggerTest {
 
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
        
        OrderApi__Item_Class__c workingGroupClass = buildItemClass('Working Groups');
        insert workingGroupClass;
        
        OrderApi__Sales_Order__c salesOrder = buildSalesOrder(contact.Id);
        insert salesOrder;
        
        OrderApi__Item_Class__c indMemClass = buildItemClass('Individual Memberships');
        insert indMemClass;
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
     *@purpose   : Build Item class record 
     *@parameter : -
     *@return    : Itesm class record
     */
    private static OrderApi__Item_Class__c buildItemClass(String itemClassName){
        return new OrderApi__Item_Class__c(Name = itemClassName,
                                           Is_Membership__c =  false);
    }
    
    /**
     *@purpose   : Build Item record
     *@parameter : -
     *@return    : Item record
     */
    static OrderApi__Item__c buildItem(Id itemClassId, String itemName){
        return new OrderApi__Item__c(Name = itemName,
                                     OrderApi__Item_Class__c = itemClassId,
                                     OrderApi__Is_Active__c = true,
                                     Is_Active_Membership_Type__c =true,
                                     OrderApi__Price__c = 50,
                                     Fon_Association_Journal_Type__c = 'Online Only',
                                     Eligible_Nominator_Membership__c = true);
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
     *@purpose : to test single sales order line item Insertion
     */
    static testMethod void testSingleLIInsertDelete(){
        Test.startTest();
        
        User user = [SELECT Id, ContactId 
                     FROM User 
                     WHERE lastname =: 'Test User2'];
        
        System.runAs(user){
            OrderApi__Item_Class__c WorkingGroupClass = [SELECT Id, Name FROM OrderApi__Item_Class__c WHERE Name =: 'Working Groups'];
            OrderApi__Item_Class__c activeMemClass = [SELECT Id, Name FROM OrderApi__Item_Class__c WHERE Name =: 'Individual Memberships'];
            
            
            OrderApi__Item__c workingGroupitem1 = buildItem(WorkingGroupClass.Id, 'Behavioral Science in Cancer Research (BSCR)');
            insert workingGroupitem1;
            
            OrderApi__Item__c workingGroupitem2 = buildItem(WorkingGroupClass.Id, 'Chemistry in Cancer Research (CICR)');
            insert workingGroupitem2;
            
            OrderApi__Item__c indMemitem = buildItem(WorkingGroupClass.Id, 'Behavioral Science in Cancer Research (BSCR)');
            insert indMemitem;
            
            OrderApi__Sales_Order__c salesOrder = [SELECT Id FROM OrderApi__Sales_Order__c];
            List<OrderApi__Sales_Order_Line__c> sol = new List<OrderApi__Sales_Order_Line__c>();
            // Test sales order Line item insertion
            OrderApi__Sales_Order_Line__c salesOrderLI1 = new OrderApi__Sales_Order_Line__c(OrderApi__Item__c = indMemitem.Id,
                                                                                           OrderApi__Sales_Order__c = salesOrder.Id,
                                                                                           OrderApi__Item_Class__c = activeMemClass.Id,
                                                                                           OrderApi__Activation_Date__c = System.today(),
                                                                                           OrderApi__End_Date__c = System.today()+2);
            insert salesOrderLI1;
            
            // Test sales order Line item insertion
            OrderApi__Sales_Order_Line__c salesOrderLI2 = new OrderApi__Sales_Order_Line__c(OrderApi__Item__c = workingGroupitem1.Id,
                                                                                            OrderApi__Sales_Order__c = salesOrder.Id,
                                                                                            OrderApi__Item_Class__c = WorkingGroupClass.Id);
            insert salesOrderLI2;
            sol.add(salesOrderLI1);
            sol.add(salesOrderLI2);
              DW_CommitteeAutomationTriggerHandler.getCommiteesToUpdate(sol);
            DW_CommitteeAutomationTriggerHandler.updateCommiteeAfterLIDelete(sol);
            
            
        }
        Test.stopTest();
    }
    
    /**
     *@purpose : to test bulk sales order line item Insertion
     */
    static testMethod void testBulkLIInsertDel(){
        Test.startTest();
        
        User user = [SELECT Id, ContactId 
                     FROM User 
                     WHERE lastname =: 'Test User2'];
        
        System.runAs(user){
            OrderApi__Item_Class__c WorkingGroupClass = [SELECT Id, Name FROM OrderApi__Item_Class__c WHERE Name =: 'Working Groups'];
            OrderApi__Item_Class__c activeMemClass = [SELECT Id, Name FROM OrderApi__Item_Class__c WHERE Name =: 'Individual Memberships'];
            
            OrderApi__Item__c indMemitem = buildItem(WorkingGroupClass.Id, 'Behavioral Science in Cancer Research (BSCR)');
            insert indMemitem;
            
            OrderApi__Sales_Order__c salesOrder = [SELECT Id FROM OrderApi__Sales_Order__c];
            
            // Test sales order Line item insertion
            OrderApi__Sales_Order_Line__c salesOrderLI1 = new OrderApi__Sales_Order_Line__c(OrderApi__Item__c = indMemitem.Id,
                                                                                            OrderApi__Sales_Order__c = salesOrder.Id,
                                                                                            OrderApi__Item_Class__c = activeMemClass.Id,
                                                                                            OrderApi__Activation_Date__c = System.today(),
                                                                                            OrderApi__End_Date__c = System.today()+2);
            insert salesOrderLI1;
            
            // insert class items
            List<OrderApi__Item__c> itemList = new List<OrderApi__Item__c>();
            for(Integer index = 0; index < 5; index ++){
                itemList.add(buildItem(WorkingGroupClass.Id, 
                                       'Behavioral Science in Cancer Research (BSCR)'+index));
            }
            insert itemList;
            
            // test insert sales order LI records
            List<OrderApi__Sales_Order_Line__c> salesOredrLIList = new List<OrderApi__Sales_Order_Line__c>();
            for(Integer index = 0; index < 5; index ++){
                salesOredrLIList.add(new OrderApi__Sales_Order_Line__c(OrderApi__Item__c = itemList[index].Id,
                                                                       OrderApi__Sales_Order__c = salesOrder.Id,
                                                                       OrderApi__Item_Class__c = WorkingGroupClass.Id));
            }
            insert salesOredrLIList;
            
            List<Committees__c> committeeList = [SELECT Id, Name, Committee_Related_To__c,Committees__c, Date_From__c, Date_Through__c, Dropped__c 
                                                 FROM Committees__c
                                                 WHERE Committee_Related_To__c IN : itemList];
            
            // test deletion of sales order LI record
            delete salesOredrLIList;
            
            committeeList = [SELECT Id, Name, Committee_Related_To__c,Committees__c, Date_From__c, Date_Through__c, Dropped__c 
                             FROM Committees__c
                             WHERE Id IN : committeeList];
            
            
        }
        Test.stopTest();
    }
}