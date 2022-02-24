/**
 * Created by lauren.lezberg on 2/6/2019.
 * @purpose Provides methods for subscription renewal and renewal permissions
 */

public without sharing class RenewalUtils {

    /**
     * @purpose checks if current user has custom permission ROERenew and the contact is eligible for renewal
     *
     * @return true or false
     */
    @AuraEnabled
    public static Boolean canPerformROERenew(Id contactId) {
        return FeatureManagement.checkPermission('ROERenew') && canRenew(contactId);
    }


    /**
     * @purpose Determine if specified contact is eligible for renewal
     *
     * @param con
     *
     * @return True or false
     */
    public static Boolean canRenew(Id contactId) {
        Boolean canRenew = false;
        Integer currentYear = System.now().year();
        OrderApi__Subscription__c memSub;
        List<OrderApi__Subscription__c> individualMemSubList = getIndividualMembershipSubscription(contactId);

        if (!individualMemSubList.isEmpty()) { //if membership subscription was found
            memSub = individualMemSubList[0];
            if(memSub.OrderApi__Item__r.Managed__c) {
                Renewal_Settings__c renewalProcess = Renewal_Settings__c.getInstance();
                if (!renewalProcess.Is_Active__c) { //renewal process is not active
                    if (currentYear == renewalProcess.Term_Year__c || currentYear == renewalProcess.Term_Year__c - 1) {
                        if (memSub.OrderApi__Current_Term_End_Date__c.year() == currentYear - 1) {
                            canRenew = true;
                        } else if (memSub.OrderApi__Current_Term_End_Date__c.year() == currentYear - 2) {
                            canRenew = true;
                            //add 1 YR Dues;
                        } else {
                            canRenew = false;
                        }
                    } else {
                        canRenew = false;
                    }
                } else { //renewal process is active
                    if (currentYear == renewalProcess.Term_Year__c) {
                        if (memSub.OrderApi__Current_Term_End_Date__c.year() == currentYear - 1) {
                            canRenew = true;
                        } else if (memSub.OrderApi__Current_Term_End_Date__c.year() == currentYear - 2) {
                            canRenew = true;
                            //add 1 YR Dues;
                        } else {
                            canRenew = false;
                        }
                    } else if (currentYear == renewalProcess.Term_Year__c - 1) {
                        if (memSub.OrderApi__Current_Term_End_Date__c.year() == currentYear) {
                            canRenew = true;
                        } else if (memSub.OrderApi__Current_Term_End_Date__c.year() == currentYear - 1) {
                            canRenew = true;
                            //add 1 YR Dues;
                        } else if (memSub.OrderApi__Current_Term_End_Date__c.year() == currentYear - 2) {
                            canRenew = true;
                            //add 2 YR Dues;
                        } else {
                            canRenew = false;
                        }
                    } else {
                        canRenew = false;
                    }
                }
            }
        } else {
            canRenew = false;
        }

        return canRenew;
    }




    /**
    * @Purpose: Perform subscription renewal by creating new sales order and copying all subscriptions as sales order lines
    * @Param: Contact
    * @return: Response DTO
    */
    public static DW_ECRMDTO.Response renewSubscriptions(Contact con, Boolean renewalsActive) {
        System.debug('renewSubscriptions was just called with contact: ' + con);
        OrderApi__Sales_Order__c newSalesOrder;
        DW_ECRMDTO.Response response;

        //get individual membership subscription
        List<OrderApi__Subscription__c> individualMemSubList = getIndividualMembershipSubscription(con.Id);
        system.debug('individualMemSubList::' + individualMemSubList);
        //check for errors
        if (individualMemSubList.isEmpty()) {
            response = new DW_ECRMDTO.Response(false, 'No membership subscription found', NULL);
        } else {
            //create new sales order with lines
            JP_Helper.JPResponse SOResponse = createRenewalSO(con.Id, individualMemSubList[0], renewalsActive);
            if (SOResponse.isSuccess) {
                response = processPortalRenew(con.Id, SOResponse.record.Id, individualMemSubList[0]);
            } else {
                response = new DW_ECRMDTO.Response(false, SOResponse.message, NULL);
            }
        }
        return response;
    }

    /**
     * @purpose Process back office renewal for contact record
     *
     * @param contactId
     *
     * @return Instance of JP_Helper.JPResponse class with success or failure
     */
    @AuraEnabled
    public static JP_Helper.JPResponse processROERenew(Id contactId) {
        System.debug('Total Number of SOQL Queries allowed in this Apex code context: ' +  Limits.getLimitQueries());
        System.debug('Total Number of records that can be queried  in this Apex code context: ' +  Limits.getLimitDmlRows());
        System.debug('Total Number of DML statements allowed in this Apex code context: ' +  Limits.getLimitDmlStatements() );
        System.debug('Total Number of CPU usage time (in ms) allowed in this Apex code context: ' +  Limits.getLimitCpuTime());

        //get membership subscription
        List<OrderApi__Subscription__c> individualMemSubList = getIndividualMembershipSubscription(contactId);

        if (individualMemSubList.isEmpty()) {
            System.debug('Error: No membership subscription found');
            return new JP_Helper.JPResponse(false, 'No membership subscription found.', null);
        } else {
            //create new renewal sales order
            Renewal_Settings__c renewalProcess = Renewal_Settings__c.getInstance();
            JP_Helper.JPResponse SOResponse = createRenewalSO(contactId, individualMemSubList[0], renewalProcess.Is_Active__c);
            System.debug('1. Number of Queries used in this Apex code so far: ' + Limits.getQueries());
            System.debug('2. Number of rows queried in this Apex code so far: ' + Limits.getDmlRows());
            System.debug('3. Number of DML statements used so far: ' +  Limits.getDmlStatements());
            System.debug('4. Amount of CPU time (in ms) used so far: ' + Limits.getCpuTime());
            if (SOResponse.isSuccess) {
                try {
//                    addDuesToSO2(SOResponse.record.Id, individualMemSubList[0].Id, contactId);
//                    addDuesToSO(SOResponse.record.Id, individualMemSubList[0], contactId);
                    return new JP_Helper.JPResponse(true, 'Successfully created sales order.', SOResponse.record);
                } catch (Exception e) {
                    System.debug('Error adding dues to Sales order');
                    return new JP_Helper.JPResponse(false, 'Could not add prior dues to the sales order.', null);
                }
            } else {
                System.debug('Could not create sales order.');
                return SOResponse;
            }
        }
    }

    /**
     *@Purpose : Process portal renew for contact record
     *@Param   : -
     *@return  : Response
     */
    public static DW_ECRMDTO.Response processPortalRenew(Id contactId, Id salesOrderId, OrderApi__Subscription__c subscription) {
        System.debug('processRenew');
        DW_ECRMDTO.Response response;
        String successMsg = String.isNotBlank(Label.DW_Sales_Order_LIs_Creation_Msg) ? Label.DW_Sales_Order_LIs_Creation_Msg : 'Sales Order Line Items Created Successfully';

        // Create RenewDTO
        DW_ECRMDTO.RenewDTO renewDTO = createRenewDTO(contactId, salesOrderId);
        if (String.isBlank(renewDTO.joinProcessURL)) {
            response = new DW_ECRMDTO.Response(false, 'Could not construct join URL ', renewDTO);
        } else {
            response = new DW_ECRMDTO.Response(true, successMsg, renewDTO);
        }
        return response;
    }

    /**
    * @purpose Create renewal SO based off membership subscription and adds all valid subscriptions as sales order lines
    *
    * @param contactId
    * @param salesOrderId
    *
    * @return Sales Order for renewal
    */
    public static JP_Helper.JPResponse createRenewalSO(Id contactId, OrderApi__Subscription__c individualMembership, Boolean renewalsActive) {
        System.debug('createRenewalSO was just called with contactId: ' + contactId + ' and membership: ' + individualMembership);
        OrderApi__Sales_Order__c newSalesOrder;
        List<OrderApi__Subscription__c> subscriptionList = new List<OrderApi__Subscription__c>();
        List<OrderApi__Subscription__c> allContactSubscriptions;

        try {
            allContactSubscriptions = [
                    SELECT Id, OrderApi__Contact__c, OrderApi__Account__c, OrderApi__Item_Class__c, OrderApi__Item__r.Future_Income_Account__c, OrderApi__Item__r.OrderApi__Income_Account__c, OrderApi__Is_Expired__c, OrderApi__Current_Term_End_Date__c,
                            OrderApi__Business_Group__c,OrderApi__Item__c, OrderApi__Entity__c, OrderApi__Item__r.OrderApi__Is_Active__c, OrderApi__Subscription_Plan__r.OrderApi__Is_Active__c, OrderApi__Item__r.Name,OrderApi__Item_Class__r.Name,
                            OrderApi__Is_Active__c, OrderApi__Subscription_Plan__c, OrderApi__Enable_Auto_Renew__c, OrderApi__Item__r.Managed__c, (SELECT OrderApi__Item__c FROM OrderApi__Subscription_Lines__r)
                    FROM OrderApi__Subscription__c
                    WHERE OrderApi__Contact__c = :contactId AND
                    OrderApi__Paid_Through_Date__c = :individualMembership.OrderApi__Paid_Through_Date__c AND
                    OrderApi__Item__r.OrderApi__Is_Active__c = true AND
                    OrderApi__Subscription_Plan__r.OrderApi__Is_Active__c = true AND
                    OrderApi__Is_Cancelled__c = false
            ];
            system.debug('subscriptionList::' + subscriptionList);
        } catch (Exception exp) {
            System.debug('Exception Occured While fetching Subscriptions :::' + exp.getMessage() + '\t' + exp.getStackTraceString());
            return new JP_Helper.JPResponse(false, 'Could not retrieve subscriptions.', null);
        }

        //check that all subscriptions are valid and items match
        for (OrderApi__Subscription__c sub : allContactSubscriptions) {
            for (OrderApi__Subscription_Line__c subLine : sub.OrderApi__Subscription_Lines__r) {
                if (subLine.OrderApi__Item__c == sub.OrderApi__Item__c) {
                    subscriptionList.add(sub);
                }
            }
        }

        if (!subscriptionList.isEmpty()) {
            //create new sales order based off individual membership subscription
            newSalesOrder = createSalesOrder(individualMembership);
            System.debug('newSalesOrder==>' + newSalesOrder);
            //create new sales order lines
            if (newSalesOrder != NULL) {
                if (!subscriptionList.isEmpty()) {
//                    List<OrderApi__Sales_Order_Line__c> salesOrderLIList = createSalesOrderLIs(subscriptionList, newSalesOrder,renewalsActive);
                    List<OrderApi__Sales_Order_Line__c> salesOrderLIList = createRenewalSOLines(subscriptionList, newSalesOrder,renewalsActive);
                    system.debug('salesOrderLIList::' + salesOrderLIList);

                }
            }
            return new JP_Helper.JPResponse(true, 'Successfully created sales order.', newSalesOrder);
        } else {
            System.debug('No valid subscriptions were found');
            return new JP_Helper.JPResponse(false, 'No valid subscriptions were found.', null);
        }
    }


    /**
     * @purpose Add any prior dues items to sales order based off membership status
     *
     * @param contactId
     * @param salesOrderId
     * @param subscription
     */
    public static OrderApi__Sales_Order_Line__c addDuesToSO(Id salesOrderId, OrderApi__Subscription__c subscription) {
        String duesItemName;

        // if delinquency is more than 1 year
        if (subscription.OrderApi__Is_Expired__c && subscription.OrderApi__Item__r.Name != 'Emeritus Membership') {
            //get dues item name from custom setting
            duesItemName = getDuesItemName(getRequiredYearsOfDues(subscription));
            return getItemAndCreateSOLI(duesItemName, salesOrderId, subscription);
        }

        return null;
    }

    /**
     *@Purpose : get item and create sales order line item
     *@Param   : item name, salesOrderId
     *@return  : -
     */
    public static OrderApi__Sales_Order_Line__c getItemAndCreateSOLI(String itemName, Id salesOrderId, OrderApi__Subscription__c subscription) {

        System.debug('in getItemAndCreateSOLI');
        OrderApi__Item__c item;

        try {
            item = [
                    SELECT Id, Name, OrderApi__Item_Class__c
                    FROM OrderApi__Item__c
                    WHERE OrderApi__Item_Class__r.Name = 'Prior Year Dues' AND
                    Name = :itemName
            ];

            system.debug('item::' + item);
        } catch (Exception exp) {
            System.debug('Exception Occured While fetching Item :::' + exp.getMessage() + '\t' + exp.getStackTraceString());
        }

        if (item != NULL) {
            // Create salesOrderLI
            system.debug('item not null create SOLI' + salesOrderId + ' sub::' + subscription);
            return createSalesOrderLI(salesOrderId, item, subscription);
        }
        return null;
    }

    /**
   *@Purpose : create sales order Line item
   *@Param   :
   *@return  :
   */
    public static OrderApi__Sales_Order_Line__c createSalesOrderLI(Id salesOrderId, OrderApi__Item__c item, OrderApi__Subscription__c subscription) {
        System.debug('in createSalesOrderLI');
        System.debug('item==>' + item);


        OrderApi__Sales_Order_Line__c salesOderLI = new OrderApi__Sales_Order_Line__c(OrderApi__Sales_Order__c = salesOrderId,
                OrderApi__Is_Renewal__c = true,
                OrderApi__Item__c = item.Id,
                OrderApi__Item_Class__c = item.OrderApi__Item_Class__c,
                OrderApi__Subscription__c = subscription.Id
        );
        try {
            return salesOderLI;
        } catch (Exception exp) {
            System.debug('Exception Occured While inserting Subscription :::' + exp.getMessage() + '\t' + exp.getStackTraceString());
        }

        return null;
    }

    /**
    *@Purpose : Create Renewal Sales Order Lines
    *@Param   : subscriptionList,salesOrder
    *@return  : Sales Order Line Item List
    */
    public static List<OrderApi__Sales_Order_Line__c> createRenewalSOLines(List<OrderApi__Subscription__c> subscriptionList,
            OrderApi__Sales_Order__c salesOrder, Boolean renewalsActive) {
        Boolean hasBloodCancerJournal = false;

        List<OrderApi__Item_Subscription_Plan__c> itemSubscriptionPlans = new List<OrderApi__Item_Subscription_Plan__c>();
//        List<OrderApi__Subscription_Plan__c> subPlans = [SELECT Id FROM OrderApi__Subscription_Plan__c WHERE (Show_In_Portal__c = true OR OrderApi__Advanced_Calendar_Days__c = 365) AND OrderApi__Is_Active__c = true AND OrderApi__Type__c = 'Calendar' ORDER BY OrderApi__Advanced_Calendar_Days__c];

        system.debug('in createSalesOrderLIs::' + salesOrder + ' ' + subscriptionList);
        List<OrderApi__Sales_Order_Line__c> salesOrderLIList = new List<OrderApi__Sales_Order_Line__c>();
        OrderApi__Sales_Order_Line__c salesOrderLI;

        Renewal_Settings__c renewalProcess = Renewal_Settings__c.getInstance();

        OrderApi__Subscription__c membershipSubscription;

        List<OrderApi__Subscription__c> membershipSubs = getIndividualMembershipSubscription(salesOrder.OrderApi__Contact__c);
        membershipSubscription = membershipSubs[0];

        // Creating renewal Sales Order line items for all subscriptions
        for (OrderApi__Subscription__c subscription : subscriptionList) {
//            if(subscription.OrderApi__Item_Class__r.Name == 'Individual Memberships'){
//                membershipSubscription = subscription;
//            }
            if(subscription.OrderApi__Item__r.Name=='Blood Cancer Discovery - Online'){
                hasBloodCancerJournal = true;
            }

            //get available subscription plans
            itemSubscriptionPlans = [SELECT OrderApi__Subscription_Plan__c FROM OrderApi__Item_Subscription_Plan__c WHERE OrderApi__Item__c=:membershipSubscription.OrderApi__Item__c ORDER BY OrderApi__Subscription_Plan__r.OrderApi__Type__c, OrderApi__Subscription_Plan__r.OrderApi__Advanced_Calendar_Days__c ASC];

            salesOrderLI = new OrderApi__Sales_Order_Line__c(
                    OrderApi__Sales_Order__c = salesOrder.id,
                    OrderApi__Is_Renewal__c = true,
                    OrderApi__Item__c = subscription.OrderApi__Item__c,
                    OrderApi__Item_Class__c = subscription.OrderApi__Item_Class__c,
                    OrderApi__Subscription__c = subscription.Id,
                    OrderApi__Business_Group__c = subscription.OrderApi__Business_Group__c,
                    OrderApi__Entity__c = subscription.OrderApi__Entity__c,
                    OrderApi__Enable_Auto_Renew__c = subscription.OrderApi__Enable_Auto_Renew__c,
                    OrderApi__GL_Account__c = subscription.OrderApi__Item__r.OrderApi__Income_Account__c
            );

            //check renewal settings for managed membership types
            if(membershipSubscription.OrderApi__Item__r.Managed__c) {
                salesOrderLI.OrderApi__Subscription_Plan__c = itemSubscriptionPlans[0].OrderApi__Subscription_Plan__c;

                if (renewalsActive) {
                    if (System.now().year() == renewalProcess.Term_Year__c - 1) {
                        if (subscription.OrderApi__Current_Term_End_Date__c.year() == System.now().year() - 1 || subscription.OrderApi__Current_Term_End_Date__c.year() == System.now().year() - 2) {
                            salesOrderLI.OrderApi__Subscription_Plan__c = itemSubscriptionPlans[1].OrderApi__Subscription_Plan__c;
                            salesOrderLI.OrderApi__Gl_Account__c = subscription.OrderApi__Item__r.OrderApi__Income_Account__c;
                            salesOrder.Is2YR__c = true;

                        } else {
                            if (subscription.OrderApi__Item__r.Future_Income_Account__c != null) {
                                salesOrderLI.OrderApi__GL_Account__c = subscription.OrderApi__Item__r.Future_Income_Account__c;
                            }
                        }
                    }
                }
            } else { //renewals use future year GL for unmanaged memberships
                salesOrderLI.OrderApi__GL_Account__c = subscription.OrderApi__Item__r.Future_Income_Account__c;
            }

            salesOrderLIList.add(salesOrderLI);
        }


        system.debug('salesOrderLIList::' + salesOrderLIList);
        //Add extra items
        if (!salesOrderLIList.isEmpty()) {
            try {
                //add dues item to sales order if necessary
                OrderApi__Sales_Order_Line__c line = addDuesToSO(salesOrder.Id, membershipSubscription);
                System.debug('duesItemLine: ' + line);
                if(line!=null) {
                    salesOrderLIList.add(line);
                }
                if(!hasBloodCancerJournal){
                    //add blood cancer discovery journal if it doesn't already exist
                    OrderApi__Item__c bloodCancerJournal = [SELECT Id, OrderApi__Item_Class__c FROM OrderApi__Item__c WHERE Name='Blood Cancer Discovery - Online'];
                    OrderApi__Sales_Order_Line__c bcjLine = new OrderApi__Sales_Order_Line__c(OrderApi__Sales_Order__c=salesOrder.Id, OrderApi__Item__c=bloodCancerJournal.Id, OrderApi__Item_Class__c=bloodCancerJournal.OrderApi__Item_Class__c);
                    //check renewal settings for managed memberships sub plan assignment
                    if(membershipSubscription.OrderApi__Item__r.Managed__c) {
                        if (renewalsActive) {
                            if (System.now().year() == renewalProcess.Term_Year__c - 1) {
                                bcjLine.OrderApi__Subscription_Plan__c = itemSubscriptionPlans[1].OrderApi__Subscription_Plan__c;
                                salesOrderLIList.add(bcjLine);
                            }
                        } else {
                            bcjLine.OrderApi__Subscription_Plan__c = itemSubscriptionPlans[0].OrderApi__Subscription_Plan__c;
                            salesOrderLIList.add(bcjLine);
                        }
                    } else { //unmanaged memberships always have same subscription plan
                        bcjLine.OrderApi__Subscription_Plan__c = membershipSubscription.OrderApi__Subscription_Plan__c;
                        bcjLine.OrderApi__Activation_Date__c = Date.newInstance(System.now().year() + 1, 1, 1);
                        salesOrderLIList.add(bcjLine);
                    }

                }
                insert salesOrderLIList;
                update salesOrder;
            } catch (Exception exp) {
                System.debug('Exception Occurred While inserting Sales Order LIs:::' + exp.getMessage() + '\t' + exp.getStackTraceString());
            }
        }
        return salesOrderLIList;
    }


    /**
     *@Purpose : Create Sales Order Line Items
     *@Param   : subscriptionList,salesOrder
     *@return  : Sales Order Line Item List
     */
//    public static List<OrderApi__Sales_Order_Line__c> createSalesOrderLIs(List<OrderApi__Subscription__c> subscriptionList,
//            OrderApi__Sales_Order__c salesOrder, Boolean renewalsActive) {
////        OrderApi__Subscription_Plan__c subPlan = [SELECT Id FROM OrderApi__Subscription_Plan__c WHERE Show_In_Portal__c = true AND OrderApi__Is_Active__c = true LIMIT 1];
//
//        Boolean hasBloodCancerJournal = false;
//        //get available subscription plans
//        List<OrderApi__Subscription_Plan__c> subPlans = [SELECT Id FROM OrderApi__Subscription_Plan__c WHERE (Show_In_Portal__c = true OR OrderApi__Advanced_Calendar_Days__c= 365) AND OrderApi__Is_Active__c = true AND OrderApi__Type__c = 'Calendar' ORDER BY OrderApi__Advanced_Calendar_Days__c];
//
//        system.debug('in createSalesOrderLIs::' + salesOrder + ' ' + subscriptionList);
//        List<OrderApi__Sales_Order_Line__c> salesOrderLIList = new List<OrderApi__Sales_Order_Line__c>();
//        OrderApi__Sales_Order_Line__c salesOrderLI;
//
//        Renewal_Settings__c renewalProcess = Renewal_Settings__c.getInstance();
//
//        OrderApi__Subscription__c membershipSubscription;
//
//        // Creating new Sales Order line items for all subscriptions
//        for (OrderApi__Subscription__c subscription : subscriptionList) {
//            if(subscription.OrderApi__Item_Class__r.Name == 'Individual Memberships'){
//                membershipSubscription = subscription;
//            }
//            if(subscription.OrderApi__Item__r.Name=='Blood Cancer Discovery - Online'){
//                hasBloodCancerJournal = true;
//            }
//            salesOrderLI = new OrderApi__Sales_Order_Line__c(
//                    OrderApi__Sales_Order__c = salesOrder.id,
//                    OrderApi__Is_Renewal__c = true,
//                    OrderApi__Item__c = subscription.OrderApi__Item__c,
//                    OrderApi__Item_Class__c = subscription.OrderApi__Item_Class__c,
//                    OrderApi__Subscription__c = subscription.Id,
//                    OrderApi__Business_Group__c = subscription.OrderApi__Business_Group__c,
//                    OrderApi__Entity__c = subscription.OrderApi__Entity__c,
//                    OrderApi__Enable_Auto_Renew__c = subscription.OrderApi__Enable_Auto_Renew__c,
//                    OrderApi__Subscription_Plan__c = subPlans[0].Id
//            );
//
//            if (renewalsActive) {
//                if(System.now().year() == renewalProcess.Term_Year__c - 1) {
//                    if (subscription.OrderApi__Current_Term_End_Date__c.year() == System.now().year() - 1 || subscription.OrderApi__Current_Term_End_Date__c.year() == System.now().year() - 2) {
//                        salesOrderLI.OrderApi__Subscription_Plan__c = subPlans[1].Id;
//                        salesOrderLI.OrderApi__Gl_Account__c = subscription.OrderApi__Item__r.OrderApi__Income_Account__c;
//                        salesOrder.Is2YR__c = true;
//
//                    } else {
//                        if (subscription.OrderApi__Item__r.Future_Income_Account__c != null) {
//                            salesOrderLI.OrderApi__GL_Account__c = subscription.OrderApi__Item__r.Future_Income_Account__c;
//                        }
//                    }
//                }
//            } else {
//                salesOrderLI.OrderApi__Gl_Account__c = subscription.OrderApi__Item__r.OrderApi__Income_Account__c;
//            }
//
//            salesOrderLIList.add(salesOrderLI);
//        }
//
//
//
//        system.debug('salesOrderLIList::' + salesOrderLIList);
//        //Add extra items
//        if (!salesOrderLIList.isEmpty()) {
//            try {
//                //add dues item to sales order if necessary
//                OrderApi__Sales_Order_Line__c line = addDuesToSO(salesOrder.Id, membershipSubscription);
//                System.debug('duesItemLine: ' + line);
//                if(line!=null) {
//                    salesOrderLIList.add(line);
//                }
//                if(!hasBloodCancerJournal){
//                    //add blood cancer discovery journal
//                    OrderApi__Item__c bloodCancerJournal = [SELECT Id, OrderApi__Item_Class__c FROM OrderApi__Item__c WHERE Name='Blood Cancer Discovery - Online'];
//                    OrderApi__Sales_Order_Line__c bcjLine = new OrderApi__Sales_Order_Line__c(OrderApi__Sales_Order__c=salesOrder.Id, OrderApi__Item__c=bloodCancerJournal.Id, OrderApi__Item_Class__c=bloodCancerJournal.OrderApi__Item_Class__c);
//                    if (renewalsActive) {
//                        if (System.now().year() == renewalProcess.Term_Year__c - 1) {
//                            bcjLine.OrderApi__Subscription_Plan__c = subPlans[1].Id;
//                            salesOrderLIList.add(bcjLine);
//                        }
//                    } else {
//                        bcjLine.OrderApi__Subscription_Plan__c = subPlans[0].Id;
//                        salesOrderLIList.add(bcjLine);
//                    }
//
//                }
//                insert salesOrderLIList;
//                update salesOrder;
//            } catch (Exception exp) {
//                System.debug('Exception Occurred While inserting Sales Order LIs:::' + exp.getMessage() + '\t' + exp.getStackTraceString());
//            }
//        }
//        return salesOrderLIList;
//    }

    /**
     *@Purpose : Create Sales Order
     *@Param   : subscription
     *@return  : sales Order record
     */
    public static OrderApi__Sales_Order__c createSalesOrder(OrderApi__Subscription__c subscription) {
        OrderApi__Sales_Order__c salesOrder;

        salesOrder = new OrderApi__Sales_Order__c(OrderApi__Contact__c = subscription.OrderApi__Contact__c,
                OrderApi__Account__c = subscription.OrderApi__Account__c,
                OrderApi__Business_Group__c = subscription.OrderApi__Business_Group__c,
                OrderApi__Entity__c = subscription.OrderApi__Entity__c);
        try {
            insert salesOrder;
        } catch (Exception exp) {
            System.debug('Exception Occurred While inserting Sales Order :::' + exp.getMessage() + '\t' + exp.getStackTraceString());
        }
        return salesOrder;
    }


    /**
    *@Purpose : Create RenewDTO record
    *@Param   : contactId, salesOrderId, membershipStatus
    *@return  : Instance of DW_ECRMDTO.RenewDTO class that includes contactId, salesOrderId & the joinProcessURL
    */
    public static DW_ECRMDTO.RenewDTO createRenewDTO(Id contactId, Id salesOrderId) {
        DW_ECRMDTO.RenewDTO renewDTORecord = new DW_ECRMDTO.RenewDTO();
        renewDTORecord.contactId = contactId;
        renewDTORecord.salesOrderId = salesOrderId;

        String joinProcessURL = getRenewURL(contactId, salesOrderId);
        if (joinProcessURL != null && String.isNotBlank(joinProcessURL)) {
            joinProcessUrl += '&isRenew=true&salesOrder=' + salesOrderId;
        }
        renewDTORecord.joinProcessURL = String.isNotBlank(joinProcessURL) ? joinProcessURL : '';

        return renewDTORecord;
    }

    /**
     *@Purpose : Get Individual Membership Subscription
     *@Param   : contactId
     *@return  : individual Membership Subscription List
     */
    public static List<OrderApi__Subscription__c> getIndividualMembershipSubscription(Id contactId) {
        List<OrderApi__Subscription__c> individualMemSubList = new List<OrderApi__Subscription__c>();
        Set<String> itemClassNamesSet = new Set<String>();
        itemClassNamesSet.add('Individual Memberships');

        // IF itemClassNamesSet is not empty
        if (!itemClassNamesSet.isEmpty()) {
            individualMemSubList = getClassSubscriptions(contactId, itemClassNamesSet);
        }
        return individualMemSubList;
    }

    public static Map<Id, OrderApi__Subscription__c> getContactMembershipMap(Set<Id> contactIds){
        Map<Id, OrderApi__Subscription__c> membershipMap = new Map<Id, OrderApi__Subscription__c>();
        List<OrderApi__Subscription__c> subcriptionList = new List<OrderApi__Subscription__c>();
        subcriptionList = [
                SELECT Id,OrderApi__Paid_Through_Date__c, OrderApi__Subscription_Plan__c, OrderApi__Contact__c, OrderApi__Current_Term_End_Date__c, OrderApi__Days_To_Lapse__c,
                        OrderApi__Item__c, OrderApi__Item__r.Name, OrderApi__Item__r.Fon_Association_Journal_Type__c, OrderApi__Grace_Period_End_Date__c, OrderApi__In_Grace_Period__c,
                        OrderApi__Item_Class__r.Name, Join_Date__c, OrderApi__Account__c,OrderApi__Is_Active__c, OrderApi__Is_Expired__c, OrderApi__Current_Term_Start_Date__c, Days_Left__c,
                        OrderApi__Business_Group__c, OrderApi__Entity__c, OrderApi__Enable_Auto_Renew__c,Delinquency__c, OrderApi__Item__r.OrderApi__Image_Path__c, OrderApi__Item__r.Managed__c,
                        OrderApi__Item__r.Show_In_Portal__c, OrderApi__Subscription_Plan__r.Name
                FROM OrderApi__Subscription__c
                WHERE OrderApi__Contact__c IN: contactIds AND
                OrderApi__Item_Class__r.Name='Individual Memberships' AND
                OrderApi__Is_Cancelled__c = false
                ORDER BY OrderApi__Paid_Through_Date__c DESC, CreatedDate DESC
        ];
        if(!subcriptionList.isEmpty()){
            membershipMap.put(subcriptionList[0].OrderApi__Contact__c, subcriptionList[0]);
//            for(OrderApi__Subscription__c sub: subcriptionList){
//                membershipMap.put(sub.OrderApi__Contact__c, sub);
//            }
        }

        return membershipMap;
    }

    /**
     *@Purpose : Getting Specific class Subcriptions
     *@Param   : contactId, classNameSet
     *@return  : Subscription list
     */
    public static List<OrderApi__Subscription__c> getClassSubscriptions(Id contactId, Set<String> classNameSet) {
        List<OrderApi__Subscription__c> subcriptionList = new List<OrderApi__Subscription__c>();

        // Fetching Subscriptions of specific clsses
        try {
            subcriptionList = [
                    SELECT Id,OrderApi__Paid_Through_Date__c, OrderApi__Subscription_Plan__c, OrderApi__Contact__c, OrderApi__Current_Term_End_Date__c, OrderApi__Days_To_Lapse__c,
                            OrderApi__Item__c, OrderApi__Item__r.Name, OrderApi__Item__r.Fon_Association_Journal_Type__c, OrderApi__Grace_Period_End_Date__c, OrderApi__In_Grace_Period__c,
                            OrderApi__Item_Class__r.Name, Join_Date__c, OrderApi__Account__c,OrderApi__Is_Active__c, OrderApi__Is_Expired__c, OrderApi__Current_Term_Start_Date__c, Days_Left__c,
                            OrderApi__Business_Group__c, OrderApi__Entity__c, OrderApi__Enable_Auto_Renew__c,Delinquency__c, OrderApi__Item__r.OrderApi__Image_Path__c, OrderApi__Item__r.Managed__c,
                            OrderApi__Item__r.Show_In_Portal__c, OrderApi__Subscription_Plan__r.Name
                    FROM OrderApi__Subscription__c
                    WHERE OrderApi__Contact__c = :contactId AND
                    OrderApi__Item_Class__r.Name IN :classNameSet AND
                    OrderApi__Is_Cancelled__c = false
                    ORDER BY OrderApi__Paid_Through_Date__c DESC, CreatedDate DESC
            ];
        } catch (Exception exp) {
            System.debug('Exception Occured While fetching Subscriptions :::' + exp.getMessage() + '\t' + exp.getStackTraceString());
        }
        return subcriptionList;
    }


    /**
     *@Purpose : Get renewal Process URL based off sales order and deleting last accessed step information
     *@Param   : -
     *@return  : Join Process URL String
     */
    public static String getRenewURL(Id contactId, Id salesOrderId) {
        System.debug('getJoinProcessURL');

        // Getting individual membership sales order LI list
        List<OrderApi__Sales_Order_Line__c> salesOrderLIList = ECRMUtils.getSpecificSalesOrderIndMemLIs(salesOrderId);
        if (!salesOrderLIList.isEmpty() && String.isNotBlank(salesOrderLIList[0].OrderApi__Item__c)) {
            try {
                List<Join_Process__mdt> process = [SELECT Id FROM Join_Process__mdt WHERE Is_Renewal__c = true AND Item__c LIKE:('%' + salesOrderLIList[0].OrderApi__Item__r.Name + '%') LIMIT 1];
                JP_Helper.deleteContactLastAccessedStep(process[0].Id);
                return '/apex/JP_Container?id=' + process[0].Id;
            } catch (Exception exp) {
                System.debug('Exception Occured While fetching Join Process :::' + exp.getMessage() + '\t' + exp.getStackTraceString());
                return null;
            }
        }
        System.debug('No sales order lines found...');
        return null;
    }


    /**
     *@Purpose : Getting Prior year dues item names from DW_Manage_Dues_Item__c custom setting based of years of delinquency
     *@Param   : delinquency
     *@return  : prior year item name
     */
    public static String getDuesItemName(Decimal delinquency) {
        System.debug('getDuesItemName was just called with delinquency: ' + delinquency);
        String itemName;
        if (delinquency != null) {
            // getting dues item from setting
            List<DW_Manage_Dues_Item__c> duesItems = DW_Manage_Dues_Item__c.getAll().values();
            for (DW_Manage_Dues_Item__c item : duesItems) {
                if (item.Delinquent_Years__c == delinquency) {
                    itemName = item.Membership_Item_Name__c;
                }
            }
        }
        return itemName;
    }

    /**
     * @purpose Get required years of dues that should be added based of membership subscription
     *
     * @param memSub
     *
     * @return Number of years of dues that should be added to sales order
     */
    public static Integer getRequiredYearsOfDues(OrderApi__Subscription__c memSub) {
        Integer currentYear = System.now().year();

        if (memSub != null) { //if membership subscription was found
            Renewal_Settings__c renewalProcess = Renewal_Settings__c.getInstance();
            if (currentYear == renewalProcess.Term_Year__c || currentYear == renewalProcess.Term_Year__c - 1) {
                if (memSub.OrderApi__Current_Term_End_Date__c.year() == currentYear - 2) {
                    //add 1 YR Dues;
                    return 1;
                }
            }
        }

        return 0;

    }

}