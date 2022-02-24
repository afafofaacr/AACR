/**************************************************************************************************************************************************************************************************************************************************************
Name            :-  DW_UpdateInstitutionCtrl
Created Date    :-  7/17/2018
Updated Date    :-  
Created By      :-  
Updated By      :-  
Dependencies    :-  
Description     :-  
**************************************************************************************************************************************************************************************************************************************************************/

global class DW_UpdateInstitutionCtrl extends PagesApi.DefaultTemplateController {

    global Contact UserContactData { get; set; }
    global Id accountRecordTypeId { get; set; }
    global Id activeAccountRecordTypeId { get; set; }
    public DW_UpdateInstitutionCtrl() {
        system.debug( 'in constuctor '+ UserInfo.getUserId() );  
        this.UserContactData = getCurrentContact();
        system.debug( 'this.UserContactData  '+ JSON.serialize(this.UserContactData));        
        accountRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Unapproved Account').getRecordTypeId();
        activeAccountRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Active Account').getRecordTypeId();
    }

    public Contact getConObj() {
        return UserContactData;
    }

    public DW_UpdateInstitutionCtrl(ApexPages.StandardController stdCon) {

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

    @remoteAction
    public static Response updateContact( String contactId, String accountId ) {
        Response response;
        Contact contacToUpdate = new Contact();
        contacToUpdate.Id = contactId;
        contacToUpdate.AccountId = accountId;
        system.debug( 'account to update '+contacToUpdate );
        try{ 
            upsert contacToUpdate;
            Map<String, Object> dataToSend = new Map<String, Object>();
            response = new Response( true, 'Contact updated successfully!', dataToSend );
        } catch ( DMLException e ) { 
            // show the messages to the user 
            response = new Response( e );
        } 
        return response;
    }
}