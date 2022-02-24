/**
 *@Purpose       : Test class for DW_MarkBadAdressForMembership controller
 *@Created Date  : 03-08-2018
 *@Modified Date : 
 */
@isTest
private class DW_MarkBadAdressForMembershipTest {
    
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
        Id recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Active Account').getRecordTypeId();
        
        return new Account(RecordTypeId = recordTypeId,
                           Name = 'Test account');
    }
    
     /**
     *@purpose   : Build Contact record
     *@param     : -
     *@return    : Contact record
     */
    static Contact buildContact(Id accountId){
        Id recordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get( Label.Contact_Non_Member_Record_Type ).getRecordTypeId();
        
        // Creating Contact record
        return new Contact(LastName = 'Test contact',
                           AccountId = accountId,
                           RecordTypeId = recordTypeId,
                           Bad_Journal_Address__c = false,
                           Bad_Mailing_Address__c = false,
                           Bad_Other_Address__c = false,
                           MailingStreet = 'Test MailingStreet',
                           MailingCity = 'Jack,',
                           MailingState ='Virginia',
                           MailingPostalcode = '432001',
                           MailingCountry ='United States',
                           OtherStreet = 'Test OtherStreet',
                           OtherCity ='Test OtherCity',
                           OtherState ='Virginia',
                           OtherPostalCode = '432001',
                           OtherCountry ='United States',
                           Journal_Street__c ='Test 123',
                           Journal_City__c = 'test journal city',
                           Journal_State_Province__c = 'Maharashtra',
                           Journal_Zip_Postal_Code__c = '430991',
                           Journal_Country__c ='India');
        
    }
    
    /**
     *@Purpose : test markAsBadAddressOnContact() positively
     */
    static testMethod void posTestmarkAsBadAddressOnContact(){
        // fetching Contact record
        Contact contact = [SELECT Id, Bad_Journal_Address__c, Bad_Mailing_Address__c, Bad_Other_Address__c 
                           FROM Contact 
                           WHERE LastName = 'Test contact'];
        
        Test.startTest();
        
        //Create ApexPages.StandardController instance 
        ApexPages.StandardController stdContact = new ApexPages.StandardController(contact); 
        
        PageReference pageReference = Page.DW_MarkBadAddressForMembership; 
        pageReference.getParameters().put('id', String.valueOf(contact.Id));
        Test.setCurrentPage(pageReference);
        
        // set slected picklist value as 'Mailing Address'
        DW_MarkBadAdressForMembership markBadMailingAddress = new DW_MarkBadAdressForMembership(stdContact);
        markBadMailingAddress.selectedValue = 'Mailing Address';
        markBadMailingAddress.markAsBadAddressOnContact();
        
        // fetching updated contact record
        contact = [SELECT Id, Bad_Mailing_Address__c
                   FROM Contact 
                   WHERE LastName = 'Test contact'];
        
        System.assertEquals(true, contact.Bad_Mailing_Address__c);
        
        // set slected picklist value as 'Other Address'
        DW_MarkBadAdressForMembership markBadOtherAddress = new DW_MarkBadAdressForMembership(stdContact);
        markBadOtherAddress.selectedValue = 'Other Address';
        markBadOtherAddress.markAsBadAddressOnContact();
        
        // fetching updated contact record
        contact = [SELECT Id, Bad_Other_Address__c
                   FROM Contact 
                   WHERE LastName = 'Test contact'];
        
        System.assertEquals(true, contact.Bad_Other_Address__c);
        
        // set slected picklist value as 'Journal Address'
        DW_MarkBadAdressForMembership markBadJournalAddress = new DW_MarkBadAdressForMembership(stdContact);
        markBadJournalAddress.selectedValue = 'Journal Address';
        markBadJournalAddress.markAsBadAddressOnContact();
        
        // fetching updated contact record
        contact = [SELECT Id, Bad_Journal_Address__c
                   FROM Contact 
                   WHERE LastName = 'Test contact'];
        
        System.assertEquals(true, contact.Bad_Journal_Address__c);
        
        Test.stopTest();
    }
    
    /**
     *@Purpose : test markAsBadAddressOnContact() negatively
     */
    static testMethod void negTestmarkAsBadAddressOnContact(){
        Test.startTest();
        
        // fetching Contact record
        Contact contact = [SELECT Id, Bad_Journal_Address__c, Bad_Mailing_Address__c, Bad_Other_Address__c 
                           FROM Contact 
                           WHERE LastName = 'Test contact'];
                
        //Create ApexPages.StandardController instance 
        ApexPages.StandardController stdContact = new ApexPages.StandardController(contact);
        DW_MarkBadAdressForMembership markBadJournalAddress = new DW_MarkBadAdressForMembership(stdContact);
        
        markBadJournalAddress.getContact(NULL);
        
        Test.stopTest();
    }
    
    /**
     *@Purpose : test getPickLstValue()
     */
    static testMethod void testGetPickLstValue(){
        Test.startTest();
        
        // fetching Contact record
        Contact contact = [SELECT Id, Bad_Journal_Address__c, Bad_Mailing_Address__c, Bad_Other_Address__c,
                                      MailingStreet, MailingCity, MailingState, MailingPostalcode , MailingCountry,
                                      OtherStreet, OtherCity,  OtherState, OtherPostalCode, OtherCountry,
                                      Journal_Street__c, Journal_City__c, Journal_State_Province__c, Journal_Zip_Postal_Code__c, Journal_Country__c
                           FROM Contact 
                           WHERE LastName = 'Test contact'];
        String invalidAddress = Label.DW_Invalid_Address;
        
        //Create ApexPages.StandardController instance 
        ApexPages.StandardController stdContact = new ApexPages.StandardController(contact);
        DW_MarkBadAdressForMembership markBadAddress = new DW_MarkBadAdressForMembership(stdContact);
        
        PageReference pageReference = Page.DW_MarkBadAddressForMembership; 
        pageReference.getParameters().put('id', String.valueOf(contact.Id));
        Test.setCurrentPage(pageReference);
        
        List<SelectOption> options = markBadAddress.getPickLstValue();
        
        contact.MailingStreet = '';
        contact.MailingCity ='';
        contact.MailingState ='';
        contact.MailingPostalcode ='';
        contact.MailingCountry ='';
        contact.OtherStreet ='';
        contact.OtherCity ='';
        contact.OtherState ='';
        contact.OtherPostalCode ='';
        contact.OtherCountry ='';
        contact.Journal_Street__c ='';
        contact.Journal_City__c ='';
        contact.Journal_State_Province__c ='';
        contact.Journal_Zip_Postal_Code__c = '';
        contact.Journal_Country__c = '';
        update contact;
        
        //Create ApexPages.StandardController instance 
        ApexPages.StandardController stdContact1 = new ApexPages.StandardController(contact);
        DW_MarkBadAdressForMembership markBadAddress1 = new DW_MarkBadAdressForMembership(stdContact1);
        List<SelectOption> optionList = markBadAddress1.getPickLstValue(); 
      
        Test.stopTest();
    }
}