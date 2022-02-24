/**
    @ PURPOSE : 1. Test Batch Class ContactSubscriptionBatch
    @ AUTHER  : (Nilesh K.)
*/
@isTest
public class ContactSubscriptionBatchTest {
    
    @testSetup
    public Static void setupData(){
        // build Account record
        Account account = buildAccount('Test Account1');
        insert account;
        System.assertEquals(1, [SELECT Id FROM Account].size());
        
        // Build Contact record
        List<Contact> contacts = buildContacts(account.Id);
        insert contacts;
        System.assertEquals(200, [SELECT Id FROM contact].size());
        
        // Build OrderApi__Item_Class__c record
        OrderApi__Item_Class__c indMemClass = buildItemClass('Individual Memberships');
        insert indMemClass;
        System.assertEquals(1, [SELECT Id FROM OrderApi__Item_Class__c].size());
        
        // Build OrderApi__Item__c record
        OrderApi__Item__c activeMemitem = buildItem(indMemClass.Id, 'Active Membership (REN)');
        insert activeMemitem;
        System.assertEquals(1, [SELECT Id FROM OrderApi__Item__c].size());
        
        // Build OrderApi__Subscription_Plan__c record
        OrderApi__Subscription_Plan__c subPlan = buildsubPlan();
        insert subPlan;
        System.assertEquals(1, [SELECT Id FROM OrderApi__Subscription_Plan__c].size());
        
        // Build OrderApi__Subscription__c record
        List<OrderApi__Subscription__c> subscription = buildSubscription(contacts, subPlan.Id, activeMemitem.Id, indMemClass.Id );
        insert subscription;
        System.assertEquals(200, [SELECT Id FROM OrderApi__Subscription__c].size());
           
    } 
    
     /**
     *@purpose   : Test the Batch Class ContactSubscriptionBatch
     *@param     : -
     *@return    : -
     */
    @isTest
    public static void ContactSubscriptionBatchTestMethod(){
        Test.startTest();
        ID batchprocessid = Database.executeBatch(new ContactSubscriptionBatch());
        
        AsyncApexJob aaj = [SELECT Id, Status, JobItemsProcessed, TotalJobItems, NumberOfErrors 
                            FROM AsyncApexJob WHERE ID =: batchprocessid ];
        Test.stopTest();
        
        for(Contact contactRec : [SELECT ID, Member_Type__c FROM Contact]){
            System.assertEquals('Active Member', contactRec.Member_Type__c);
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
                           Name = accountName,
                           Institution_Type__c = 'Home');
    }
    
    /**
     *@purpose   : Build Contact record
     *@param     : accountId
     *@return    : List of Contact record
     */
    static List<Contact> buildContacts(Id accountId){
        Id recordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Member').getRecordTypeId();
        
        List<Contact> contacts = new List<Contact>();
        // Creating Contact record
        for(integer i = 0 ; i < 200 ; i++){
            contacts.add(new Contact(LastName = 'Test contact',
                                     AccountId = accountId,
                                     RecordTypeId = recordTypeId,
                                     Phone ='9878986789',
                                     Membership_Status__c = '1-YR Suspended',
                                     Fax = 'fax'));
        }
        return contacts;
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
    static List<OrderApi__Subscription__c> buildSubscription(List<Contact> contacts, Id subPlanId,Id itemId, Id itemclassId){
        
        List<OrderApi__Subscription__c> subscriptList = new List<OrderApi__Subscription__c>();
        for(Contact contactRec : contacts){
            subscriptList.add(new OrderApi__Subscription__c(OrderApi__Contact__c = contactRec.Id,
                                             OrderApi__Subscription_Plan__c = subPlanId,
                                             OrderApi__Item__c = itemId,
                                             OrderApi__Is_Active__c =false,
                                             OrderApi__Item_Class__c = itemclassId,
                                             OrderApi__Current_Term_Start_Date__c = system.today()));
        }
        return subscriptList;
    }
}