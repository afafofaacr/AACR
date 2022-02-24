/**
 * Created by lauren.lezberg on 4/12/2021.
 */

trigger AACR_InvoiceTrigger on OrderApi__Invoice__c (after insert, after update) {

    AACR_InvoiceTriggerHandler hndlr = new AACR_InvoiceTriggerHandler();
    if(trigger.isAfter) {
        List<OrderApi__Invoice__c> invoices = [SELECT Id, OrderApi__Is_Posted__c FROM OrderApi__Invoice__c WHERE Id IN:trigger.new];
        if (trigger.isInsert) {
            hndlr.setAppStatusFromInvoice(invoices[0].Id);
        } else if(trigger.isUpdate){
            if(trigger.new[0].OrderApi__Is_Posted__c && !trigger.old[0].OrderApi__Is_Posted__c){
                //TODO: cancel old subs
            }
        }
    }
}