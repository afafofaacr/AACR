/**
 * Created by lauren.lezberg on 3/19/2020.
 */

trigger acSalesOrderTrigger on OrderApi__Sales_Order__c (after update) {

    if ( Trigger.isAfter && Trigger.isUpdate ) {
        brSalesOrderTriggerHandler handler = new brSalesOrderTriggerHandler();

        handler.approveBoughtTickets(Trigger.new, Trigger.oldMap);
    }
}