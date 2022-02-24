/**
 *@Purpose       : Util methods to provide data for journal, working gruopa and optional page
 *@Created Date  : 31-07-2018
 *@Modified Date : 31 -08 -2018
 */
public class DW_ECRMHelper {
    
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
      *@Purpose : Getting items of specific classes.
      *@Param   : classNamesSet, isRenewal, alesOrderId, currentStepId, type
      *@return  : Response data
      */ 
    public static DW_ECRMDTO.Response getItemsOfSpecificClass(Set<String> classNamesSet, Boolean isRenewal, String salesOrderId, 
                                                              String currentStepId, String type){
        
        // to take Response
        DW_ECRMDTO.Response response;
        // Map of item classname to ItemsList
        Map<String,List<DW_ECRMDTO.ItemDTO>> itemClassToItemsMap = new Map<String,List<DW_ECRMDTO.ItemDTO>>();
        Map<String,Object> stringToObjectMap = new Map<String,Object>();
        Map<String,String> stepURLToURLValue = new Map<String,String>();
        DW_ECRMDTO.ItemDTO itemDTO;
        String itemClassName = '';
        Map<String,Contact> contactStrToContactMap = new Map<String,Contact>();
        OrderApi__Sales_Order__c salesOrder;
        String salesOrderIdToProcess = '';
        
        // Getting current login user contact Id
        Id contactId = DW_ECRMUtils.getCurrentLoginUserContactId();
        
        // If type equals to modify getting Closed And Posted sales order Id
        if(String.isNotBlank(type) && type == 'modify'){
            if(String.isNotBlank(contactId)){
                // Getting Closed and Posted Sales order Id
                salesOrderIdToProcess = DW_ECRMUtils.getSalesOrderId(contactId);
            }
        }else{
            // process current sales order Id
            salesOrderIdToProcess = salesOrderId;
        }
        
        // putting sales Order Id to stringToObjectMap
        stringToObjectMap.put('SalesOrder_Id', salesOrderIdToProcess);
        // put all prevoius items to itemClassToItemsMap
        itemClassToItemsMap.putAll(getPreviousItems(salesOrderIdToProcess, classNamesSet, isRenewal));
        // Putting all step URLS to stringToObjectMap
        stringToObjectMap.put('Step_URLs', getStepURLs(currentStepId, type));
        // putting Current login user contact to stringToObjectMap
        stringToObjectMap.put('Contact', getCurrentLoginContact());
      
        try{
            // fetching itemlist of specific class
            for(OrderApi__Item__c item : [SELECT Id, Name, OrderApi__Price__c, Fon_Association_Journal_Type__c, OrderApi__Item_Class__r.Name,
                                          Hide_In_Join__c, Default_Selected_In_Join__c 
                                          FROM OrderApi__Item__c
                                          WHERE OrderApi__Item_Class__r.Name IN : classNamesSet AND 
                                                OrderApi__Is_Active__c = true
                                          Order by Name ]){
                
                itemDTO = new DW_ECRMDTO.ItemDTO();
                itemDTO = createItemDTORecord(item, null ,null);                                   
                                        
                // Replace Black space in class name with '_'                                    
                itemClassName = item.OrderApi__Item_Class__r.Name.replace(' ','_');
                                                    
                // if itemClassToItemsMap map not contains item Class name then put it into the map                                 
                if(! itemClassToItemsMap.containsKey(itemClassName)){
                  itemClassToItemsMap.put(itemClassName, new List<DW_ECRMDTO.ItemDTO>());                         
                } 
                // Add Items of particuler class to Map                                    
                itemClassToItemsMap.get(itemClassName).add(itemDTO);                                   
            } 
        }catch(Exception itemException){
            System.debug('Exception Occured ::'+itemException);
            response = new DW_ECRMDTO.Response(false, 'FAIL', NULL);
        }
      
        // If item list is empty return response false
        if(! itemClassToItemsMap.isEmpty()){
           // putting all the class items in stringToObjectMap
           stringToObjectMap.put('Items', itemClassToItemsMap);
           response = new DW_ECRMDTO.Response(true, 'SUCCESS with data', stringToObjectMap); 
        }else{
           response = new DW_ECRMDTO.Response(true, 'SUCCESS with NULL data', NULL);  
        }
        return response;
    }
   
    /**
     *@Purpose : Create Sales order line items
     *@Param   : Sales order Id, itemsToInsertList, className, itemsToDeleteList,
                 isJournalAddrSameAsPreferedAddr, currentStepId
     *@Return  : Response Data
     */
    public static DW_ECRMDTO.Response createNDeleteSalesOrderLineItems(String salesOrderId, 
                                                                       List<DW_ECRMDTO.ItemDTO> itemsToInsertList, 
                                                                       String className, 
                                                                       List<DW_ECRMDTO.ItemDTO> itemsToDeleteList,
                                                                       Boolean isJournalAddrSameAsPreferedAddr,
                                                                       String currentStepId){
       // sales order to update                                                                    
       OrderApi__Sales_Order__c salesOrderToUpdate;
       // to take Response
       DW_ECRMDTO.Response response;
       OrderApi__Sales_Order_Line__c salesOrderLineitem;
       List<OrderApi__Sales_Order_Line__c> salesOrderLIToInsertList = new List<OrderApi__Sales_Order_Line__c>();
       
       // Upsert contact Last accessed step                                                                    
       DW_ECRMUtils.upsertContLastAccessedStep(currentStepId);
                                                                           
       //  if className equels to Journals then fetch that sales order                                                                  
       if(className == 'Journals'){
           // Update Contacts Journal Address
           updateContactsJournalAddr(getCurrentLoginContact(), isJournalAddrSameAsPreferedAddr);
       }                                                                   
                                                                     
       if(! itemsToDeleteList.isEmpty()){
           // delete sales order line items
           deleteClassItems(itemsToDeleteList);                                                              
       }   
                                                                           
       // Create new sales order line by assigning items data
       for(DW_ECRMDTO.ItemDTO itemRecord : itemsToInsertList){
           if(String.isBlank(itemRecord.salesOrderLineItemId)){
               // create new salesOrder line item
               salesOrderLineitem = new OrderApi__Sales_Order_Line__c();
               salesOrderLineitem.OrderApi__Item__c = itemRecord.Id;
               salesOrderLineitem.OrderApi__Quantity__c = 1;
               salesOrderLineitem.OrderApi__Sales_Order__c = salesOrderId;
               salesOrderLIToInsertList.add(salesOrderLineitem);
           }
       }
                                                                           
       // Inserting sales order line items 
       if(! salesOrderLIToInsertList.isEmpty()){
           try{
               insert salesOrderLIToInsertList;
               return new DW_ECRMDTO.Response(true, getSuccessMessage(className), NULL); 
           }
           catch(Exception exp){
               System.debug('Exception Occured :::'+exp.getMessage());
               return new DW_ECRMDTO.Response(false,'Failure In creation of Sales order LI', NULL); 
           }
       }
       return new DW_ECRMDTO.Response(true, getSuccessMessage(className), NULL);
    }
    
    /**
     *@Purpose : delete class Item list 
     *@Param   : list of class items 
     *@Return  : -  
     */
    static void deleteClassItems(List<DW_ECRMDTO.ItemDTO> itemsToDeleteList){
        List<Id> salesOrderLIIdToDeleteList = new List<Id>(); 
        
        // delete sales order line items
        for(DW_ECRMDTO.ItemDTO itemRecord : itemsToDeleteList){
            salesOrderLIIdToDeleteList.add(itemRecord.salesOrderLineItemId);                                                                     
        }                                                               
        if(! salesOrderLIIdToDeleteList.isEmpty()){
            try{
                delete [SELECT Id 
                        FROM OrderApi__Sales_Order_Line__c 
                        WHERE Id IN : salesOrderLIIdToDeleteList];
            }catch(Exception exp){
                System.debug('Exception Occured :::'+ exp.getMessage() + '\t' + exp.getStackTraceString());
            }
        }                                                                    
    }
    
    /**
     *@Purpose : Getting Success message depending on class name  
     *@Param   : classname
     *@Return  : success  
     */
    static String getSuccessMessage(String className){
        String successMessage = '';
        // getting particular classes success message
        if(className == 'Working Groups'){
            successMessage = String.isNotBlank(Label.DW_Working_Groups_Success_Msg) ? Label.DW_Working_Groups_Success_Msg : 'Working Group items Saved Successfully';
        }
        else if(className == 'Optional Items'){
            successMessage = String.isNotBlank(Label.DW_Optional_Items_Success_Msg) ? Label.DW_Optional_Items_Success_Msg : 'Optional Items Saved Successfully';
        }
        else if(className == 'Journals'){
            successMessage = String.isNotBlank(Label.DW_Journal_Success_Msg) ? Label.DW_Journal_Success_Msg : 'Journal Items Saved Successfully';
        }   
        return successMessage;
    }
    
    /**
     *@Purpose : Getting previous Items list
     *@Param   : salesOrderId, classNamesSet, isRenewal
     *@Return  : item Class String To Items Map
     */
    static Map<String,List<DW_ECRMDTO.ItemDTO>> getPreviousItems(Id salesOrderId, Set<String> classNamesSet, Boolean isRenewal){
        // Map of item classname to ItemsList
        Map<String,List<DW_ECRMDTO.ItemDTO>> itemClassToItemsMap = new Map<String,List<DW_ECRMDTO.ItemDTO>>();
        DW_ECRMDTO.ItemDTO itemDTO;
        List<OrderApi__Sales_Order_Line__c> salesOrderLineItemsList = new List<OrderApi__Sales_Order_Line__c>();
        
        // Puting key, values in map according to Item class Name
        if(classNamesSet.contains('Complimentary Journals')){
            itemClassToItemsMap.put('Previous_Complimentary_Journals', new List<DW_ECRMDTO.ItemDTO>());
            itemClassToItemsMap.put('Previous_Journal_Subscriptions', new List<DW_ECRMDTO.ItemDTO>());
        }
        if(classNamesSet.contains('Working Groups')){
            itemClassToItemsMap.put('Previous_Working_Groups', new List<DW_ECRMDTO.ItemDTO>());
        }
        if(classNamesSet.contains('ZDecline of the Journals')){
            itemClassToItemsMap.put('Previous_Declined_Journal', new List<DW_ECRMDTO.ItemDTO>());
        }
        
        // Getting current login user contact Id
        Id contactId = DW_ECRMUtils.getCurrentLoginUserContactId();
        
        // Getting previous declined journal 
        OrderApi__Sales_Order_Line__c declinedSalesOrderLI = getDeclinedSalesOrderLI(salesOrderId, classNamesSet);
        if(declinedSalesOrderLI != NULL){
            salesOrderLineItemsList.add(declinedSalesOrderLI);
            System.debug('declinedSalesOrderLI.OrderApi__Item__r==>'+declinedSalesOrderLI.OrderApi__Item__r);
            
        }
        else{
            OrderApi__Item__c declinedJournalItem = getDeclinedJournalItem(classNamesSet);
            if(declinedJournalItem != NULL){
                itemDTO = new DW_ECRMDTO.ItemDTO();
                // Create ItemDTO record
                itemDTO = createItemDTORecord(declinedJournalItem, null, null);
                itemClassToItemsMap = addItemDTOToMap(itemClassToItemsMap, 'Previous_Declined_Journal', itemDTO);
            }
        }
        
        // Getting sales order line items.
        salesOrderLineItemsList = getSalesOrderLineItems(contactId, classNamesSet, salesOrderId, isRenewal);
                                                 
        if( ! salesOrderLineItemsList.isEmpty()){
            
            for(OrderApi__Sales_Order_Line__c salesOrderLineItem : salesOrderLineItemsList){
                
                itemDTO = new DW_ECRMDTO.ItemDTO();
                
                // Create ItemDTO record
                itemDTO = createItemDTORecord(salesOrderLineItem.OrderApi__Item__r, salesOrderLineItem.OrderApi__Sales_Order__c, 
                                              salesOrderLineItem.Id);
                
                // iF Item class is 'Complimentary Journals' then add its item for 'Previous_Complimentary_Journals' key     
                if(salesOrderLineItem.OrderApi__Item_Class__r.Name == 'Complimentary Journals'){
                    itemClassToItemsMap = addItemDTOToMap(itemClassToItemsMap, 'Previous_Complimentary_Journals', itemDTO);
                }
                // iF Item class is 'Journal Subscriptions' then add its item for 'Previous_Journal_Subscriptions' key         
                if(salesOrderLineItem.OrderApi__Item_Class__r.Name == 'Journal Subscriptions'){
                    itemClassToItemsMap = addItemDTOToMap(itemClassToItemsMap, 'Previous_Journal_Subscriptions', itemDTO);
                }     
                // iF Item class is 'Working Groups' then add its item for 'Previous_Working_Groups' key          
                if(salesOrderLineItem.OrderApi__Item_Class__r.Name == 'Working Groups'){
                    itemClassToItemsMap = addItemDTOToMap(itemClassToItemsMap, 'Previous_Working_Groups', itemDTO);
                }
                // iF Item class is 'ZDecline of the Journals' then add its item Declined Free Journal          
                if(salesOrderLineItem.OrderApi__Item_Class__r.Name == 'ZDecline of the Journals'){
                    System.debug('itemDTO==>'+itemDTO);
                    itemClassToItemsMap = addItemDTOToMap(itemClassToItemsMap, 'Previous_Declined_Journal', itemDTO);
                }
            }                                           
        }   
        if(!itemClassToItemsMap.isEmpty()){
            return itemClassToItemsMap;
        }
        return itemClassToItemsMap;
    }
    
    /**
     *@Purpose : Getting all sales order with its line items
     *@Param   : contactId, classNamesSet
     *@Return  : List of sales order
     */
    static List<OrderApi__Sales_Order_Line__c> getSalesOrderLineItems(Id contactId, Set<String> classNamesSet, 
                                                                             Id salesOrderId, Boolean isRenewal){
        List<OrderApi__Sales_Order_Line__c> allSalesOrderLIList = new List<OrderApi__Sales_Order_Line__c>();
        List<OrderApi__Sales_Order_Line__c> specificSalesOrderLIList = new List<OrderApi__Sales_Order_Line__c>();
        List<OrderApi__Item__c> itemList = new List<OrderApi__Item__c>();
        OrderApi__Sales_Order__c specificSalesOrder;
        
        // Getting specific sales order Line items list
        specificSalesOrderLIList = getSpecificSalesOrderLIs(salesOrderId, classNamesSet);
        
        if(! specificSalesOrderLIList.isEmpty()){
            for(OrderApi__Sales_Order_Line__c salesOrderLineItem : specificSalesOrderLIList){
                itemList.add(salesOrderLineItem.OrderApi__Item__r);
            }
        }
        // If Itemlist is not empty then process that items only else Process all sales order line items
        if(! itemList.isEmpty()){
            return specificSalesOrderLIList;
        }
        else{
            if(isRenewal){
               allSalesOrderLIList =  getAllSalesOrderLIs(contactId, classNamesSet);
            }
            if(! allSalesOrderLIList.isempty()){
                return allSalesOrderLIList;
            }
        }
        return allSalesOrderLIList;
    }
    
     /**
     *@Purpose : Getting Specific sales order line items
     *@Param   : contactId, classNamesSet
     *@Return  : List of sales order
     */
    static List<OrderApi__Sales_Order_Line__c> getSpecificSalesOrderLIs(Id salesOrderId, Set<String> classNamesSet){
        List<OrderApi__Sales_Order_Line__c> specificSalesOrderLIList = new List<OrderApi__Sales_Order_Line__c>();
        OrderApi__Sales_Order__c specificSalesOrder = new OrderApi__Sales_Order__c();
        
        try{
            specificSalesOrder = [SELECT Id, OrderApi__Contact__c, OrderApi__Status__c,
                                        (SELECT Id, Name, OrderApi__Item__c, OrderApi__Item_Class__r.Name, 
                                                OrderApi__Item__r.Fon_Association_Journal_Type__c, OrderApi__Sales_Order__c,
                                                OrderApi__Item__r.Name, OrderApi__Item__r.OrderApi__Price__c, OrderApi__Item__r.Hide_In_Join__c, 
                                         		OrderApi__Item__r.Default_Selected_In_Join__c 
                                         FROM OrderApi__Sales_Order_Lines__r
                                         WHERE OrderApi__Item_Class__r.Name IN : classNamesSet
                                               Order by createdDate, Name DESC)
                                  FROM OrderApi__Sales_Order__c
                                  WHERE Id =: salesOrderId];
        }catch(Exception exp){
            System.debug('Exception Occured :::'+ exp.getMessage() + '\t' + exp.getStackTraceString());
        }
        
        if(specificSalesOrder !=  NULL){
            specificSalesOrderLIList = specificSalesOrder.OrderApi__Sales_Order_Lines__r;
        }
        
        if(! specificSalesOrderLIList.isEmpty()){
            return specificSalesOrderLIList;
        }
        return specificSalesOrderLIList;
    }
    
    /**
     *@Purpose : Getting all sales order with its line items
     *@Param   : contactId, classNamesSet
     *@Return  : List of sales order
     */
    static List<OrderApi__Sales_Order_Line__c> getAllSalesOrderLIs(Id contactId, Set<String> classNamesSet){
        List<OrderApi__Sales_Order__c> salesOrderList = new List<OrderApi__Sales_Order__c>();
        List<OrderApi__Sales_Order_Line__c> allSalesOrderLIList = new List<OrderApi__Sales_Order_Line__c>();
        try{
             salesOrderList = ([SELECT Id, OrderApi__Contact__c, OrderApi__Status__c,
                                      (SELECT Id, Name, OrderApi__Item__c, OrderApi__Item_Class__r.Name, 
                                            OrderApi__Item__r.Fon_Association_Journal_Type__c, OrderApi__Sales_Order__c,
                                            OrderApi__Item__r.Name, OrderApi__Item__r.OrderApi__Price__c, OrderApi__Item__r.Hide_In_Join__c, 
                                         	OrderApi__Item__r.Default_Selected_In_Join__c 
                                       FROM OrderApi__Sales_Order_Lines__r
                                       WHERE OrderApi__Item_Class__r.Name IN : classNamesSet
                                             Order by createdDate, Name DESC)
                                FROM OrderApi__Sales_Order__c
                                WHERE OrderApi__Status__c =: 'Closed' AND
                                     OrderApi__Contact__c =: contactId]);
        }catch(Exception exp){
            System.debug('Exception Occured :::'+ exp.getMessage() + '\t' + exp.getStackTraceString());
        }
        
        if(! salesOrderList.isEmpty()){
            for(OrderApi__Sales_Order__c salesOrder : salesOrderList){
                allSalesOrderLIList.addAll(salesOrder.OrderApi__Sales_Order_Lines__r);
            }
        }
        
        if(! allSalesOrderLIList.isEmpty()){
            return allSalesOrderLIList;
        }
        return allSalesOrderLIList;
    }
    
    /**
     *@Purpose : Create ItemDTO record
     *@Param   : item
     *@Return  : ItemDTO record
     */
    static DW_ECRMDTO.ItemDTO createItemDTORecord(OrderApi__Item__c item, Id salesOrderId, Id salesOrderLineItemId){
        
        DW_ECRMDTO.ItemDTO itemDTO = new DW_ECRMDTO.ItemDTO();
        
        if(item != NULL){
            itemDTO.Id = item.Id;
            itemDTO.name = item.Name;
            itemDTO.type = item.Fon_Association_Journal_Type__c;
            
            // if price is null                                    
            if(item.OrderApi__Price__c == NULL){
                itemDTO.price = 0;                                     
            }else{
                itemDTO.price = item.OrderApi__Price__c;
            } 
            itemDTO.hideInJoin = item.Hide_In_Join__c;
            itemDTO.defaultSelectedInJoin = item.Default_Selected_In_Join__c;
        }
        if(salesOrderId != NULL){
            itemDTO.parentId = salesOrderId;
        } 
        if(salesOrderLineItemId != NULL){
            itemDTO.salesOrderLineItemId = salesOrderLineItemId;
        }
        return itemDTO;
    }
    
    /**
     *@Purpose : Adding ItemDTO to its particuler map
     *@Param   : itemClassToItemsMap, itemClass, itemDTO 
     *@Return  : previous item Class name To ItemsMap
     */
    static Map<String,List<DW_ECRMDTO.ItemDTO>> addItemDTOToMap(Map<String,List<DW_ECRMDTO.ItemDTO>> itemClassToItemsMap,
                                                                String itemClass, DW_ECRMDTO.ItemDTO itemDTO){
        
        if(itemClassToItemsMap.containsKey(itemClass)){
            itemClassToItemsMap.get(itemClass).add(itemDTO);
        }
        return itemClassToItemsMap;
    }
    
    /**
     *@Purpose : Getting all step URLs
     *@Param   : currentStepId
     *@Return  : step URL name to URL value map
     */
    static Map<String, String> getStepURLs(String currentStepId, String type){
        String nextStepId = '';
        String stepId = '';
        String nextStepURLValue = '';
        String previousstepURLValue = '';
        String cancelStepURLValue = '';
        String stepName = '';
        joinapi__Step__c workingGroupsStep;
        Map<String,String> stepURLNameToURLMap = new Map<String,String>();
        
        // Getting step name from DW_Working_Group_Step_Config__c custom setting
        DW_Working_Group_Step_Config__c workingGroupStepConfig = DW_Working_Group_Step_Config__c.getOrgDefaults();
        if(workingGroupStepConfig != NULL){
            stepName = workingGroupStepConfig.Step_Name__c;
            System.debug('stepName==>'+stepName);
        }
        
        if(String.isNotBlank(stepName)){
            try{
                workingGroupsStep = [SELECT Id, joinapi__Next_Step__c FROM joinapi__Step__c WHERE Name =: stepName];
            }catch(Exception exp){
                System.debug('Exception Occured :::'+ exp.getMessage() + '\t' + exp.getStackTraceString());
            }
        }
        // if attribute type is modify in URL then take payment card step Id for nextStep Id
        if(type == 'modify'){
            stepId = workingGroupsStep.Id;
            //nextStepId  = getStepId(workingGroupsStep.joinapi__Next_Step__c);
              nextStepId = workingGroupsStep.joinapi__Next_Step__c;      
        }
        else{
           stepId = currentStepId;
        }
        System.debug('stepId==>'+stepId);
        // Putting Curent step Id in stepURLNameToURLMap
        stepURLNameToURLMap.put('Step_Id', workingGroupsStep.Id);
        
        if(String.isNotBlank(nextStepId)){
            // getting all steps URLs
            nextStepURLValue = getNextStepURL(nextStepId);
        }else{
             // getting all steps URLs
            nextStepURLValue = getNextStepURL(stepId);
        }    
        
        previousstepURLValue = getPreviousStepURL(stepId);
        cancelStepURLValue = getCancelStepURL(stepId);
        
        if(String.isNotBlank(nextStepURLValue)){
            stepURLNameToURLMap.put('Next_Step_URL', nextStepURLValue);
        }
        if(String.isNotBlank(previousstepURLValue)){
            stepURLNameToURLMap.put('Previous_Step_URL', previousstepURLValue);
        }
        if(String.isNotBlank(cancelStepURLValue)){
            stepURLNameToURLMap.put('Cancel_Step_URL', cancelStepURLValue);
        }
        return stepURLNameToURLMap;
    }
     
    /**
     *@Purpose : Getting next step URL
     *@Param   : currentStepId
     *@Return  : next step URL
     */
    static String getNextStepURL(String currentStepId) {
        return new joinApi.JoinUtils(currentStepId).navStepsMap.get('Next');
    }
    
    /**
     *@Purpose : Getting previous step URL
     *@Param   : currentStepId
     *@Return  : previous step URL
     */
    static String getPreviousStepURL(String currentStepId) {
      return new joinApi.JoinUtils(currentStepId).navStepsMap.get('Previous');
    }
    
    /**
     *@Purpose : Getting Cancel step URL
     *@Param   : currentStepId
     *@Return  : Cancel step URL
     */
    static String getCancelStepURL(String currentStepId) {
        return new joinApi.JoinUtils(currentStepId).navStepsMap.get('First');
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
                                  Journal_Zip_Postal_Code__c, Journal_Country__c
                           FROM Contact 
                           WHERE Id =: contactId];
            }catch(Exception exp){
                System.debug('Exception Occured :::'+ exp.getMessage() + '\t' + exp.getStackTraceString());
            }
        }
        return contact;
    }
        
    /**
     *@Purpose : Update contact's journal address
     *@Param   : contact record, isJournalAddrSameAsPreferedAddr boolean value
     *@Return  : -
     */
    static void updateContactsJournalAddr(Contact contact, Boolean isJournalAddrSameAsPreferedAddr){
        
        //update Contact journal address field;
        contact.Is_Journal_Addr_Same_As_Preferred_Addr__c =  isJournalAddrSameAsPreferedAddr;
                                                     
        // if journal address is same as Preferred address
        if(isJournalAddrSameAsPreferedAddr){
            // if Preferred Address id 'Business' then populate journal address with contact's mailing address
            if(contact.Preferred_Address__c == 'Business'){
                contact = populateJournalAddr(contact, contact.MailingStreet, contact.MailingCity, contact.MailingState,
                                                     contact.MailingCountry, contact.MailingPostalCode);
            }
            // if Preferred Address id 'Home' then populate journal address with contact's mailing address
            if(contact.Preferred_Address__c == 'Home'){
               contact = populateJournalAddr(contact, contact.OtherStreet, contact.OtherCity, contact.OtherState,
                                             contact.OtherCountry, contact.OtherPostalCode);
            }
            
        }
        // update contact
        try{
            update contact;
        }catch(Exception exp){
            System.debug('Exception Occured :::'+ exp.getMessage() + '\t' + exp.getStackTraceString());
        }
    }
    
    /**
     *@Purpose : Pupulate contact's Journal Address
     *@Param   : contact,street,city,state,country,zip
     *@Return  : updated contact
     */
    static Contact populateJournalAddr(Contact contact, String street,String city,String state,String country,String zip){ 
        contact.Journal_Street__c = street;
        contact.Journal_City__c = city;
        contact.Journal_State_Province__c = state;
        contact.Journal_Country__c = country;
        contact.Journal_Zip_Postal_Code__c = zip;
        return Contact;
    }  
    
    /**
     *@Purpose : get Previous declined journal
     *@Param   : salesOrderId, classNamesSet
     *@Return  : sales order LI
     */
    static OrderApi__Sales_Order_Line__c getDeclinedSalesOrderLI(Id salesOrderId, Set<String> classNamesSet){
        
        OrderApi__Sales_Order_Line__c declineSalesOrderLI;
        String className = getClassName('ZDecline of the Journals');
        try{
            declineSalesOrderLI = [SELECT Id, OrderApi__Item__c, OrderApi__Item_Class__r.Name, 
                                          OrderApi__Sales_Order__c,
                                          OrderApi__Item__r.Name
                                   FROM OrderApi__Sales_Order_Line__c 
                                   WHERE OrderApi__Sales_Order__c =: salesOrderId AND
                                         OrderApi__Item__r.Name =: Label.DW_Declined_Free_Journal AND
                                         OrderApi__Item_Class__r.Name IN : classNamesSet];
        }catch(Exception exp){
            System.debug('Exception Occured while getting Sales Order LI :::'+ exp.getMessage() +
                         '\t' + exp.getStackTraceString());
        }
        return declineSalesOrderLI; 
    }
    
    /**
     *@Purpose : get declined journal item
     *@Param   : classNamesSet
     *@Return  : Declined journal item
     */
    static OrderApi__Item__c getDeclinedJournalItem(Set<String> classNamesSet){
        OrderApi__Item__c declinedJournalItem;
        try{
            declinedJournalItem = [SELECT Id, Name, OrderApi__Price__c, Fon_Association_Journal_Type__c, OrderApi__Item_Class__r.Name,
                                   Hide_In_Join__c, Default_Selected_In_Join__c 
                                   FROM OrderApi__Item__c
                                   WHERE OrderApi__Item_Class__r.Name IN : classNamesSet AND 
                                         Name =: Label.DW_Declined_Free_Journal];  
        }catch(Exception exp){
            System.debug('Exception Occured while getting Declined journal Item :::'+ exp.getMessage() +
                         '\t' + exp.getStackTraceString());
        }
        return declinedJournalItem; 
    }
}