/**
 * Created by lauren.lezberg on 10/1/2019.
 */

public with sharing class TermUpdateTriggerHandler {

    public static void updateTermDates(List<OrderApi__Renewal__c> terms){
        for(OrderApi__Renewal__c term : terms){
            System.debug('term: ' + term);
            if(term.OrderApi__Sales_Order__r.Is2YR__c) {
                System.debug('sales order is 2 YR');
                if (term.OrderApi__Term_Start_Date__c.year() == Date.today().year() + 1) {
                    System.debug('term year starts next year');
                    if (term.OrderApi__Subscription__r.OrderApi__Current_Term_Start_Date__c < term.OrderApi__Term_Start_Date__c && term.OrderApi__Subscription__r.OrderApi__Current_Term_End_Date__c == term.OrderApi__Term_End_Date__c) {
                        term.OrderApi__Term_Start_Date__c = Date.today();
                    }
                }
            }
        }

        update terms;
    }

}