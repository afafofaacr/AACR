/**
 *@Purpose       : Test class for DW_SubscriptionRenewController controller
 *@Created Date  : 22-10-2018
 *@Modified Date : 22-10-2018
 */
@isTest
public class DW_SubscriptionRenewControllerTest {

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

    	// Build OrderApi__Item_Class__c record
        OrderApi__Item_Class__c indMemClass = buildItemClass('Prior Year Dues');
        insert indMemClass;
        System.assertEquals(1, [SELECT Id FROM OrderApi__Item_Class__c].size());
        
        // Build OrderApi__Item__c record
        OrderApi__Item__c activeMemitem = buildItem(indMemClass.Id, 'Active Membership (REN)');
        insert activeMemitem;
        System.assertEquals(1, [SELECT Id FROM OrderApi__Item__c].size());

        OrderApi__Sales_Order__c salesOrder = buildSalesOrder(contact.Id);
        insert salesOrder;

        OrderApi__Sales_Order_Line__c salesOrderLine =  buildSalesLineOrder(activeMemitem.Id, salesOrder.Id, indMemClass.Id);
        insert salesOrderLine;

    }
    
   @isTest
    public static void getRenewItemMethodTest(){
    	OrderApi__Sales_Order__c salesOrder = [SELECT ID FROM OrderApi__Sales_Order__c LIMIT 1];

       PageReference pageRef = Page.DW_SubscriptionRenew;
       pageRef.getParameters().put('salesOrder',salesOrder.id);

       Test.startTest();
       DW_SubscriptionRenewController controller = new DW_SubscriptionRenewController();
       DW_ECRMDTO.Response responseRenewItem = controller.getRenewItem(salesOrder.Id);
       Test.stopTest();

       System.assert(responseRenewItem!=null, 'Renew item should not be null');

    }

    @isTest
    public static void removeRenewalLinesFromSO(){
        joinapi__Join_Process__c jp = new joinapi__Join_Process__c();
        jp.joinapi__Join_Process_Display_Name__c = 'Pay Dues Only';
        jp.joinapi__Landing_Url__c = 'https://google.com';
        insert jp;

        OrderApi__Sales_Order__c salesOrder = [SELECT ID FROM OrderApi__Sales_Order__c LIMIT 1];
        PageReference pageRef = Page.DW_SubscriptionRenew;
        pageRef.getParameters().put('salesOrder',salesOrder.id);

        Test.startTest();
        DW_SubscriptionRenewController controller = new DW_SubscriptionRenewController();
        controller.removeRenewalLinesFromSO();
        Test.stopTest();




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
        Id recordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(System.Label.Contact_Non_Member_Record_Type).getRecordTypeId();
        
        // Creating Contact record
        return new Contact(LastName = 'Test contact',
                           AccountId = accountId,
                           RecordTypeId = recordTypeId,
                           Phone ='9878986789',
                           Fax = 'fax');
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
     *@Purpose : Build sales order
     *@Param   : contactId
     *@return  : sales order rwecord
     */
    static OrderApi__Sales_Order__c buildSalesOrder(Id contactId){
        return new OrderApi__Sales_Order__c(OrderApi__Contact__c = contactId);
    }

    /**
     *@Purpose : Build sales order
     *@Param   : contactId
     *@return  : sales order rwecord
     */
    static OrderApi__Sales_Order_Line__c buildSalesLineOrder(Id activeMemitemId, Id salesOrderId, Id indMemClassId){
        return new OrderApi__Sales_Order_Line__c(OrderApi__Item__c = activeMemitemId,
                                                 OrderApi__Sales_Order__c = salesOrderId,
                                                 OrderApi__Item_Class__c = indMemClassId,
                                                 OrderApi__Activation_Date__c = System.today(),
                                                 OrderApi__End_Date__c = System.today()+2);
    }

}