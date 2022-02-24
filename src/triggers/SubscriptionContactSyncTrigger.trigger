/**
 * Created by lauren.lezberg on 10/2/2019.
 */

trigger SubscriptionContactSyncTrigger on OrderApi__Subscription__c (after insert, after update) {
    System.debug('SubscriptionContactSyncTrigger....' + Trigger.isUpdate);

    List<OrderApi__Subscription__c> subs = [SELECT Id, OrderApi__Item__c, OrderApi__Is_Active__c, OrderApi__Is_Expired__c, OrderApi__Current_Term_End_Date__c, OrderApi__Contact__c, OrderApi__Item__r.Name
                                            FROM OrderApi__Subscription__c
                                            WHERE Id IN:Trigger.new AND
                                            OrderApi__Item__r.OrderApi__Item_Class__r.Name = 'Individual Memberships'
                                            AND OrderApi__Is_Cancelled__c = false];

//    if(!Test.isRunningTest()) {
        SubscriptionContactSyncTriggerHandler.updateContactFromSubscription(subs, Trigger.isUpdate);
//    }


}