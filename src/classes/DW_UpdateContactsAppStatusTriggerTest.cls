/**
 *@Purpose       : Test class for DW_UpdateContactsAppStatusTrigger
 *@Created Date  : 30-10-2018
 *@Modified Date : 
 */
@isTest
public class DW_UpdateContactsAppStatusTriggerTest {

    /**
     *@purpose   : build test data.
     */
    @testSetup
    private static void buildTestData(){ 
        
        // build Account record
        Account account = buildAccount('Test Account1');
        insert account;
        
        // Getting non member record type Id
        Id nonMemberRecTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(System.Label.Contact_Non_Member_Record_Type).getRecordTypeId();

         // Build Contact record
        Contact contact = buildContact(account.Id, nonMemberRecTypeId);
        insert contact;
    }
    
    /**
     *@purpose   : build Account record
     *@param     : accountName
     *@return    : Account record
     */
    public static Account buildAccount(String accountName){
        Id recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Active Account').getRecordTypeId();
        
        return new Account(RecordTypeId = recordTypeId,
                           Name = accountName);
    }
    
    /**
     *@purpose   : Build Contact record
     *@param     : accountId
     *@return    : Contact record
     */
    public static Contact buildContact(Id accountId, Id recordTypeId){
        
        // Creating Contact record
        return new Contact(LastName = 'Test contact',
                           AccountId = accountId,
                           RecordTypeId = recordTypeId,
                           Phone ='9878986789',
                           Fax = 'fax',
                           Membership_Status__c= 'Current',
                           Application_Status__c = null
                          );
    }
    
    /**
     *@Purpose : Build sales order
     *@Param   : contactId
     *@return  : sales order rwecord
     */
    public static OrderApi__Sales_Order__c buildSalesOrder(Id contactId){
        return new OrderApi__Sales_Order__c(OrderApi__Contact__c = contactId,
                                            OrderApi__Posting_Status__c =null,
                                            OrderApi__Status__c ='Open');
    }
    
    /*
     *@Purpose : to test sales order creation and updation
     */
    static testMethod void testSOInsertUpdate(){
        // Getting Member record type
        Id recordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(Label.Contact_Member_Record_Type).getRecordTypeId();

        Account account = [SELECT Id FROM Account WHERE Name = 'Test Account1'];
        
        // Build Contact record
        Contact contact = buildContact(account.Id, recordTypeId);
        insert contact;
        
        // Inserting salesorder
        OrderApi__Sales_Order__c salesOrder = buildSalesOrder(contact.Id);
        insert salesOrder;
        
        // Updating sales order with posting status to posted
        salesOrder.OrderApi__Status__c = 'Closed';
        salesOrder.OrderApi__Posting_Status__c = Label.DW_SO_Posting_Status;
        update salesOrder;
        
        //fetching updated contact with 'Pending approval' application status
        Contact updatedContact = [SELECT Id, Application_Status__c 
                                  FROM Contact 
                                  WHERE Id =: contact.Id];
        //System.assertEquals(Label.DW_Contact_App_Status, updatedContact.Application_Status__c);
    }
    
    /*
     *@Purpose : to test sales order creation and updation
     */
    static testMethod void testBulkSOInsertUpdate(){
        // Getting Member record type
        Id recordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(Label.Contact_Member_Record_Type).getRecordTypeId();

        Account account = [SELECT Id FROM Account WHERE Name = 'Test Account1'];
        
        List<Contact> contactList = new List<Contact>();
        for(Integer index=0; index < 10; index++){
            contactList.add(buildContact(account.Id, recordTypeId));
        }
        insert contactList;
        
        List<OrderApi__Sales_Order__c> salesOrderList = new List<OrderApi__Sales_Order__c>();
        for(Integer index=0; index < 10; index++){
            salesOrderList.add(buildSalesOrder(contactList[index].Id));
        }
        insert salesOrderList; 
        
        List<OrderApi__Sales_Order__c> soToUpdateList = new List<OrderApi__Sales_Order__c>();
        for(OrderApi__Sales_Order__c salesOrder : salesOrderList){
            salesOrder.OrderApi__Status__c = 'Closed';
            salesOrder.OrderApi__Posting_Status__c = Label.DW_SO_Posting_Status;
            soToUpdateList.add(salesOrder);
        }
        // updating salesorder list
        update soToUpdateList;
        
        //fetching updated contact list with 'Pending approval' application status
        List<Contact> updatedContactList = [SELECT Id, Application_Status__c 
                                            FROM Contact 
                                            WHERE Id IN :contactList];  
        //for(Contact updatedContact : updatedContactList){
            //System.assertEquals(Label.DW_Contact_App_Status, updatedContact.Application_Status__c);
        //}
    }
}