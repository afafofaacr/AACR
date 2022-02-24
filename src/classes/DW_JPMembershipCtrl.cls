/**************************************************************************************************************************************************************************************************************************************************************
Name            :-  DW_JPMembershipCtrl
Created Date    :-  5/23/2017
Updated Date    :-  
Created By      :-  Arpita Munjal
Updated By      :-  
Dependencies    :-  
Description     :-  Custom Controller for Join Process membership. 
State and Country picklist can not be used on JP so creating custom page to gather user information.
**************************************************************************************************************************************************************************************************************************************************************/

global class DW_JPMembershipCtrl extends PagesApi.DefaultTemplateController {

    
    global Contact UserContactData           { get; set; }
    public Orderapi__Item__c itm        { get; set; }
    public list<Attachment> usrfiles    { get; set; }
    public List<Contact> currentContacts { get; set; }
    public String[] streetAddresses   { get; set; }
    public Date Birthdate { get; set; }
    public Id accountRecordTypeId { get; set; }
    public Id activeAccountRecordTypeId { get; set; }

    public DW_JPMembershipCtrl() {
        currentContacts = [SELECT Id, Account.Name, is_affiliated_with_self__c, AccountId  FROM Contact WHERE Id IN ( SELECT ContactId FROM User WHERE Id =: UserInfo.getUserId() ) ];
        system.debug( 'currentContacts '+currentContacts );
        this.UserContactData = getCurrentContact();
        system.debug( 'this.UserContactData  '+ JSON.serialize(this.UserContactData));
        if( !currentContacts.isEmpty() ) {
            Contact currentContact = currentContacts[0];
            system.debug( 'currentContact.is_affiliated_with_self__c: '+currentContact.is_affiliated_with_self__c );
            UserContactData.is_affiliated_with_self__c = currentContact.is_affiliated_with_self__c;
            system.debug( 'UserContactData.is_affiliated_with_self__c: '+UserContactData.is_affiliated_with_self__c );
            if( UserContactData.is_affiliated_with_self__c == false ) {
                //String accountName = UserContactData.Account_Name__c;
                //if household keyword found in account name then set associated with radio button to self
                UserContactData.is_affiliated_with_self__c = ( (UserContactData.Account_Name__c).contains( 'Household' ) ) ? true : false;
                /*if( accountName.indexOf( 'Household' ) != -1 ) { 
                    UserContactData.is_affiliated_with_self__c = true;
                } else {
                    UserContactData.is_affiliated_with_self__c = false;
                }*/
            }
        }
        streetAddresses = new String[]{'','','','','',''};
        if(UserContactData.OtherStreet!=null && UserContactData.OtherStreet!=''){
            String[] str =  UserContactData.OtherStreet.split('\n');
            if(str!=null && str.size() >0)
                streetAddresses[0] = str[0];
            
            if(str!=null && str.size() >1)
                streetAddresses[1] = str[1];

            if(str!=null && str.size() >2)
                streetAddresses[2] = str[2];
      
        }
        if(UserContactData.MailingStreet!=null && UserContactData.MailingStreet!=''){
            String[] str =  UserContactData.MailingStreet.split('\n');
            if(str!=null && str.size() >0)
                streetAddresses[3] = str[0];
            
            if(str!=null && str.size() >1)
                streetAddresses[4] = str[1];

            if(str!=null && str.size() >2)
                streetAddresses[5] = str[2];
         
        }        
        //UserContactData.is_affiliated_with_self__c = true;
        accountRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Unapproved Account').getRecordTypeId();
        activeAccountRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Active Account').getRecordTypeId();
    }
  
    public PageReference nextStep() {
        //save contact address
        try{
            String stepId = Framework.PageUtils.getParam('id');
            System.debug( 'stepId: '+stepId );
            
            // Updating user contact Last accessed Step
            DW_ECRMUtils.upsertContLastAccessedStep(stepId);
            
            //add all street addresses
            if(streetAddresses[0]!=null || streetAddresses[1] !=null && streetAddresses[2] !=null)
                UserContactData.OtherStreet = streetAddresses[0]+'\n '+streetAddresses[1]+ '\n '+streetAddresses[2];

            if(streetAddresses[3]!=null || streetAddresses[4] !=null && streetAddresses[5] !=null)
                UserContactData.MailingStreet = streetAddresses[3]+'\n '+streetAddresses[4]+ '\n '+streetAddresses[5];
                
            // added on Jume, 29th: get ITEM Id against selected marketing steps and update Membership_Id__c
            Id itemId = getItemId(stepId);
            System.debug('Inside JPAddrPage: ITEM : ' + itemId);
            
            UserContactData.Membership_Id__c =  itemId;  

            update UserContactData;
            
            
            joinApi.JoinUtils joinUtil = new joinApi.JoinUtils(stepId);
            String redirectURL = joinUtil.navStepsMap.get('Next');
            System.debug( 'redirectURL: '+redirectURL );
            JSONGenerator gen = JSON.createGenerator(true);
            gen.writeStartObject();
            gen.writeStringField('stepId', stepId);
            //system.debug('===UserContact '+UserContact);
            //add URL param to manage is it a new join process or renewal process
            PageReference pgRef = new PageReference(redirectURL);
            String isJoinStr = ApexPages.currentPage().getParameters().get('isJoin');
            system.debug( 'isJoinStr: '+isJoinStr );
            if( String.isNotBlank( isJoinStr ) ) {
                pgRef.getParameters().put( 'isJoin', isJoinStr );
            }

            gen.writeStringField('redirectURL', redirectURL);
            gen.writeEndObject();
            system.debug( 'gen genAsString'+gen.getAsString() );
            system.debug( 'joinUtil'+joinUtil );
            /*if(gen.getAsString()!=null)
                joinUtil.setRedirectURLCookie(gen.getAsString());*/           
            return pgRef;
            //return null;
        }
        catch(Exception e){
            system.debug('===exception'+e.getLineNumber()+e.getStackTraceString());
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Error,e.getMessage()));
             return null;

        }
    }
    
    public PageReference previousStep() {
        String stepId = Framework.PageUtils.getParam('id');
        joinApi.JoinUtils joinUtil = new joinApi.JoinUtils(stepId);
        //if(!Test.isRunningTest())
            return new PageReference(joinUtil.navStepsMap.get('Previous'));

        //return null;
    }
    
    public PageReference cancelStep() {
        String stepId = Framework.PageUtils.getParam('id');
        joinApi.JoinUtils joinUtil = new joinApi.JoinUtils(stepId);        
        joinUtil.deleteCookies();
        return new PageReference(joinUtil.navStepsMap.get('First'));
    }
   
    public Contact getConObj() {
        return UserContactData;
    }


    public DW_JPMembershipCtrl(ApexPages.StandardController stdCon) {

    }
    
    public Boolean getIsPreviewMode() {
        return Framework.PageUtils.getBooleanParam('preview_mode');
    }

    public PageReference cancelPreview() {
        return new PageReference('/');
    }
    
    public static id getItemId(Id stepId){
        id itemId = NULL;
        joinapi__Step__c[] authStepList = [Select Id, Name, joinapi__Is_Authentication_Step__c, joinapi__Next_Step__c From joinapi__Step__c 
                                           Where joinapi__Next_Step__c =: stepId 
                                                 AND joinapi__Is_Authentication_Step__c = TRUE];
        
        joinapi__Step__c authStep = authStepList.size()>0?authStepList[0]:NULL;
        System.debug('authStep: ' + authStep);
        If(authStep==NULL)
        return NULL;
        
        joinapi__Step_Condition__c[] step_Condition = [ Select Id, joinapi__Item__c, joinapi__Is_Published__c, joinapi__Is_Marketing_Item__c From joinapi__Step_Condition__c
                                                        Where joinapi__Next_Step__c=: authStep.Id
                                                              AND joinapi__Is_Published__c = TRUE
                                                              AND joinapi__Is_Marketing_Item__c = TRUE];
                                                              
        System.debug('step_Condition: ' + step_Condition);
        itemId = step_Condition.size()>0?step_Condition[0].joinapi__Item__c:NULL; 
        return  itemId;
    }

    /*
    * Method to get picklist values of field from object 
    * @ObjectApi_name : object API name
    * @Field_name : field API name
    */
    public static list<SelectOption> getPicklistValues( String ObjectApi_name, String Field_name ){
        //list<SelectOption> options = new list<SelectOption>();
        List<SelectOption> options = new List<SelectOption>();
        Schema.SObjectType targetType = Schema.getGlobalDescribe().get(ObjectApi_name);//From the Object Api name retrieving the SObject
        Sobject Object_name = targetType.newSObject();
        Schema.sObjectType sobject_type = Object_name.getSObjectType(); //grab the sobject that was passed
        Schema.DescribeSObjectResult sobject_describe = sobject_type.getDescribe(); //describe the sobject
        Map<String, Schema.SObjectField> field_map = sobject_describe.fields.getMap(); //get a map of fields for the passed sobject
        List<Schema.PicklistEntry> pick_list_values = field_map.get(Field_name).getDescribe().getPickListValues(); //grab the list of picklist values for the passed field on the sobject
        for (Schema.PicklistEntry a : pick_list_values)
        { 
            options.add( new SelectOption( a.getValue(), a.getLabel() ) ); 
        }        
        return options;
    }

    /*
    * Method to get picklist values preferred address field
    */
    public List<SelectOption> getAddressoptions() {
        List<SelectOption> options = new List<SelectOption>();
        options.addAll( getPicklistValues( 'Contact', 'Preferred_Address__c' ) );  
        return options;
    }

    @remoteAction
    public static Response saveAccount( String accountName ) {
        Response response;
        Account account = new Account();
        account.Name = accountName;
        string ownerId = DW_accountOwnerSettings__c.getOrgDefaults().ownerId__c;
        if( String.isNotBlank( ownerId ) ) {
            account.OwnerId = ownerId;
        }
        //set record type of new account as "Unapproved Account"
        Id recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Unapproved Account').getRecordTypeId();
        system.debug( 'recordTypeId: '+recordTypeId );
        if( String.isNotBlank( recordTypeId  ) ) {
            system.debug( 'In not blank' );
            account.RecordTypeId = recordTypeId;
        }
        system.debug( 'account to insert '+account );
        try{ 
            upsert account;
            Map<String, Object> dataToSend = new Map<String, Object>();
            dataToSend.put( 'Id', account.Id );
            dataToSend.put( 'Name', account.Name );
            response = new Response( true, 'Account saved successfully!', dataToSend );
        } catch ( DMLException e ) { 
            // show the messages to the user 
            response = new Response( e );
        } 
        return response;
    }
    public void updateContactField() {         
        String contactFieldApiName = ApexPages.CurrentPage().getParameters().get( 'contactFieldApiName' );
        String contactFieldValue = ApexPages.CurrentPage().getParameters().get( 'contactFieldValue' );
        System.debug('contactFieldApiName: '+ contactFieldApiName);
        System.debug('contactFieldValue: '+ contactFieldValue);
        UserContactData.put( contactFieldApiName, contactFieldValue ); 
    }   
    
}