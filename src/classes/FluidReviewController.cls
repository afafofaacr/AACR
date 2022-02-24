//Class to create connection with FluidReview
public class FluidReviewController {
    public Id Id { get; set; }
    public String userid;
    public String first_name;
    public String last_name;
    public String userType;
    public String ssoUser;
    public Contact memberContact;
    public Account memberAccount; 
    public Education__c memberEdu;
    FRSession__c fr_session;
    String apiURL;
    String payLoad;    
    String payLoadMeta, resetPayload;
    ID conId;
    FR_Metadata__mdt fr_meta;
    
    //Constructor to fetch user details and fetch Connection settings
    public FluidReviewController() {
        userType = UserInfo.getUserType();
        userid = UserInfo.getUserName();
        ssoUser = UserInfo.getUserName();
        first_name = UserInfo.getFirstName();
        last_name = UserInfo.getLastName();   
        
        List<User> userList = [select SSO_Email__c from user where username=:userid LIMIT 1];
        User u;
        if (userList.size()>0){
            u = userList.get(0);
            if (u.sso_email__c != null) {
                ssoUser = u.SSO_Email__c;
            }
        }
                        
        fr_session = FRSession__c.getOrgDefaults();
    }

    public PageReference login() {
        Http h;
        HttpRequest reqLogin;
        HttpResponse resLogin;
        PageReference pageRef;              
        
        try{
            System.debug('User type: ' + userType);
            //Check if user is logged in. If not redirect to login page
            if (userType == 'Guest'){
                pageRef = new PageReference('/CPBase__custom_login');
                pageRef.setRedirect(true);
                return pageRef; 
            }
            
            System.debug('Get access token');
            apiURL = fr_session.FR_ConnectURL__c;
            System.debug('apiURL: ' + apiURL);

            //Check if the session is valid. If not valid refresh token
            //getAccessToken();
            //
            //FRRefreshToken.refreshToken();
            //refreshToken(); Convert this to a batch job that runs every 2 hours
            
            System.debug('Get member details');
            
            payLoad = 'email=' + EncodingUtil.urlEncode(ssoUser, 'UTF-8') +
                       '&first_name=' + EncodingUtil.urlEncode(replaceNull(first_name), 'UTF-8') +
                        '&last_name=' + EncodingUtil.urlEncode(last_name, 'UTF-8') + 
                        '&identifier=IMIS_ID'; //Use AACR ID for matching users
              
            DateTime dtTime = System.now();
            String strDtTime = String.valueof(dtTime);
            String resetEmail = ssoUser.left(2) + strDtTime.replaceAll('[^\\d]','') + ssoUser.mid(ssoUser.indexOf('@'), ssoUser.length());
            System.debug('resetEmail = ' + resetEmail);
            resetPayload = 'email=' + EncodingUtil.urlEncode(resetEmail, 'UTF-8') +
                       '&first_name=' + EncodingUtil.urlEncode(replaceNull(first_name), 'UTF-8') +
                        '&last_name=' + EncodingUtil.urlEncode(last_name, 'UTF-8') + 
                        '&identifier=IMIS_ID&IMIS_ID=' + EncodingUtil.urlEncode(ssoUser, 'UTF-8') ; //Payload used for rewriting the SSO Token in FluidReview
            
            System.debug('Payload before call to fetchMemberDetails ' + payLoad);
            System.debug('Reset Payload before call to fetchMemberDetails ' + resetPayLoad);
            //Get Member details to be sent to Fluid Review
            fetchMemberDetails();
            
            payLoad = payLoad + payLoadMeta;
            resetPayLoad = resetPayLoad + payLoadMeta;
            
            System.debug('Payload after call to fetchMemberDetails ' + payLoad);
            System.debug('Reset Payload after call to fetchMemberDetails ' + resetPayLoad);
            //If sign in logged in portal user to FluidReview
            System.debug('Details fetched');
            h = new Http();
            System.debug('http CREATED');
            reqLogin = new HttpRequest();
            reqLogin.setEndpoint(apiURL + '/api/v2/signin/');
            System.debug ('Endpoint set');
            reqLogin.setHeader('Content-Type', 'application/x-www-form-urlencoded');
            reqLogin.setHeader('Authorization', 'Bearer ' + fr_session.FR_AccessToken__c);
            reqLogin.setHeader('Cache-Control', 'no-cache');
            reqLogin.setHeader('accept', 'text/html');
            System.debug ('Authorization token ' + fr_session.FR_AccessToken__c);
            
            reqLogin.setMethod('POST');
            
            System.debug ('Next request: ' + reqLogin.getEndpoint());
            System.debug ('payload: ' + payLoad);                        
            reqLogin.setBody(payLoad);
            System.debug('Body = '+ reqLogin.getBody());             
            System.debug('Header Content type= ' + reqLogin.getHeader('Content-Type'));
            System.debug('Header Authorization = ' + reqLogin.getHeader('Authorization'));
            System.debug('Header Cache-Control = ' + reqLogin.getHeader('Cache-Control'));
            System.debug('Header User Agent = ' + reqLogin.getHeader('user-agent'));
            System.debug('Header Pragma = ' + reqLogin.getHeader('pragma'));
            System.debug('Header accept = ' + reqLogin.getHeader('accept'));
            
            resLogin = h.send(reqLogin);
            System.debug('response status code' + resLogin.getStatusCode());
            System.debug('response body' + resLogin.getBody());
            if (resLogin.getStatusCode() == 200) {
                Map<String, Object> result3 = (Map<String, Object>) JSON.deserializeUntyped(resLogin.getBody());
                String error =  (String)result3.get('error');
                if (error == 'Email address conflict'){
                    reqLogin.setEndpoint(apiURL + '/api/v2/signin/');
                    reqLogin.setHeader('Content-Type', 'application/x-www-form-urlencoded');
                    reqLogin.setHeader('Authorization', 'Bearer ' + fr_session.FR_AccessToken__c);
                    reqLogin.setHeader('Cache-Control', 'no-cache');
                    reqLogin.setHeader('accept', 'text/html');
                    System.debug ('Authorization token ' + fr_session.FR_AccessToken__c);
            
                    reqLogin.setMethod('POST');
            
                    reqLogin.setBody(resetPayload);
                    System.debug('Body = '+ reqLogin.getBody());             
                    resLogin = h.send(reqLogin);
                    System.debug('response status code' + resLogin.getStatusCode());
                    if (resLogin.getStatusCode() != 200) {
                        throw new FluidReviewException('SSO Reset Failed');
                    }                        
                }                   
                // Deserialize the JSON string into collections of primitive data types.
                Map<String, Object> result2 = (Map<String, Object>) JSON.deserializeUntyped(resLogin.getBody());
                String return_path =  (String)result2.get('return_path');
                System.debug('Received the following return_path:');
                System.debug(return_path);
                
                System.debug(result2.get('user_id'));
                Integer user_id =  (Integer)result2.get('user_id');
                System.debug('Received the following userid:');
                System.debug(user_id);
                
                pageRef = new PageReference(return_path);
                update fr_session;
                pageRef.setRedirect(true);
                
            }                        
        }
        catch(Exception e){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.FATAL,'The website encountered an unexpected error. Please try again later.');
            ApexPages.addMessage(myMsg);
            System.debug('Exception block');
            System.debug(e.getMessage());
            System.debug(e.getLineNumber());
            System.debug(e.getStackTraceString());
            //Enable when Email Deliverability set
            List<ApexEmailNotification> apList = [SELECT  Email, user.email from ApexEmailNotification];
            String[] toAddresses = new String[apList.size()];
            Integer count = 0;
            for (ApexEmailNotification ap : apList){
                if (ap.Email != null)
                    toAddresses[count] = ap.Email;
                else{
                    toAddresses[count] = ap.User.Email;
                }
                count++;
            }
            
            Messaging.SingleEmailMessage mail=new Messaging.SingleEmailMessage();
            
            mail.setToAddresses(toAddresses);            
            mail.setSenderDisplayName('Apex error message ');
            mail.setSubject('FluidReview Connection Error from Org : ' + UserInfo.getOrganizationName() + UserInfo.getUserId());
            mail.setPlainTextBody('Error message: ' + e.getMessage() + 'Stack Trace: '+ e.getStackTraceString() + 'Line No.: ' + e.getLineNumber());

            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });   
        }
        return PageRef;
    }
    
    private void fetchMemberDetails(){
        List<Account> accList = new List<Account>();
        List<Contact> conList = new List<Contact>(); 
        List<Education__c> eduList = new List<Education__c>(); 
        List<OrderApi__Badge__c> badgeList = new List<OrderApi__Badge__c>();
        //FR_Metadata__mdt fr_meta;
        //ID conId;
        String orgType;
        
        //Fetch ContactId for logged in user
        List<User> usrList = [SELECT ContactId from user where username = :userid ];
        System.debug('user ID: ' + userid);
        System.debug('List size: ' + usrList.size());
        
        conId = usrList.get(0).contactId;
        
        System.debug('Contact ID: ' + conId); 
        
        conList = [SELECT Salutation, DonorApi__Suffix__c, FirstName, MiddleName, LastName, Title, OtherStreet, OtherCity,
                   OtherState, OtherPostalCode, OtherCountry, HomePhone, OrderApi__Work_Phone__c, OrderApi__Preferred_Email__c,
                   Race__c, Gender__c , Birthdate, Primary_Research_Area_of_Expertise__c , AACR_ID__c, Membership_Status__c, Member_Type__c, AccountID
                   FROM Contact WHERE id = :conId];
        
        if (conList == null || conList.size() == 0 )  {
            System.debug('Contact record does not exist for user ' + userid);
            return;
        }
        
        memberContact = conList.get(0);
        System.debug('Account ID: ' + memberContact.AccountId); 
        
        //Fetch details of related instituition
        accList = [SELECT iMIS_ID__c, Institution_Type__c, 
                   Name, BillingStreet, BillingCity, BillingState, 
                   BillingPostalCode, BillingCountry, Phone, OrderApi__Account_Email__c
                   FROM Account where id = :memberContact.AccountId];
        
        if (accList == null || accList.size() == 0)  {
            System.debug('Account record does not exist for user ' + userid);
            return;
        }
        
        System.debug('Account ID: ' + memberContact.AccountId);
        System.debug('List size: ' + accList.size());
        
        memberAccount = accList.get(0);                     
                
        //Create query string for Member Contact, Account and Education
        List<Organization> org = [SELECT Id, IsSandbox, Name FROM Organization LIMIT 1];
        if (org.get(0).IsSandbox == true)
            orgType = 'Sandbox';
        else
            orgType = 'Production';
        
        System.debug('orgType = ' + orgType);
        //Query custom metadata for FluidReview metadata field values
        List<FR_Metadata__mdt> fr_metaList = [SELECT Prefix__c, Suffix__c, First_Name__c, Middle_Initial__c, 
                                          Last_Name__c, Current_Degree_s_Conferred__c, Current_Title__c, 
                                          Institution_iMIS_ID__c, Institution_Type__c, Institution_Name__c, 
                                          Institutional_Address_Line_1__c, Institutional_Address_City__c,
                                          Institutional_Address_State__c, Institutional_Address_ZIP__c, Institutional_Address_Country__c, 
                                          Institutional_Telephone_Number__c, Institutional_Email_Address__c, Home_Address_Line_1__c, 
                                          Home_Address_City__c, Home_Address_State__c, Home_Address_ZIP__c, Home_Address_Country__c, 
                                          Preferred_Direct_Telephone_Number__c, Alternate_Phone_Number__c, Home_Email_Address__c, 
                                          Race_Ethnicity__c, Gender__c, Date_of_Birth__c, Primary_Major_Program__c, AACR_ID__c, 
                                          AACR_Fellow__c, BSCR__c, CIMM__c , CICR__c, MEG__c, PCWG__c, RSM__c, TME__c, 
                                          Member_Type__c, Membership_Status__c, WICR__c
                                          FROM FR_Metadata__mdt where MasterLabel = :orgType];
        System.debug('Metadata list retrieved: ' + fr_metaList.size());
        fr_meta = fr_metaList.get(0);
        
        System.debug('Set payload '+ payLoad);
        
        //Send AACR id as first parameter that will be used for matching
        payLoad = payLoad + '&IMIS_ID=' + EncodingUtil.urlEncode(replaceNull(memberContact.AACR_ID__c), 'UTF-8');
        
        //Fetch education details, if available
        eduList = [SELECT Degree__c FROM Education__c WHERE Education_Related_to_Contact__c = :conId];
        System.debug('Queried education');
        payLoadMeta = '';
        if (eduList != null && eduList.size() > 0)  {
            System.debug('Response not null ' + eduList.size());
            memberEdu = eduList.get(0);       
            payLoadMeta = payLoadMeta + '&' + fr_meta.Current_Degree_s_Conferred__c + '=' + EncodingUtil.urlEncode(replaceNull(memberEdu.Degree__c), 'UTF-8');
        }

        payLoadMeta = payLoadMeta + '&' + fr_meta.Prefix__c + '=' + EncodingUtil.urlEncode(replaceNull(memberContact.Salutation), 'UTF-8');
        payLoadMeta = payLoadMeta + '&' + fr_meta.Suffix__c + '=' + EncodingUtil.urlEncode(replaceNull(memberContact.DonorApi__Suffix__c), 'UTF-8');
        payLoadMeta = payLoadMeta + '&' + fr_meta.First_Name__c + '=' + EncodingUtil.urlEncode(replaceNull(memberContact.FirstName), 'UTF-8');
        payLoadMeta = payLoadMeta + '&' + fr_meta.Middle_Initial__c + '=' + EncodingUtil.urlEncode(replaceNull(memberContact.MiddleName), 'UTF-8');
        payLoadMeta = payLoadMeta + '&' + fr_meta.Last_Name__c + '=' + EncodingUtil.urlEncode(replaceNull(memberContact.LastName), 'UTF-8');        
        payLoadMeta = payLoadMeta + '&' + fr_meta.Current_Title__c + '=' + EncodingUtil.urlEncode(replaceNull(memberContact.Title), 'UTF-8');
        payLoadMeta = payLoadMeta + '&' + fr_meta.Institution_iMIS_ID__c + '=' + EncodingUtil.urlEncode(replaceNull(memberAccount.iMIS_ID__c), 'UTF-8');
        payLoadMeta = payLoadMeta + '&' + fr_meta.Institution_Type__c + '=' + EncodingUtil.urlEncode(replaceNull(memberAccount.Institution_Type__c), 'UTF-8');
        payLoadMeta = payLoadMeta + '&' + fr_meta.Institution_Name__c + '=' + EncodingUtil.urlEncode(replaceNull(memberAccount.Name), 'UTF-8');
        payLoadMeta = payLoadMeta + '&' + fr_meta.Institutional_Address_Line_1__c + '=' + EncodingUtil.urlEncode(replaceNull(memberAccount.BillingStreet), 'UTF-8');
        payLoadMeta = payLoadMeta + '&' + fr_meta.Institutional_Address_City__c + '=' + EncodingUtil.urlEncode(replaceNull(memberAccount.BillingCity), 'UTF-8');
        payLoadMeta = payLoadMeta + '&' + fr_meta.Institutional_Address_State__c + '=' + EncodingUtil.urlEncode(replaceNull(memberAccount.BillingState), 'UTF-8');
        payLoadMeta = payLoadMeta + '&' + fr_meta.Institutional_Address_ZIP__c + '=' + EncodingUtil.urlEncode(replaceNull(memberAccount.BillingPostalCode), 'UTF-8');
        payLoadMeta = payLoadMeta + '&' + fr_meta.Institutional_Address_Country__c + '=' + EncodingUtil.urlEncode(replaceNull(memberAccount.BillingCountry), 'UTF-8');
        payLoadMeta = payLoadMeta + '&' + fr_meta.Institutional_Telephone_Number__c + '=' + EncodingUtil.urlEncode(replaceNull(memberAccount.Phone), 'UTF-8');
        payLoadMeta = payLoadMeta + '&' + fr_meta.Institutional_Email_Address__c + '=' + EncodingUtil.urlEncode(replaceNull(memberAccount.OrderApi__Account_Email__c), 'UTF-8');
        payLoadMeta = payLoadMeta + '&' + fr_meta.Home_Address_Line_1__c + '=' + EncodingUtil.urlEncode(replaceNull(memberContact.OtherStreet), 'UTF-8');
        payLoadMeta = payLoadMeta + '&' + fr_meta.Home_Address_City__c + '=' + EncodingUtil.urlEncode(replaceNull(memberContact.OtherCity), 'UTF-8');
        payLoadMeta = payLoadMeta + '&' + fr_meta.Home_Address_State__c + '=' +EncodingUtil.urlEncode(replaceNull(memberContact.OtherState), 'UTF-8');
        payLoadMeta = payLoadMeta + '&' + fr_meta.Home_Address_ZIP__c + '=' + EncodingUtil.urlEncode(replaceNull(memberContact.OtherPostalCode), 'UTF-8');
        payLoadMeta = payLoadMeta + '&' + fr_meta.Home_Address_Country__c + '=' + EncodingUtil.urlEncode(replaceNull(memberContact.OtherCountry), 'UTF-8');
        payLoadMeta = payLoadMeta + '&' + fr_meta.Preferred_Direct_Telephone_Number__c + '=' + EncodingUtil.urlEncode(replaceNull(memberContact.HomePhone), 'UTF-8');
        payLoadMeta = payLoadMeta + '&' + fr_meta.Alternate_Phone_Number__c + '=' + EncodingUtil.urlEncode(replaceNull(memberContact.OrderApi__Work_Phone__c), 'UTF-8');
        payLoadMeta = payLoadMeta + '&' + fr_meta.Home_Email_Address__c + '=' + EncodingUtil.urlEncode(replaceNull(memberContact.OrderApi__Preferred_Email__c), 'UTF-8');
        payLoadMeta = payLoadMeta + '&' + fr_meta.Race_Ethnicity__c + '=' + EncodingUtil.urlEncode(replaceNull(memberContact.Race__c), 'UTF-8');
        payLoadMeta = payLoadMeta + '&' + fr_meta.Gender__c + '=' + EncodingUtil.urlEncode(replaceNull(memberContact.Gender__c), 'UTF-8');
        payLoadMeta = payLoadMeta + '&' + fr_meta.AACR_ID__c + '=' + EncodingUtil.urlEncode(replaceNull(memberContact.AACR_ID__c), 'UTF-8');
        payLoadMeta = payLoadMeta + '&' + fr_meta.Date_of_Birth__c + '=' + EncodingUtil.urlEncode(replaceNull(String.valueOf(memberContact.Birthdate)), 'UTF-8');
        payLoadMeta = payLoadMeta + '&' + fr_meta.Primary_Major_Program__c + '=' + EncodingUtil.urlEncode(replaceNull(memberContact.Primary_Research_Area_of_Expertise__c), 'UTF-8');
        payLoadMeta = payLoadMeta + '&' + fr_meta.Membership_Status__c + '=' + EncodingUtil.urlEncode(replaceNull(memberContact.Membership_Status__c), 'UTF-8');
        payLoadMeta = payLoadMeta + '&' + fr_meta.Member_Type__c + '=' + EncodingUtil.urlEncode(replaceNull(memberContact.Member_Type__c), 'UTF-8');
        System.debug('payload before badges '+ payLoadMeta);
        
        //Get Membership type
        /*List<OrderApi__Subscription__c> subsList = [SELECT OrderApi__Item__r.name 
                                                    FROM OrderApi__Subscription__c 
                                                    WHERE OrderApi__Contact__c= :conId AND OrderApi__Is_Active__c = True 
                                                    ORDER BY OrderApi__Current_Term_End_Date__c DESC LIMIT 1];
        if (subsList != null && subsList.size() >0){
            payLoad = payLoad + '&' + fr_meta.Member_Type__c + '=' + EncodingUtil.urlEncode(replaceNull(subsList.get(0).OrderApi__Item__r.name), 'UTF-8');
        }
        else{
            payLoad = payLoad + '&' + fr_meta.Member_Type__c + '=null';
        }*/
        
        
        List <Association_Data__mdt> nameList = [SELECT AACR_Fellow__c,BSCR__c, CICR__c, CIMM__c, MEG__c, 
                                                 PCWG__c, RSM__c, TME__c, WICR__c
                                                 FROM Association_Data__mdt LIMIT 1];
        Association_Data__mdt badgeNames = nameList.get(0);
            
        //Fetch badge/association details
        //AACR
        if (isBadge(badgeNames.AACR_Fellow__c)){
            payLoadMeta = payLoadMeta + '&' + fr_meta.AACR_Fellow__c + '=' + EncodingUtil.urlEncode('Yes', 'UTF-8');
        }
        else {
            payLoadMeta = payLoadMeta + '&' + fr_meta.AACR_Fellow__c + '=' + EncodingUtil.urlEncode('No', 'UTF-8');
        }
        
        //BSCR
        if (isBadge(badgeNames.BSCR__c)){
            payLoadMeta = payLoadMeta + '&' + fr_meta.BSCR__c + '=' + EncodingUtil.urlEncode('True', 'UTF-8');
        }
        else {
            payLoadMeta = payLoadMeta + '&' + fr_meta.BSCR__c + '=' + EncodingUtil.urlEncode('False', 'UTF-8');
        }
        
        //CICR
        if (isBadge(badgeNames.CICR__c)){
            payLoadMeta = payLoadMeta + '&' + fr_meta.CICR__c + '=' + EncodingUtil.urlEncode('True', 'UTF-8');
        }
        else {
            payLoadMeta = payLoadMeta + '&' + fr_meta.CICR__c + '=' + EncodingUtil.urlEncode('False', 'UTF-8');
        }
        
        //CIMM
        if (isBadge(badgeNames.CIMM__c)){
            payLoadMeta = payLoadMeta + '&' + fr_meta.CIMM__c + '=' + EncodingUtil.urlEncode('True', 'UTF-8');
        }
        else {
            payLoadMeta = payLoadMeta + '&' + fr_meta.CIMM__c + '=' + EncodingUtil.urlEncode('False', 'UTF-8');
        }
        
        //MEG
        if (isBadge(badgeNames.MEG__c)){
            payLoadMeta = payLoadMeta + '&' + fr_meta.MEG__c + '=' + EncodingUtil.urlEncode('True', 'UTF-8');
        }
        else {
            payLoadMeta = payLoadMeta + '&' + fr_meta.MEG__c + '=' + EncodingUtil.urlEncode('False', 'UTF-8');
        }
        
        //PCWG
        if (isBadge(badgeNames.PCWG__c)){
            payLoadMeta = payLoadMeta + '&' + fr_meta.PCWG__c + '=' + EncodingUtil.urlEncode('True', 'UTF-8');
        }
        else {
            payLoadMeta = payLoadMeta + '&' + fr_meta.PCWG__c + '=' + EncodingUtil.urlEncode('False', 'UTF-8');
        }
        
        //RSM
        if (isBadge(badgeNames.RSM__c)){
            payLoadMeta = payLoadMeta + '&' + fr_meta.RSM__c + '=' + EncodingUtil.urlEncode('True', 'UTF-8');
        }
        else {
            payLoadMeta = payLoadMeta + '&' + fr_meta.RSM__c + '=' + EncodingUtil.urlEncode('False', 'UTF-8');
        }
        
        //TME
        if (isBadge(badgeNames.TME__c)){
            payLoadMeta = payLoadMeta + '&' + fr_meta.TME__c + '=' + EncodingUtil.urlEncode('True', 'UTF-8');
        }
        else {
            payLoadMeta = payLoadMeta + '&' + fr_meta.TME__c + '=' + EncodingUtil.urlEncode('False', 'UTF-8');
        }
        
        //WICR
        if (isBadge(badgeNames.WICR__c)){
            payLoadMeta = payLoadMeta + '&' + fr_meta.WICR__c + '=' + EncodingUtil.urlEncode('True', 'UTF-8');
        }
        else {
            payLoadMeta = payLoadMeta + '&' + fr_meta.WICR__c + '=' + EncodingUtil.urlEncode('False', 'UTF-8');
        }
        
        System.debug('Final payload '+ payLoad);
        return;
    }
    
    //Get BadgeData
    
    private boolean isBadge(String badgeName){
        List<OrderApi__Badge__c> badgeList = [SELECT Name FROM OrderApi__Badge__c 
                     WHERE OrderApi__Is_Active__c=TRUE AND OrderApi__Contact__c = :memberContact.id 
                     AND OrderApi__Badge_Type__r.Name = :badgeName order by OrderApi__Awarded_Date__c desc LIMIT 1];
        
        if (badgeList!= null && badgeList.size() == 1)
            return true;
        return false;
    }
       
    //Refresh Token
    
    @TestVisible private void refreshToken(){
        Http h;
        HttpRequest reqAuth;
        HttpResponse resAuth;
        
        h = new Http();
        reqAuth = new HttpRequest();
        
        // If the token was refreshed more than 2 hours ago, refresh the token
        if (fr_session.FR_LastUpdate__c == null || (fr_session.FR_LastUpdate__c.addHours(2) <= System.now()) ) {                           
            reqAuth.setEndpoint(apiURL + '/api/v2/o/token/');
            reqAuth.setMethod('POST');
            reqAuth.setHeader('Content-Type', 'application/x-www-form-urlencoded');
            
            System.debug('Refresh token');
                       
            payLoad = 'grant_type=' + EncodingUtil.urlEncode('refresh_token', 'UTF-8') +
                       '&client_id=' + EncodingUtil.urlEncode(replaceNull(fr_session.FR_ClientID__c), 'UTF-8') +
                       '&client_secret=' + EncodingUtil.urlEncode(replaceNull(fr_session.FR_ClientSecret__c), 'UTF-8')+
                        '&refresh_token=' + EncodingUtil.urlEncode(replaceNull(fr_session.FR_RefreshToken__c), 'UTF-8');
            System.debug('payLoad = ' + payLoad);
            reqAuth.setBody(payLoad);
            
            resAuth= h.send(reqAuth);
            System.debug('Status code for refresh: ' + resAuth.getStatus());
            if (resAuth.getStatusCode() == 200){
                // Deserialize the JSON string into collections of primitive data types.
                Map<String, Object> result2 = (Map<String, Object>) JSON.deserializeUntyped(resAuth.getBody());
                fr_session.FR_RefreshToken__c =  (String)result2.get('refresh_token');
                fr_session.FR_AccessToken__c =  (String)result2.get('access_token'); 
                fr_session.FR_LastUpdate__c = System.now();
                System.debug('Access Token ' + fr_session.FR_AccessToken__c);
                System.debug('Last Update ' + fr_session.FR_LastUpdate__c);
                //update fr_session;
            }
            if (resAuth.getStatusCode() == 401 && resAuth.getStatus() == 'Unauthorized') {   
                throw new FluidReviewException('Please generate new access token credentials');
            }        
                
        }
        return;
    }
    
    //Replace null strings with ''
    private String replaceNull(String str){
        if (str == null)
            return '';
        return str;
    }
}