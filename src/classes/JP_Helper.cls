/**
 * Created by lauren.lezberg on 1/3/2019.
 */

public without sharing class JP_Helper {


    /**
     * @purpose Remove last accessed step record for a contact record and a particular join process
     *
     * @param joinId
     */
    public static void deleteContactLastAccessedStep(Id joinId){
        Id contactId = ECRMUtils.getCurrentLoginUserContactId();
        List<contact_last_accessed_step__c> lastStep = [SELECT Id FROM contact_last_accessed_step__c WHERE JoinId__c=: joinId AND Contact__c=: contactId LIMIT 1];
        delete lastStep;
    }

    /**
     * @purpose Retrieves last accessed step record for the current contact and a specified join process. If one doesn't exist, a new one is created for the specified join.
     *
     * @param joinId
     *
     * @return Order of last accessed step
     */
    public static Decimal getLastAccessedStepOrder(Id joinId){ 
        Id contactId = ECRMUtils.getCurrentLoginUserContactId();
        if(contactId!=null) {
            List<contact_last_accessed_step__c> lastStepList = [
                    SELECT Id, Contact__c, Join_Process__c, Step_Order__c
                    FROM contact_last_accessed_step__c
                    WHERE JoinId__c = :joinId AND
                    Contact__c = :contactId
            ];
            if (!lastStepList.isEmpty()) {
                return lastStepList[0].Step_Order__c;
            } else {
                contact_last_accessed_step__c contLastAccessedStep = new contact_last_accessed_step__c(
                        Contact__c = contactId,
                        JoinId__c = joinId,
                        Step_Order__c = 1
                );

                try {
                    insert contLastAccessedStep;
                    return contLastAccessedStep.Step_Order__c;
                } catch (Exception exp) {
                    System.debug('Exception Occurred while Inserting Last Step :::' + exp.getMessage() + '\t' + exp.getStackTraceString());
                }
            }
        }

        return null;
    }

    /**
     * @purpose Updates last accessed step for a particular join process when the user moves forward. If one doesn't exist, a new record is created
     *
     * @param stepId
     */
    public static void upsertLastAccessedStep(Id stepId){
        System.debug('upsert last accessed step with stepId: ' +  stepId);
        contact_last_accessed_step__c contLastAccessedStep;
        List<contact_last_accessed_step__c> lastStepList = new List<contact_last_accessed_step__c>();
        List<Process_Steps__mdt> currentStep = [SELECT Id, Step_Order__c, Step_Title__c, Description__c, Join_Step__r.Component_Name__c, Join_Step__r.MasterLabel, Process__r.Is_Renewal__c, Process__c FROM Process_Steps__mdt WHERE Id =: stepId LIMIT 1];

        Id contactId = ECRMUtils.getCurrentLoginUserContactId();
        if(contactId!=null) {
            try {
                lastStepList = [
                        SELECT Id, Contact__c, Join_Process__c, Step_Order__c
                        FROM contact_last_accessed_step__c
                        WHERE JoinId__c = :currentStep[0].Process__c AND
                        Contact__c = :contactId
                ];
            } catch (Exception exp) {
                System.debug('Exception Occurred :::' + exp.getMessage() + '\t' + exp.getStackTraceString());
            }

            if (lastStepList.isEmpty()) {
                contLastAccessedStep = new contact_last_accessed_step__c(
                        Contact__c = contactId,
                        JoinId__c = currentStep[0].Process__c,
                        Step_Order__c = 1.0
                );

                try {
                    insert contLastAccessedStep;
                } catch (Exception exp) {
                    System.debug('Exception Occurred while Inserting Last Step :::' + exp.getMessage() + '\t' + exp.getStackTraceString());
                }
            } else {

                // Update last step records step order with current sales order
                if (currentStep[0].Step_Order__c > lastStepList[0].Step_Order__c) {
                    lastStepList[0].Step_Order__c = currentStep[0].Step_Order__c;
                    // update last step
                    System.debug('updating last step with ' + lastStepList[0]);
                    try {
                        update lastStepList[0];
                    } catch (Exception exp) {
                        System.debug('Exception Occured :::' + exp.getMessage() + '\t' + exp.getStackTraceString());
                    }
                }
            }
        }
    }


    /**
     * @purpose Gets list of items and their associated data to display in portal based off item class names
     * @param classNames - list of item class names
     *
     * @return List of items
     */
    public static List<OrderApi__Item__c> getPortalItemsByClass(Set<String> classNames){

        return [SELECT Id, Name, OrderApi__Price__c, Fon_Association_Journal_Type__c, OrderApi__Item_Class__r.Name, OrderApi__Description__c, OrderApi__Line_Description__c, Journal_Location_URL__c,
                                                        Hide_In_Join__c, Default_Selected_In_Join__c, Portal_Label__c, OrderApi__Image_Path__c, OrderApi__Item_Class__c, Show_In_Portal__c
                                                        FROM OrderApi__Item__c
                                                        WHERE OrderApi__Item_Class__r.Name IN: classNames AND
                                                        OrderApi__Is_Active__c = true
                                                        Order by OrderApi__Item_Class__r.Name DESC, Portal_Label__c ];
    }



    /** DEPRECATED BECAUSE WORKING GROUPS NO LONGER HAVE PRICES
    * @purpose Gets mapping of select working groups and their price with the correct price rule
    * @param items - select items to make price map for
    * @param contactId - current contact record id
    *
    * @return Map of item and price with applied price rule value
    */

//    public static Map<Id, Decimal> getWorkingGroupPriceMap(List<OrderApi__Item__c> items, Id contactId, String salesOrderId){
//        System.debug('getting working group price map...');
//        Map<Id, Decimal> itemPriceMap = new Map<Id, Decimal>();
//
//        Set<String> badgeTypeNames = new Set<String>();
//        List<OrderApi__Sales_Order_Line__c> lines = [SELECT Id, OrderApi__Item__r.Name FROM OrderApi__Sales_Order_Line__c WHERE OrderApi__Sales_Order__c =: salesOrderId];
//        for(OrderApi__Sales_Order_Line__c sol : lines){
//            badgeTypeNames.add(sol.OrderApi__Item__r.Name);
//        }
//
//        List<OrderApi__Badge_Type__c> bTypes = [SELECT Id FROM OrderApi__Badge_Type__c WHERE Name IN: badgeTypeNames];
//
//        Set<String> badgeTypes = new Set<String>();
//        for(OrderApi__Badge_Type__c bt : bTypes){
//            badgeTypes.add(bt.Id);
//        }
//
//        Set<String> itemIds = new Set<String>();
//        for(OrderApi__Item__c i : items){
//            itemIds.add(i.Id);
//        }
//
//        List<OrderApi__Price_Rule__c> priceRules = [SELECT Id, OrderApi__Item__c, OrderApi__Item__r.Name, OrderApi__Price__c, OrderApi__Required_Badge_Types__c FROM OrderApi__Price_Rule__c WHERE OrderApi__Is_Active__c = true AND OrderApi__Item__c IN: itemIds];
//
//        for(OrderApi__Price_Rule__c pr : priceRules){
//            String badgeTypeList = pr.OrderApi__Required_Badge_Types__c;
//            if(badgeTypeList!=null) {
//                List<String> reqBTypes = badgeTypeList.split(',');
//                for(String type : reqBTypes){
//                    if(badgeTypes.contains(type)){
//                        if(pr.OrderApi__Price__c!=null) {
//                            itemPriceMap.put(pr.OrderApi__Item__c, pr.OrderApi__Price__c);
//                            System.debug('selected price rule: ' + pr);
//                        } else {
//                            itemPriceMap.put(pr.OrderApi__Item__c, 0.00);
//                        }
//
//                    }
//                }
//            } else {
//                itemPriceMap.put(pr.OrderApi__Item__c, 0.00);
//            }
//        }
//        return itemPriceMap;
//    }

    /**
     * @purpose Gets mapping of select items and their price with the correct price rule applied by creating a dummy sales order and sales order lines and then deleting.
     * If the user is from canada, the country is changed temporarily and then changed back.
     * @param items - select items to make price map for
     * @param currentContact - current contact record
     *
     * @return Map of item and price with applied price rule value
     */
    public static Map<Id, Decimal> getItemPriceMap(List<OrderApi__Item__c> items, Contact currentContact, Id membershipId, Id itemClassId, Id subscriptionPlanId, String salesOrderId){

        Boolean fromCanada = false;
        //Mailing country is changed for users with a canada address because fonteva price rules fire twice for canada tax which causes a soql query error. The country will be set back at the end.
        if(currentContact.MailingCountryCode == 'CA'){
            currentContact.MailingCountryCode = 'FR';
            fromCanada = true;
            update currentContact;
        }

        try {
            List<OrderApi__Sales_Order_Line__c> soLines = new List<OrderApi__Sales_Order_Line__c>();
            OrderApi__Sales_Order__c so = [SELECT OrderApi__Source_Code__c, OrderApi__Contact__c, OrderApi__Account__c, OrderApi__Entity__c FROM OrderApi__Sales_Order__c WHERE Id=:salesOrderId];
            //create new dummy sales order
            OrderApi__Sales_Order__c salesOrder = so.clone(false);
            //insert dummy sales order
            insert salesOrder;

            //insert sales order line with membership item
            if(membershipId!=null && itemClassId!=null) {
                insert new OrderApi__Sales_Order_Line__c(OrderApi__Item__c = membershipId, OrderApi__Sales_Order__c = salesOrder.Id, OrderApi__Item_Class__c = itemClassId);
            }

            //for all items, add sales order line so that price rule is applied
            for(OrderApi__Item__c item :items){
                OrderApi__Sales_Order_Line__c salesOrderLI = new OrderApi__Sales_Order_Line__c(
                        OrderApi__Sales_Order__c = salesOrder.id,
                        OrderApi__Item__c = item.Id,
                        OrderApi__Item_Class__c = item.OrderApi__Item_Class__c,
                        OrderApi__Entity__c = 'Contact',
                        OrderApi__Subscription_Plan__c = subscriptionPlanId,
                        OrderApi__Enable_Auto_Renew__c = false);
                soLines.add(salesOrderLI);
            }
            //insert dummy sales order lines
            insert soLines;

            //update soLines to get price rules --> They are not always correct on first insert
            update soLines;

            //create map of all items with applied price rules
            Map<Id, Decimal> itemPriceMap = new Map<Id, Decimal>();
            soLines = [SELECT OrderApi__Item__c, OrderApi__Sale_Price__c FROM OrderApi__Sales_Order_Line__c WHERE OrderApi__Sales_Order__c =: salesOrder.Id];
            for(OrderApi__Sales_Order_Line__c line : soLines){
                System.debug('line: ' + line);
                itemPriceMap.put(line.OrderApi__Item__c, line.OrderApi__Sale_Price__c);
            }
            System.debug('createdSalesOrder: ' + salesOrder);

            //delete dummy sales order
            delete salesOrder;

            //if user is from canada, set country back to canada
            if(fromCanada){
                currentContact.MailingCountryCode = 'CA';
                update currentContact;
            }

            return itemPriceMap;
        } catch(Exception e){
            System.debug('Error getting price map: ' + e.getMessage());
            return null;
        }
    }

    /**
     * @purpose Compares item selections made in join process with current SO lines
     *          If any matching items are found in a sales order line, they are removed from the selectedItems list and left as a sales order line
     *          If no match is found, the sales order line is deleted
     * @param itemClassNames - all item class names for selected items
     * @param salesOrderId  - current sales order id
     * @param selectedItems - list of ids of items selected in join process
     *
     * @return Set of unique selected item ids
     */
    public static Set<Id> matchItemsWithSOLines(Set<String> itemClassNames, Id salesOrderId, List<Id> selectedItems){
        Set<Id> selectedIds = new Set<Id>();
        selectedIds.addAll(selectedItems);

        List<OrderApi__Sales_Order_Line__c> linesToDelete = new List<OrderApi__Sales_Order_Line__c>();
        //get all sales order lines with selected item classes
        List<OrderApi__Sales_Order_Line__c> soLines = [
                SELECT Id, OrderApi__Item__c
                FROM OrderApi__Sales_Order_Line__c
                WHERE OrderApi__Sales_Order__c = :salesOrderId
                AND OrderApi__Item_Class__r.Name IN: itemClassNames];


        if (soLines.size() > 0) {
            for (OrderApi__Sales_Order_Line__c line : soLines) {
                //if sales order line contains one of the selected items
                if(selectedIds.contains(line.OrderApi__Item__c)){
                    //remove it from the selected list so we dont duplicate sales order lines
                    selectedIds.remove(line.OrderApi__Item__c);
                } else {
                    //add to list of lines to delete
                    linesToDelete.add(line);
                }
            }
            try{
                delete linesToDelete;
            } catch (Exception e){
                System.debug('Error deleting sales order lines: ' + e.getMessage());
                return null;
            }
        }
        return selectedIds;
    }

    /**
     * @purpose Adds sales order lines for all selected items to specified sales order
     *
     * @param selectedItems
     * @param salesOrderId
     *
     * @return JPError instance with success or failure
     */
    public static JPError addItemsToSalesOrder(Set<Id> selectedItems, Id salesOrderId){

        Renewal_Settings__c renewalProcess = Renewal_Settings__c.getInstance();
        OrderApi__Sales_Order_Line__c membershipLine = [SELECT OrderApi__Is_Renewal__c, OrderApi__Item__r.Managed__c, OrderApi__Item__r.Name, OrderApi__Subscription_Plan__c, OrderApi__Subscription_Plan__r.OrderApi__Advanced_Calendar_Days__c, OrderApi__Activation_Date__c FROM OrderApi__Sales_Order_Line__c WHERE OrderApi__Item_Class__r.Name = 'Individual Memberships' AND  OrderApi__Sales_Order__c=: salesOrderId];

        OrderApi__Sales_Order__c SO = [SELECT OrderApi__Contact__c FROM OrderApi__Sales_Order__c WHERE Id=: salesOrderId];
        List<OrderApi__Subscription__c> individualMemSubList = RenewalUtils.getIndividualMembershipSubscription(SO.OrderApi__Contact__c);

        if(selectedItems.size()>0) {
            List<OrderApi__Item__c> remainingItems = [SELECT Id, Managed__c, OrderApi__Item_Class__c, Future_Income_Account__c, OrderApi__Income_Account__c, OrderApi__Is_Subscription__c FROM OrderApi__Item__c WHERE Id IN: selectedItems];
            List<OrderApi__Sales_Order_Line__c> linesToInsert = new List<OrderApi__Sales_Order_Line__c>();
            for(OrderApi__Item__c item : remainingItems){
                //create new sales order line for each selected item
                OrderApi__Sales_Order_Line__c line = new OrderApi__Sales_Order_Line__c(
                        OrderApi__Sales_Order__c = salesOrderId,
                        OrderApi__Item__c = item.Id,
                        OrderApi__Item_Class__c = item.OrderApi__Item_Class__c,
                        OrderApi__Quantity__c = 1,
                        OrderApi__Activation_Date__c = membershipLine.OrderApi__Activation_Date__c
                );
                //if item is a subscription & membership is not emeritus, add subscription plan
                if(item.OrderApi__Is_Subscription__c && membershipLine.OrderApi__Item__r.Name!='Emeritus Membership'){
                    line.OrderApi__Subscription_Plan__c = membershipLine.OrderApi__Subscription_Plan__c;
                }

                if( !individualMemSubList.isEmpty() ) { //RENEWAL
                    if(membershipLine.OrderApi__Item__r.Managed__c) {
                        if (renewalProcess.Is_Active__c) {
                            //if renewal process is active and subscription plan is 1YR and should be activated for next year, set GL account to future income account
                            if (item.Future_Income_Account__c != null && membershipLine.OrderApi__Subscription_Plan__r.OrderApi__Advanced_Calendar_Days__c != 365 && Integer.valueOf(renewalProcess.Term_Year__c) == membershipLine.OrderApi__Activation_Date__c.year()) {
                                line.OrderApi__GL_Account__c = item.Future_Income_Account__c;
                            }
                        } else { //renewal process is not active
                            line.OrderApi__Auto_Calculate_Activation_Date__c = false;
                            line.OrderApi__Activation_Date__c = Date.today();
                            line.OrderApi__Gl_Account__c = item.OrderApi__Income_Account__c;
                        }
                    } else {
                        line.OrderApi__Auto_Calculate_Activation_Date__c = false;
                        if(membershipLine.OrderApi__Is_Renewal__c){
                            line.OrderApi__Activation_Date__c = Date.newInstance(System.now().year()+1, 1, 1);
                        } else {
                            line.OrderApi__Activation_Date__c = membershipLine.OrderApi__Activation_Date__c;
                        }
                        line.OrderApi__GL_Account__c = item.Future_Income_Account__c;
                    }
                } else {//JOIN
                    if(renewalProcess.Is_Active__c) {
                        //if renewal process is active and subscription plan is 1YR and should be activated for next year, set GL account to future income account
                        if (Integer.valueOf(renewalProcess.Term_Year__c) == membershipLine.OrderApi__Activation_Date__c.year() && item.Future_Income_Account__c != null && membershipLine.OrderApi__Subscription_Plan__r.OrderApi__Advanced_Calendar_Days__c!=365) {
                            line.OrderApi__GL_Account__c = item.Future_Income_Account__c;
                        } else {
                            line.OrderApi__Gl_Account__c = item.OrderApi__Income_Account__c;
                        }
                    }
                }

                linesToInsert.add(line);
            }
            try {
                insert linesToInsert;

                return new JPError(true, 'Sales order lines inserted successfully', null);
            } catch (DmlException e) {
                System.debug('Error inserting sales order lines: ' + e.getMessage());
                return new JPError(false, e.getMessage(), null);
            }
        } else {
            return new JPError(true, 'There were no selected items', null);
        }
    }


    /**
     * @purpose Saves item selections made in join process as sales order lines
     *
     * @param itemClassNames - all item class names for selected items
     * @param salesOrderId  - current sales order id
     * @param selectedItems - list of ids of items selected in join process
     *
     * @return JPError wrapper class object with failure/success and accompanying message
     */
    public static JPError saveItemSelections(Set<String> itemClassNames, Id salesOrderId, List<Id> selectedItems){
        Set<Id> selectedIds = new Set<Id>();
        System.debug('selectedItems: ' + selectedItems);
        if(salesOrderId!=null ) {
            selectedIds =  matchItemsWithSOLines(itemClassNames, salesOrderId, selectedItems);
            //for all remaining selected items, add sales order lines
            System.debug('remaining item ids: ' + selectedIds);
            return addItemsToSalesOrder(selectedIds, salesOrderId);
        } else {
            return new JPError(false,'Missing sales order Id', null);
        }
    }

    /**
     * @purpose Gets most recent Sales order for current contact and its status
     *
     * @param contactId - current contactId
     *
     * @return Most recent sales order or null
     */
    public static OrderApi__Sales_Order__c getMostRecentSO(Id contactId){
        System.debug('Getting most recent sales order...');
        List<OrderApi__Sales_Order__c> salesOrders = [SELECT Id, OrderApi__Has_Subscription__c, OrderApi__Status__c, OrderApi__Posting_Status__c FROM OrderApi__Sales_Order__c WHERE OrderApi__Contact__c =: contactId ORDER BY CreatedDate DESC LIMIT 1];
        if(salesOrders.size()==1){
            return salesOrders[0];
        }
        return null;
    }

    /**
   * @purpose Create initial SO for new member
   * @param con - current contact record
   * @param item - item to be used to create sales order line
   *
   * @return new sales order with one line for given item
   */
    public static OrderApi__Sales_Order__c createNewMemberSOWithLine(Contact con, OrderApi__Item__c item){
        System.debug('creating new so');
        OrderApi__Sales_Order__c salesOrder;

        salesOrder = new OrderApi__Sales_Order__c(OrderApi__Contact__c = con.Id,
                OrderApi__Account__c = con.AccountId,
                OrderApi__Business_Group__c = item.OrderApi__Business_Group__c,
                OrderApi__Entity__c = 'Contact');

        try{
            insert salesOrder;
            OrderApi__Sales_Order_Line__c membershipLine = createSOLine(salesOrder, item, false);
            System.debug('membership Line: ' + membershipLine);
            membershipLine = [SELECT Id, OrderApi__Subscription_Plan__c FROM OrderApi__Sales_Order_Line__c WHERE OrderApi__Sales_Order__c=: salesOrder.Id AND OrderApi__Item_Class__r.NAme='Individual Memberships'];
            //add blood cancer discovery journal
            OrderApi__Item__c bloodCancerJournal = [SELECT Id, OrderApi__Item_Class__c FROM OrderApi__Item__c WHERE Name='Blood Cancer Discovery - Online'];
            insert new OrderApi__Sales_Order_Line__c(OrderApi__Subscription_Plan__c=membershipLine.OrderApi__Subscription_Plan__c, OrderApi__Sales_Order__c=salesOrder.Id, OrderApi__Item__c=bloodCancerJournal.Id, OrderApi__Item_Class__c=bloodCancerJournal.OrderApi__Item_Class__c);
        }catch(Exception exp){
            System.debug('Exception Occured While inserting Sales Order :::'+ exp.getMessage() + '\t' + exp.getStackTraceString());
        }
        return salesOrder;
    }

    /**
   * @purpose Create initial SO for reinstate-transfer
   * @param con - current contact record
   * @param item - item to be used to create sales order line
   *
   * @return new sales order with one line for given item
   */
    public static OrderApi__Sales_Order__c createReinstateTransferSOWithLine(Contact con, OrderApi__Item__c item){
        System.debug('creating new so');
        OrderApi__Sales_Order__c salesOrder;

        salesOrder = new OrderApi__Sales_Order__c(OrderApi__Contact__c = con.Id,
                OrderApi__Account__c = con.AccountId,
                OrderApi__Business_Group__c = item.OrderApi__Business_Group__c,
                OrderApi__Entity__c = 'Contact',
                OrderApi__Posting_Entity__c='Receipt',
                OrderApi__Schedule_Type__c = 'Simple Receipt',
                Is_Transfer__c = true,
                Is_Reinstatement__c = true,
                OrderApi__Description__c = 'Transfer Application');

        try{
            insert salesOrder;
            OrderApi__Sales_Order_Line__c membershipLine = createSOLine(salesOrder, item, false);
            //add blood cancer discovery journal
            OrderApi__Item__c bloodCancerJournal = [SELECT Id, OrderApi__Item_Class__c FROM OrderApi__Item__c WHERE Name='Blood Cancer Discovery - Online'];
            insert new OrderApi__Sales_Order_Line__c(OrderApi__Subscription_Plan__c=membershipLine.OrderApi__Subscription_Plan__c, OrderApi__Sales_Order__c=salesOrder.Id, OrderApi__Item__c=bloodCancerJournal.Id, OrderApi__Item_Class__c=bloodCancerJournal.OrderApi__Item_Class__c);
        }catch(Exception exp){
            System.debug('Exception Occured While inserting Sales Order :::'+ exp.getMessage() + '\t' + exp.getStackTraceString());
        }
        return salesOrder;
    }

    /**
   * @purpose Create initial SO for transfer
   * @param con - current contact record
   * @param item - item to be used to create sales order line
   *
   * @return new sales order with one line for given item
   */
    public static OrderApi__Sales_Order__c createTransferSOWithLine(Contact con, OrderApi__Item__c item){
        System.debug('creating new so');
        OrderApi__Sales_Order__c salesOrder;

        salesOrder = new OrderApi__Sales_Order__c(OrderApi__Contact__c = con.Id,
                OrderApi__Account__c = con.AccountId,
                OrderApi__Business_Group__c = item.OrderApi__Business_Group__c,
                OrderApi__Entity__c = 'Contact',
                OrderApi__Posting_Entity__c='Receipt',
                OrderApi__Schedule_Type__c = 'Simple Receipt',
                Is_Transfer__c = true,
                OrderApi__Description__c = 'Transfer Application');

        try{
            insert salesOrder;
            OrderApi__Sales_Order_Line__c membershipLine = createSOLine(salesOrder, item, false);
            membershipLine = [SELECT Id, OrderApi__Subscription_Plan__c FROM OrderApi__Sales_Order_Line__c WHERE Id=: membershipLine.Id];

        }catch(Exception exp){
            System.debug('Exception Occured While inserting Sales Order :::'+ exp.getMessage() + '\t' + exp.getStackTraceString());
        }
        return salesOrder;
    }


    /**
     * @purpose Created sales order line given item and relates it to given sales order
     * @param so - sales order to add lines to
     * @param item - select item to make sales order line for
     *
     * @return new sales order line
     */
    public static OrderApi__Sales_Order_Line__c createSOLine(OrderApi__Sales_Order__c so, OrderApi__Item__c item, Boolean isRenewal){
        System.debug('creating sales order line with sales order: ' + so + ' item: ' + item + ' and isRenewal: ' + isRenewal);
        OrderApi__Sales_Order_Line__c sol = new OrderApi__Sales_Order_Line__c();
        sol.OrderApi__Sales_Order__c = so.Id;
        sol.OrderApi__Is_Renewal__c = isRenewal;
        sol.OrderApi__Item__c = item.Id;
        sol.OrderApi__Item_Class__c = item.OrderApi__Item_Class__c;
        sol.OrderApi__Entity__c = so.OrderApi__Entity__c;

//        Renewal_Settings__c renewalProcess = Renewal_Settings__c.getInstance();
//        if(renewalProcess.Is_Active__c){
//            if(item.OrderApi__Price__c == 0.0 && item.Name!='Emeritus Membership'){ //if item is an associate or student membership - automatically give them 2YR subscription
//                OrderApi__Subscription_Plan__c subPlan = [SELECT Id FROM OrderApi__Subscription_Plan__c WHERE OrderApi__Is_Active__c=true AND OrderApi__Advanced_Calendar_Days__c = 365 ORDER BY Show_In_Portal__c DESC LIMIT 1];
//                sol.OrderApi__Subscription_Plan__c = subPlan.Id;
//                so.Is2YR__c = true;
//            }
//        }
        try{
            insert sol;
            update so;
            return sol;
        }catch(Exception exp){
            System.debug('Exception Occurred While inserting Sales Order :::'+ exp.getMessage() + '\t' + exp.getStackTraceString());
        }
        return null;
    }

    /**
    * @purpose Error wrapper class object to return to join process steps/components
    */
    public class JPResponse{
        @AuraEnabled
        public Boolean isSuccess;

        @AuraEnabled
        public String message;

        @AuraEnabled
        public sObject record;

        public JPResponse(Boolean success, String error, sObject obj){
            this.isSuccess = success;
            this.message = error;
            this.record = obj;

        }
    }

    /**
     * @purpose Error wrapper class object to return to join process steps/components
     */
    public class JPError{
        @AuraEnabled
        public Boolean isSuccess;

        @AuraEnabled
        public String message;

        @AuraEnabled
        public List<Id> recordIds;

        public JPError(Boolean success, String error, List<Id> ids){
            this.isSuccess = success;
            this.message = error;
            if(ids!=null){
                this.recordIds = ids;
            } else {
                this.recordIds = new List<Id>();
            }

        }
    }


}