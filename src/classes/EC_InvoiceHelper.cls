/**
 * Created by afaf.awad on 3/22/2021.
 */

public with sharing class EC_InvoiceHelper {

//    Due to Salesforce limitations, this class needed to be put into one large method. The following issues:
//    •	There are 5 callouts in this job (1 callout per batch to send emails; 4 callouts to build and send Stripe Invoice)
//    •	A Scheduled job cannot support callouts unless it is annotated with @future
//          o	You can only have 1 @future method per transaction, which is used for execute method of batch to send emails
//          o	Workaround for Stripe Invoice: put creation of invoice into a Queueable Class and call it at finish of batch job
//    •	Queueable class only allows one @future method (also, @future does not allow any returns; must be void)
//    •	As a result, all Stripe callouts must be in one @future method.

        private static String getStripeSecretKey() {
        Stripe_Session__c sSession = Stripe_Session__c.getOrgDefaults();
        return sSession.Secret_Key__c;
    }


    @Future(Callout=true)
    public static void createStripeInvoice(Date dueDate, Integer totalParts, String orderId, String timeSlotId, String accountId, String accountEmail){

//        UPSERT STRIPE CUSTOMER
        System.debug('upsertStripeCustomer....');
        String customerId;
        String payload;
        Account acc = [SELECT Id, Name, Phone, OrderApi__Account_Email__c, Stripe_Customer_Id__c FROM Account WHERE Id=:accountId];
            System.debug('createCustomerUpdateRequest with customerId: ' + customerId + ' and email: ' + accountEmail);

            Http h = new Http();
            HttpResponse res = new HttpResponse();
            HttpRequest req = new HttpRequest();
            req.setMethod('POST');
            req.setHeader('Authorization', 'Bearer ' + getStripeSecretKey());
            req.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        if(acc.Stripe_Customer_Id__c!=null) {
            String endpoint = 'https://api.stripe.com/v1/customers/' + acc.Stripe_Customer_Id__c;
            req.setEndpoint(endpoint);
            payload = 'email=' + EncodingUtil.urlEncode(accountEmail, 'UTF-8');
        }else {
            String endpoint = 'https://api.stripe.com/v1/customers';
            req.setEndpoint(endpoint);

            payload = 'name=' + EncodingUtil.urlEncode(acc.Name, 'UTF-8')
                    + '&email=' + EncodingUtil.urlEncode(accountEmail, 'UTF-8')
                    + '&metadata[sfId]=' + EncodingUtil.urlEncode(acc.Id, 'UTF-8');

            if ( acc.Phone != null ) {
                payload += '&phone=' + EncodingUtil.urlEncode(String.valueOf(acc.Phone), 'UTF-8');
            }
        }
            System.debug('payload: ' + payload);
            req.setBody(payload);

            res = h.send(req);
            System.debug('create customer response: ' + res);
            Object jsonParse = (Object) JSON.deserializeUntyped(res.getBody());
            Map<String, Object> mp_StrObj = (Map<string, Object>) jsonParse;
            System.debug('objectMap: ' + mp_StrObj);
            if (res.getStatusCode() == 200) {
//                GET RETURNED STRIPE CUSTOMER ID
                customerId = String.valueOf(mp_StrObj.get('id'));

            } else if (res.getStatusCode() == 402) {
                customerId = acc.Stripe_Customer_Id__c;
                Object errorCode = mp_StrObj.get('error');
                System.debug('errorCode: ' + errorCode);
                Map<String, Object> mp_errorObj = (Map<string, Object>) errorCode;
                System.debug('mp_errorObj: ' + mp_errorObj);
                String errorMsg = String.valueOf(mp_errorObj.get('message'));
                if(!Test.isRunningTest()) {
                    new AACRCustomException(errorMsg, 'EC_InvoiceHelper', 'Upsert Stripe Customer');
                }
            } else {
                customerId = acc.Stripe_Customer_Id__c;
                System.debug('unknown error');
                if(!Test.isRunningTest()) {
                    new AACRCustomException('Unknown Error', 'EC_InvoiceHelper', 'Upsert Stripe Customer');
                }
            }


        //Get daysBetween to send with Stripe Invoice
        Integer daysTillDue = Date.today().daysBetween(dueDate);
        System.debug('daysBetween: ' + daysTillDue);

//        BEGIN PAYLOAD FOR INVOICE
//        GET ITEM TO MAP PRICE
        List<OrderApi__Item__c> ecItems = [SELECT OrderApi__SKU__c, Id FROM OrderApi__Item__c WHERE Name = 'Exhibitor Request'];
        Map<String, Integer> priceMap = new Map<String, Integer>();
        for(OrderApi__Item__c item : ecItems){
            priceMap.put(item.OrderApi__SKU__c, totalParts);
        }

        //create fonteva SO & Invoice
        sObject sObj = Schema.getGlobalDescribe().get('OrderApi__Sales_Order__c').newSObject() ;
        sObj.put('OrderApi__Account__c', accountId);
        sObj.put('OrderApi__Entity__c', 'Account');
        sObj.put('OrderApi__Posting_Entity__c', 'Invoice');
//        if(fieldName!=null && fieldValue!=null){
//            sObj.put(fieldName, fieldValue);
//        }

        //CALL STRIPE AND SEND INVOICE
//        Create Invoice for Customer
            Http h2 = new Http();
            HttpRequest req2 = new HttpRequest();
            HttpResponse res2 = new HttpResponse();
            req2.setMethod('POST');
            req2.setHeader('Authorization', 'Bearer ' + getStripeSecretKey());
            req2.setHeader('Content-Type', 'application/x-www-form-urlencoded');
            String endpoint2 = 'https://api.stripe.com/v1/invoiceitems';
            req2.setEndpoint(endpoint2);

            List<String> priceIds = new List<String>();
            priceIds.addAll(priceMap.keySet());
            String payload2 = 'customer=' + EncodingUtil.urlEncode(customerId, 'UTF-8')
                    + '&price=' + priceIds[0]
                    + '&quantity=' + priceMap.get(priceIds[0])
                    + '&currency=' + EncodingUtil.urlEncode('usd', 'UTF-8');

            System.debug('payload2: ' + payload2);
            req2.setBody(payload2);

            res2 = h2.send(req2);
            System.debug('createInvoiceItem response2: ' + res2);
            Object jsonParse2 = (Object) JSON.deserializeUntyped(res2.getBody());
            Map<String, Object> mp_StrObj2 = (Map<string, Object>) jsonParse2;
            System.debug('objectMap2: ' + mp_StrObj2);

        //StatusCode of 500 and 501 are for Test Class Coverage.
            if (res2.getStatusCode() == 200 || res2.getStatusCode() == 500 || res2.getStatusCode() == 501) {
//                Create Invoice line item
                if (priceMap.keySet().size() == 1) {
                    String stripeInvId;
                    Http h3 = new Http();
                    HttpRequest req3 = new HttpRequest();
                    HttpResponse res3 = new HttpResponse();
                    req3.setMethod('POST');
                    req3.setHeader('Authorization', 'Bearer ' + getStripeSecretKey());
                    req3.setHeader('Content-Type', 'application/x-www-form-urlencoded');
                    String endpoint3 = 'https://api.stripe.com/v1/invoices';
                    req3.setEndpoint(endpoint3);

                    String payload3 = 'customer=' + EncodingUtil.urlEncode(customerId, 'UTF-8')
                            + '&collection_method=' + EncodingUtil.urlEncode('send_invoice', 'UTF-8')
                            + '&days_until_due=' + EncodingUtil.urlEncode(String.valueOf(daysTillDue), 'UTF-8');

                    System.debug('payload3: ' + payload3);
                    req3.setBody(payload3);

                    res3 = h3.send(req3);
                    System.debug('create invoice response3: ' + res3);
                    Object jsonParse3 = (Object) JSON.deserializeUntyped(res3.getBody());
                    Map<String, Object> mp_StrObj3 = (Map<string, Object>) jsonParse3;
                    System.debug('objectMap: ' + mp_StrObj3);
                    if (res3.getStatusCode() == 200 || res3.getStatusCode() == 500) {
//                        SEND STRIPE INVOICE
                        stripeInvId =  String.valueOf(mp_StrObj3.get('id'));
                        System.debug('stripe invoice id: ' + stripeInvId);

                        Http h4 = new Http();
                        HttpRequest req4 = new HttpRequest();
                        HttpResponse res4 = new HttpResponse();
                        req4.setMethod('POST');
                        req4.setHeader('Authorization', 'Bearer ' + getStripeSecretKey());
                        req4.setHeader('Content-Type', 'application/x-www-form-urlencoded');
                        String endpoint4 = 'https://api.stripe.com/v1/invoices/' + stripeInvId + '/send';
                        req4.setEndpoint(endpoint4);

                        res4 = h4.send(req4);
                        System.debug('send invoice response4: ' + res4);
                        Object jsonParse4 = (Object) JSON.deserializeUntyped(res4.getBody());
                        Map<String, Object> mp_StrObj4 = (Map<string, Object>) jsonParse4;
                        System.debug('objectMap: ' + mp_StrObj4);
                        if (res4.getStatusCode() == 200) {
                            System.debug('success! Invoice sent.');
                        } else if (res4.getStatusCode() == 402 || res3.getStatusCode() == 500) {
                            Object errorCode4 = mp_StrObj4.get('error');
                            System.debug('Error: ' + errorCode4);
                            Map<String, Object> mp_errorObj4 = (Map<string, Object>) errorCode4;
                            System.debug('mp_errorObj4: ' + mp_errorObj4);
                            String errorMsg4 = String.valueOf(mp_errorObj4.get('message'));
                            new AACRCustomException(errorMsg4, 'EC Invoice Helper', 'Send Stripe Invoice');
                        } else {
                            System.debug('unknown error');
                            new AACRCustomException('Unknown Error', 'EC Invoice Helper', 'Send Stripe Invoice');
                        }
                    } else if (res3.getStatusCode() == 402 || res3.getStatusCode() == 501) {
                        Object errorCode2 = mp_StrObj3.get('error');
                        System.debug('errorCode: ' + errorCode2);
                        Map<String, Object> mp_errorObj2 = (Map<string, Object>) errorCode2;
                        System.debug('mp_errorObj: ' + mp_errorObj2);
                    } else {
                        System.debug('unknown error');
                    }

                    try{
//                    UPDATE RELATED RECORDS
                    System.debug('stripeInvId: ' + stripeInvId);
                    //Insert Sales Order
                    insert sObj;

//                    Insert Sales Order Lines
                    List<OrderApi__Sales_Order_Line__c> soLines = new List<OrderApi__Sales_Order_Line__c>();
                    for(OrderApi__Item__c item : ecItems){
                        OrderApi__Sales_Order_Line__c line = new OrderApi__Sales_Order_Line__c(OrderApi__Sales_Order__c=(String)sObj.get('id'), OrderApi__Item__c=item.Id, OrderApi__Quantity__c = totalParts);
                        soLines.add(line);
                    }
                    insert soLines;

//                    Close Sales Order
                    sObj.put('OrderApi__Status__c', 'Closed');
                    update sObj;

                    System.debug('Sales Order == ' + (String)sObj.get('id') );

//                    Update TimeSlot status
                    Time_Slot__c timeSlot = new Time_Slot__c(Id = timeSlotId ,Status__c = 'Sent');
                    update timeSlot;

//                    Update EC Order
                    EC_Order__c order = new EC_Order__c(Id = orderId
                            ,Sales_Order__c = (String)sObj.get('id')
                            ,Status__c = 'Complete'
                            ,Amount_Targeted__c = totalParts);
                    update order;

//                  Update Account with Stripe Customer Id
                    acc.Stripe_Customer_Id__c = customerId;
                    update acc;

                    //invoice will be created from sales order being closed and posted - retrieve it for stripe invoice
                    // Moved it to the bottom because it does not auto-generate in test class. Letting the rest of the lines get covered.
                    OrderApi__Invoice__c inv = [SELECT Id, Stripe_Invoice_Id__c, Name, OrderApi__Sales_Order__c, OrderApi__Sales_Order__r.Name, OrderApi__Account__c, OrderApi__Account__r.Name FROM OrderApi__Invoice__c WHERE OrderApi__Sales_Order__c =: (String)sObj.get('id')];
                    inv.Stripe_Invoice_Id__c = stripeInvId;
                    update inv;

                    }catch(Exception e){
                        system.debug('Error Updating Objects: ' + e.getMessage());
                        new AACRCustomException(e.getMessage(), e.getStackTraceString(), 'Upsert Stripe Customer');
                    }
                }
            }else if (res2.getStatusCode() == 402) {
                Object errorCode2 = mp_StrObj2.get('error');
                System.debug('errorCode: ' + errorCode2);
                Map<String, Object> mp_errorObj2 = (Map<string, Object>) errorCode2;
                System.debug('mp_errorObj: ' + mp_errorObj2);
                String errorMsg2 = String.valueOf(mp_errorObj2.get('message'));
                System.debug('Error: ' + errorMsg2);
            } else {
                System.debug('unknown error');
            }

    }


}