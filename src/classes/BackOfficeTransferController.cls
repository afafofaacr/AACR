/**
 * Created by lauren.lezberg on 11/18/2019.
 */

public with sharing class BackOfficeTransferController {

    @AuraEnabled
    public static TransferInfo cancelOldSubscriptionsAndGetSOLines(String salesOrderId){
        OrderApi__Sales_Order__c SO = [SELECT OrderApi__Contact__c FROM OrderApi__Sales_Order__c WHERE Id=:salesOrderId];
        /** Get most recent membership subscription **/
        List<OrderApi__Subscription__c> memSubs = RenewalUtils.getIndividualMembershipSubscription(SO.OrderApi__Contact__c);
        List<OrderApi__Subscription__c> allSubs = new List<OrderApi__Subscription__c>();
        String termValue = null;
        if(!memSubs.isEmpty()) {
            /** Get all subscriptions that match membership subscription paid through date **/
            allSubs = [
                    SELECT Id
                    FROM OrderApi__Subscription__c
                    WHERE OrderApi__Contact__c = :SO.OrderApi__Contact__c AND
                    OrderApi__Paid_Through_Date__c = :memSubs[0].OrderApi__Paid_Through_Date__c AND
                    OrderApi__Item__r.OrderApi__Is_Active__c = true AND
                    OrderApi__Subscription_Plan__r.OrderApi__Is_Active__c = true AND
                    OrderApi__Is_Cancelled__c = false
            ];

            /** Cancel all old subscriptions **/
            for (OrderApi__Subscription__c sub : allSubs) {
                sub.OrderApi__Cancelled_Reason__c = 'Transfer';
                sub.OrderApi__Is_Cancelled__c = true;
            }
            update allSubs;

//            /** Get subscription line **/
//            List<OrderApi__Subscription_Line__c> subLines = [SELECT Id, OrderApi__Item__c, OrderApi__Sales_Order_Line__c
//            FROM OrderApi__Subscription_Line__c
//            WHERE OrderApi__Subscription__c=: memSubs[0].Id];
//            if(!subLines.isEmpty()) {
            /** Get old badge from subscription**/
            List<OrderApi__Badge__c> oldBadges = [
                    SELECT Id
                    FROM OrderApi__Badge__c
                    WHERE OrderApi__Item__c = :memSubs[0].OrderApi__Item__c
                    AND OrderApi__Is_Active__c = true
                    AND (Active_Lookup__c = :memSubs[0].OrderApi__Contact__c OR Inactive_Lookup__c = :memSubs[0].OrderApi__Contact__c)
            ];
            if (!oldBadges.isEmpty()) {
                /**Remove sales order line lookup **/
                oldBadges[0].OrderApi__Sales_Order_Line__c = null;
                oldBadges[0].OrderApi__Is_Active__c = false;
                oldBadges[0].OrderApi__Expired_Date__c = Date.today().addDays(-1);
                update oldBadges[0];
            }

            /** Determine if its a 2YR sub for managed memberships **/
            if(memSubs[0].OrderApi__Item__r.Managed__c) {
                Renewal_Settings__c renewalProcess = Renewal_Settings__c.getInstance();
                if (renewalProcess.Is_Active__c) {
                    if (System.now().year() == renewalProcess.Term_Year__c - 1) {
                        List<OrderApi__Item_Subscription_Plan__c> isps = [SELECT OrderApi__Subscription_Plan__c FROM OrderApi__Item_Subscription_Plan__c WHERE OrderApi__Item__c = :memSubs[0].OrderApi__Item__c AND OrderApi__Subscription_Plan__r.OrderApi__Advanced_Calendar_Days__c = 365];
                        termValue = memSubs[0].OrderApi__Subscription_Plan__c;
                        if(termValue == isps[0].OrderApi__Subscription_Plan__c) {
                            SO.Is2YR__c = true;
                            update SO;
                        }
                    }
                }
            }
        }

        return new TransferInfo(salesOrderId, termValue);
    }

    public class TransferInfo{
        @AuraEnabled
        public List<OrderApi__Sales_Order_Line__c> soLines;

        @AuraEnabled
        public String subPlanId;

        public TransferInfo(String salesOrderId, String planId){
            this.soLines = ECRMUtils.getAllSalesOrderLines(salesOrderId);
            this.subPlanId = planId;

        }
    }

}