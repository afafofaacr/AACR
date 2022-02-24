/**
 * Created by afaf.awad on 1/13/2021.
 */

public with sharing class InvoicePaymentController {


    @AuraEnabled
    public static OrderApi__Invoice__c getInvoice(String invoiceId){
        return [SELECT Id, Name, OrderApi__Contact__c, OrderApi__Total__c, OrderApi__Amount_Paid__c, OrderApi__Balance_Due__c, OrderApi__Sales_Order__c, OrderApi__Due_Date__c FROM OrderApi__Invoice__c WHERE Id=:invoiceId];
    }



//    @AuraEnabled
//    public static Id getApplyPaymentJoinId(){
//        return [SELECT Id FROM Join_Process__mdt WHERE DeveloperName='Apply_Invoice_Payment'].Id;
//    }
//
//
//
//    @AuraEnabled
//    public static List<OrderApi__Invoice_Line__c> getSalesOrder(String invoiceId){
//        return [SELECT Id, Name, OrderApi__Invoice__r.OrderApi__Sales_Order__c, OrderApi__Item__r.Name, OrderApi__Sale_Price__c, OrderApi__Total__c,
//                        OrderApi__Invoice__r.OrderApi__Total__c, OrderApi__Invoice__r.OrderApi__Balance_Due__c, OrderApi__Invoice__r.OrderApi__Amount_Paid__c,
//                OrderApi__Invoice__r.Name, OrderApi__Invoice__c
//                    FROM OrderApi__Invoice_Line__c WHERE OrderApi__Invoice__c =: invoiceId];
//
//    }

}