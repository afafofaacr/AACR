/**
 *@Class Name   : DW_ForgotPasswordController
 *@Purpose      : DW_Forgot_Password page controller that exposes the site forgot password functionality
 *@Created Date : 24-09-2018
 *@Modified Date: 24-10-2018
 */
public class DW_ForgotPasswordController{
    public String emailAddress {get; set;} 
    public String contactAACRID {get; set;}
    public static String encodedEmail;
    public String validEmailAddress{get; set;}


    @testVisible
    private static String generateTemporaryPassword(){
        Integer passLength = 8;
        String charString = '!@#$%^&*()nopqrstuvwABCDPQRSTUVWXYZ0123456789abcdefghijkEFGHIJKLMNOlmxyz';
        String randomNew = '';
        while (randomNew .length() < passLength) {
            Integer changeInt = Math.mod(Math.abs(Crypto.getRandomInteger()), charString.length());
            randomNew += charString.substring(changeInt , changeInt +1);
        }

        return randomNew ;
    }


    /**
     * @purpose Validate AACRID exists in our system & has active user record
     * If user record does not exist,error
     * If user record is inactive --> activate it & set temporary password
     *
     * @param contactAACRID
     *
     */
    public static void validateAACRID(String contactAACRID){
        Contact contact;
        User user;
        Boolean success = false;

        if(contactAACRID!=null){ //user entered aacrId
            try{
                // Fetching contact of given member id
                contact = [SELECT Id, AACR_ID__c, Email, FirstName, LastName, AccountId
                FROM Contact
                WHERE AACR_ID__c =: contactAACRID];
            }catch(Exception Exp){
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Error, 'Could not find a user record associated with this Member ID. Please submit a help form <a href="/myAACRHelp">here</a> so we can address your issue.'));
                success = false;
            }
            if(contact!=null){
                try {
                    // Fetching particular user
                    User[] users = [
                            SELECT Id, Username, Email, IsActive, ContactId
                            FROM User
                            WHERE ContactId = :contact.Id
                    ];
                    System.debug('users: ' + users.size());
                    if (users.size() > 0) {
                        user = users[0];
                        if (!user.IsActive) {
                            System.debug('user is not active...');

                            try {
                                // activate the user
                                user.IsActive = true;
                                update user;

                                //set temporary password to avoid email reset loop
                                System.setPassword(user.Id, generateTemporaryPassword());

                            } catch (Exception Exp) {
                                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Error,'User record is inactive and could not be reactivated.'));
                            }
                        }
                    } else {
                        ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Error, 'Could not find a user record associated with this Member ID. Please submit a help form <a href="/myAACRHelp">here</a> so we can address your issue.'));
                    }
                } catch(Exception e){

                    System.debug('Exception :: '+ e.getMessage());
                }
            }
        }
    }

     /**
      *@Purpose : Encode Email
      *@Param   : email
      *@return  : encoded email
      */ 
    public static String encodeEmail(String email){
        Integer len = email.length();
        String innserWords = email.substring(3,len-3);
        System.debug('s3::'+innserWords);
        String encodedStr = email.replace(innserWords,'****');
        System.debug('email::'+encodedStr);
        return encodedStr;
    }

    /**
     * @purpose Validates email address is associated with active user
     * If user is inactive - activate it & set temporary password
     * If user doesn't exist - error
     *
     * @param emailAddress
     *
     * @return emailAddress
     */
    public static String validateEmail(String emailAddress){
        String userEmail = '';
        User user;

        if(String.isNotBlank(emailAddress)){
            try {
                User[] users = [
                        SELECT Id, Username, Email, IsActive, ContactId
                        FROM User
                        WHERE Email = :emailAddress AND ContactId != null
                ];
                if( users.size() > 0 ) {
                    user = users[0];
                    if(! user.IsActive){
                        // activate the user & set temporary password
                        try{
                            user.IsActive = true;
                            update user;
                            //set temporary password to avoid email reset loop
                            System.setPassword(user.Id, generateTemporaryPassword());
                        }
                        catch(Exception Exp){
                            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Error,'User record is inactive and cannot be reactivated.'));
                        }
                    }
                    userEmail = user.Email;
                } else {
                    ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Error,'Could not find a user record associated with this email. Please submit a help form <a href="/myAACRHelp">here</a> so we can address your issue.'));
                    userEmail = 'Invalid';
                }

            } catch(Exception e){
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Error,'Please Enter Valid Email Address'));
                userEmail = 'Invalid';
            }
        } else{
            userEmail = 'Invalid';
        }
        return userEmail;
    }
    

    private static User getUser(String emailAddress, String AACRID){
        User user;
        Contact contact;


            if (String.isNotBlank( emailAddress ) && emailAddress!='') {
                try {
                    User[] users = [
                            SELECT Id, Username, Email, IsActive, ContactId
                            FROM User
                            WHERE Email = :emailAddress AND ContactId != null
                    ];
                    if (users.size() > 0) {
                        user = users[0];
                        return user;
                    }
                } catch (Exception e) {
                    return null;
                }
            } else if(String.isNotBlank(AACRID) && AACRID!=''){
                try {
                    // Fetching contact of given member id
                    contact = [
                            SELECT Id, AACR_ID__c, Email, FirstName, LastName, AccountId
                            FROM Contact
                            WHERE AACR_ID__c = :AACRID
                    ];
                } catch (Exception Exp) {
                    return null;
                }
                if (contact != null) {
                    try {
                        // Fetching particular user
                        User[] users = [
                                SELECT Id, Username, Email, IsActive, ContactId
                                FROM User
                                WHERE ContactId = :contact.Id
                        ];
                        System.debug('users size: ' + users.size());
                        if (users.size() > 0) {
                            user = users[0];
                            return user;
                        }
                    } catch (Exception e) {
                        return null;
                    }
                }
            }
        return null;
    }


    /**
     * @purpose Reset user's password & redirect to confirmation
     *
     * @return PageReference to confirmation pg
     */
    public PageReference sendResetPasswordMail() {
        String emailAddress = ApexPages.CurrentPage().getParameters().get('emailAddress');
        String contactAACRID = ApexPages.CurrentPage().getParameters().get('contactAACRID');
        System.debug( 'in sendResetPasswordMail emailAddress'+ emailAddress+' contactAACRID '+contactAACRID );

        User u = getUser(emailAddress, contactAACRID);

        if( u!=null ) {
            System.debug( 'user is not null' );
            PageReference redirectPageURL = Page.DW_Forgot_Password_Confirm;

            encodedEmail = encodeEmail(u.Email);

            // send forgot password link on user email address
            try{
                System.resetPassword(u.Id, true);

                redirectPageURL.getParameters().put('encodedEmail',encodedEmail);
                redirectPageURL.setRedirect(true);

                return redirectPageURL;
            } catch(Exception e){
                System.debug('No success');
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Error, 'We have encountered an error resetting your password. Please try again or click \'Get AACR IT Help\' below'));
                return null;
            }

        } else { //contact does not have email
            System.debug( 'user is null');
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Error, 'Could not find user record.'));
            return null;
        }
    }
    /**
     *@Purpose : validate all reset password data
     *@Param   : -
     *@return  : page reference to redirect
     */
    public static void forgotPassword() {
        String emailAddress = ApexPages.CurrentPage().getParameters().get('emailAddress');
        String contactAACRID = ApexPages.CurrentPage().getParameters().get('contactAACRID');
        System.debug( 'emailAddress::'+emailAddress+' contactAACRID:'+contactAACRID );

            if(String.isNotBlank(emailAddress) && emailAddress!='') {
                System.debug('validating email....');
                String userEmail = validateEmail(emailAddress);

            } else if(String.isNotBlank(contactAACRID) && contactAACRID!='') {
                System.debug('validating AACRID...');
                validateAACRID(contactAACRID);
            } else {
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.WARNING,'Please enter at least one field'));

            }
    }

    /* ------------------------------- DEPRECATED --------------------------------------- */


    /**
   *@Purpose : Validating User name
   *@Param   : -
   *@return  : Boolean value
   */
//    public static String validateUserName( String emailAddress ){
//        String userEmail = '';
//        User user;
//        Contact contact;
//        if(String.isNotBlank(emailAddress)){
//            try{
//                // Fetching conatct of given member id
//                contact = [SELECT Id, AACR_ID__c, Email, FirstName, LastName, AccountId
//                           FROM Contact
//                           WHERE Email =: emailAddress];
//            }catch(Exception Exp){
//                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Error, 'Invalid Conatct'));
//            }
//            System.debug( 'Contact'+contact );
//            if(contact != NULL){
//                try{
//                    User[] users = [SELECT Id, Username, Email, IsActive, ContactId
//                                 FROM User
//                                 WHERE ContactId =: contact.Id];
//                    if( users.size() > 0 ) {
//                        user = users[0];
//                        if(! user.IsActive){
//                            // activate the user
//                            try{
//                                user.IsActive = true;
//                                update user;
//                            }
//                            catch(Exception Exp){
//                                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Error,'User is not activated! Please activate it first'));
//                            }
//                        }
//                        userEmail = user.Email;
//                    } else { //create community user
//                        if(String.isBlank(contact.Email)){
//                            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Error, 'Invalid email address Please <a href="#" onclick="verifyEmail()">Update email address</a>'));
//                            //return null;
//                        }else{
//                            System.debug('Craete community user');
//                            String communityId = createCommunityUser(contact);
//
//                            if(String.isNotBlank(communityId)){
//
//                                User createdUser = [SELECT Id, Username, Email
//                                                    FROM User
//                                                    WHERE Id =: communityId];
//                                System.debug('createdUser==>'+createdUser);
//                            }
//                        }
//                    }
//                }
//                catch(Exception Exp){
//                    ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Error,'Please Enter Valid Email Address'));
//                    userEmail = 'Invalid';
//                }
//            }
//        }else{
//            userEmail = 'Invalid';
//        }
//        return userEmail;
//    }

    /**
     *@Purpose : createCommunityUser
     *@Param   :
     *@return  :
     */
//    public static String createCommunityUser(Contact contact){
//        System.debug('In createCommunityUser');
//        DW_aacrCustomLoginController customLoginCon = new DW_aacrCustomLoginController();
//
//        // Creating nickname
//        String CommunityUsernickname = customLoginCon.createCommunityUserNickName( contact.FirstName, contact.LastName);
//        String password = '';
//
//        User communityUser = new User();
//        communityUser.Firstname = contact.FirstName;
//        communityUser.Lastname = contact.LastName;
//        if( String.isNotBlank( CommunityUsernickname ) ){
//            communityUser.Communitynickname = CommunityUsernickname;//objUserDTO.FirstName + objUserDTO.LastName.left(1);
//        }
//        communityUser.Username = contact.Email;
//        communityUser.profileId = customLoginCon.getPWCommunityProfileId();
//        communityUser.Email = contact.Email;
//        Id communityId;
//
//        // create community user
//        try{
//            communityId = Site.createExternalUser( communityUser, contact.AccountId, password);
//            System.debug('communityId==>'+communityId);
//        }catch(Exception Exp){
//            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Error,'The Portal user already exists for contact'));
//        }
//        return communityId;
//    }



    //    public String getUserEmailofContact( String emailAddress, String contactAACRID ) {
//        String userEmail = '';
//        Boolean success = false;
//        if( String.isNotBlank( emailAddress ) || String.isNotBlank(contactAACRID) ) {
//            if( String.isNotBlank( emailAddress ) ) {
//                Contact contact;
//                try {
//                        // Fetching conatct of given member id
//                        contact = [SELECT Id, AACR_ID__c, Email, FirstName, LastName, AccountId
//                                   FROM Contact
//                                   WHERE Email =: emailAddress];
//                }catch(Exception Exp){
//                    ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Error, 'Invalid Conatct'));
//                    success = false;
//                }
//                System.debug( 'Contact'+contact );
//                if(contact != NULL){
//
//                    try{
//                        User[] users = [SELECT Id, Username, Email, IsActive, ContactId
//                                     FROM User
//                                     WHERE ContactId =: contact.Id AND IsActive = true ];
//                        system.debug( 'found user size :'+users.size() );
//                        if( users.size() > 0 ) {
//                            userEmail = users[0].Email;
//                            system.debug( 'userEmail :'+users[0].Email );
//                        } else {
//                            system.debug( 'No user found' );
//                        }
//                    }
//                    catch(Exception Exp){
//                        ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Error,'Please Enter Valid Email Address'));
//                        userEmail = 'Invalid';
//                    }
//                }
//            } else if( String.isNotBlank( contactAACRID ) ) {
//                Contact contact;
//                try {
//                        // Fetching conatct of given member id
//                        contact = [SELECT Id, AACR_ID__c, Email, FirstName, LastName, AccountId
//                                   FROM Contact
//                                   WHERE AACR_ID__c =: contactAACRID];
//                }catch(Exception Exp){
//                    ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Error, 'Invalid Conatct'));
//                    success = false;
//                }
//                System.debug( 'Contact'+contact );
//                if(contact != NULL){
//                    try{
//                        system.debug( 'SELECT Id, Username, Email, IsActive FROM User WHERE ContactId = '+contact.Id+' OR Username ='+ emailAddress+'' );
//                       // Fetching particular user
//                        User[] users = [SELECT Id, Username, Email, IsActive, ContactId
//                               FROM User
//                               WHERE ContactId =: contact.Id AND IsActive = true ];
//                        system.debug( 'found user size :'+users.size() );
//                        if( users.size() > 0 ) {
//                            userEmail = users[0].Email;
//                            system.debug( 'userEmail :'+users[0].Email );
//                        }
//                    } catch( Exception Exp ) {
//                        ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Error, 'Issue while fetching user'));
//                        success = false;
//                    }
//                }
//            }
//        } else {
//            return '';
//        }
//        return userEmail;
//    }


    /**
 *@Purpose : validating contact AACR Id
 *@Param   : -
 *@return  : redirect to forgot password confirm page.
 */
//    public static void validateContactAACRId( String emailAddress, String contactAACRID ){
//        Contact contact;
//        User user;
//        Boolean success = false;
//
//        try{
//            // Fetching contact of given member id
//            contact = [SELECT Id, AACR_ID__c, Email, FirstName, LastName, AccountId
//                       FROM Contact
//                       WHERE AACR_ID__c =: contactAACRID];
//        }catch(Exception Exp){
//            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Error, 'Invalid Conatct'));
//            success = false;
//        }
//        System.debug( 'Contact'+contact );
//        if(contact != NULL){
//           try{
//               system.debug( 'SELECT Id, Username, Email, IsActive FROM User WHERE ContactId = '+contact.Id+' OR Email ='+ emailAddress+'' );
//               // Fetching particular user
//               User[] users = [SELECT Id, Username, Email, IsActive, ContactId
//                       FROM User
//                       WHERE ContactId =: contact.Id ];
//                System.debug( 'users size: '+users.size() );
//               if( users.size() > 0 ) {
//                    user = users[0];
//                    System.debug( 'users size greater: isactive :'+user.IsActive );
//                    if(! user.IsActive){
//                       // activate the user and if previously contact disabled then add contact to it
//                       try{
//                            System.debug( 'in update user try' );
//                            user.IsActive = true;
//                            update user;
//                            System.debug( 'user after update' );
//                       }
//                       catch(Exception Exp){
//                           ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Error,'User is not activated! Please activate it first'));
//                           //return null;
//                       }
//                    }
//                    System.debug('user==>'+user);
//                } else { //create user
//                    if(String.isBlank(contact.Email)){
//                        ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Error, 'Invalid email address Please <a href="#" onclick="verifyEmail()">Update email address</a>'));
//                        //return null;
//                    }else{
//                        System.debug('Craete community user');
//                        String communityId = createCommunityUser(contact);
//
//                        if(String.isNotBlank(communityId)){
//
//                            User createdUser = [SELECT Id, Username, Email
//                                                FROM User
//                                                WHERE Id =: communityId];
//                            System.debug('createdUser==>'+createdUser);
//                        }
//                    }
//                }
//
//           }catch(Exception Exp){
//               System.debug('Exception :: '+Exp.getMessage());
//           }
//       }
//        // Create new user
//        /*if(user == NULL && contact != NULL){
//            if(String.isBlank(contact.Email)){
//                success = false;
//                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Error, 'Invalid email address Please <a href="#" onclick="verifyEmail()">Update email address</a>'));
//                return null;
//            }else{
//                System.debug('Craete community user');
//                String communityId = createCommunityUser(contact);
//
//                if(String.isNotBlank(communityId)){
//                    success = true;
//                    // fetching created user
//                    User createdUser = [SELECT Id, Username, Email
//                                        FROM User
//                                        WHERE Id =: communityId];
//                    // encode email address
//                    encodedEmail = encodeEmail(createdUser.email);
//                    System.debug('encodedEmail==>'+encodedEmail);
//                    redirectPageURL.getParameters().put('encodedEmail',encodedEmail);
//                }
//            }
//        }
//        redirectPageURL.setRedirect(success);
//        return redirectPageURL;*/
//    }
    
    /**
     *@Purpose : Update contacts varified email address and send verification link
     *@Param   : -
     *@return  : -
     */ 
//    public PageReference updateContact(){
//        Contact contact;
//        PageReference pageRefer;
//
//        if(String.isNotBlank(validEmailAddress)){
//            try{
//                if(String.isNotBlank(contactAACRID)){
//                    // Fetching conatct
//                    contact = [SELECT Id, AACR_ID__c, Email, FirstName, LastName, AccountId, Unverified_Email_Address__c
//                               FROM Contact
//                               WHERE AACR_ID__c =: contactAACRID];
//                    System.debug('contact==>'+contact);
//                }
//
//                // Updating Contact's Unverified_Email_Address__c field
//                if(contact != NULL){
//                    contact.Unverified_Email_Address__c = validEmailAddress;
//                    update contact;
//                    System.debug('contact==>'+contact);
//                }
//            }catch(Exception Exp){
//                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Error, Exp.getMessage()));
//            }
//            // send verification email to new valid address
//            if(contact != NULL && String.isNotBlank(contact.Unverified_Email_Address__c)){
//                pageRefer = sendVerificationEmail(contact);
//            }
//        }
//        else{
//            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.WARNING,'Please enter valid email address'));
//        }
//        return pageRefer;
//    }
    
    /**
     *@Purpose : Send verification email
     *@Param   : updatedContact
     *@return  : -
     */ 
//    public PageReference sendVerificationEmail(Contact updatedContact){
//        System.debug('In sendVerificationEmail');
//        System.debug('updatedContact==>'+updatedContact);
//        System.debug('updatedContact.Unverified_Email_Address__c==>'+updatedContact.Unverified_Email_Address__c);
//        //String body='<html><body>'+label.DW_Email_Verification_Body+'<p><a href="'+label.DW_Email_Verification_Link+'?id='+updatedContact.Id+'&email='+updatedContact.Unverified_Email_Address__c + '">verifyemail</a></p></body></html>';
//
//        //getting email body
//        String body = getEmailBody(updatedContact);
//        System.debug('body==>'+body);
//
//        List<string> toAddress = new List<string>();
//        toAddress.add(updatedContact.Unverified_Email_Address__c);
//
//        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
//        //Set list of people who should get the email
//        mail.setToAddresses(toAddress);
//        // Set mail body
//        mail.setHtmlBody(body);
//        mail.setSaveAsActivity(false);
//        mail.setUseSignature(false);
//        // set subject
//        mail.setSubject('Email Verification');
//        // Set who the email is sent from
//        mail.setReplyTo(System.UserInfo.getUserEmail());
//        // Fetching org wide defaults addresses.
//        List<OrgWideEmailAddress> senderEmailAddList = [SELECT Id
//                                                        FROM OrgWideEmailAddress
//                                                        WHERE Address =: Label.DW_Sender_Email_Address];
//        // set sender mail address
//        if (! senderEmailAddList.isEmpty()){
//            mail.setOrgWideEmailAddressId(senderEmailAddList[0].Id);
//        }
//
//        Messaging.SendEmailResult[] results;
//        try{
//            // send mail
//            results = Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
//        }catch(Exception e){
//            System.debug('Exception occured at line no.:'+e.getLineNumber()+' error:'+e.getMessage());
//        }
//
//        if(results[0].success){
//            System.debug('The email was sent successfully.');
//        } else {
//            System.debug('The email failed to send: ' + results[0].errors[0].message);
//        }
//        // encode Email Address
//        encodedEmail = encodeEmail(updatedContact.Unverified_Email_Address__c);
//        PageReference pr = Page.DW_Forgot_Password_Confirm;
//        pr.setRedirect(true);
//        pr.getParameters().put('encodedEmail',encodedEmail);
//        return pr;
//    }
    
    /**
     *@Purpose : Getting Email body
     *@Param   : 
     *@return  : 
     */ 
//    public static String getEmailBody(Contact contact){
//        String emailBody ='';
//
//        //Set Savepoint
//        Savepoint sp = Database.setSavepoint();
//
//        if(contact.email == null) {
//			contact.email = 'test@abc12345.com';
//		}
//        update contact;
//
//        EmailTemplate verifyEmailTemplate = [SELECT Id, HtmlValue, Body
//                                             FROM EmailTemplate
//                                             WHERE DeveloperName =: Label.DW_Verify_Email_template_name];
//
//        System.debug('verifyEmailTemplate==>'+verifyEmailTemplate);
//        List<string> toAddress = new List<string>();
//        toAddress.add(contact.Email);
//
//        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
//        //Set list of people who should get the email
//        mail.setToAddresses(toAddress);
//        // set template Id
//        mail.setTemplateID(verifyEmailTemplate.Id);
//        //mail.setWhatId(Userinfo.getUserId());
//        mail.setTargetObjectId(contact.Id);
//        // Set who the email is sent from
//        mail.setReplyTo(System.UserInfo.getUserEmail());
//        mail.setUseSignature(false);
//        mail.setSaveAsActivity(false);
//        mail.setWhatId(contact.Id);
//
//        // Fetching org wide defaults addresses.
//        List<OrgWideEmailAddress> senderEmailAddList = [SELECT Id
//                                                        FROM OrgWideEmailAddress
//                                                        WHERE Address =: Label.DW_Sender_Email_Address];
//        // set sender mail address
//        if (! senderEmailAddList.isEmpty()){
//            mail.setOrgWideEmailAddressId(senderEmailAddList[0].Id);
//        }
//
//        try{
//            // Send email
//            Messaging.SendEmailResult[] results = Messaging.sendEmail(new Messaging.SingleEmailMessage[]{ mail });
//            // getting email body
//            emailBody = mail.getHtmlBody();
//            //Get HTML Body
//        }catch(Exception e){
//            System.debug('Exception occured at line no.:'+e.getLineNumber()+' error:'+e.getMessage());
//        }
//
//        // rollback transaction
//        Database.rollback(sp);
//
//        System.debug('emailBody==>'+emailBody);
//        return emailBody;
//    }
     
}