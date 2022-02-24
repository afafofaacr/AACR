/*
 * @Purpose     : Controller for DW_JPMembership1 visualforce page
 * @Author      : Rabaab (Dreamwares)
 * @Date        : 14-August-2018
 */
public class DW_JPMembershipControllerCloneHelper {
    
    /*
     * @Purpose : Init metjod for JPMEmbership page
     */
    public static Response doInit( String stepId, String salesOrderId ){
        Id userId = UserInfo.getUserId();
        Integer totalAttachmentCount = 0;
        Integer totalNominatorsCount = 0;
        String membershipType = '';
        //Querying user to get contact Id of logged in community user
        User user = [SELECT ContactId, Contact.Membership_Id__c FROM User WHERE ID = :userId ];
        Contact currentContact = [ Select Id, Contact_StudentNominatorType__c, Contact_StudentNominatorName__c, 
                                  Contact_StudentNominatorTitle__c FROM Contact WHERE Id =: user.ContactId ];
        Map<String, String> contactStudentNomInfo = new Map<String, String> {
                                    'name' => currentContact.Contact_StudentNominatorName__c, 
                                    'title' => currentContact.Contact_StudentNominatorTitle__c, 
                                    'type' => currentContact.Contact_StudentNominatorType__c
                                };
                                    
        // Getting sales order LI list
        List<OrderApi__Sales_Order_Line__c> membershipSalesOrderLIs =  DW_ECRMUtils.getSpecificSalesOrderIndMemLIs(salesOrderId);
        // pdate total Attachments Count
        if( membershipSalesOrderLIs.size() > 0 ) {
            OrderApi__Sales_Order_Line__c membershipSalesOrederLI = membershipSalesOrderLIs[ 0 ];
            membershipType = membershipSalesOrederLI.OrderApi__Item__r.Name;
            if(membershipSalesOrederLI.OrderApi__Item__r.Name.contains('Active') ||
               membershipSalesOrederLI.OrderApi__Item__r.Name.contains('Associate')){
                totalAttachmentCount = 1;
                System.debug('Active==>'+totalAttachmentCount);
                if( membershipSalesOrederLI.OrderApi__Item__r.Name.contains('Active') ) {
                    totalNominatorsCount = 2;
                } else { //Associate
                    totalNominatorsCount = 1;
                }
            } else if(membershipSalesOrederLI.OrderApi__Item__r.Name.contains('Student')){
                totalAttachmentCount = 2;
                System.debug('Student==>'+totalAttachmentCount); 
                totalNominatorsCount = 1;
            }
            else if(membershipSalesOrederLI.OrderApi__Item__r.Name.contains('Affiliate')){
                totalAttachmentCount = 3;
                System.debug('Affiliate==>'+totalAttachmentCount);
                totalNominatorsCount = 1;
            }
            
            try{
                //Orderapi__Item__c item = getItem(user.ContactId);
                
                Boolean isItemNull;
                isItemNull = ( membershipSalesOrderLIs.size() > 0 ) ? false : true;
                //Getting nominator information
                NominatorInfo[] nominatorsInfo = getNominatorsInfo(user.ContactId);
               
                //Getting attachments
                DW_JPMembershipControllerClone.Attachment_x[] attachments = new List<DW_JPMembershipControllerClone.Attachment_x>();
                //Integer numberOfAttachments =  item != null && item.Is_Active_Membership_Type__c ? 2 : 1;
                for(Attachment attachment : [SELECT Id, Name FROM Attachment WHERE ParentId = :user.ContactId LIMIT :totalAttachmentCount]){
                    attachments.add(new DW_JPMembershipControllerClone.Attachment_x(attachment.Id, attachment.Name));
                }

                //Getting url for nextstep
                String nextStepUrl = getNextStepURL( stepId );
                //get picklist values for student membership type field
                Map<String, String> nominatorTypeMap = DW_ECRMUtils.getPicklistEntries('Contact', 'Contact_StudentNominatorType__c');
                return new Response(true, '', new Map<String, 
                                    Object>{
                                            'ContactId' => user.ContactId, 
                                            'ItemIsNull' => isItemNull, 
                                            'nextStepUrl' => nextStepUrl, 
                                            'nominatorsInfo' => nominatorsInfo,
                                            'attachments' => attachments,
                                            'totalAttachmentCount' => totalAttachmentCount,
                                            'totalNominatorsCount' => totalNominatorsCount,
                                            'membershipType' => membershipType,
                                            'nominatorTypeMap' => nominatorTypeMap,
                                            'contactStudentNomInfo' => contactStudentNomInfo,
                                            'previousStepUrl' => getPreviousStepURL( stepId ),
                                            'cancelStepUrl' => getCancelStepURL( stepId )
                                            });
            }catch(Exception e){
                System.debug(e.getMessage() + ' ' + e.getStackTraceString());
                return new Response(false, '', null);
            }
        } else {
            return new Response(false, 'No membership item found', null);
        }
    }
   
    /*
     * @Purpose : Init metjod for JPMEmbership page
     */
    public static Response verifyNominators(String contactId, String memberNo , String email, List<String> existingNominatorIds ){
        if(String.isBlank(contactId)){
            return new Response(false, 'Please provide contact id', null);
        }
        
        Contact[] contacts = new List<Contact>();
        String message;
        
        try{
            /*Orderapi__Item__c item = getItem(contactId);
            if(item == null){
                return new Response(false, Label.DW_Item_Not_Found, null);
            }*/
            
            Response buildStringQueryResponse = buildStringQuery(contactId, memberNo, email);
            if(!buildStringQueryResponse.isSuccess){
                return buildStringQueryResponse;
            }
            
            //Firing query
            contacts = Database.query(buildStringQueryResponse.message);
        }catch(Exception e){
            System.debug(e.getMessage() + '\n' + e.getStackTraceString());
            return new Response(false, 'Something went wrong', null);
        }
        
        System.debug('Contacts: ' + contacts);

        //Check if contacts list is empty
        if(contacts.isEmpty()){
            message = Label.Nominator_Not_Found;
            return new Response(false, message, null);
        }
        
        //Check for duplicate nominator
        /*if(String.isNotBlank(nominatorOneId) && contacts[0].Id == nominatorOneId){
            return new Response(false, Label.DW_Duplicate_Nominator, null);
        }*/
        if( existingNominatorIds.size() > 0 && existingNominatorIds.contains( contacts[0].Id ) ) {
            return new Response(false, Label.DW_Duplicate_Nominator, null);
        }
        System.debug('subscription size()==>'+contacts[0].OrderApi__Subscriptions__r.size());
        //Check if nominator is valid
        Map<String, Object> returnMap = new Map<String, Object>();
        if(contacts[0].Membership_Status__c == 'Current' && contacts[0].OrderApi__Subscriptions__r.size() > 0){
            //Initializing map to be returned
            //Map<String, Object> returnMap = new Map<String, Object>();
            
            //message = Label.Nominator_Name_Verified.replace('NominatorName', contacts[0].Name);
            //returnMap.put('NominatorID', contacts[0].Id);
            String statusText = contacts[0].Name+' has been verified';
            NominatorInfo nom = new NominatorInfo( contacts[0].Id, contacts[0].AACR_ID__c, contacts[0].Email,
                                                 contacts[0].Name, statusText, true );
            returnMap.put( 'nominator', nom );
            return new Response( true, statusText, returnMap );
        }else{
            message = Label.Nominator_Cannot_Be_Used.replace('NominatorName', contacts[0].Name);
            NominatorInfo nom = new NominatorInfo( contacts[0].Id, contacts[0].AACR_ID__c, contacts[0].Email,
                                                 contacts[0].Name, message, false );
            returnMap.put( 'nominator', nom );
            return new Response(false, message, returnMap);
        }       
    }
    
    /*
     * @Purpose     : nextStep processing
     * @Parameter   : String contactId, String stepId, DW_JPMembershipControllerClone.Attachment_x[] attachments, String[] nominatorIDs
     * @Returns     : Response
     */
    public static Response nextStep( String contactId, String stepId, DW_JPMembershipControllerClone.Attachment_x[] attachments, 
        String[] nominatorIDs , String[] oldAttachmentIds, Boolean isStudentMembership, Map<String, String> studentNominator ){
        // Updating user contact Last accessed Step
        DW_ECRMUtils.upsertContLastAccessedStep(stepId);
        
        //Intializing record lists to be inserted
        Attachment[] insertAttachments = new List<Attachment>();
        npe4__Relationship__c[] relationships =new List<npe4__Relationship__c>();
        
        //Getting contactId if contactId is null or blank
        if(String.isBlank(contactId)){
            Id userId = UserInfo.getUserId();
            User user = [SELECT ContactId FROM User WHERE ID = :userId ];
            contactId = user.ContactId;
        }
        
        try{
            //Adding attachment records to attachment list
            for( DW_JPMembershipControllerClone.Attachment_x attachment : attachments ){
                insertAttachments.add(new Attachment(ParentId=contactId, Body=EncodingUtil.base64Decode(attachment.body), Name = attachment.name, Description = 'JoinProcess'));
            }
            if(!insertAttachments.isEmpty()){
                //Deleting old attachments
                delete [SELECT Id FROM Attachment WHERE ParentId = :contactId AND Description LIKE '%JoinProcess%' AND Id NOT IN :oldAttachmentIds ];
            }
            
            //Inserting attachments
            insert insertAttachments;
            if( !isStudentMembership ) { //if not student membership then only create and delete relationship records
                for( String nominatorId : nominatorIDs ){
                    //Adding relationship records
                    relationships.add( new npe4__Relationship__c( npe4__Contact__c = contactId,
                                                                npe4__RelatedContact__c = nominatorId,
                                                                npe4__Status__c = 'Current',
                                                                npe4__Type__c = 'Nominator'
                                                               ) );
                }

                //Deleting old relationship records
                npe4__Relationship__c[] oldRelationships = [SELECT Id, npe4__RelatedContact__c
                                                            FROM npe4__Relationship__c
                                                            WHERE npe4__Contact__c = :contactId LIMIT 2 ];
                delete oldRelationships;
                
                //Inserting relationship records for nominies
                insert relationships;
            } else {
                Contact contactObj = new Contact();
                contactObj.Id = contactId;
                contactObj.Contact_StudentNominatorType__c = studentNominator.get('type');
                contactObj.Contact_StudentNominatorName__c = studentNominator.get('name');
                contactObj.Contact_StudentNominatorTitle__c = studentNominator.get('title');
                upsert contactObj;
            }
            //Changes in code
            joinApi.JoinUtils joinUtil = new joinApi.JoinUtils(stepId);
            JSONGenerator gen = JSON.createGenerator(true);
            gen.writeStartObject();
            gen.writeStringField('stepId', stepId);
            String redirectURL = joinUtil.navStepsMap.get('Next');
            system.debug('===redirectURL '+redirectURL);
            gen.writeStringField('redirectURL', redirectURL);
            gen.writeEndObject();
            system.debug('gen='+gen);
            
            try{if(gen.getAsString()!=null)
                joinUtil.setRedirectURLCookie(gen.getAsString());
               }
            catch(Exception e){system.debug('===='+e);}
            
            return new Response(true, '', null);
            
            
            //return new Response(true, ''+item, null);
        }catch(Exception e){
            System.debug(e.getMessage() + '\t' + e.getStackTraceString());
            return new Response(false, e.getMessage() + '\t' + e.getStackTraceString(), null);
        }
    }
    
    /*
     * @Purpose     : Method to fetch Item record for the given contact
     * @Parameter   : Contact Id (String)
     * @Returns     : Item record
     */
   /* private static Orderapi__Item__c getItem(String contactId){
        Contact contact = [SELECT Membership_Id__c FROM Contact WHERE Id = :contactId];
        system.debug( 'SELECT Membership_Id__c FROM Contact WHERE Id = '+contactId );
        system.debug( 'contact: ' + contact );
        Orderapi__Item__c item;
        if(contact.Membership_Id__c != null){
            item = (Orderapi__Item__c) new Framework.Selector(Orderapi__Item__c.SObjectType).selectById(contact.Membership_Id__c);
            System.debug('@@@item:' + item);
        }
        return item;
    }*/
    
    /*
     * @Purpose     : Method to fetch URL of next step
     * @Parameter   : Current Step Id (String)
     * @Returns     : URL (String)
     */
    public static String getNextStepURL(String currentStepId) {
        return new joinApi.JoinUtils( currentStepId ).navStepsMap.get('Next');
    }
    
    public static String getPreviousStepURL(String currentStepId) {
    	return new joinApi.JoinUtils(currentStepId).navStepsMap.get('Previous');
    }
    
    public static String getCancelStepURL(String currentStepId) {
        return new joinApi.JoinUtils(currentStepId).navStepsMap.get('First');
    }
    
    /*
     * @Purpose     : Builds soql string to be fired to verify nominator
     * @Parameter   : Current Step Id (String)
     * @Returns     : Response
     */
    private static Response buildStringQuery(String contactId, String memberNo , String email){
        if(String.isBlank(memberNo) && String.isBlank(email)){
            return new Response(false, 'Please enter member# or email', null);
        }
        
        //Building sql query string
        String soqlString = 'SELECT Id, Name, Lastname, Email, AACR_ID__c, OrderApi__Personal_Email__c, OrderApi__Other_Email__c, OrderApi__Work_Email__c, Membership_Status__c,'
            + ' (SELECT Id, OrderApi__Item__r.Eligible_Nominator_Membership__c FROM OrderApi__Subscriptions__r WHERE OrderApi__Item__r.Eligible_Nominator_Membership__c = true)'
            + ' FROM ' + Schema.SobjectType.Contact.Name
            + ' WHERE ';
        
        //Adding where clause to the query
        soqlString += String.isNotBlank(memberNo) ? 'AACR_ID__c =\'' + memberNo + '\' ' : '';
        soqlString += String.isNotBlank(memberNo) && String.isNotBlank(email) ? ' OR ' : '';
        soqlString += String.isNotBlank(email) ? 'Email =\'' + email + '\' ' : '';
        
        System.debug('soqlString: ' + soqlString);
        
        return new Response(true, soqlString);
    }
    /*
     * @Purpose     : Fetch all details about nominators related to the given contact
     * @Parameter   : Contact Id (String)
     * @Returns     : List of nominators with their details
     */
    private static NominatorInfo[] getNominatorsInfo(String contactId){
        //Getting nominator information
        NominatorInfo[] nominatorsInfo = new List<NominatorInfo>();
        for(npe4__Relationship__c nominator : [SELECT Id, npe4__RelatedContact__c, npe4__RelatedContact__r.AACR_ID__c, npe4__RelatedContact__r.Email, 
                                               npe4__RelatedContact__r.Name
                                               FROM npe4__Relationship__c
                                               WHERE npe4__Contact__c = :contactId LIMIT 2 ]){
            String statusText = nominator.npe4__RelatedContact__r.Name + ' has been verified';
            nominatorsInfo.add(new NominatorInfo(nominator.npe4__RelatedContact__c, nominator.npe4__RelatedContact__r.AACR_ID__c, nominator.npe4__RelatedContact__r.Email,
                                                 nominator.npe4__RelatedContact__r.Name, statusText, true));
        }
        return nominatorsInfo;
    }
    
    /*
     * @Purpose     : Wrapper to store each nominators details
     */
    public class NominatorInfo{
        String nominatorId;
        String memberNo;
        String email;
        String name;
        String status;
        Boolean isVerified;
        
        public NominatorInfo(){}
        
        public NominatorInfo(String nominatorId, String memberNo, String email, String name, String status, Boolean isVerified){
            this.nominatorId = nominatorId;
            this.memberNo = memberNo;
            this.email = email;
            this.name = name;
            this.status = status;
            this.isVerified = isVerified;
        }
    }

    public static Response deleteAttachment( String contactId, String attachmentId ) {
        if( String.isNotBlank( contactId ) && String.isNotBlank( attachmentId ) ){
            Attachment attach = new Attachment();
            try {
                attach = [ SELECT Id FROM Attachment WHERE Id =: attachmentId ];
                delete attach; 
                return new Response( true, 'Attachment deleted successfully', null );   
            } catch( Exception e ) {
                system.debug( 'Exception while attachment delete: '+e.getMessage() + ' ' + e.getStackTraceString() );
                return new Response( false, 'Error occured while deleting attachment', null );
            }            
        } else {
            return new Response( false, 'Bad data', null );
        }
    }
}