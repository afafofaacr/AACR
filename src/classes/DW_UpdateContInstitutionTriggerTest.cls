/**
 *@Purpose       : Test class for DW_UpdateContInstitutionTrigger
 *@Created Date  : 15-08-2018
 *@Modified Date : 
 */
@isTest
public class DW_UpdateContInstitutionTriggerTest {
    
    /**
     *@purpose   : build Account record
     *@param     : recordTypeId, accountnName, institutionType
     *@return    : Account record
     */
    static Account buildAccount(String accountnName, String institutionType){
        Id recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Active Account').getRecordTypeId();
        
        return new Account(RecordTypeId = recordTypeId,
                           Name = accountnName,
                           Institution_Type__c = institutionType,
                           Minority_Institution__c = true,
                           MSI_Type__c = 'HBCU' );
    }
    
    /**
     *@purpose   : Build Contact record
     *@param     : institutionType
     *@return    : Contact record
     */
    static List<Contact> buildContact(Id accountId){
        Id recordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(Label.Contact_Member_Record_Type).getRecordTypeId();
        
        List<Contact> contactList = new List<Contact>();
        
        for(Integer index = 0; index < 10 ; index ++){
            contactList.add(new Contact(RecordTypeId = recordTypeId,
                                        LastName = 'Test contact'+index,
                                        AccountId = accountId,
                                        Institution_Type__c ='',
                                        Minority_Institution__c = false));
        }
        return contactList;
    }
    
    /**
     *@purpose : to test single contact insertion
     */
    static testMethod void testAccountInsertUpdate(){
        Test.startTest();
        // Inserting account
        Account testAccount = buildAccount('Test Account', 'Foundation');
        insert testAccount;
        
        // inserting contacts
        List<Contact> contactList = buildContact(testAccount.Id);
        insert contactList;
        // Updating account        
        testAccount.Institution_Type__c = 'Government';
        update testAccount;
        
        Account updatedAccount = [SELECT Id,Institution_Type__c,Minority_Institution__c 
                                  FROM Account
                                  WHERE Id =: testAccount.Id];
        
        List<Contact> updatedContactList = [SELECT Id,Institution_Type__c,Minority_Institution__c
                                            FROM Contact
                                            WHERE AccountId =: updatedAccount.Id];
        
        // Checking updated contact value
        for(Integer index = 0 ; index < updatedContactList.size(); index++){
            System.assertEquals(updatedAccount.Institution_Type__c, updatedContactList[index].Institution_Type__c);
            System.assertEquals(updatedAccount.Minority_Institution__c, updatedContactList[index].Minority_Institution__c);
        }
        
        // Inserting account witch contains 'Household' keyword
        Account householdAccount = buildAccount('Household Account', 'Home');
        insert householdAccount;
        
        // inserting contacts
        contactList = buildContact(householdAccount.Id);
        insert contactList;
        
        householdAccount.Institution_Type__c = 'Foundation';
        update householdAccount;
        
        updatedAccount = [SELECT Id,Institution_Type__c,Minority_Institution__c 
                          FROM Account
                          WHERE Id =: householdAccount.Id];
        
        updatedContactList = [SELECT AccountId,Id,Account.Name,Institution_Type__c,Minority_Institution__c
                              FROM Contact
                              WHERE AccountId =: householdAccount.Id];
        
        // Checking updated contact value
        for(Integer index = 0 ; index < updatedContactList.size(); index++){
            System.assertEquals(updatedContactList[0].Institution_Type__c, Label.DW_Contact_Institution_Type);
            System.assertEquals(updatedContactList[0].Minority_Institution__c, updatedAccount.Minority_Institution__c);
        }
            
        Test.stopTest();
    }
}