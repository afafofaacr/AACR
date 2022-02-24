/**
 * Created by lauren.lezberg on 10/1/2019.
 */

trigger TermUpdateTrigger on OrderApi__Renewal__c (after insert) {
    System.debug('term update trigger');

    List<OrderApi__Renewal__c> terms = [SELECT OrderApi__Term_Start_Date__c, OrderApi__Term_End_Date__c, OrderApi__Subscription__r.OrderApi__Current_Term_End_Date__c, OrderApi__Subscription__r.OrderApi__Current_Term_Start_Date__c, OrderApi__Sales_Order__r.Is2YR__c
                                        FROM OrderApi__Renewal__c
                                        WHERE Id IN: Trigger.new];

    TermUpdateTriggerHandler.updateTermDates(terms); 
}