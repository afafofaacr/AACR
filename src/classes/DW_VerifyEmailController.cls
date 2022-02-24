/**
 *@Class Name   : DW_VerifyEmailController
 *@Purpose      : Verify contact email address and update contact and crete user for that contact
 *@Created Date : 17-10-2018
 *@Modified Date: 25-10-2018
 */
public class DW_VerifyEmailController {
    public Boolean isEmailVerified{get; set;}
    
    /**
     *@Purpose : Updating Contact email address
     *@Param   : 
     *@return  : 
     */
    public PageReference updateContactEmailAddress(){
        // Getting current contact page Id
        Id contactId = ApexPages.currentPage().getParameters().get('id');
        String email = ApexPages.currentPage().getParameters().get('email');
        Contact updatedContact;
        
        if(String.isNotBlank(contactId) && String.isNotBlank(email)){
            
            try{
                // Updating contact's email address
                Contact contact = new Contact();
                contact.Id = contactId;
                contact.Email = email;
                contact.Unverified_Email_Address__c = '';
                update contact;
                System.debug('contact==>'+contact);
                
                // fetching updated contact
                updatedContact = [SELECT Id, AACR_ID__c, Email, FirstName, LastName, AccountId, Unverified_Email_Address__c
                                  FROM Contact 
                                  WHERE Id =: contactId];
                
                System.debug('updatedContact==>'+updatedContact); 
            }
            catch(Exception Exp){
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Error, 
                                                           String.isNotBlank(Label.DW_Duplicate_Email_Address_Msg) ? 
                                                                             Label.DW_Duplicate_Email_Address_Msg :
                                                                             'The Email address is already used by another portal user'));
                return NULL;
            }
           
            if(updatedContact != NULL){
                isEmailVerified = true;
                String baseUrl = System.URL.getSalesforceBaseUrl().toExternalForm();
				System.debug('community baseUrl =' + baseUrl);
                // Creating community user
                return createCommunityUser(updatedContact);
            } 
        }
        else{
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Error, 
                                                       String.isNotBlank(Label.DW_Email_not_verified_msg) ?
                                                       Label.DW_Email_not_verified_msg :
                                                       'Contact email address is not verified!'));
            return NULL;
        }
        return NULL;
    }
    
     /**
      *@Purpose : create Community User
      *@Param   : contact
      *@return  : -
      */ 
    public PageReference createCommunityUser(Contact contact){
        // Creating nickname
        String CommunityUsernickname = createCommunityUserNickName( contact.FirstName, contact.LastName);
        String password = '';
        
        User communityUser = new User();
        communityUser.Firstname = contact.FirstName;
        communityUser.Lastname = contact.LastName;
        if( String.isNotBlank( CommunityUsernickname ) ){
            communityUser.Communitynickname = CommunityUsernickname;//objUserDTO.FirstName + objUserDTO.LastName.left(1);
        }
        communityUser.Username = contact.Email;
        communityUser.profileId = getPWCommunityProfileId();
        communityUser.Email = contact.Email;
        communityUser.ContactId = contact.Id;
        
        communityUser.emailencodingkey ='UTF-8';
        communityUser.languagelocalekey = 'en_US';
        communityUser.timezonesidkey = 'America/Los_Angeles';
        communityUser.localesidkey = 'en_US';
        communityUser.Alias ='us';
        System.debug('communityUser==>'+communityUser);
       
        // create community user
        Database.DMLOptions dlo = new Database.DMLOptions();
        dlo.EmailHeader.triggerUserEmail= true;
        Database.saveresult result;
        
        try{
            result = Database.insert(communityUser,dlo);
            if( !result.success ) {
                isEmailVerified = false;
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Error, 'Duplicate Username ! The username already exists. Please use different email address'));
                //reset contact's email to blank
                Contact contactRec = new Contact();
                contactRec.Id = contact.Id;
                contactRec.Email = '';
                update contactRec;
                return NULL;
            } else { //if success redirect to page from custom label
                System.debug( 'in community user success' );
                String redirectUrl = Label.DW_Community_Base_Url+'/'+Label.DW_Post_Verify_Redirect;
                System.debug( 'redirectUrl: '+redirectUrl );
                PageReference retURL = new PageReference( redirectUrl );
                retURL.setRedirect(true);
                return retURL;
                
            }
        }catch(Exception Exp){
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Error, 'Duplicate Username ! The username already exists'));
            return NULL;
        }
    }
  
     /**
        @Purpose    : Create User nickName.
        @Parameters : users FirstName, users LastName
        @Return Type: String
     */
    @testvisible
    public String createCommunityUserNickName( string firstName, string lastName ) {
        
        if( String.isNotBlank(firstName) && String.isNotBlank(lastName) ){            
            
            String formattedUserNickName = getFormattedNickName( firstName, lastName ) ;
            
            if( String.isNotBlank(formattedUserNickName)){               
                String searchNickName = '%' + String.escapeSingleQuotes(formattedUserNickName) + '%';
                System.debug('searchNickName'+searchNickName);
                List<User> listUsers ;
                try{
                    listUsers = [ SELECT CommunityNickname, Username
                                 FROM User
                                 WHERE CommunityNickname LIKE : searchNickName 
                                ];
                }catch(Exception e){
                    System.debug(' exception has occured to fetch users : '+e.getMessage());
                } 
                
                if( listUsers != NULL && !listUsers.isEmpty() ){
                    Integer intCount = 2 ;
                    Set<String> setUserNickName = new Set<String>();
                    
                    for( User user : listUsers ){
                        if( String.isNotBlank(user.CommunityNickname)){
                            setUserNickName.add(user.CommunityNickname);
                        }
                    }
                    
                    if( setUserNickName != NULL && !setUserNickName.isEmpty() ){
                        String currentNickName = formattedUserNickName;
                        
                        while(setUserNickName.contains(currentNickName)){
                            //  keep updating nickname until a unique one is created.                             
                            currentNickName = formattedUserNickName + intCount;
                            intCount++;
                        }                        
                        return currentNickName;
                    }
                }
                return formattedUserNickName ;
            }
        }
        return NULL ;
    } 
    
    /**
        @Purpose    : Create formatted nickName.
        @Parameters : users FirstName, users LastName
        @Return Type: String
    */
    public String getFormattedNickName( String firstName, String lastName ){
        
        if( String.isNotBlank( firstName ) && String.isNotBlank( lastName ) ){
            return firstName.capitalize() + lastName.substring(0,1).toUpperCase(); 
        }
        return null;
    }
    
    /**
        @Purpose    : Fetch the profile Id of the Community User that the new User is to be designated with.      
        @Return Type: Id [ Profile Id]
     */ 
    public Id getPWCommunityProfileId(){
        String profileName = String.isNotBlank(Label.DW_Profile_Name) ? Label.DW_Profile_Name : 'Fonteva Customer Community Login User';
        try{
            return [SELECT Id
                    FROM Profile
                    WHERE Name =: profileName].Id;
        }
        catch( Exception e ){
            System.debug('Exception in fetching Profile for user ::: '+ e);
        }
        return null;
    }
}