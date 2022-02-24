/**
 * Created by lauren.lezberg on 2/11/2020.
 */

public with sharing class CurrentSubscriptionsController {


    @AuraEnabled
    public static List<OrderApi__Subscription__c> getAllCurrentSubscriptions(String contactId){
        System.debug('contactId: ' + contactId);
        List<OrderApi__Subscription__c> currentSubs = new List<OrderApi__Subscription__c>();

        //get most recent membership subscription
        List<OrderApi__Subscription__c> memSubs = RenewalUtils.getIndividualMembershipSubscription(contactId);
        if(!memSubs.isEmpty()) {

            //get all subscriptions matching membership paid through date
//            currentSubs = ECRMUtils.getSubscriptionsFromMembership(null, memSubs[0]);
            currentSubs = [SELECT Id, OrderApi__Contact__c, OrderApi__Subscription_Plan__r.Name, OrderApi__Account__c,
                    OrderApi__Item_Class__c, OrderApi__Item__r.Future_Income_Account__c,
                    OrderApi__Item__r.OrderApi__Income_Account__c, OrderApi__Is_Expired__c,
                    OrderApi__Current_Term_End_Date__c, OrderApi__Business_Group__c,OrderApi__Item__c,
                    OrderApi__Entity__c, OrderApi__Item__r.OrderApi__Is_Active__c,
                    OrderApi__Subscription_Plan__r.OrderApi__Is_Active__c, OrderApi__Item__r.Name,
                    OrderApi__Item_Class__r.Name, OrderApi__Is_Active__c, OrderApi__Subscription_Plan__c,
                    OrderApi__Enable_Auto_Renew__c
            FROM OrderApi__Subscription__c
            WHERE OrderApi__Paid_Through_Date__c >= :Date.today()
            AND OrderApi__Contact__c = :contactId
            AND OrderApi__Is_Cancelled__c = false];

        }

        return currentSubs;
    }


    @AuraEnabled
    public static void cancelSubscriptions(List<String> subIds){
        List<OrderApi__Subscription__c> subsToCancel = [SELECT Id FROM OrderApi__Subscription__c WHERE Id IN: subIds];
        ECRMUtils.cancelSubscriptions(subsToCancel, 'Customer Request');
    }
}