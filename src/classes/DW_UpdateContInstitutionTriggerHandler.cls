/**
 *@Purpose      : Update Account's all related Contact's Institution type 
 *@Created Date : 11-10-2018
 *@Modified Date: 11-10-2018
 */
public class DW_UpdateContInstitutionTriggerHandler {

    /**
     *@purpose : update Account contact's institution type after update
     *@param   : newAccountList,oldAccountMap 
     *@return  : -
     */
    public static void onafterUpdateAccount(List<Account> newAccountList, Map<Id,Account> oldAccountMap){
        Account oldAccount;
        List<Account> accountToUpdateList = new List<Account>();
        
        for(Account newAccount : newAccountList){
            oldAccount = oldAccountMap.get(newAccount.Id);
            
            // Check if previous Account values and new values are not same
            if(oldAccount.Institution_Type__c != newAccount.Institution_Type__c
              || oldAccount.Minority_Institution__c != newAccount.Minority_Institution__c){ 
                accountToUpdateList.add(newAccount);
            }
        }
        if(! accountToUpdateList.isEmpty()){
            updateContact(accountToUpdateList);
        }
    }
    
    /**
     *@purpose : update Account contact's institution type and Minority Serving Institution 
     *@param   : newAccountList
     *@return  : 
     */
    public static void updateContact(List<Account> newAccountList){
        // contact list to update
        List<Contact> contactToUpdateList = new List<Contact>();
        List<Contact> contactList = new List<Contact>();
        
        // Fetching account and its related all contacts
        List<Account> accountList = [SELECT Id, Name, Minority_Institution__c,Institution_Type__c,
                                            (SELECT Id, Minority_Institution__c, Institution_Type__c 
                                             FROM Contacts)
                                      FROM Account
                                      WHERE Id IN : newAccountList];
        
        for(Account account : accountList){
            // check if account having contacts or not
            if(! account.Contacts.isEmpty()){
                contactList = account.Contacts;
            }
            
            if(! contactList.isEmpty()){
                // Update all related contact's
                for(Contact contact : contactList){
                    // If account name contains 'Household' keyword update contact with 'No Institution Type'
                    if(account.Name.contains('Household')){
                        contact.Institution_Type__c = Label.DW_Contact_Institution_Type != NULL ? 
                            Label.DW_Contact_Institution_Type : 'No Institution Type';
                    }
                    else if(String.isNotBlank(account.Institution_Type__c)){
                        // Update contact with account institution type
                        contact.Institution_Type__c = account.Institution_Type__c;
                    }
                    contact.Minority_Institution__c = account.Minority_Institution__c;
                    // add contact in contactToUpdateList for updation
                    contactToUpdateList.add(contact);
                }
            }
        }
        if(! contactToUpdateList.isEmpty()){
            update contactToUpdateList;
        }
    }
}