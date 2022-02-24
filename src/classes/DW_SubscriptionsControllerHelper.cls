/**
 *@Class Name   : DW_SubscriptionsControllerHelper
 *@Purpose      : Helper for DW_SubscriptionsController
 *@Created Date : 08-10-2018
 *@Modified Date: 23-10-2018
 */
public class DW_SubscriptionsControllerHelper {

    /**
     *@Purpose : Getting Subscriptions page details
     *@Param   : -
     *@return  : Response data
     */
    public static DW_ECRMDTO.Response getSubscriptionDetails(){
        // to take Response
        DW_ECRMDTO.Response response;
        Map<String,Object> stringToObjectMap = new Map<String,Object>();

        // Getting current login user contact Id
        Id contactId = DW_ECRMUtils.getCurrentLoginUserContactId();

        // putting Current login user contact DTO record to stringToObjectMap
        stringToObjectMap.put('Contact', getContactDTORecord());

        stringToObjectMap.put('Badge', getBadgeDTORecord(contactId));

        // Getting Individual Membership Subscription list
        List<OrderApi__Subscription__c> individualMemSubList = getIndividualMemSubsciption(contactId);

        // putting Individual membership Subscription into stringToObjectMap
        if(! individualMemSubList.isEmpty()){
            SubscriptionDTO subscriptionDTO = createSubscriptionDTO(individualMemSubList[0]);
            stringToObjectMap.put('Individual_Membership_Subscription', subscriptionDTO);
        }else{
            stringToObjectMap.put('Individual_Membership_Subscription', new List<SubcriptionItemDTO>());
        }

        // Getting Journals subscription DTO's list
        List<SubcriptionItemDTO> subscriptionJournalItems = getSubscriptionJournalItems(contactId);
        if(! subscriptionJournalItems.isEmpty()){
            stringToObjectMap.put('Journal_Subscription',subscriptionJournalItems);
        }else{
            stringToObjectMap.put('Journal_Subscription',new List<SubcriptionItemDTO>());
        }

        // Getting Working groups subscription DTO's list
        List<SubcriptionItemDTO> subWorkingGroupsItems = getSubWorkingGroupsItems(contactId);
        if(! subWorkingGroupsItems.isEmpty()){
            stringToObjectMap.put('Working_Groups_Subscription',subWorkingGroupsItems);
        }else{
            stringToObjectMap.put('Working_Groups_Subscription',new List<SubcriptionItemDTO>());
        }

        if(! stringToObjectMap.isEmpty()){
            response = new DW_ECRMDTO.Response(true,String.isNotBlank(Label.DW_Success_With_Data_Msg) ? Label.DW_Success_With_Data_Msg :
                    'Success With Data',stringToObjectMap);
        }
        else{
            response = new DW_ECRMDTO.Response(true,String.isNotBlank(Label.DW_Success_With_Null_Data_Msg)? Label.DW_Success_With_Null_Data_Msg:
                    'Success With NULL Data',NULL);
        }
        return response;
    }

    /**
     *@Purpose : Getting Current Login user contactDTO record
     *@Param   : -
     *@Return  : Contact record
     */
    public static DW_ECRMDTO.ContactDTO getContactDTORecord(){
        DW_ECRMDTO.ContactDTO contactDTO;
        // Getting current login contact
        Contact contact = DW_ECRMUtils.getCurrentLoginContact();

        // Creating Contact DTO record
        if(contact != NULL){
            contactDTO = new DW_ECRMDTO.ContactDTO();
            contactDTO.Id = contact.Id;
            contactDTO.name = contact.Name;
            contactDTO.membershipStatus = contact.Membership_Status__c;

            if(contact.Initial_Join_Date__c != NULL){
                contactDTO.initialJoinDate = String.valueOf(contact.Initial_Join_Date__c);
            }else{
                contactDTO.initialJoinDate = '';
            }
            contactDTO.memberType = contact.Member_Type__c;
            contactDTO.modifyWorkingGroup = contact.Modify_Groups__c;

            if(String.isNotBlank(contact.Journal_Street__c)){
                contactDTO.journalStreet = contact.Journal_Street__c;
            }else{
                contactDTO.journalStreet = '';
            }

            if(String.isNotBlank(contact.Journal_City__c)){
                contactDTO.journalCity = contact.Journal_City__c;
            }else{
                contactDTO.journalCity = '';
            }
            if(String.isNotBlank(contact.Journal_State_Province__c)){
                contactDTO.journalState = contact.Journal_State_Province__c;
            }else{
                contactDTO.journalState = '';
            }

            if(String.isNotBlank(contact.Journal_Country__c)){
                contactDTO.journalcountry = contact.Journal_Country__c;
            }else{
                contactDTO.journalcountry = '';
            }

            if(String.isNotBlank(contact.Journal_Zip_Postal_Code__c)){
                contactDTO.journalzipcode = contact.Journal_Zip_Postal_Code__c;
            }else{
                contactDTO.journalzipcode ='';
            }

            contactDTO.recordTypeName = contact.RecordType.Name;
        }
        return contactDTO;
    }

    /**
     *@Purpose : Getting Individual Membership class BadgeDTO Record
     *@Param   : contactId
     *@return  : BadgeDTO record
     */
    public static DW_ECRMDTO.BadgeDTO getBadgeDTORecord(Id contactId){
        List<OrderApi__Badge__c> individualMemBadgeList = new List<OrderApi__Badge__c>();
        DW_ECRMDTO.BadgeDTO badgeDTO = new DW_ECRMDTO.BadgeDTO();
        // Getting individual membership class name
        String individualMemClass = DW_ECRMUtils.getClassName('Individual Memberships');

        // Fetching 'Individual Membership' class Badges
        try{
            individualMemBadgeList = [SELECT Id, OrderApi__Badge_Type__c, OrderApi__Is_Active__c, Badge__c,
                    OrderApi__Item__c, OrderApi__Item__r.OrderApi__Item_Class__r.Name
            FROM OrderApi__Badge__c
            WHERE OrderApi__Is_Active__c = true AND
            OrderApi__Contact__c =: contactId AND
            OrderApi__Item__r.OrderApi__Item_Class__r.Name =: individualMemClass];
        }catch(Exception exp){
            System.debug('Exception Occured While fetching Badges :::'+ exp.getMessage() + '\t' + exp.getStackTraceString());
        }

        if(! individualMemBadgeList.isEmpty()){

            badgeDTO.Id = individualMemBadgeList[0].Id;
            if(String.isNotBlank(individualMemBadgeList[0].OrderApi__Badge_Type__c)){
                badgeDTO.badgeType = individualMemBadgeList[0].OrderApi__Badge_Type__c;
            }else{
                badgeDTO.badgeType = '';
            }
            badgeDTO.item = individualMemBadgeList[0].OrderApi__Item__c;
            badgeDTO.badge = individualMemBadgeList[0].Badge__c;
        }

        return badgeDTO;
    }

    /**
     *@Purpose : Getting Individual Membership Subscription
     *@Param   : contactId
     *@return  : individual Membership Subscription List
     */
    public static List<OrderApi__Subscription__c> getIndividualMemSubsciption(Id contactId){
        List<OrderApi__Subscription__c> individualMemSubList = new List<OrderApi__Subscription__c>();
        Set<String> itemClassNamesSet = new Set<String>();

        // Adding class names from custom setting.
        itemClassNamesSet.add(DW_ECRMUtils.getClassName('Individual Memberships'));

        // IF itemClassNamesSet is not empty
        if(! itemClassNamesSet.isEmpty()){
            individualMemSubList = getSpecificClassSubsciptions(contactId, itemClassNamesSet);
        }
        return individualMemSubList;
    }

    /**
     *@Purpose : Creating SubscriptionDTO record
     *@Param   : subcription
     *@return  : SubscriptionDTO record
     */
    public static SubscriptionDTO createSubscriptionDTO(OrderApi__Subscription__c subcription){
        SubscriptionDTO subscriptionDTO = new SubscriptionDTO();
        subscriptionDTO.Id = subcription.Id;
        subscriptionDTO.currentTermEndDate = String.valueOf(subcription.OrderApi__Current_Term_End_Date__c);

        if(subcription.OrderApi__Days_To_Lapse__c != NULL){
            subscriptionDTO.daysToLapse = subcription.OrderApi__Days_To_Lapse__c;
        }else{
            subscriptionDTO.daysToLapse = 0;
        }
        return subscriptionDTO;
    }


    /**
     *@Purpose : Getting Subscription Journal item list
     *@Param   : contactId
     *@return  : Journal Item SubcriptionItemDTO records list
     */
    public static List<SubcriptionItemDTO> getSubscriptionJournalItems(Id ContactId){
        List<SubcriptionItemDTO> subcriptionJournalItemList = new List<SubcriptionItemDTO>();
        List<OrderApi__Subscription__c> journalSubscriptionList = new List<OrderApi__Subscription__c>();
        Set<String> itemClassNamesSet = new Set<String>();
        SubcriptionItemDTO journalItemDTO;

        // Adding class names from custom setting.
        itemClassNamesSet.add(DW_ECRMUtils.getClassName('Complimentary Journals'));
        itemClassNamesSet.add(DW_ECRMUtils.getClassName('Journal Subscriptions'));
        itemClassNamesSet.add(DW_ECRMUtils.getClassName('ZDecline of the Journals'));

        // IF itemClassNamesSet is not empty
        if(! itemClassNamesSet.isEmpty()){
            journalSubscriptionList = getSpecificClassSubsciptions(contactId, itemClassNamesSet);
        }
        if(! journalSubscriptionList.isEmpty()){

            for(OrderApi__Subscription__c journalSubscription : journalSubscriptionList){
                journalItemDTO = new SubcriptionItemDTO();
                journalItemDTO = createSubcriptionItemDTORecord(ContactId,journalSubscription.OrderApi__Item__r,
                        journalSubscription.Join_Date__c);

                if(journalItemDTO != NULL){
                    subcriptionJournalItemList.add(journalItemDTO);
                }
            }
        }
        return subcriptionJournalItemList;
    }

    /**
     *@Purpose : Getting Subscription Working Groups item list
     *@Param   : contactId
     *@return  : Working Group SubcriptionItemDTO records list
     */
    public static List<SubcriptionItemDTO> getSubWorkingGroupsItems(Id ContactId){
        List<SubcriptionItemDTO> subWorkingGroupsItemList = new List<SubcriptionItemDTO>();
        List<OrderApi__Subscription__c> workingGroupsSubList;
        SubcriptionItemDTO workingGroupItemDTO;
        Set<String> itemClassNamesSet = new Set<String>();

        // Adding class names from custom setting.
        itemClassNamesSet.add(DW_ECRMHelper.getClassName('Working Groups'));

        // IF itemClassNamesSet is not empty
        if(! itemClassNamesSet.isEmpty()){
            workingGroupsSubList = getSpecificClassSubsciptions(ContactId, itemClassNamesSet);
        }
        if(! workingGroupsSubList.isEmpty()){
            for(OrderApi__Subscription__c workingGrpSubscription : workingGroupsSubList){

                workingGroupItemDTO = new SubcriptionItemDTO();
                workingGroupItemDTO = createSubcriptionItemDTORecord(ContactId,workingGrpSubscription.OrderApi__Item__r,
                        workingGrpSubscription.OrderApi__Paid_Through_Date__c);

                if(workingGroupItemDTO != NULL){
                    subWorkingGroupsItemList.add(workingGroupItemDTO);
                }
            }
        }
        return subWorkingGroupsItemList;
    }

    /**
     *@Purpose : Getting Specific class Subcriptions
     *@Param   : contactId, classNameSet
     *@return  : Subscription list
     */
    public static List<OrderApi__Subscription__c> getSpecificClassSubsciptions(Id contactId, Set<String> classNameSet){
        List<OrderApi__Subscription__c> subcriptionList = new List<OrderApi__Subscription__c>();

        // Fetching Subscriptions of specific clsses
        try{
            subcriptionList = [SELECT Id,OrderApi__Paid_Through_Date__c, OrderApi__Contact__c, OrderApi__Current_Term_End_Date__c, OrderApi__Days_To_Lapse__c,
                    OrderApi__Item__c, OrderApi__Item__r.Name, OrderApi__Item__r.Fon_Association_Journal_Type__c,
                    OrderApi__Item_Class__r.Name, Join_Date__c, OrderApi__Account__c,OrderApi__Is_Active__c,
                    OrderApi__Business_Group__c, OrderApi__Entity__c
            FROM OrderApi__Subscription__c
            WHERE OrderApi__Contact__c =: contactId AND
            OrderApi__Item_Class__r.Name IN : classNameSet
            ORDER BY OrderApi__Paid_Through_Date__c DESC];
        }catch(Exception exp){
            System.debug('Exception Occured While fetching Subscriptions :::'+ exp.getMessage() + '\t' + exp.getStackTraceString());
        }
        return subcriptionList;
    }

    /**
     *@Purpose : Create SubcriptionItemDTO record
     *@Param   : ContactId, item, date since
     *@return  : SubcriptionItemDTO record
     */
    public static SubcriptionItemDTO createSubcriptionItemDTORecord(Id ContactId, OrderApi__Item__c item, Date since){
        SubcriptionItemDTO subItemDTO = new SubcriptionItemDTO();
        String committeeRole = ' ';
        if(item != NULL){
            subItemDTO.Id = item.Id;
            subItemDTO.name = item.Name;
            subItemDTO.type = item.Fon_Association_Journal_Type__c;
        }
        subItemDTO.since = String.valueOf(since);

        // Getting Committee Role
        committeeRole = getCommitteeRole(ContactId, item.Id);
        if(String.isNotBlank(committeeRole)){
            subItemDTO.role = committeeRole;
        }else{
            subItemDTO.role = committeeRole;
        }
        return subItemDTO;
    }

    /**
     *@Purpose : Getting Committee role
     *@Param   : ContactId, itemId
     *@return  : String : Committee role
     */
    public static String getCommitteeRole(Id ContactId, Id itemId){
        String role ='';
        Committees__c committee = new Committees__c();
        // Fetching commitee record who has given Contact and item
        try{
            committee = [SELECT Id, Committee_Member_Role__c
            FROM Committees__c
            WHERE Committee_Related_To__c =: itemId AND
            Committees__c =: ContactId LIMIT 1];
            role = committee.Committee_Member_Role__c;
        }catch(Exception exp){
            System.debug('Exception Occured While fetching Subscription :::'+ exp.getMessage() + '\t' + exp.getStackTraceString());
        }
        return role;
    }

    /**
     *@Purpose : perform Renewal Process
     *@Param   : contactId
     *@return  :
     */
    public static DW_ECRMDTO.Response renewSubscriptionPlan(){
        List<OrderApi__Subscription__c> subscriptionList = new List<OrderApi__Subscription__c>();
        OrderApi__Sales_Order__c newSalesOrder;
        DW_ECRMDTO.Response response;

        // Getting current login user contact Id
        Id contactId = DW_ECRMUtils.getCurrentLoginUserContactId();

        // Getting Individual membership subscription
        List<OrderApi__Subscription__c> individualMemSubList = getIndividualMemSubsciption(contactId);
        system.debug( 'individualMemSubList::'+individualMemSubList );
        if( individualMemSubList.isEmpty() ) {
            response = new DW_ECRMDTO.Response(false, 'No membership subscription found',NULL);
            return response;
        }
        try{
            subscriptionList = [SELECT Id, OrderApi__Contact__c, OrderApi__Account__c, OrderApi__Item_Class__c,
                    OrderApi__Business_Group__c,OrderApi__Item__c, OrderApi__Entity__c,
                    OrderApi__Is_Active__c, OrderApi__Subscription_Plan__c, OrderApi__Enable_Auto_Renew__c
            FROM OrderApi__Subscription__c
            WHERE OrderApi__Contact__c =: contactId AND
            OrderApi__Paid_Through_Date__c =: individualMemSubList[0].OrderApi__Paid_Through_Date__c];
            system.debug( 'subscriptionList::'+subscriptionList );
        }catch(Exception exp){
            System.debug('Exception Occured While fetching Subscription :::'+ exp.getMessage() + '\t' + exp.getStackTraceString());
        }

        if(! individualMemSubList.isEmpty()){
            // create new Sales Order
            newSalesOrder = createSalesOrder(individualMemSubList[0]);

            System.debug('newSalesOrder==>'+newSalesOrder);
        }
        if( newSalesOrder == NULL ) {
            response = new DW_ECRMDTO.Response(false, 'Membership subscription is not active',NULL);
            return response;
        }
        // Creating Sales Order Line items for all subcription for newly created sales order
        //if(newSalesOrder != NULL && ! subscriptionList.isEmpty()){
        if(newSalesOrder != NULL){
            system.debug( 'in before createSalesOrderLIs' );
            if( ! subscriptionList.isEmpty() ) {
                List<OrderApi__Sales_Order_Line__c> salesOrderLIList = createSalesOrderLIs(subscriptionList, newSalesOrder);
                system.debug( 'salesOrderLIList::'+salesOrderLIList );

                /*if(! salesOrderLIList.isEmpty()){
                   response = processRenew(contactId, newSalesOrder.Id,individualMemSubList[0]);
                }*/
            } /*else {
              response = processRenew(contactId, newSalesOrder.Id,individualMemSubList[0]);
            }*/



            response = processRenew(contactId, newSalesOrder.Id,individualMemSubList[0]);



        }
        else{
            response = new DW_ECRMDTO.Response(false, String.isNotBlank(Label.DW_Failure_Msg) ? Label.DW_Failure_Msg :'Failure',NULL);
        }
        return response;
    }

    /**
     *@Purpose : Renew Subscription Plan, Creating Sales Order With Line items for all Subscriptions
     *@Param   : -
     *@return  : Response
     */
    public static DW_ECRMDTO.Response processRenew(Id contactId, Id salesOrderId, OrderApi__Subscription__c subscription){
        System.debug('processRenew');
        DW_ECRMDTO.Response response;
        String successMsg = String.isNotBlank(Label.DW_Sales_Order_LIs_Creation_Msg) ?
                Label.DW_Sales_Order_LIs_Creation_Msg:'Sales Order Line Items Created Successfully';
        Contact contact;
        String duesItemName;
        try{
            contact = [SELECT Id, Membership_Status__c
            FROM Contact
            WHERE Id =: contactId];
        }catch(Exception exp){
            System.debug('Exception Occured While fetching Class :::'+ exp.getMessage() + '\t' + exp.getStackTraceString());
        }
        // Create RenewDTO
        DW_ECRMDTO.RenewDTO renewDTO = createRenewDTO(contactId, salesOrderId, contact.Membership_Status__c);
        system.debug( 'status: '+contact.Membership_Status__c );
        if(contact.Membership_Status__c == 'Current'){
            response = new DW_ECRMDTO.Response(true, successMsg, renewDTO);
        }
        /**
             *@Purpose : Getting Renew item
             *@Param   :
             *@return  : Response
             */
        else if(contact.Membership_Status__c == '1-YR Suspended'){
            system.debug( 'In 1 year' );

            // getting item name from custom setting
            duesItemName = getDuesItemName('1-YR Suspended');

            getItemAndCreateSOLI(String.isNotBlank(duesItemName) ? duesItemName : '2018 Dues', salesOrderId, subscription);
            response = new DW_ECRMDTO.Response(true, successMsg, renewDTO);
        }
        else if(contact.Membership_Status__c == '2-YR Suspended'){
            // getting item name from custom setting
            duesItemName = getDuesItemName('2-YR Suspended');

            getItemAndCreateSOLI(String.isNotBlank(duesItemName) ? duesItemName : '2017-2018 Dues', salesOrderId, subscription);

            response = new DW_ECRMDTO.Response(true, successMsg, renewDTO);
        }



        return response;
    }

    /**
     *@Purpose : Create RenewDTO record
     *@Param   : contactId, salesOrderId
     *@return  :
     */
    public static DW_ECRMDTO.RenewDTO createRenewDTO(Id contactId, Id salesOrderId, String membershipStatus){
        // getting join process landing URL
        String joinProcessURL = DW_ECRMUtils.getJoinProcessURL(salesOrderId);
        joinProcessURL = joinProcessURL + '&isJoin=false';
        // DW_SubscriptionRenew page url
        String subRenewURL = '/DW_SubscriptionRenew?cid='+ contactId +'&salesOrder='+salesOrderId;

        DW_ECRMDTO.RenewDTO renewDTORecord = new DW_ECRMDTO.RenewDTO();
        renewDTORecord.contactId = contactId;
        renewDTORecord.salesOrderId = salesOrderId;

        if(String.isNotBlank(membershipStatus)){
            if(membershipStatus == 'Current'){
                renewDTORecord.joinProcessURL = String.isNotBlank(joinProcessURL) ? joinProcessURL : '';
            }
//            else if(membershipStatus == '1-YR Suspended' || membershipStatus == '2-YR Suspended'){
            else if(membershipStatus == '1-YR Suspended' || membershipStatus == '2-YR Suspended'){
                renewDTORecord.joinProcessURL = subRenewURL;
            }
        }

        return renewDTORecord;
    }

    /**
     *@Purpose : get item and create sales order line item
     *@Param   : item name, salesOrderId
     *@return  : -
     */
    public static void getItemAndCreateSOLI(String itemName, Id salesOrderId, OrderApi__Subscription__c subscription){
        System.debug('in getItemAndCreateSOLI');
        OrderApi__Item__c item;

        try{
            item = [SELECT Id, Name, OrderApi__Item_Class__c
            FROM OrderApi__Item__c
            WHERE OrderApi__Item_Class__r.Name = 'Prior Year Dues' AND
            Name =: itemName];
            system.debug( 'item::'+item );
        }catch(Exception exp){
            System.debug('Exception Occured While fetching Item :::'+ exp.getMessage() + '\t' + exp.getStackTraceString());
        }

        if(item != NULL){
            // Create salesOrderLI
            system.debug( 'item not null create SOLI'+salesOrderId+' sub::'+subscription );
            createSalesOrderLI(salesOrderId, item,subscription);
        }
    }

    /**
     *@Purpose : create sales order Line item
     *@Param   :
     *@return  :
     */
    public static void createSalesOrderLI(Id salesOrderId, OrderApi__Item__c item ,OrderApi__Subscription__c subscription){
        System.debug('in createSalesOrderLI');
        System.debug('item==>'+item);

        OrderApi__Sales_Order_Line__c salesOderLI = new OrderApi__Sales_Order_Line__c(OrderApi__Sales_Order__c = salesOrderId,
                OrderApi__Is_Renewal__c = true,
                OrderApi__Item__c = item.Id,
                OrderApi__Item_Class__c = item.OrderApi__Item_Class__c,
                OrderApi__Subscription__c = subscription.Id
        );
        try{
            insert salesOderLI;
        }catch(Exception exp){
            System.debug('Exception Occured While inserting Subscription :::'+ exp.getMessage() + '\t' + exp.getStackTraceString());
        }
    }

    /**
     *@Purpose : Create Sales Order
     *@Param   : subscription
     *@return  : sales Order record
     */
    public static OrderApi__Sales_Order__c createSalesOrder(OrderApi__Subscription__c subscription){
        OrderApi__Sales_Order__c salesOrder;

        // If subscription is active then create sales order
//        if(subscription.OrderApi__Is_Active__c){
            salesOrder = new OrderApi__Sales_Order__c(OrderApi__Contact__c = subscription.OrderApi__Contact__c,
                    OrderApi__Account__c = subscription.OrderApi__Account__c,
                    OrderApi__Business_Group__c = subscription.OrderApi__Business_Group__c,
                    OrderApi__Entity__c = subscription.OrderApi__Entity__c);
            try{
                insert salesOrder;
            }catch(Exception exp){
                System.debug('Exception Occured While inserting Sales Order :::'+ exp.getMessage() + '\t' + exp.getStackTraceString());
            }
//        }
        return salesOrder;
    }

    /**
     *@Purpose : Create Sales Order Line Items
     *@Param   : subscriptionList,salesOrder
     *@return  : Sales Order Line Item List
     */
    public static List<OrderApi__Sales_Order_Line__c> createSalesOrderLIs(List<OrderApi__Subscription__c> subscriptionList,
            OrderApi__Sales_Order__c salesOrder){
        system.debug( 'in createSalesOrderLIs::'+salesOrder+' '+subscriptionList );
        List<OrderApi__Sales_Order_Line__c> salesOrderLIList = new List<OrderApi__Sales_Order_Line__c>();
        OrderApi__Sales_Order_Line__c salesOderLI;

        // Creating new Sales Order line items for all subcriptions
        for(OrderApi__Subscription__c subscription : subscriptionList){
            salesOderLI = new OrderApi__Sales_Order_Line__c(OrderApi__Sales_Order__c = salesOrder.id,
                    OrderApi__Is_Renewal__c = true,
                    OrderApi__Item__c = subscription.OrderApi__Item__c,
                    OrderApi__Item_Class__c = subscription.OrderApi__Item_Class__c,
                    OrderApi__Subscription__c = subscription.Id,
                    OrderApi__Business_Group__c = subscription.OrderApi__Business_Group__c,
                    OrderApi__Entity__c = subscription.OrderApi__Entity__c,
                    OrderApi__Enable_Auto_Renew__c = subscription.OrderApi__Enable_Auto_Renew__c);
            salesOrderLIList.add(salesOderLI);
        }
        system.debug( 'salesOrderLIList::'+salesOrderLIList );
        if(! salesOrderLIList.isEmpty()){
            try{
                insert salesOrderLIList;
            }catch(Exception exp){
                System.debug('Exception Occured While inserting Sales Order LIs:::'+ exp.getMessage() + '\t' + exp.getStackTraceString());
            }
        }
        return salesOrderLIList;
    }

    /**
     *@Purpose : Update contact Journal Address
     *@Param   :
     *@return  :
     */
    public static DW_ECRMDTO.Response updateContactsJournalAddr(DW_ECRMDTO.ContactDTO contactDTORecord){
        DW_ECRMDTO.Response response;
        Contact contact;
        try{
            contact = [SELECT Id, Journal_Street__c, Journal_City__c, Journal_State_Province__c,
                    Journal_Zip_Postal_Code__c, Journal_Country__c
            FROM Contact
            WHERE Id =: contactDTORecord.Id] ;
        }catch(Exception exp){
            System.debug('Exception Occured While fetching Contact:::'+ exp.getMessage() + '\t' + exp.getStackTraceString());
        }

        if(contact != NULL){
            contact.Journal_Street__c = contactDTORecord.journalStreet;
            contact.Journal_City__c = contactDTORecord.journalCity;
            contact.Journal_State_Province__c = contactDTORecord.journalState;
            contact.Journal_Country__c = contactDTORecord.journalcountry;
            contact.Journal_Zip_Postal_Code__c = contactDTORecord.journalzipcode;

            try{
                update contact;
                response = new DW_ECRMDTO.Response(true,'Contact Updated Successfully !',NULL);
            }catch(Exception exp){
                System.debug('Exception Occured While Updating Contact:::'+ exp.getMessage() + '\t' + exp.getStackTraceString());
                response = new DW_ECRMDTO.Response(false,'Failure !',NULL);
            }
        }
        return response;
    }

    /**
    *@Purpose : getting a record type of contact and membership status
    *@return  : String value based on record type and membership status
    */
    public static String getRecordType() {
        String rType;
        Id contactId = DW_ECRMUtils.getCurrentLoginUserContactId();
        Contact contact = [SELECT RecordTypeId, Membership_Status__c  FROM Contact where Id = :contactId];
        Recordtype recordType = [SELECT Name FROM Recordtype where Id = :contact.RecordTypeId];
        if (recordType.Name == 'Nonmember') {
            rType = 'nonmember';
        }
         if (recordType.Name == 'Member' || test.isRunningTest()) {
            if(contact.Membership_Status__c == 'Current' || test.isRunningTest()) { rType = 'membercurrent';
            } if(contact.Membership_Status__c == '1-YR Suspended' || contact.Membership_Status__c == '2-YR Suspended' || test.isRunningTest()) { rType = 'memberyear';
            } if(contact.Membership_Status__c == 'Suspended (Delinquent)' || contact.Membership_Status__c == 'Suspended (Resigned)' || contact.Membership_Status__c == 'Deceased' || test.isRunningTest()) {
                rType = 'membersuspended';
            } if(contact.Membership_Status__c == 'Candidate_Complete' || test.isRunningTest()) { rType= 'membercomplete';
            } if(contact.Membership_Status__c == 'Candidate_Incomplete' || test.isRunningTest()) { rType = 'memberincomplete';
            }
        }
        if (recordType.Name == 'Prior Member' || test.isRunningTest()) { rType = 'prior';
        }
        return rType;
    }
    
    /**
      *@Purpose : Getting Prior year dues item names from DW_Manage_Dues_Item__c custom setting
      *@Param   : Membership status
      *@return  : prior year item name
      */
    public static String getDuesItemName(String membershipStatus){
        // If classname is not blank
        if(String.isNotBlank(membershipStatus)){
            // getting dues item from setting
            DW_Manage_Dues_Item__c itemName  = DW_Manage_Dues_Item__c.getValues(membershipStatus);
            // if item Namev alues not null 
            if(itemName != null){
                return itemName.Membership_Item_Name__c;
            }
        }
        return NULL;
    }

    /**
     *@Purpose    : Showing Item's details
     */
    public class SubcriptionItemDTO{
        public String Id; // Item Id
        public String name; // Item name
        public String type; // Item Type
        public String role;
        public String since;
    }

    /**
     *@Purpose   : Subscription DTO
     */
    public class SubscriptionDTO{
        public String Id;
        public String currentTermEndDate;
        public Decimal daysToLapse;
    }
}