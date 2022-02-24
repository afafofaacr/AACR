global class DW_aacrCustomLoginController extends PagesApi.DefaultTemplateController {
    
    public String username                      {get;set;}
    public String password                      {get;set;}
    public String resetUsername                 {get;set;}
    public Boolean enableSocial                 {get;private set;}
    public String intType                       {get;set;}
    public String intSys                        {get;set;}
    public CommunityUserDTO objUserDTO          { get; set; }  
    public PagesApi__Site__c siteConfig         {get; private set;}
    private Id siteId;
    private String referrerUrl;
    public boolean showError {get; set;}
    public string errorMsg {get; set;}
    public boolean showModel {get; set;}
    public String maintenanceMessage              {get; private set;}

    public String campaignId {get;set;}
    public String startURL {get;set;}
    public boolean updateEmailSuccess {get; set;}

    
    
    global DW_aacrCustomLoginController() {
        system.debug(LoggingLevel.Info,'Constructor...');
        objUserDTO = new CommunityUserDTO();

        intSys = ApexPages.currentPage().getParameters().get('system');
        system.debug(LoggingLevel.Info,'****system****'+intSys);
        intType = ApexPages.currentPage().getParameters().get('type');
        system.debug(LoggingLevel.Info,'****type****'+intType);
        siteId = Framework.PageUtils.getIdParam('site');
        siteConfig = getSite();
        if (siteConfig != null &&
            (siteConfig.PagesApi__Twitter_Login_URL__c != null || siteConfig.PagesApi__LinkedIn_Login_URL__c != null ||
             siteConfig.PagesApi__Google_Login_URL__c != null)) {
                 enableSocial = true;
             } else {
                 enableSocial = false;
             }
        referrerUrl = ApexPages.currentPage().getHeaders().get('Referer');
        showError = false;
        errorMsg = '';
        maintenanceMessage = getMaintenanceMessage();

        startURL = ApexPages.currentPage().getParameters().get('startURL');
        if(startURL!=null) {
            campaignId = startURL.substringAfter('campaignId=') != null ? startURL.substringAfter('campaignId=') : null;
            startURL = startURL.replaceAll('&', '%26');
        } else {
            campaignId = null;
        }

    }

    private String getMaintenanceMessage(){
        String pageName = ApexPages.currentPage().getUrl().substringBetween('apex/', '?');
        List<Maintenance_Mode_Config__mdt> configs = [SELECT Id, Maintenance_Message__c FROM Maintenance_Mode_Config__mdt WHERE Is_Active__c = true AND Page_API_Name__c =: pageName];
        if(configs.size() == 1){
            return configs[0].Maintenance_Message__c;
        }
        return null;
    }
    
    global PageReference checkSession() {
        Boolean isAuth;
        if(! Test.isRunningTest()){
             isAuth = this.getIsAuthenticated();
        }else{
            isAuth = true;
        }
        PageReference loginRedirectObj = null;
        if (isAuth) {
//            loginRedirectObj = buildLoginRedirect();
            if(intSys == '' || intSys == null){
                loginRedirectObj = buildLoginRedirect();
                return loginRedirectObj;
            } else if(intSys == 'compusystems' && (intType == '' || intType == null)){
                PageReference pageRef = new PageReference('/apex/redirectPage?system=compusystems&manage=false');
                return pageRef;
            } else if(intSys == 'compusystems' && (intType == 'manage')){
                PageReference pageRef = new PageReference('/apex/redirectPage?system=compusystems&manage=true');
                return pageRef;
            } else if(intSys == 'CMR'){
                PageReference pageRef = new PageReference('/apex/redirectPage?system=cmr');
                return pageRef;
            }
        } else {
            return null;
        }
        
        return null;
    }
    
    @TestVisible
    private PageReference buildLoginRedirect() {
        System.debug('buildLoginRedirect');
        PageReference redirectUrlObj = null;
        String pageParamRedirect = Framework.PageUtils.getParam('retUrl');
        System.debug('pageParamRedirect: ' + pageParamRedirect);
        String startUrl = Framework.PageUtils.getParam('startURL');
        System.debug('startUrl: ' + startUrl);
        System.debug('campaignId: ' + campaignId);

        if (String.isNotEmpty(startUrl) && campaignId!=null && campaignId!='') {
            System.debug('start url not empty & campaign id not null');
            redirectUrlObj = new PageReference(startUrl);
        } else if (String.isNotEmpty(pageParamRedirect)) {
            System.debug('retUrl not null');
            redirectUrlObj = new PageReference(pageParamRedirect);
        } else if(String.isNotEmpty(startUrl)){
            redirectUrlObj = new PageReference(startUrl);
        } else if (String.isNotEmpty(referrerUrl) && !referrerUrl.containsIgnoreCase('login') && !referrerUrl.containsIgnoreCase('logout') && referrerUrl.containsIgnoreCase(System.Site.getBaseSecureUrl())) {
            redirectUrlObj = new PageReference(referrerUrl);
        } else if (String.isNotEmpty(siteConfig.PagesApi__Login_Redirect_URL__c)) {
            redirectUrlObj = new PageReference(siteConfig.PagesApi__Login_Redirect_URL__c);
        }else {
            redirectUrlObj = System.Page.MemberProfile;
        }
        if (siteId != null) {
            redirectUrlObj.getParameters().put('site',siteId);
        }
        return redirectUrlObj;
    }
    
    public PageReference login() {
        system.debug(LoggingLevel.Info,'login...');
        PageReference redirect = null;
        Boolean formIsValid = String.isNotEmpty(username) && String.isNotEmpty(password);
        if (!formIsValid) {
            if (String.isEmpty(username)) {
                Framework.Message.addMessage(Label.CPBase.Login_Username_Required_Message,Framework.Message.Severity.Danger,false);
            }
            if (String.isEmpty(password)) {
                Framework.Message.addMessage(Label.CPBase.Login_Password_Required_Message,Framework.Message.Severity.Danger,false);
            }
        } else {
            if (siteConfig != null) {
                PageReference redirectUrlObj = buildLoginRedirect();
                System.debug('redirectUrlObj==>'+redirectUrlObj);
                String url = redirectUrlObj.getUrl().replace(Site.getBaseSecureUrl(),'');
                System.debug('url==>'+url);
                system.debug(LoggingLevel.Info,'****type****'+intType);
                system.debug(LoggingLevel.Info,'****sys****'+intSys);
                if(intSys == '' || intSys == null){
                    try {
                        User usr = [SELECT Id, Name, Email, Bad_Email_Address__c, ContactId, AccountId FROM User WHERE username =: username LIMIT 1];
                        if(usr.Bad_Email_Address__c && password!=null && username!=null){
                            //bad email check
                            showError = true;
                            objUserDTO.Email = usr.Email;
                            return null;
                        } else {
                            redirect = System.Site.login(username, password, url);
                            System.debug('redirect==>' + redirect);
                            if (redirect == null) {
                                System.debug('MSG==>' + System.Label.CPBase.Invalid_Username_Password);
                                System.debug('MSG==>' + Framework.Message.Severity.Danger);
                                Framework.Message.addMessage(System.Label.CPBase.Invalid_Username_Password, Framework.Message.Severity.Danger, false);
                            } else {
//
                                updateSO(username);
                                return redirect;
                            }
                        }
                    } catch (Exception ex) {
                        System.debug('ERROR: ' + ex.getMessage());
                        System.debug('LOCATION: ' + ex.getStackTraceString());
                        Framework.Message.addMessage(System.Label.CPBase.Invalid_Username_Password,Framework.Message.Severity.Danger,false);
                    }
                } else if(intSys == 'compusystems' && (intType == '' || intType == null)){
                    try {                   
                        redirect = Site.login(username,password,'/apex/redirectPage?system=compusystems&manage=false');
                        system.debug(LoggingLevel.Info,'****redirect****'+redirect);
                        if (redirect == null) {
                            Framework.Message.addMessage(System.Label.CPBase.Invalid_Username_Password,Framework.Message.Severity.Danger,false);
                        }
                        else {
                            //updateSO(username);
                            return redirect;
                        }
                    } catch (Exception ex) {
                        Framework.Message.addMessage(System.Label.CPBase.Invalid_Username_Password,Framework.Message.Severity.Danger,false);
                    }
                } else if(intSys == 'compusystems' && (intType == 'manage')){
                    try {                   
                        redirect = Site.login(username,password,'/apex/redirectPage?system=compusystems&manage=true');
                        system.debug(LoggingLevel.Info,'****redirect****'+redirect);
                        if (redirect == null) {
                            Framework.Message.addMessage(System.Label.CPBase.Invalid_Username_Password,Framework.Message.Severity.Danger,false);
                        }
                        else {
                            //updateSO(username);
                            return redirect;
                        }
                    } catch (Exception ex) {
                        Framework.Message.addMessage(System.Label.CPBase.Invalid_Username_Password,Framework.Message.Severity.Danger,false);
                    }
                } else if(intSys == 'CMR'){
                    try {                   
                        redirect = Site.login(username,password,'/apex/redirectPage?system=cmr');
                        system.debug(LoggingLevel.Info,'****redirect****'+redirect);
                        if (redirect == null) {
                            Framework.Message.addMessage(System.Label.CPBase.Invalid_Username_Password,Framework.Message.Severity.Danger,false);
                        }
                        else {
                            //updateSO(username);
                            return redirect;
                        }
                    } catch (Exception ex) {
                        Framework.Message.addMessage(System.Label.CPBase.Invalid_Username_Password,Framework.Message.Severity.Danger,false);
                    }
                }
            } else {
                Framework.Message.addMessage('Invalid site configuration!',Framework.Message.Severity.Danger,false);
            }
        }
        
        return null;
    }

    public void updateUserEmail(){
        updateEmailSuccess = BriteVerifyHelper.verifyEmail(objUserDTO.Email);

        if(updateEmailSuccess) {
            User u = [SELECT Id, Email, Bad_Email_Address__c FROM User WHERE Username = :username];
            u.Email = objUserDTO.Email;
            u.Username = objUserDTO.Email;
            u.Bad_Email_Address__c = false;
            update u;

            showError = false;
            errorMsg = null;
            username=objUserDTO.Email;

            System.resetPassword(u.Id, true);
        } else {
            showError = true;
            errorMsg = 'Email could not be verified.';
            System.debug('ERROR');
        }

    }
    
    @testVisible
    private void updateSO(String username) {
        try {
            OrderApi.ShoppingCart sc = new OrderApi.ShoppingCart(false);
            OrderApi__Sales_Order__c so;
            if(! Test.isRunningTest()){
                so = sc.getSalesOrder();
            }else{
                so = [SELECT Id FROM OrderApi__Sales_Order__c LIMIT 1];
            }
            
            if (so != null && so.Id != null) {
                User usr = [SELECT Id, Name, ContactId, AccountId FROM User WHERE username =: username LIMIT 1];
                if (usr.ContactId != null) {
                    so.OrderApi__Contact__c =  usr.ContactId;
                    so.OrderApi__Account__c = usr.AccountId;
                    update so;
                    List<OrderApi__Sales_Order_Line__c> lines = new List<OrderApi__Sales_Order_Line__c>();
                    for(OrderApi__Sales_Order_Line__c line : so.OrderApi__Sales_Order_Lines__r) {
                        line.OrderApi__Contact__c =  usr.ContactId;
                        line.OrderApi__Account__c = usr.AccountId;
                        lines.add(line);
                    }
                    update lines;
                    OrderApi.ShoppingCart.updateCookie(so.Id,usr.Id);
                }
            }
        }
        catch (Exception ex) {
            Framework.Log.debugException(ex);
        }
    }
    
    public PageReference loginTwitter() {
        PageReference login;
        if(! Test.isRunningTest()){
             login = new PageReference(siteConfig.PagesApi__Twitter_Login_URL__c);
        }else{
            login = new PageReference('https://aacruatf-fontevacustomer-15e958fad93-15f4a97b013.cs97.force.com/DW_WorkingGroups');
        }
        login.getParameters().put('community',System.Site.getBaseSecureUrl());
        if(intSys == '' || intSys == null){
            login.getParameters().put('startURL',System.Site.getPathPrefix());
        } else if(intSys == 'compusystems' && (intType == '' || intType == null)){
            login.getParameters().put('startURL','/apex/redirectPage?system=compusystems&manage=false');
        } else if(intSys == 'compusystems' && intType == 'manage'){
            login.getParameters().put('startURL','/apex/redirectPage?system=compusystems&manage=true');   
        } else if(intSys == 'CMR'){
            login.getParameters().put('startURL','/apex/redirectPage?system=cmr&manage=null'); 
        }
        login.setRedirect(true);
        
        return login;
    }
    
    public PageReference loginLinkedIn() {
        PageReference login;
        if(! Test.isRunningTest()){
             login = new PageReference(siteConfig.PagesApi__LinkedIn_Login_URL__c);
        }else{
            login = new PageReference('https://aacruatf-fontevacustomer-15e958fad93-15f4a97b013.cs97.force.com/DW_WorkingGroups');
        }
        login.getParameters().put('community',System.Site.getBaseSecureUrl());
        if(intSys == '' || intSys == null){
            login.getParameters().put('startURL',System.Site.getPathPrefix());
        } else if(intSys == 'compusystems' && (intType == '' || intType == null)){
            login.getParameters().put('startURL','/apex/redirectPage?system=compusystems&manage=false');
        } else if(intSys == 'compusystems' && intType == 'manage'){
            login.getParameters().put('startURL','/apex/redirectPage?system=compusystems&manage=true');   
        } else if(intSys == 'CMR'){
            login.getParameters().put('startURL','/apex/redirectPage?system=cmr&manage=null'); 
        }
        login.setRedirect(true);
        return login;
    }
    
    public PageReference loginGoogle() {
        PageReference login;
        if(! Test.isRunningTest()){
             login = new PageReference(siteConfig.PagesApi__Google_Login_URL__c);
        }else{
            login = new PageReference('https://aacruatf-fontevacustomer-15e958fad93-15f4a97b013.cs97.force.com/DW_WorkingGroups');
        }
        login.getParameters().put('community',System.Site.getBaseSecureUrl());
        if(intSys == '' || intSys == null){
            login.getParameters().put('startURL',System.Site.getPathPrefix());
        } else if(intSys == 'compusystems' && (intType == '' || intType == null)){
            login.getParameters().put('startURL','/apex/redirectPage?system=compusystems&manage=false');
        } else if(intSys == 'compusystems' && intType == 'manage'){
            login.getParameters().put('startURL','/apex/redirectPage?system=compusystems&manage=true');   
        } else if(intSys == 'CMR'){
            login.getParameters().put('startURL','/apex/redirectPage?system=cmr&manage=null');   
        }
        login.setRedirect(true);
        return login;
    }
    
    /**
        @Purpose    : Create Individual account, and ECRM Community user        
        @Return Type: PageReference
    */  
    public PageReference createECRMCommunityUser(){       
        System.debug('In createECRMCommunityUser');
        if( isUserExists(objUserDTO.Email)){
            showError = true;
            showModel = true;
            displayMessage( ApexPages.SEVERITY.INFO,
                           'This email address has already been used to create an account');
            return null;
        }
        
        Contact individualContact;
        
        if(! Test.isRunningTest()){
            // Create contact
            individualContact = createContactFromDTO();
        }else{
            individualContact = [SELECT Id, AccountId FROM Contact LIMIT 1];
        }
       
        Account updatedAccount;
        Contact updatedContact;
        
        // Fetch updated contact with Account
        try{
            updatedContact = [SELECT Id, AccountId 
                              FROM Contact 
                              WHERE Id =: individualContact.Id];
            
            Account individualAccount = [SELECT Id, OwnerId 
                                         FROM Account 
                                         WHERE Id =: updatedContact.AccountId];
            System.debug('individualAccount==>'+individualAccount);
            
            // Getting Owner Id and update account's owner Id
            individualAccount.OwnerId = getOwnerIdForAccount();
            update individualAccount;
            
            updatedAccount = [SELECT Id, OwnerId 
                              FROM Account 
                              WHERE Id =: individualAccount.Id];
        }
        catch(Exception e){
            System.debug('Exception occured :: '+ e);
            displayMessage(ApexPages.SEVERITY.ERROR, e.getMessage());
        }
        if(! Test.isRunningTest()){
            if(String.isNotBlank(updatedAccount.Id)){
                return createCommunityUser( updatedAccount.Id); 
            }
        }else{
            return createCommunityUser( individualContact.AccountId);
        }
        
        return NULL;
    }
    
    /**
        @Purpose    : check user Email already present
        @Parameters : String
        @Return Type: Boolean
    */  
    public Boolean isUserExists( String email ){
        if ( String.isNotBlank( email) ){
            User[] users;          // if Email already present (check for duplicate)       
            try{
                users = [ SELECT CommunityNickname, Username
                        FROM User
                        WHERE Username  =: email 
                       ];
            }catch(Exception e){
                System.debug(' exception in fetch UserName: ' + e.getMessage() );
            }
            if( users.size() > 0) {
                return true;
            }
        }
        return false;
    }
    
    /**
        @Purpose    : Createes Account from DTO
        @Parameters : Individual Account Id
        @Return Type: Contact record
    */
    public Contact createContactFromDTO(){
        //System.debug('in createContactFromDTO::'+objUserDTO);
        Contact recordContact;
        recordContact = new Contact (RecordTypeId = getRecordTypeIdFromSObjectName( 'Contact', Label.Contact_Non_Member_Record_Type),
                                     FirstName = objUserDTO.FirstName,
                                     Lastname = objUserDTO.LastName,
                                     Email = objUserDTO.Email
                                    );
        //System.debug( 'created contact::'+recordContact );
        try{
            //System.debug( 'in try' );
            if(recordContact != NULL){
                //System.debug( 'in contact not null' );
                insert recordContact;
                return recordContact;
            }
        }catch(Exception e){
            //System.debug( 'in catch exception' );
            System.debug('Exception occured in creating Account : '+ e);
            displayMessage(ApexPages.SEVERITY.ERROR, e.getMessage());
        }
        //System.debug( 'returning null' );
        return null;
    }
    
    /**
        @Purpose    : Create and inserts community User
        @Parameters : Individual Account Id 
        @Return Type: PageReference
    */
    private PageReference createCommunityUser( Id individualAccId){
        
        String CommunityUsernickname = createCommunityUserNickName( objUserDTO.FirstName, objUserDTO.LastName );
        
        User communityUser = new User();
        communityUser.Firstname = objUserDTO.FirstName;
        communityUser.Lastname = objUserDTO.LastName;
        if( String.isNotBlank( CommunityUsernickname ) ){
            communityUser.Communitynickname = CommunityUsernickname;//objUserDTO.FirstName + objUserDTO.LastName.left(1);
        }
        communityUser.Username = objUserDTO.Email;
        communityUser.profileId = getPWCommunityProfileId();
        communityUser.Email = objUserDTO.Email;
       
        try{
            // Create community user
            Id communityId = Site.createExternalUser( communityUser, individualAccId, objUserDTO.Password );
            System.debug('communityId==>'+communityId);
            
            String redirectPageURL = '';
            String nextStepURL ='';
            
            String starURL = ApexPages.currentPage().getParameters().get('startURL');
            
            // Getting Join Process 12 landing URL
            String landingURL = getJPLandingURL();
            
            // redirect to particular star url
            if(String.isNotBlank(starURL)){
                System.debug('starurl==>'+ApexPages.currentPage().getParameters().get('startURL'));
                redirectPageURL = System.Site.getBaseSecureUrl() + ApexPages.currentPage().getParameters().get('startURL');
                System.debug('redirectPageURL==>'+redirectPageURL); 
            }
            else if(String.isNotBlank(landingURL)){
                // redirects to join process
                redirectPageURL = landingURL;
                System.debug('redirectPageURL==>'+redirectPageURL);
            }
            
            // send confirmation email to new user
            return Site.login(communityUser.Username, 
                              objUserDTO.Password, 
                              redirectPageURL);
            
        }
        catch( Exception e ){
            System.debug('Exception while creating Community User ::: '+ e);
            displayMessage( ApexPages.SEVERITY.ERROR, 'Sorry, an internal error occurred!');
        }
        return NULL;
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
    
    /*
        Get Id of paticular SObject record type 
        @param SObject Name
        @param record Type name
    */
    public static Id getRecordTypeIdFromSObjectName( String SObjectName, String recordTypeName ){
        try{
            return Schema.getGlobalDescribe().get(SObjectName).getDescribe().
                getRecordTypeInfosByName().get(recordTypeName).getRecordTypeId();
        }
        catch( Exception e ){
            System.debug('Exception in fetching RecordTypeId by name :'+ e);
        }
        return null;
    }
    
    /**
         @Purpose    : get owner Id for creating  for Community User        
         @Return Type: Owner Id ( User Id from DW_Account_Owner_Username label )
     */   
    public Id getOwnerIdForAccount(){
        try{
            return [SELECT Id 
                    FROM User
                    WHERE Name =: Label.DW_Account_Owner_Name LIMIT 1 ].Id; 
        }
        catch(Exception e){
            System.debug('Exception in fetching Owner Id for creating account:'+ e);
        }
        return null;
    }
 
    /*
         Display page message on vf page
         @param ApexPage severity
         @param Message
     */
    public void displayMessage( ApexPages.severity severity, String message ){
        System.debug('testing:::'+message);
        if(ApexPages.currentPage() != null){
            System.debug('ApexPages.currentPage() != null');
            ApexPages.addmessage(new ApexPages.message( severity, message ));
        }
        else{
            throw new LoginException('Exception: ' + message );
        }
    }
    
    /**
     *@Purpose : Getting JP 12 landing URL
     *@Param   : 
     *@Return  : landing URL
     */
    public static String getJPLandingURL(){
        String jpLandingURL ='';
          // Getting JP landing URL from DW_JP12_Landing_URL__c custom setting
        DW_New_Account_Redirect_URL__c  jpURL = DW_New_Account_Redirect_URL__c.getOrgDefaults();
        if(jpURL != NULL){
            jpLandingURL = jpURL.JP_Landing_URL__c;
            System.debug('jpLandingURL==>'+jpLandingURL);
        }
        return jpLandingURL;
    }
    
    private class LoginException extends Exception{}
    
    //Wrapper Class
    public class CommunityUserDTO{
        public String Firstname      { get; set; }
        public String Lastname       { get; set; }
        public String Email          { get; set; }
        public String Password       { get; set; }
        //public String promoCode      { get; set; }
    }
    
}