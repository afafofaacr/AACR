/**
*@purpose : to test DW_UpsertNonMemberBadgeTrgHandler
*@param   : 
*@return  : 
*/
@isTest
public class DW_UpsertNonMemberBadgeTrgHandlerTest{
    
      /**
*@purpose : Setup All required Data
*@param   : -
*@return  : void
*/
    @testSetup
    public static void setupData(){
            
       List<OrderApi__Badge_Type__c> badgeTypeList = createBadgeType();
       insert badgeTypeList;
       System.assertEquals(9, [SELECT Id FROM OrderApi__Badge_Type__c].size()); 
        
       Account account = createAccount();
       insert account;
       System.assertEquals(1, [SELECT Id FROM Account].size()); 
        
       List<Contact> contacts = createContact(account.Id);
       insert contacts;
       System.assertEquals(1, [SELECT Id FROM Contact].size()); 
        
       // Unapproved Testing
       OrderApi__Badge_Type__c badgeType = [SELECT Id FROM OrderApi__Badge_Type__c WHERE Name = 'Active Membership - Unapproved' LIMIT 1];
       insert new OrderApi__Badge__c(OrderApi__Awarded_Date__c = Date.Today(),  
                               OrderApi__Badge_Type__c = badgeType.Id);        
    }
    
      /**
*@purpose : Test after Insert Method
*@param   : -
*@return  : void
*/
    @isTest
    Public static void onafterInsertContactMethodTest(){
        
        List<String> badgeTypeNameList = new List<String>();
        for(DW_BadgeTypeName__mdt BadgeNameMeta : [SELECT MasterLabel, BadgeTypeName__c FROM DW_BadgeTypeName__mdt]){
            badgeTypeNameList.add(BadgeNameMeta.BadgeTypeName__c);
        }
        
        System.debug('badgeTypeNameList ::: '+badgeTypeNameList);
        for(Contact contact : [SELECT ID, (SELECT ID, OrderApi__Badge_Type__r.Name 
                                FROM OrderApi__Badges__r 
                                WHERE OrderApi__Badge_Type__r.Name IN :badgeTypeNameList )  
                               FROM Contact ]){
            System.debug('Badge Type ::: '+contact.OrderApi__Badges__r);                       
            System.assertEquals(5, contact.OrderApi__Badges__r.size());            
        }
    }
    
      /**
*@purpose : To test after update 
*@param   : -
*@return  : void
*/
    @isTest
    Public static void onafterUpdateContactMethodTest(){
       
        Account account = [Select Id, Institution_Type__c FROM Account LIMIT 1];
        List<String> badgeTypeNameList = new List<String>();
        for(DW_BadgeTypeName__mdt BadgeNameMeta : [SELECT MasterLabel, BadgeTypeName__c FROM DW_BadgeTypeName__mdt]){
            badgeTypeNameList.add(BadgeNameMeta.BadgeTypeName__c);
        }
        
        List<Contact> contactsList = new List<Contact>(); 
        for(Contact contact : [SELECT ID, Current_Education_Status__c,
                                (SELECT ID, OrderApi__Badge_Type__r.Name 
                                FROM OrderApi__Badges__r 
                                WHERE OrderApi__Badge_Type__r.Name IN :badgeTypeNameList)  
                               FROM Contact ]){
            contact.Current_Education_Status__c = 'Postdoctoral Fellow';
            contactsList.add(contact);                
        }
        update contactsList;

        for(Contact contact : [SELECT ID, (SELECT ID, OrderApi__Badge_Type__r.Name 
                                FROM OrderApi__Badges__r 
                                WHERE OrderApi__Badge_Type__r.Name IN :badgeTypeNameList)  
                               FROM Contact ]){
            System.debug('Badge Type ::: '+contact.OrderApi__Badges__r);
            System.assertEquals(8, contact.OrderApi__Badges__r.size());            
        }
        Contact contact = [SELECT Id From Contact LIMIT 1];
        OrderApi__Badge_Type__c badgeType = [SELECT Id FROM OrderApi__Badge_Type__c WHERE Name = 'Active Membership - Unapproved' LIMIT 1];
        OrderApi__Badge__c badge = [SELECT ID, OrderApi__Contact__c FROM OrderApi__Badge__c WHERE OrderApi__Badge_Type__c = :badgeType.Id LIMIT 1]; 
        
        badge.OrderApi__Contact__c = contact.Id;
        update badge;
        
        // Record Types
        Id memberRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(System.Label.Contact_Member_Record_Type).getRecordTypeId();
        Id nonMemberRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(System.Label.Contact_Non_Member_Record_Type).getRecordTypeId();
        
        // Non Member to Member
        contact.Email = 'test@example.com';
        contact.RecordTypeId = memberRecordTypeId;
        update contact;
		
		// Member to Non Member        
        contact.RecordTypeId = nonMemberRecordTypeId;
        update contact;
        
        
        // Checking
        account.Institution_Type__c = 'Vendor';
        update account;
        
        contact.LastName = 'TestTestTest1';
        update contact;
        
        // Checking
        account.Institution_Type__c = 'Hospital/Clinic';
        update account;
        
        contact.LastName = 'TestTestTest2';
        update contact; 
        
        // Checking
        account.Institution_Type__c = 'Government';
        update account;
        
        contact.LastName = 'TestTestTest3';
        update contact;
        
        
        

    }
    
      /**
*@purpose : To create Badge Type records. 
*@param   : -
*@return  : List<OrderApi__Badge_Type__c>
*/
    Public static List<OrderApi__Badge_Type__c> createBadgeType(){
        
        List<OrderApi__Badge_Type__c> badgeTypeList = new List<OrderApi__Badge_Type__c>();
        
        for(DW_BadgeTypeName__mdt BadgeNameMeta : [SELECT MasterLabel, BadgeTypeName__c FROM DW_BadgeTypeName__mdt]){
           
            badgeTypeList.add(new OrderApi__Badge_Type__c(Name = BadgeNameMeta.BadgeTypeName__c,OrderApi__Is_Active__c = true));
        }
        // Unapproved Testing
        badgeTypeList.add(new OrderApi__Badge_Type__c(Name = 'Active Membership - Unapproved',OrderApi__Is_Active__c = true));
        
        System.debug('createBadgeType : badgeTypeList ::: '+badgeTypeList);
        return badgeTypeList;
    }
    
  /**
*@purpose : To create Account record.
*@param   : -
*@return  : Account
*/    
    Public static Account createAccount(){      
        Id recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Active Account').getRecordTypeId();
        
         return new Account(RecordTypeId = recordTypeId,
                           Name = 'Test Account',
                           Institution_Type__c = 'Association/Professional Org');
    }
  
      /**
*@purpose : To create Contact Records
*@param   : Account Id
*@return  : List<Contact>
*/
    Public static List<Contact> createContact(Id accountId){      
        Id recordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(System.Label.Contact_Non_Member_Record_Type).getRecordTypeId();
        List<Contact> contactsList = new List<Contact>();
        
        for(integer i=1; i<=1 ;i++){
            contactsList.add(new Contact(LastName = 'TestLN', Advocate__c = true, AccountId = accountId));
        }
        
        return contactsList;    
    }
}