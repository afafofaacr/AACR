/**
 *@Purpose      : Getting community contact's Marketing Preferences or Communication preference and Display on VF page and saved updated values
 *@Created Date : 20/08/18
 *@Modified Date: 
 */
public class DW_ContactServiceHelper {
    
    /**
     *@purpose : Getting current login user contact Id
     *@param   : -
     *@return  : Contact Id
     **/
    public static Id getcurrentLoginContactId(){
        // Getting current login user id
        Id userId = UserInfo.getUserId();
        
        User user = [SELECT Id, ContactId 
                     FROM User 
                     WHERE Id = : userId];
        return user.ContactId;
    }
    
    /**
     *@Purpose : Getting contact with Marketing Preferences fields
     *@Param   : contactId
     *@return  : Contact record
     */
    public static Contact getMarketingPrefContact(Id contactId){
        
        List<String> marketingPrefFieldsList = new List<String>{'AACR_Announcements__c','Conferences_Workshops__c','AACR_Foundation__c','Membership_Information__c',
                                                                'Annual_Meeting__c','Minorities_in_Cancer_Research__c','Awards_Grants__c','Molecular_Epidemiology__c',
                                                                'Cancer_Immunology_Group__c','Stand_Up_2_Cancer__c','Cancer_Policy_Advocacy__c','Survivor_Advocacy__c',
                                                                'Cancer_Today_Magazine__c','Tumor_Microenvironment__c','Chemistry_in_Cancer_Research__c',
                                                                'Women_in_Cancer_Research__c'};
        // Getting contact with fields in  marketingPrefFieldsList   
        Contact contact = getContact(contactId, marketingPrefFieldsList);
        return contact;
    }
    
    /**
     *@Purpose : Getting contact with Communication Preferences fields
     *@Param   : contactId
     *@return  : Contact record
     */
    public static Contact getcommunicationPrefContact(Id contactId){
        
        List<String> communiactionPrefFieldsList = new List<String>{'Nickname__c', 'OrderApi__Work_Do_Not_Call__c', 'OrderApi__Home_Do_Not_Call__c', 'OrderApi__Mobile_Do_Not_Call__c',
                                                                    'Maiden_Name__c', 'Formerly_Known_As__c', 'CEO_Preference__c', 'Preferred_Address__c',
            													    'OrderApi__Preferred_Phone_Type__c','OrderApi__Preferred_Email_Type__c', 'Email', 
                                                                    'Do_Not_Display_in_Directory__c','Foundation_Do_Not_Solicit__c', 'OrderApi__Preferred_Phone__c',
                                                                    'OrderApi__Preferred_Email__c','Journal_Street__c','Journal_City__c', 'OrderApi__Work_Phone__c', 'HomePhone',
                                                                    'Journal_State_Province__c','Journal_Zip_Postal_Code__c','Journal_Country__c', 'MobilePhone',
                                                                    'Do_Not_Mail__c', 'DoNotCall','Do_Not_Email__c', 'OrderApi__Work_Email__c', 'OrderApi__Personal_Email__c',
                                                                    'Do_Not_Trade_Externally__c', 'Birthdate'};
       // Getting contact with fields in  communiactionPrefFieldsList 
       Contact contact = getContact(contactId, communiactionPrefFieldsList);
       return contact;
    }
    
    /**
     *@Purpose : Getting contact with particular fields
     *@Param   : contactId, contactFieldsList
     *@return  : Contact record
     */
    public static Contact getContact(Id contactId, List<String> contactFieldsList){
        Contact contact;
        
        if(contactId != NULL && ! contactFieldsList.isEmpty()){
            try{
                
                String contactQuery = 'SELECT Id,';
                contactQuery += String.join(contactFieldsList,','); 
                contactQuery += ' FROM Contact WHERE Id = \'' + contactId +'\'';
                
                //Getting contacts List
                contact  = Database.query(contactQuery);
                
            }catch(Exception exp){
                System.debug('Exception occured ::'+exp.getMessage());
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Error,Exp.getMessage()));
            }
        }
        return contact;
    }
}