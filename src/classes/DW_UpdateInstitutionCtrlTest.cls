/**
 *@Purpose       : Test class for DW_UpdateInstitutionCtrl controller
 *@Created Date  : 31-08-2018
 *@Modified Date : 
 */
@isTest
private class DW_UpdateInstitutionCtrlTest {
    
    /**
     *@purpose   : build test data.
     */
    @testSetup
    private static void buildTestData(){ 
        // build Account record
        Account account = buildAccount();
        insert account;
        
        // Build Contact record
        Contact contact= buildContact(account.Id);
        insert contact;
    }
    
    /**
     *@purpose   : build Account record
     *@param     : -
     *@return    : Account record
     */
    static Account buildAccount(){
        Id recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Unapproved Account').getRecordTypeId();
        
        return new Account(RecordTypeId = recordTypeId,
                           Name = 'Test account');
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
                           RecordTypeId = recordTypeId
                           );
    }

    /**
     *@purpose : to test saveAccount()
     */
    private static testMethod void testSaveAccount(){
        Contact contact = [SELECT Id FROM Contact WHERE LastName = 'Test contact'];
        
        ApexPages.StandardController stdCon = new ApexPages.StandardController(contact);
        DW_UpdateInstitutionCtrl institutionCtrl1 = new DW_UpdateInstitutionCtrl(stdCon);
        DW_UpdateInstitutionCtrl institutionCtrl2 = new DW_UpdateInstitutionCtrl();
        institutionCtrl2.getConObj();
        
        Response response = DW_UpdateInstitutionCtrl.saveAccount('Test Account1');
        
        Object account = response.data;
        System.assertEquals(response.message, 'Account saved successfully!');
        
        DW_UpdateInstitutionCtrl.saveAccount(NULL);
    }
    
    /**
     *@purpose : to test updateContact()
     */
    private static testMethod void testUpdateContact(){
        Contact contact = [SELECT Id, AccountId 
                           FROM Contact 
                           WHERE LastName = 'Test contact'];
       
        Account account = buildAccount();
        insert account;
        
        Response response = DW_UpdateInstitutionCtrl.updateContact(contact.Id, account.Id);
        System.assertEquals(response.message, 'Contact updated successfully!');
        
        // fetch updated contact
        Contact updatedContact = [SELECT Id, AccountId 
                                  FROM Contact 
                                  WHERE LastName = 'Test contact'];
        System.assertEquals(updatedContact.AccountId, account.Id);
        
        DW_UpdateInstitutionCtrl.updateContact(NULL, NULL);
    }
}