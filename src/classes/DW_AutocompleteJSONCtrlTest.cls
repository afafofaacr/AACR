/**
 *@Purpose       : Test class for DW_AutocompleteJSONCtrl
 *@Created Date  : 04-09-2018
 *@Modified Date : 
 */
@isTest
public class DW_AutocompleteJSONCtrlTest {
    
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
                           Preferred_Address__c = 'Business');
    }
    
    /**
     *@Purpose : to test getAutocompleteJSON()
     */
    static testMethod void testGtAutocompleteJSON(){
        Test.startTest();
        
        Contact contact = [SELECT Id, RecordTypeId, Name, Preferred_Address__c
                           FROM Contact 
                           WHERE LastName =: 'Test contact'];
        
        Pagereference currentPage = Page.DW_aacr_custom_login;
        Test.setCurrentPage(currentPage);
        currentPage.getParameters().put('obj','Contact');
        currentPage.getParameters().put('label','Preferred_Address__c');
        currentPage.getParameters().put('q', contact.Preferred_Address__c);
        currentPage.getParameters().put('detail','Id');
        //currentPage.getParameters().put('wc','Email');
        currentPage.getParameters().put('value','Name');
        currentPage.getParameters().put('lm','1');
        
        DW_AutocompleteJSONCtrl autocompleteJSON = new DW_AutocompleteJSONCtrl();
        String result = autocompleteJSON.getAutocompleteJSON();
        List<DW_AutocompleteJSONCtrl.DataWrapper> dataWrap = ( List<DW_AutocompleteJSONCtrl.DataWrapper>) System.JSON.deserialize(result, List<DW_AutocompleteJSONCtrl.DataWrapper>.class);
        System.assertEquals(dataWrap[0].value, contact.Name);
        System.assertEquals(dataWrap[0].label, contact.Preferred_Address__c);
        System.assertEquals(dataWrap[0].detail, contact.Id);
        
        Test.stopTest();
    }
}