/**
 * Created by lauren.lezberg on 8/23/2019.
 */

public with sharing class BackOfficeOrderController {


    @AuraEnabled
    public static List<TermOptions> getTermOptions(String membershipItemId, String salesOrderId, Boolean isRenew){

        Renewal_Settings__c renewalProcess = Renewal_Settings__c.getInstance();
        List<OrderApi__Item_Subscription_Plan__c> subPlans = [SELECT Id, OrderApi__Subscription_Plan__c, OrderApi__Subscription_Plan__r.OrderApi__Type__c, OrderApi__Subscription_Plan__r.OrderApi__Advanced_Calendar_Days__c, OrderApi__Is_Default__c FROM OrderApi__Item_Subscription_Plan__c WHERE OrderApi__Item__c=:membershipItemId ORDER BY OrderApi__Subscription_Plan__r.OrderApi__Type__c, OrderApi__Subscription_Plan__r.OrderApi__Advanced_Calendar_Days__c ASC];
        List<TermOptions> termOpts = new List<TermOptions>();
        if(!isRenew) {
            //unmanaged memberships
            if (subPlans.size() == 1) {
                if(subPlans[0].OrderApi__Subscription_Plan__r.OrderApi__Type__c=='Lifetime'){
                    termOpts.add(new TermOptions(subPlans[0].OrderApi__Subscription_Plan__c, 'Lifetime'));
                } else {
                    termOpts.add(new TermOptions(subPlans[0].OrderApi__Subscription_Plan__c, String.valueOf(System.now().year())));
                }
            } else {
                termOpts.add(new TermOptions(subPlans[0].OrderApi__Subscription_Plan__c, String.valueOf(System.now().year())));
                termOpts.add(new TermOptions(subPlans[0].OrderApi__Subscription_Plan__c, String.valueOf(Integer.valueOf(renewalProcess.Term_Year__c))));
                termOpts.add(new TermOptions(subPlans[1].OrderApi__Subscription_Plan__c, String.valueOf(System.now().year() + ' - ' + Integer.valueOf(renewalProcess.Term_Year__c))));
            }
        } else {
            System.debug('is renewal');
            OrderApi__Sales_Order__c SO = [SELECT OrderApi__Contact__c FROM OrderApi__Sales_Order__c WHERE Id=: salesOrderId LIMIT 1];
            List<OrderApi__Subscription__c> memSubs = RenewalUtils.getIndividualMembershipSubscription(SO.OrderApi__Contact__c);
            Boolean canCatchUp = (Integer)renewalProcess.Term_Year__c - 1 == System.now().year() && memSubs[0].OrderApi__Current_Term_End_Date__c.year() < renewalProcess.Term_Year__c - 1;
            System.debug('canCatchUp: ' + canCatchUp);
            if(canCatchUp) {
                termOpts.add(new TermOptions(subPlans[0].OrderApi__Subscription_Plan__c, String.valueOf(System.now().year())));
                termOpts.add(new TermOptions(subPlans[1].OrderApi__Subscription_Plan__c, String.valueOf(Integer.valueOf(renewalProcess.Term_Year__c))));
            }

            if(renewalProcess.Is_Active__c || !memSubs[0].OrderApi__Item__r.Managed__c){
                System.debug('renewal process is active or item is unmanaged');
                if(memSubs[0].OrderApi__Paid_Through_Date__c.year() == System.now().year()){ // if paid through date is current
                    System.debug('PTD is current');
                    termOpts.add(new TermOptions(subPlans[0].OrderApi__Subscription_Plan__c, String.valueOf(System.now().year() + 1)));
                }
            }
        }
        return termOpts;
    }



    /**
     * @purpose Retrieves sales order information as well as available terms and renewal information
     *
     * @param salesOrderId
     *
     * @return BackOfficeOrderData
     */
    @AuraEnabled
    public static BackOfficeOrderData getBackOfficeData(String salesOrderId, Boolean isRenew){
        System.debug('getBackOfficeData was just called with salesOrderId: ' + salesOrderId);
        Renewal_Settings__c renewalProcess = Renewal_Settings__c.getInstance();
        List<OrderApi__Sales_Order_Line__c> lines = ECRMUtils.getAllSalesOrderLines(salesOrderId);
        List<TermOptions> termOpts = new List<TermOptions>();
        if(lines.size()>0){
            for(OrderApi__Sales_Order_Line__c line: lines){
                if(line.OrderApi__Item_Class__r.Name == 'Individual Memberships'){
                    termOpts = getTermOptions(line.OrderApi__Item__c, salesOrderId, isRenew);
                }
            }

        }
//        List<OrderApi__Subscription_Plan__c> subPlans = [SELECT Id, Name FROM OrderApi__Subscription_Plan__c WHERE OrderApi__Is_Active__c = true AND (Show_In_Portal__c=true OR OrderApi__Advanced_Calendar_Days__c=365) ORDER BY Name];
//        List<TermOptions> termOpts = new List<TermOptions>();
//        String subPlanId = null;
//
//        if(!isRenew) { // is not renewal
//            termOpts.add(new TermOptions(subPlans[0].Id, String.valueOf(System.now().year())));
//            termOpts.add(new TermOptions(subPlans[0].Id, String.valueOf(Integer.valueOf(renewalProcess.Term_Year__c))));
//            termOpts.add(new TermOptions(subPlans[1].Id, String.valueOf(System.now().year() + ' - ' + Integer.valueOf(renewalProcess.Term_Year__c))));
//        } else { // is renewal
//            System.debug('is renewal');
//            OrderApi__Sales_Order__c SO = [SELECT OrderApi__Contact__c FROM OrderApi__Sales_Order__c WHERE Id=: salesOrderId LIMIT 1];
//            List<OrderApi__Subscription__c> memSubs = RenewalUtils.getIndividualMembershipSubscription(SO.OrderApi__Contact__c);
//            Boolean canCatchUp = (Integer)renewalProcess.Term_Year__c - 1 == System.now().year() && memSubs[0].OrderApi__Current_Term_End_Date__c.year() < renewalProcess.Term_Year__c - 1;
//            if(canCatchUp) {
//                termOpts.add(new TermOptions(subPlans[0].Id, String.valueOf(System.now().year())));
//                termOpts.add(new TermOptions(subPlans[1].Id, String.valueOf(Integer.valueOf(renewalProcess.Term_Year__c))));
//            }
//
//            if(renewalProcess.Is_Active__c){
//                if(memSubs[0].OrderApi__Paid_Through_Date__c.year() == System.now().year()){ // if paid through date is current
//                    termOpts.add(new TermOptions(subPlans[0].Id, String.valueOf(Integer.valueOf(renewalProcess.Term_Year__c))));
//                }
//            }
//
//        }


        return new BackOfficeOrderData(lines, renewalProcess.Is_Active__c, termOpts);
    }


    /**
     * @purpose Adds a selected to item to a specified sales order with the specified subscription plan and activation date. Based on the subscription plan and activation date, the correct GL will be used.
     *
     * @param itemId
     * @param subPlanId
     * @param futureEndDate
     * @param salesOrderId
     *
     * @return List of all sales order lines including added line
     */
    @AuraEnabled
    public static List<OrderApi__Sales_Order_Line__c> addSelectedItem(String itemId, String subPlanId, Boolean futureEndDate, String salesOrderId){
        System.debug('adding selected item: ' + itemId );
        return OrderEntryFormController.addSelectedItem(itemId, subPlanId, futureEndDate, salesOrderId);
    }


    /**
     * @purpose Removes a sales order line from the specified sales order based on the item
     *
     * @param itemId
     * @param salesOrderId
     *
     * @return List of all remaining sales order lines
     */
    @AuraEnabled
    public static List<OrderApi__Sales_Order_Line__c> removeItem(String itemId, String salesOrderId){
        return OrderEntryFormController.removeItem(itemId, salesOrderId);
    }


    /**
     * @purpose Changes term(subscription plan) for all sales order lines in the specified sales order based on the given subscription plan id and term end date.
     * If the term is changed to a 2YR term, the sales order is updated to be an Is2YR sales order and vice versa for a term change to 1YR
     *
     * @param subPlanId
     * @param futureEndDate
     * @param salesOrderId
     *
     * @return List of all updated sales order lines
     */
    @AuraEnabled
    public static List<OrderApi__Sales_Order_Line__c> changeTerm(String subPlanId, Boolean futureEndDate, String salesOrderId ){
        OrderApi__Subscription_Plan__c subPlan = [SELECT OrderApi__Advanced_Calendar_Days__c FROM OrderApi__Subscription_Plan__c WHERE Id=: subPlanId];

        OrderApi__Sales_Order__c so = [SELECT Id, Is2YR__c FROM OrderApi__Sales_Order__c WHERE Id=: salesOrderId];
        if(subPlan.OrderApi__Advanced_Calendar_Days__c == 365){
            so.Is2YR__c = true;
        } else {
            so.Is2YR__c = false;
        }
        update so;

        Renewal_Settings__c renewalProcess = Renewal_Settings__c.getInstance();

        ECRMUtils.changeSubscriptionTerm(subPlan.Id, salesOrderId, futureEndDate?String.valueOf(renewalProcess.Term_Year__c):String.valueOf(Date.today().year()));

        return ECRMUtils.getAllSalesOrderLines(salesOrderId);
    }

    //Consolidation of back office order data
    public class BackOfficeOrderData{
        @AuraEnabled
        public List<OrderApi__Sales_Order_Line__c> lines;

        @AuraEnabled
        public Boolean renewalsOpen;

        @AuraEnabled
        public List<TermOptions> subscriptionPlans;


        public BackOfficeOrderData(List<OrderApi__Sales_Order_Line__c> lines, Boolean isOpen, List<TermOptions> subPlans){
            this.lines = lines;
            this.renewalsOpen = isOpen;
            this.subscriptionPlans = subPlans;
        }

    }

    //term option data
    public class TermOptions{
        @AuraEnabled
        public String subPlanId;

        @AuraEnabled
        public String termYear;

        public TermOptions(String subPlan, String termYear){
            this.subPlanId = subPlan;
            this.termYear = termYear;
        }
    }
}