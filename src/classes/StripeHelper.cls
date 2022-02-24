/**
 * Created by lauren.lezberg on 2/2/2021.
 */

public without sharing class StripeHelper {
    /**
        * @purpose Retrieve stripe public key from custom setting - for elements
        * @return stripe public key
        */
    private static String getStripePublicKey() {
        Stripe_Session__c sSession = Stripe_Session__c.getOrgDefaults();
        return sSession.Publishable_Key__c;
    }

    /**
         * @purpose Retrieve stripe secret key from custom setting - for API
         * @return stripe secret key
         */
    private static String getStripeSecretKey() {
        Stripe_Session__c sSession = Stripe_Session__c.getOrgDefaults();
        return sSession.Secret_Key__c;
    }

    public static String updateStripeCustomer(String customerId, String email){
        System.debug('createCustomerUpdateRequest with customerId: ' + customerId + ' and email: ' + email);

        Http h = new Http();
        HttpResponse res = new HttpResponse();
        HttpRequest req = new HttpRequest();
        req.setMethod('POST');
        req.setHeader('Authorization', 'Bearer ' + getStripeSecretKey());
        req.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        String endpoint = 'https://api.stripe.com/v1/customers/' + customerId;
        req.setEndpoint(endpoint);

        String payload = 'email=' + EncodingUtil.urlEncode(email, 'UTF-8');

        System.debug('payload: ' + payload);
        req.setBody(payload);

        res = h.send(req);
        System.debug('create customer response: ' + res);
        Object jsonParse = (Object) JSON.deserializeUntyped(res.getBody());
        Map<String, Object> mp_StrObj = (Map<string, Object>) jsonParse;
        System.debug('objectMap: ' + mp_StrObj);
        if (res.getStatusCode() == 200) {
            return String.valueOf(mp_StrObj.get('id'));
        } else if (res.getStatusCode() == 402) {
            Object errorCode = mp_StrObj.get('error');
            System.debug('errorCode: ' + errorCode);
            Map<String, Object> mp_errorObj = (Map<string, Object>) errorCode;
            System.debug('mp_errorObj: ' + mp_errorObj);
            String errorMsg = String.valueOf(mp_errorObj.get('message'));
            new AACRCustomException(errorMsg, 'StripeHelper.updateStripeCustomer line 41', 'Update Stripe Customer');
        } else {
//            errorMsg = 'Unknown Error';
            System.debug('unknown error');
            new AACRCustomException('Unknown Error', 'StripeHelper.updateStripeCustomer line 41', 'Update Stripe Customer');
        }


        return null;
    }



    public static String createStripeCustomer(String accountId, String email){
        Account acc = [SELECT Id, Name, Phone, OrderApi__Account_Email__c, Stripe_Customer_Id__c FROM Account WHERE Id=:accountId];

        Http h = new Http();
        HttpRequest req = new HttpRequest();
        HttpResponse res = new HttpResponse();
        req.setMethod('POST');
        req.setHeader('Authorization', 'Bearer ' + getStripeSecretKey());
        req.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        String endpoint = 'https://api.stripe.com/v1/customers';
        req.setEndpoint(endpoint);

        String payload = 'name=' + EncodingUtil.urlEncode(acc.Name, 'UTF-8')
                + '&email=' + EncodingUtil.urlEncode(email, 'UTF-8')
                + '&metadata[sfId]=' + EncodingUtil.urlEncode(acc.Id, 'UTF-8');

        if(acc.Phone!=null) {
           payload += '&phone=' + EncodingUtil.urlEncode(String.valueOf(acc.Phone), 'UTF-8');
        }


        System.debug('payload: ' + payload);
        req.setBody(payload);

        res = h.send(req);
        System.debug('create customer response: ' + res);
        Object jsonParse = (Object) JSON.deserializeUntyped(res.getBody());
        Map<String, Object> mp_StrObj = (Map<string, Object>) jsonParse;
        System.debug('objectMap: ' + mp_StrObj);
        if (res.getStatusCode() == 200) {
            return String.valueOf(mp_StrObj.get('id'));
        } else if (res.getStatusCode() == 402) {
            Object errorCode = mp_StrObj.get('error');
            System.debug('errorCode: ' + errorCode);
            Map<String, Object> mp_errorObj = (Map<string, Object>) errorCode;
            System.debug('mp_errorObj: ' + mp_errorObj);
            String errorMsg = String.valueOf(mp_errorObj.get('message'));
            new AACRCustomException(errorMsg, 'StripeHelper.createStripeCustomer line 90', 'Create Stripe Customer');
        } else {
//            errorMsg = 'Unknown Error';
            System.debug('unknown error');
            new AACRCustomException('Unknown Error', 'StripeHelper.createStripeCustomer line 90', 'Create Stripe Customer');
        }

        return null;
    }


    public static String createStripeInvoice(String customerId, Integer daysTillDue){
        System.debug('createSTripeInvoice with customer: ' + customerId + ' and daysTillDue: ' + daysTillDue);
        String stripeInvId;
        Http h = new Http();
        HttpRequest req = new HttpRequest();
        HttpResponse res = new HttpResponse();
        req.setMethod('POST');
        req.setHeader('Authorization', 'Bearer ' + getStripeSecretKey());
        req.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        String endpoint = 'https://api.stripe.com/v1/invoices';
        req.setEndpoint(endpoint);

        String payload = 'customer=' + EncodingUtil.urlEncode(customerId, 'UTF-8')
                + '&collection_method=' + EncodingUtil.urlEncode('send_invoice', 'UTF-8')
                + '&days_until_due=' + EncodingUtil.urlEncode(String.valueOf(daysTillDue), 'UTF-8');

        System.debug('payload: ' + payload);
        req.setBody(payload);

        res = h.send(req);
        System.debug('create invoice response: ' + res);
        Object jsonParse = (Object) JSON.deserializeUntyped(res.getBody());
        Map<String, Object> mp_StrObj = (Map<string, Object>) jsonParse;
        System.debug('objectMap: ' + mp_StrObj);
        if (res.getStatusCode() == 200) {
            stripeInvId =  String.valueOf(mp_StrObj.get('id'));
            System.debug('stripe invoice id: ' + stripeInvId);
            StripeHelper.sendStripeInvoice(stripeInvId);
        } else if (res.getStatusCode() == 402) {
            Object errorCode = mp_StrObj.get('error');
            System.debug('errorCode: ' + errorCode);
            Map<String, Object> mp_errorObj = (Map<string, Object>) errorCode;
            System.debug('mp_errorObj: ' + mp_errorObj);
        } else {
            System.debug('unknown error');
        }

        return stripeInvId;
    }


    public static String createStripeInvoiceItem(String customerId, Map<String,Integer> priceMap, Integer daysTillDue){
        System.debug('createStripeInvoiceItem for customer: ' + customerId + ' with priceMap: ' + priceMap + ' and daysTillDue: ' + daysTillDue);
        if(priceMap!=null) {
            Http h = new Http();
            HttpRequest req = new HttpRequest();
            HttpResponse res = new HttpResponse();
            req.setMethod('POST');
            req.setHeader('Authorization', 'Bearer ' + getStripeSecretKey());
            req.setHeader('Content-Type', 'application/x-www-form-urlencoded');
            String endpoint = 'https://api.stripe.com/v1/invoiceitems';
            req.setEndpoint(endpoint);

            List<String> priceIds = new List<String>();
            priceIds.addAll(priceMap.keySet());
            //priceIds[0]
            String payload = 'customer=' + EncodingUtil.urlEncode(customerId, 'UTF-8')
                    + '&price=' + priceIds[0]
                    + '&quantity=' + priceMap.get(priceIds[0])
                    + '&currency=' + EncodingUtil.urlEncode('usd', 'UTF-8');

            System.debug('payload: ' + payload);
            req.setBody(payload);

            res = h.send(req);
            System.debug('createInvoiceItem response: ' + res);
            Object jsonParse = (Object) JSON.deserializeUntyped(res.getBody());
            Map<String, Object> mp_StrObj = (Map<string, Object>) jsonParse;
            System.debug('objectMap: ' + mp_StrObj);
            if (res.getStatusCode() == 200) {
                if (priceMap.keySet().size() == 1) {
                    return createStripeInvoiceItem(customerId, null , daysTillDue);
                } else {
                    //remove first item from list and send list
                    priceMap.keySet().remove(priceIds[0]);
                    return createStripeInvoiceItem(customerId, priceMap, daysTillDue);
                }
            } else if (res.getStatusCode() == 402) {
                Object errorCode = mp_StrObj.get('error');
                System.debug('errorCode: ' + errorCode);
                Map<String, Object> mp_errorObj = (Map<string, Object>) errorCode;
                System.debug('mp_errorObj: ' + mp_errorObj);
                String errorMsg = String.valueOf(mp_errorObj.get('message'));
                System.debug('Error: ' + errorMsg);
            } else {
                System.debug('unknown error');
            }
        } else {
            return createStripeInvoice(customerId, daysTillDue);
        }

        return null;
    }


    public static void sendStripeInvoice(String invoiceId){

        Http h = new Http();
        HttpRequest req = new HttpRequest();
        HttpResponse res = new HttpResponse();
        req.setMethod('POST');
        req.setHeader('Authorization', 'Bearer ' + getStripeSecretKey());
        req.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        String endpoint = 'https://api.stripe.com/v1/invoices/' + invoiceId + '/send';
        req.setEndpoint(endpoint);

        res = h.send(req);
        System.debug('send invoice response: ' + res);
        Object jsonParse = (Object) JSON.deserializeUntyped(res.getBody());
        Map<String, Object> mp_StrObj = (Map<string, Object>) jsonParse;
        System.debug('objectMap: ' + mp_StrObj);
        if (res.getStatusCode() == 200) {
            System.debug('success! Invoice sent.');
        } else if (res.getStatusCode() == 402) {
            Object errorCode = mp_StrObj.get('error');
            System.debug('Error: ' + errorCode);
            Map<String, Object> mp_errorObj = (Map<string, Object>) errorCode;
            System.debug('mp_errorObj: ' + mp_errorObj);
            String errorMsg = String.valueOf(mp_errorObj.get('message'));
            new AACRCustomException(errorMsg, 'StripeHelper.sendStripeInvoice line 212', 'Send Stripe Invoice');
        } else {
            System.debug('unknown error');
            new AACRCustomException('Unknown Error', 'StripeHelper.sendStripeInvoice line 212', 'Send Stripe Invoice');
        }

    }



}