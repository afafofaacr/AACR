/**
 * Created by lauren.lezberg on 2/2/2021.
 */

public with sharing class SpecializedOrderingController {


    @AuraEnabled
    public static List<Specialized_Order_Lookups__mdt> getAvailableObjects(){
        return [SELECT Id, MasterLabel, Field_API_Name__c, Object_API_Name__c FROM Specialized_Order_Lookups__mdt];
    }

    @AuraEnabled
    public static void createSOLine(Id itemId, Id salesOrderId){
        insert new OrderApi__Sales_Order_Line__c(OrderApi__Sales_Order__c=salesOrderId, OrderApi__Item__c=itemId);

    }

    @AuraEnabled
    public static void removeSOLine(Id itemId, Id salesOrderId){
        List<OrderApi__Sales_Order_Line__c> lines = [SELECT Id FROM OrderApi__Sales_Order_Line__c WHERE OrderApi__Sales_Order__c=:salesOrderId AND OrderApi__Item__c=:itemId];
        if(!lines.isEmpty()){
            delete lines;
        }
    }

    @AuraEnabled
    public static String buildAccountSalesOrder(String accountId, String jsonItems, String fieldName, String fieldValue){
        List<String> itemIds = (List<String>)JSON.deserialize(jsonItems, List<String>.class);
        System.debug('itemIds: ' + itemIds);

        sObject sObj = Schema.getGlobalDescribe().get('OrderApi__Sales_Order__c').newSObject() ;
        sObj.put('OrderApi__Account__c', accountId);
        sObj.put('OrderApi__Entity__c', 'Account');
        if(fieldName!=null && fieldValue!=null){
            sObj.put(fieldName, fieldValue);
        }

        try{
            insert sObj;

            List<OrderApi__Sales_Order_Line__c> soLines = new List<OrderApi__Sales_Order_Line__c>();
            for(String item : itemIds){
                OrderApi__Sales_Order_Line__c line = new OrderApi__Sales_Order_Line__c(OrderApi__Sales_Order__c=sObj.Id, OrderApi__Item__c=item);
                soLines.add(line);
            }
            insert soLines;

            return (String)sObj.get('Id');
        }catch(Exception e){
            new AACRCustomException(accountId, e.getMessage(), e.getStackTraceString(), 'Specialized Order');
        }
        return null;
    }

    @AuraEnabled
    public static String upsertStripeCustomer(String accountId, String email){
        System.debug('upsertStripeCustomer....');
        String customerId;
        Account acc = [SELECT Id, Stripe_Customer_Id__c FROM Account WHERE Id=:accountId];
        if(acc.Stripe_Customer_Id__c!=null){
            customerId = StripeHelper.updateStripeCustomer(acc.Stripe_Customer_Id__c, email);
        } else {
            customerId = StripeHelper.createStripeCustomer(acc.Id, email);
            try{
                acc.Stripe_Customer_Id__c = customerId;
                update acc;
            }catch(Exception e){
                new AACRCustomException(e.getMessage(), e.getStackTraceString(), 'Upsert Stripe Customer');
            }
        }

        return customerId;
    }

    @AuraEnabled
    public static OrderApi__Invoice__c sendAccountInvoice(String customerId, String jsonItems, Date dueDate, String fieldName, String fieldValue){
        System.debug('sendAccountInvoice....');
        List<String> itemIds = (List<String>)JSON.deserialize(jsonItems, List<String>.class);
        List<OrderApi__Item__c> items = [SELECT Id, OrderApi__SKU__c FROM OrderApi__Item__c WHERE Id IN: itemIds];

        Map<String, Integer> priceSKUS = new Map<String, Integer>();
        for(OrderApi__Item__c item : items){
            priceSKUS.put(item.OrderApi__SKU__c, 1);
        }

        Integer daysBetween = Date.today().daysBetween(dueDate);
        System.debug('daysBetween: ' + daysBetween);

        Account acc = [SELECT Id, Stripe_Customer_Id__c FROM Account WHERE Stripe_Customer_Id__c=:customerId];

        //create fonteva SO & Invoice
        sObject sObj = Schema.getGlobalDescribe().get('OrderApi__Sales_Order__c').newSObject() ;
        sObj.put('OrderApi__Account__c', acc.Id);
        sObj.put('OrderApi__Entity__c', 'Account');
        sObj.put('OrderApi__Posting_Entity__c', 'Invoice');
        if(fieldName!=null && fieldValue!=null){
            sObj.put(fieldName, fieldValue);
        }

        try{

            //create stripe invoice with invoice items
            String stripeInvId = StripeHelper.createStripeInvoiceItem(customerId, priceSKUS, daysBetween);
            System.debug('stripeInvId: ' + stripeInvId);

            insert sObj;

            List<OrderApi__Sales_Order_Line__c> soLines = new List<OrderApi__Sales_Order_Line__c>();
            for(OrderApi__Item__c item : items){
                OrderApi__Sales_Order_Line__c line = new OrderApi__Sales_Order_Line__c(OrderApi__Sales_Order__c=(String)sObj.get('id'), OrderApi__Item__c=item.Id);
                soLines.add(line);
            }
            insert soLines;

            sObj.put('OrderApi__Status__c', 'Closed');
            update sObj;

            //invoice will be created from sales order being closed and posted - retrieve it for stripe invoice
            OrderApi__Invoice__c inv = [SELECT Id, Stripe_Invoice_Id__c, Name, OrderApi__Sales_Order__c, OrderApi__Sales_Order__r.Name, OrderApi__Account__c, OrderApi__Account__r.Name FROM OrderApi__Invoice__c WHERE OrderApi__Sales_Order__c =: (String)sObj.get('id')];
            inv.Stripe_Invoice_Id__c = stripeInvId;
            update inv;

            return inv;
        } catch(Exception e){
            SYstem.debug('exception: ' + e.getStackTraceString());
            System.debug('message: ' + e.getMessage());
            new AACRCustomException(acc.Id, e.getMessage(), e.getStackTraceString(), 'Specialized Order');
        }

        return null;

    }






}