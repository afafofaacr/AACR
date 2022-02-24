/**
 *@Purpose      : Test class for DW_SubscriptionsController
 *@Created Date : 15-10-2018
 *@Modified Date: 15-10-2018
 */
@isTest
public class DW_SubscriptionsControllerTest {

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
        
        // Build Contact record
        OrderApi__Badge_Type__c badgeType = buildBadgeType();
        insert badgeType;
        System.assertEquals(1, [SELECT Id FROM OrderApi__Badge_Type__c].size()); 
        
        // Build OrderApi__Item_Class__c record
        OrderApi__Item_Class__c indMemClass = buildItemClass('Individual Memberships');
        insert indMemClass;
        System.assertEquals(1, [SELECT Id FROM OrderApi__Item_Class__c].size());
        
        // Build OrderApi__Item__c record
        OrderApi__Item__c activeMemitem = buildItem(indMemClass.Id, 'Active Membership (REN)');
        insert activeMemitem;
        System.assertEquals(1, [SELECT Id FROM OrderApi__Item__c].size());
        
        // Build OrderApi__Item_Class__c record
        OrderApi__Badge__c badge = buildBadge(badgeType.Id, activeMemitem.Id, contact.Id);
        insert badge;
        System.assert([SELECT Id FROM OrderApi__Badge__c].size() > 1);
        
         // Build OrderApi__Subscription_Plan__c record
        OrderApi__Subscription_Plan__c subPlan = buildsubPlan();
        insert subPlan;
        System.assertEquals(1, [SELECT Id FROM OrderApi__Subscription_Plan__c].size());
        
        // Build OrderApi__Subscription__c record
        OrderApi__Subscription__c subscription = buildSubscription(contact.Id, subPlan.Id, activeMemitem.Id, indMemClass.Id );
        insert subscription;
        System.assertEquals(1, [SELECT Id FROM OrderApi__Subscription__c].size());
        
        List<DW_Item_Class_Names_Setting__c> itemClsNameSettingList = buildItemClassSetting(indMemClass.Name);
        insert itemClsNameSettingList;
        System.assertEquals(5, [SELECT Id FROM DW_Item_Class_Names_Setting__c].size());
        
    }

    @isTest
    public static void getMembershipTest(){
        joinapi__Join_Process__c jp = new joinapi__Join_Process__c();
        jp.joinapi__Join_Process_Display_Name__c = 'Become A Member';
        jp.joinapi__Landing_Url__c = 'https://google.com';
        insert jp;

        List<RecordType> recordTypes = [Select Id,name From RecordType where sobjecttype = 'Contact' AND (Name='Member' OR Name='Prior Member') ];

        Contact c = [SELECT Id FROM Contact LIMIT 1];
        c.OrderApi__Preferred_Email_Type__c = 'Personal';
        c.OrderApi__Personal_Email__c = 'test@testorg.com';
        c.Email = 'test@testorg.com';
        c.Paid_thru_date__c = Date.valueOf(System.now());
        update c;

        User userRecord = [SELECT ID
        FROM USER
        WHERE email = 'test@testorg.com'];

        System.runAs(userRecord){
            
            DW_SubscriptionsController controller = new DW_SubscriptionsController();
            system.assert(controller.nonMember = true, 'nonmember should be true');

            c.RecordTypeId = recordTypes[0].Id;
            c.Membership_Status__c = 'Current';
            update c;

            controller = new DW_SubscriptionsController();
            system.assert(controller.memberCurrent = true, 'contact should be a current member');

            c.RecordTypeId = recordTypes[1].Id;
            c.Membership_Status__c = 'Suspended (Delinquent)';
            update c;

             controller = new DW_SubscriptionsController();
            system.assert(controller.memberSuspended = true, 'contact should be a suspended member');


        }
    }
//
    @isTest
    public static void getSubscriptionDetailsMethodTest(){
        User userRecord = [SELECT ID 
                           FROM USER 
                           WHERE email = 'test@testorg.com'];
        
        System.runAs(userRecord){
            DW_ECRMDTO.Response responseSubDetail = DW_SubscriptionsController.getSubscriptionDetails();
            Contact contact = [SELECT ID, 
                               Initial_Join_Date__c, Journal_Street__c, Journal_City__c, 
                               Journal_State_Province__c, Journal_Country__c, Journal_Zip_Postal_Code__c 
                               FROM Contact];
            contact.Initial_Join_Date__c = Date.today();
            contact.Journal_Street__c = 'Street'; 
            contact.Journal_City__c = 'City';
            contact.Journal_State_Province__c = 'State Province'; 
            contact.Journal_Country__c = 'Country'; 
            contact.Journal_Zip_Postal_Code__c = '123456';
            
            update contact;
            
           DW_ECRMDTO.Response responseSubDetailUpdated = DW_SubscriptionsController.getSubscriptionDetails();
        }
    }
    
    @isTest
    public static void renewSubscriptionPlanMethodTest(){
        User userRecord = [SELECT ID 
                           FROM USER 
                           WHERE email = 'test@testorg.com'];
        
        System.runAs(userRecord){
            DW_SubscriptionsController subcriptionController = new DW_SubscriptionsController();
            DW_ECRMDTO.Response responseRenewSubPlan = DW_SubscriptionsController.renewSubscriptionPlan();
        }
    }
    
     @isTest
    public static void updateContactsJournalAddrMethodTest(){
         User userRecord = [SELECT ID 
                           FROM USER 
                           WHERE email = 'test@testorg.com'];
        
        System.runAs(userRecord){
            Contact contact = [SELECT Id FROM Contact LIMIT 1];
            
            DW_ECRMDTO.ContactDTO contactDTORec = new  DW_ECRMDTO.ContactDTO();
            
            contactDTORec.Id = contact.Id;
            contactDTORec.journalStreet = 'Street';
            contactDTORec.journalCity = 'City';
            contactDTORec.journalState = 'State';
            contactDTORec.journalcountry = 'Country';
            contactDTORec.journalzipcode = '123456';
            
            DW_SubscriptionsController subcriptionController = new DW_SubscriptionsController();
            DW_ECRMDTO.Response responseRenewSubPlan = DW_SubscriptionsController.updateContactsJournalAddr(contactDTORec);
        }
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
     *@purpose   : Build Contact record for non-member
     *@param     : accountId
     *@return    : Contact record
     */
    static Contact buildContact(Id accountId){
        Id recordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(System.Label.Contact_Non_Member_Record_Type).getRecordTypeId();
        
        // Creating Contact record
        return new Contact(LastName = 'Test contact',
                           AccountId = accountId,
                           RecordTypeId = recordTypeId,
                           Phone ='9878986789',
                           Fax = 'fax');
    }
    
    /**
     *@purpose   : Build Contact record for member current
     *@param     : accountId
     *@return    : Contact record
     */
    static Contact buildContactMemberCurrent(Id accountId){
        Id recordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(System.Label.Contact_Member_Record_Type).getRecordTypeId();
        
        // Creating Contact record
        return new Contact(LastName = 'Test contact 1',
                           AccountId = accountId,
                           RecordTypeId = recordTypeId,
                           Membership_Status__c = 'Current',
                           Phone ='9878986789',
                           Fax = 'fax');
    }
    
    /**
     *@purpose   : Build User record
     *@param     : contactId
     *@return    : User Record
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
     *@purpose   : Build User record
     *@param     : contactId
     *@return    : OrderApi__Badge_Type__c Record
     */
    Public static OrderApi__Badge_Type__c buildBadgeType(){
        
        return new OrderApi__Badge_Type__c(Name = 'Test Badge Type Name',OrderApi__Is_Active__c = true);
    }
    
    /**
     *@purpose   : Build Item class record 
     *@parameter : itemClassName
     *@return    : Itesm class record
     */
    private static OrderApi__Item_Class__c buildItemClass(String itemClassName){
        return new OrderApi__Item_Class__c(Name = itemClassName,
                                           Is_Membership__c =  false);
    }
    
    /**
     *@purpose   : Build Item record
     *@parameter : itemClassId, itemName
     *@return    : Item record
     */
    static OrderApi__Item__c buildItem(Id itemClassId, String itemName){
        return new OrderApi__Item__c(Name = itemName,
                                     OrderApi__Item_Class__c = itemClassId,
                                     OrderApi__Is_Active__c = true,
                                     Is_Active_Membership_Type__c =true,
                                     OrderApi__Price__c = 50,
                                     Eligible_Nominator_Membership__c = true);
    }
    
    /**
     *@purpose   : Build Item class record 
     *@parameter : badgeTypeId, activeMemitemId, contactId
     *@return    : Badge record
     */
    private static OrderApi__Badge__c buildBadge(Id badgeTypeId, Id activeMemitemId, Id contactId){
        return new OrderApi__Badge__c(OrderApi__Badge_Type__c = badgeTypeId, 
                                      OrderApi__Is_Active__c = True,
                                      OrderApi__Item__c = activeMemitemId, 
                                      OrderApi__Contact__c = contactId);
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
     *@param     : List of Contacts, subPlanId, itemId, itemclassId
     *@return    : List of Subscription records
     */
    static OrderApi__Subscription__c buildSubscription(Id contactId, Id subPlanId,Id itemId, Id itemclassId){
        return new OrderApi__Subscription__c(OrderApi__Contact__c = contactId,
                                             OrderApi__Subscription_Plan__c = subPlanId,
                                             OrderApi__Item__c = itemId,
                                             OrderApi__Is_Active__c = True,
                                             OrderApi__Item_Class__c = itemclassId,
                                             OrderApi__Current_Term_Start_Date__c = system.today());
    }
    
    /**
     *@Purpose : build Item Class Names Setting
     *@Param   : Name, itemClassName
     *@return  : Item Class Names Settings record
     */
    private static List<DW_Item_Class_Names_Setting__c> buildItemClassSetting(String itemClassName){
        List<DW_Item_Class_Names_Setting__c> itemClsNameSettingList = new List<DW_Item_Class_Names_Setting__c>();
        
        itemClsNameSettingList.add(new DW_Item_Class_Names_Setting__c(Name = 'Individual Memberships',
                                                   Class_Name__c = itemClassName));
        itemClsNameSettingList.add(new DW_Item_Class_Names_Setting__c(Name = 'Complimentary Journals',
                                                   Class_Name__c = itemClassName));
        itemClsNameSettingList.add(new DW_Item_Class_Names_Setting__c(Name = 'Journal Subscriptions',
                                                   Class_Name__c = itemClassName));
        itemClsNameSettingList.add(new DW_Item_Class_Names_Setting__c(Name = 'ZDecline of the Journals',
                                                   Class_Name__c = itemClassName));
        itemClsNameSettingList.add(new DW_Item_Class_Names_Setting__c(Name = 'Working Groups',
                                                   Class_Name__c = itemClassName));
        
        
        return itemClsNameSettingList;
    }
}