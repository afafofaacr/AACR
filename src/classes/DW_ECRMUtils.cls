/**
 *@Purpose      : Class contains all util methods 
 *@Created Date : 31/08/18
 *@Modified Date: 19/09/18
 */
public class DW_ECRMUtils {
    
     /**
      *@Purpose : Getting class names from custom setting
      *@Param   : className
      *@return  : Item class name
      */ 
    public static String getClassName(String className){
        // If classname is not blank
        if(String.isNotBlank(className)){
            // getting Class name values from setting
            DW_Item_Class_Names_Setting__c ItemClassName  = DW_Item_Class_Names_Setting__c.getValues(className);
            // if class name values not null
            if(ItemClassName != null){
                return ItemClassName.Class_Name__c;
            }
        }
        return NULL;
    }
    
    /**
     *@Purpose : Getting current login user contact Id
     *@Param   : -
     *@Return  : conatct id
     */
    public static Id getCurrentLoginUserContactId(){
        // Getting current login user id
        Id userId = UserInfo.getUserId();
        User user;
        try{
            user = [SELECT Id, ContactId 
                    FROM User 
                    WHERE Id = : userId];
            System.debug('user id+'+ user);
        }catch(Exception exp){
            System.debug('Exception Occured while fetching User:::'+ exp.getMessage() + '\t' + exp.getStackTraceString());
        } 
        return user.ContactId; 
    }
    
    /**
     *@Purpose : Getting Current Login user contact
     *@Param   : -
     *@Return  : Contact record
     */
    public static Contact getCurrentLoginContact(){
        // Getting current login user contact Id
        Id contactId = DW_ECRMUtils.getCurrentLoginUserContactId();
        Contact contact;
        
        if(String.isNotBlank(contactId)){
            try{
                contact = [SELECT Id, Name, Gender__c, Preferred_Address__c, Is_Journal_Addr_Same_As_Preferred_Addr__c,
                                  MailingStreet, MailingCity, MailingState, MailingPostalcode , MailingCountry,
                                  OtherStreet, OtherCity,  OtherState, OtherPostalCode, OtherCountry,
                                  Journal_Street__c, Journal_City__c, Journal_State_Province__c, 
                                  Journal_Zip_Postal_Code__c, Journal_Country__c,
                                  Member_Type__c, Initial_Join_Date__c, Membership_Status__c, Modify_Groups__c, RecordTypeId,
                                  RecordType.Name, Paid_thru_date__c
                           FROM Contact 
                           WHERE Id =: contactId];
            }catch(Exception exp){
                System.debug('Exception Occured :::'+ exp.getMessage() + '\t' + exp.getStackTraceString());
            }
        }
        return contact;
    }
    
    /**
     *@Purpose : update contact's journal Address
     *@Param   : -
     *@return  : -
     */
    public static void updateContactsJournalAddr(Contact UserContactData){
        // Update contact
        try{
            update UserContactData;
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.CONFIRM,'Journal Address Updated Successfully.!'));
        }
        catch(Exception exp){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,exp.getMessage()));
        }
    }
    
    /**
     *@Purpose : Create or update contact last accessed step record
     *@Param   : stepId
     *@Return  : -
     */
    public static void upsertContLastAccessedStep(Id stepId){
        joinapi__Step__c currentStep;
        List<contact_last_accessed_step__c> lastStepList = new List<contact_last_accessed_step__c>();
        contact_last_accessed_step__c contLastAccessedStep;
       
        // Getting current login user contact Id
        Id contactId = DW_ECRMUtils.getCurrentLoginUserContactId();
        
        // Fetching current step record
        try{
            if(String.isNotBlank(stepId)){
                currentStep = [SELECT Id, joinapi__Order__c, joinapi__Join_Process__c 
                               FROM joinapi__Step__c 
                               WHERE Id =: stepId];
                
                // Fetching contact last accessed step
                if(currentStep != NULL){
                    lastStepList = [SELECT Id, Contact__c, Join_Process__c, Step_Order__c 
                                    FROM contact_last_accessed_step__c
                                    WHERE Join_Process__c =: currentStep.joinapi__Join_Process__c AND
                                    Contact__c =: contactId];
                }
            }
        }catch(Exception exp){
            System.debug('Exception Occured :::'+ exp.getMessage() + '\t' + exp.getStackTraceString());
        }
        
        if(currentStep != NULL){
            // if lastStepList of particular join process is empty, create new contact last step
            if(lastStepList.isEmpty()){
                contLastAccessedStep = new contact_last_accessed_step__c(Contact__c = contactId,
                                                                         //Contact__c = '0030U00000L2tWe',
                                                                         Join_Process__c = currentStep.joinapi__Join_Process__c,
                                                                         Step_Order__c = currentStep.joinapi__Order__c);// Step_Order__c = 0
                
                try{
                    insert contLastAccessedStep;
                }catch(Exception exp){
                    System.debug('Exception Occured while Inserting Last Step :::'+ exp.getMessage() + '\t' + exp.getStackTraceString());
                }
                
            }
            else{
                // Update last step records step order with current sales order 
                if(currentStep.joinapi__Order__c > lastStepList[0].Step_Order__c){
                    lastStepList[0].Step_Order__c = currentStep.joinapi__Order__c;
                    // update last step
                    try{
                        update lastStepList[0]; 
                    }catch(Exception exp){
                        System.debug('Exception Occured :::'+ exp.getMessage() + '\t' + exp.getStackTraceString());
                    }
                }
            }
        }
    }
    
    /**
     *@Purpose : Getting Closed and Posted sales order id
     *@Param   : contactId
     *@Return  : Sales order Id
     */
    public static String getSalesOrderId(Id contactId){
        List<OrderApi__Sales_Order__c> salesOrderList = new List<OrderApi__Sales_Order__c>();
        // fetching Closed and Posted sales orders
        try{
            /*salesOrderList = [SELECT Id
                              FROM OrderApi__Sales_Order__c
                              WHERE OrderApi__Contact__c =: contactId AND
                                    OrderApi__Status__c =: 'Closed' AND
                                    OrderApi__Posting_Status__c =: 'Posted'];*/
            salesOrderList = [SELECT Id
                              FROM OrderApi__Sales_Order__c
                              WHERE OrderApi__Contact__c =: contactId ORDER BY CreatedDate DESC];
            
           
        }catch(Exception exp){
            System.debug('Exception Occured :::'+ exp.getMessage() + '\t' + exp.getStackTraceString());
        }
        if(! salesOrderList.isEmpty()){
            return salesOrderList[0].Id;
        }
        return NULL;
    }
    
    /**
     *@Purpose : Getting picklist values
     *@Param   : objectName, fieldName
     *@Return  : picklistValuesMap
     */
    public static Map<String, String> getPicklistEntries(String objectName, String fieldName) {
        Map<String, String> picklistValuesMap = new Map<String, String>();
        
        if (String.isNotBlank(objectName) && String.isNotBlank(fieldName)) {            
            SObjectType objectToken = Schema.getGlobalDescribe().get(objectName);
            if (objectToken != NULL) {
                Map<String, SObjectField> fields = objectToken.getDescribe().fields.getMap();	
                List<Schema.PicklistEntry> listOfPicklistEntries = fields.get(fieldName).getDescribe().getPickListValues();
                if (listOfPicklistEntries != NULL && !listOfPicklistEntries.isEmpty()) {
                    for (Schema.PicklistEntry pickListVal : listOfPicklistEntries) {
                        picklistValuesMap.put(pickListVal.getLabel(), pickListVal.getValue());
                    }
                } 
            }
        }
        return picklistValuesMap;
    }
    
    /**
     *@Purpose : Getting all sales order with its 'Individual Memberships' line items 
     *@Param   : contactId
     *@Return  : List of sales order line items
     */
    public static List<OrderApi__Sales_Order_Line__c> getIndividualMemSalesOrderLIs(Id contactId){
        List<OrderApi__Sales_Order_Line__c> allSalesOrderLIList = new List<OrderApi__Sales_Order_Line__c>();
        List<OrderApi__Sales_Order__c> salesOrderList = new List<OrderApi__Sales_Order__c>();
        try{
            salesOrderList = ([SELECT Id, OrderApi__Contact__c, OrderApi__Status__c,
                                     (SELECT Id, Name, OrderApi__Item__c, OrderApi__Item_Class__r.Name, 
                                             OrderApi__Sales_Order__c, OrderApi__Item__r.Name
                                     FROM OrderApi__Sales_Order_Lines__r
                                     WHERE OrderApi__Item_Class__r.Name = 'Individual Memberships'
                                     LIMIT 1)
                               FROM OrderApi__Sales_Order__c
                               WHERE OrderApi__Contact__c =: contactId 
                               ORDER BY CreatedDate DESC//AND
                               //OrderApi__Status__c =: 'Closed' 
                                ]);
        }catch(Exception exp){
            System.debug('Exception Occured :::'+ exp.getMessage() + '\t' + exp.getStackTraceString());
        }
        if(! salesOrderList.isEmpty()){
            for(OrderApi__Sales_Order__c salesOrder : salesOrderList){
                if(salesOrder.OrderApi__Sales_Order_Lines__r.size() > 0){
                    allSalesOrderLIList = salesOrder.OrderApi__Sales_Order_Lines__r;
                    break;
                }
            }
        }
        System.debug('allSalesOrderLIList==>'+allSalesOrderLIList);
        if(! allSalesOrderLIList.isEmpty()){
            return allSalesOrderLIList;
        }
        return allSalesOrderLIList;
    }
    
     /**
     *@Purpose : Getting Inividual Membership sales order LI's for specific sales order
     *@Param   : salesOrderId
     *@Return  : List of sales order LI's
     */
    public static List<OrderApi__Sales_Order_Line__c> getSpecificSalesOrderIndMemLIs( String salesOrderId ){
        List<OrderApi__Sales_Order_Line__c> membershipSalesOrderLIs = new List<OrderApi__Sales_Order_Line__c>();
        try{
            membershipSalesOrderLIs = ([SELECT Id, Name, OrderApi__Item__c, OrderApi__Item_Class__r.Name, OrderApi__Item_Class__c,
                                               OrderApi__Sales_Order__c, OrderApi__Item__r.Name, 
                                               OrderApi__Item__r.Is_Active_Membership_Type__c
                                        FROM OrderApi__Sales_Order_Line__c
                                        WHERE OrderApi__Sales_Order__c =: salesOrderId AND 
                                              OrderApi__Item_Class__r.Name = 'Individual Memberships'
                                        LIMIT 1]);
        }catch(Exception exp){
            System.debug('Exception Occured :::'+ exp.getMessage() + '\t' + exp.getStackTraceString());
        }
        return membershipSalesOrderLIs;
    }
    
    /**
     *@Purpose : Getting Join Process URL 
     *@Param   : -
     *@return  : Join Process URL
     */
    public static String getJoinProcessURL(Id salesOrderId){
        System.debug('getJoinProcessURL');
        String joinProcessURL = ' ';
        joinapi__Join_Process__c joinProcess;

        // Getting individual membership sales order LI list
        List<OrderApi__Sales_Order_Line__c> salesOrderLIList = getSpecificSalesOrderIndMemLIs(salesOrderId);
        
        if(! salesOrderLIList.isEmpty() && String.isNotBlank(salesOrderLIList[0].OrderApi__Item__c)){
            try{
                System.debug('item==>'+salesOrderLIList[0].OrderApi__Item__c);
                System.debug('SELECT Id, joinapi__Landing_Url__c, Membership_Type__c, Membership_Type__r.Name FROM joinapi__Join_Process__c WHERE Membership_Type__r.Name LIKE :'+ salesOrderLIList[0].OrderApi__Item__r.Name);
                joinProcess = [SELECT Id, joinapi__Landing_Url__c, Membership_Type__c, Membership_Type__r.Name
                               FROM joinapi__Join_Process__c
                               WHERE Membership_Type__c =: salesOrderLIList[0].OrderApi__Item__c];
                System.debug('joinProcess=>'+joinProcess);
            }catch(Exception exp){
                System.debug('Exception Occured While fetching Join Process :::'+ exp.getMessage() + '\t' + exp.getStackTraceString());
            }
        }
        if(joinProcess != NULL && String.isNotBlank(joinProcess.joinapi__Landing_Url__c)){
            joinProcessURL = joinProcess.joinapi__Landing_Url__c;
        }
        System.debug('joinProcessURL==>'+joinProcessURL);
        return joinProcessURL;
    }
}