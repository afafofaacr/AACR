/**
 * Created by lauren.lezberg on 11/12/2020.
 */

public without sharing class StripePaymentController {
    public static Join_Process__mdt joinProcess = new Join_Process__mdt(DeveloperName = 'Test', Redirect_URL__c = 'https://www.amazon.com/', Cancel_URL__c = 'https://www.amazon.com/');

    public String publicKey { get; set; }
    public String privateKey { get; set; }
    public String ltngHostName { get; set; }
    public String piSecret { get; set; }
    public String pi {get;set;}
    public String errorMsg { get; set; }
    public String retURL { get; set; }
    public String salesOrderId { get; set; }
    public String joinId { get; set; }
    public Contact currentContact { get; set; }
    public Boolean isCommunity { get; set; }
    public Boolean showPayment { get; set; }
    public Boolean requireAddress { get; set; }
    public Boolean processed { get; set; }
    public OrderApi__Known_Address__c billingAddress { get; set; }
    public Map<String, String> countryCodeMap { get; set; }
    public Decimal amount { get; set; }
    public Boolean isInvoice { get; set; }

    public StripePaymentController() {
        System.debug('currentPage: ' + ApexPages.currentPage().getUrl());

        /**get lightning hostname for redirects & communication with lightning component**/
        Id networkId = Network.getNetworkId();
        if (networkId == null) {
            /**NOT in community **/
            System.debug('no network id');
            Url baseUrl = Url.getSalesforceBaseUrl();

            String hostname = baseUrl.getHost();
            String myDomain = hostname.split('\\.')[0];
            if (myDomain.contains('--')) {
                //uses lastIndex to exclude namespace but include sandbox names
                myDomain = myDomain.substring(0, hostname.lastIndexOf('--'));
            }
            ltngHostName = 'https://' + myDomain + '.lightning.force.com';
        } else {
            /** in community **/
            System.debug('network id');
            ConnectApi.Community currentCommunity = ConnectApi.Communities.getCommunity(networkId);
            Url baseUrl = new Url(currentCommunity.siteUrl);

            ltngHostName = baseUrl.getProtocol() + '://' + baseUrl.getHost();
        }

        System.debug('lightning hostname: ' + ltngHostName);

        /** set base variables **/
        errorMsg = null;
        piSecret = null;
        billingAddress = null;

        publicKey = getStripePublicKey();
        privateKey = getStripeSecretKey();
        isCommunity = isCommunity();
        countryCodeMap = ECRMUtils.getReverseCountryPicklistValues();

        processed = false;
        isInvoice = false;
        requireAddress = true;

        System.debug('params: ' + ApexPages.currentPage().getParameters());
        /** get page url parameters **/
        joinId = ApexPages.currentPage().getParameters().get('id');
        System.debug('joinId: ' + joinId);
        salesOrderId = ApexPages.currentPage().getParameters().get('salesOrder');
        System.debug('salesOrderId: ' + salesOrderId);

        String reqAddress = ApexPages.currentPage().getParameters().get('reqAddr');
        if (reqAddress != null) {
            if (reqAddress == 'false') {
                requireAddress = false;
            }
        }


        /** get sales order/invoice info **/

        OrderApi__Invoice__c inv;
        OrderApi__Sales_Order__c so = [SELECT OrderApi__Posting_Entity__c, OrderApi__Contact__c, OrderApi__Total__c, OrderApi__Is_Posted__c, OrderApi__Is_Closed__c FROM OrderApi__Sales_Order__c WHERE Id = :salesOrderId];
        amount = so.OrderApi__Total__c;
        if (so.OrderApi__Posting_Entity__c == 'Invoice') {
            isInvoice = true;
            inv = [SELECT OrderApi__Balance_Due__c FROM OrderApi__Invoice__c WHERE OrderApi__Sales_Order__c = :so.Id];
            amount = inv.OrderApi__Balance_Due__c;
        }
        if (so.OrderApi__Total__c == 0) {
            showPayment = false;
        } else {
            showPayment = true;
        }
        if (so.OrderApi__Is_Posted__c && so.OrderApi__Is_Closed__c && so.OrderApi__Posting_Entity__c == 'Receipt') {
            errorMsg = 'Order has already been paid.';
            processed = true;
        }

        /** get contact **/
        currentContact = [SELECT Name, Preferred_Address__c, MailingAddress, OtherAddress FROM Contact WHERE Id = :so.OrderApi__Contact__c];

        /** get return url for after payment **/
        /** IN community --> retURL == fonteva receipt **/
        /** NOT IN community --> retURL == sales order **/
        if (joinId != null && joinId != '') {
            //inside join process
            Join_Process__mdt jp;
            if (!Test.isRunningTest()) {
                jp = [SELECT Redirect_URL__c, Cancel_URL__c FROM Join_Process__mdt WHERE Id = :joinId];
            } else {
                jp = joinProcess;
            }

            PaymentFormController.PayNowData pnd = PaymentFormController.getPayNowData(salesOrderId, joinId);
            System.debug('payNowData: ' + pnd);

            if (isCommunity()) {
                Site mySite = [select Id from Site where Name = 'AACR_Community'];
                SiteDetail mySiteDetail = [select SecureURL from SiteDetail where DurableId = :mySite.Id];
                retURL = mySiteDetail.SecureUrl + '/' + pnd.redirectURL;
            } else {
                retURL = ltngHostName + '/' + pnd.redirectURL;
            }
        } else {
            //not in join process
            if (isCommunity()) {
                Site mySite = [select Id from Site where Name = 'AACR_Community'];
                SiteDetail mySiteDetail = [select SecureURL from SiteDetail where DurableId = :mySite.Id];
                retURL = mySiteDetail.SecureUrl + '/orderapi__checkout?salesorder=' + so.Id;
            } else {
                if(so.OrderApi__Posting_Entity__c == 'Invoice'){
                    retURL = ltngHostName + '/' + inv.Id;
                } else {
                    retURL = ltngHostName + '/' + salesOrderId;
                }

            }
        }

    }


    /**
     * @purpose Is code being referenced internally or from community
     *
     * @return Boolean
     */
    public static boolean isCommunity() {
        Id siteId = Site.getSiteId(); // take a look at the apex class Site, you may find more useful method concerning site/community
        if (siteId != null) {
            return true;
        }
        return false;
    }

    /**
     * @purpose Calls stripe API to create initial payment intent or get already created one from sales order
     */
    public PageReference createPaymentIntent() {
        System.debug('createPaymentIntent...');


        /** get billing known address && validate **/
        List<OrderApi__Known_Address__c> billingAddresses = [SELECT Id, OrderApi__Street__c, OrderApi__City__c, OrderApi__Province__c, OrderApi__Country__c, OrderApi__Postal_Code__c FROM OrderApi__Known_Address__c WHERE Type__c = 'Billing' AND OrderApi__Contact__c = :currentContact.Id];
        System.debug('billingAddress: ' + billingAddresses);
        if (requireAddress && billingAddresses.isEmpty()) {
            errorMsg = 'You must have a billing address';
            System.debug('billing address is empty');
            return null;
        } else {
            if (!billingAddresses.isEmpty()) {
                billingAddress = billingAddresses[0];
                billingAddress.OrderApi__Country__c = countryCodeMap.get(billingAddress.OrderApi__Country__c);
            }

            /** get sales order info **/
            String salesOrderId = ApexPages.currentPage().getParameters().get('salesOrder');
            OrderApi__Sales_Order__c so = [SELECT Id, Name, OrderApi__Posting_Entity__c, Payment_Intent_Id__c, OrderApi__Status__c, OrderApi__Total__c, OrderApi__Description__c FROM OrderApi__Sales_Order__c WHERE Id = :salesOrderId];
            if (isInvoice) {
                OrderApi__Invoice__c inv = [SELECT OrderApi__Balance_Due__c FROM OrderApi__Invoice__c WHERE OrderApi__Sales_Order__c = :so.Id];
                if(amount > inv.OrderApi__Balance_Due__c){
                    errorMsg = 'Payment Amount cannot be more than balance due.';
                    return null;
                }
            }

            /** check to make sure payment has not already been processed **/
            if (piSecret == null) {
                /** check if sales order already has payment intent **/
                if (so.Payment_Intent_Id__c == null) {
                    System.debug('no payment intent stored on sales order');
                    Http h = new Http();
                    HttpRequest req = new HttpRequest();
                    HttpResponse res = new HttpResponse();
                    req.setMethod('POST');
                    req.setHeader('Authorization', 'Bearer ' + getStripeSecretKey());
                    req.setHeader('Content-Type', 'application/x-www-form-urlencoded');
                    String endpoint = 'https://api.stripe.com/v1/payment_intents';
                    req.setEndpoint(endpoint);

                    String payload;
                    /** if invoice, amount is specified and is not equal to total **/
                    if (so.OrderApi__Posting_Entity__c == 'Invoice') {
                        payload = 'amount=' + EncodingUtil.urlEncode(String.valueOf(Integer.valueOf(amount * 100)), 'UTF-8');
                    } else {
                        payload = 'amount=' + EncodingUtil.urlEncode(String.valueOf(Integer.valueOf(so.OrderApi__Total__c * 100)), 'UTF-8');

                    }
                    payload += '&currency=' + EncodingUtil.urlEncode('usd', 'UTF-8') + '&metadata[salesOrder]=' + EncodingUtil.urlEncode(so.Name, 'UTF-8');
                    System.debug('payload: ' + payload);

                    req.setBody(payload);

                    res = h.send(req);
                    System.debug('response: ' + res);
                    Object jsonParse = (Object) JSON.deserializeUntyped(res.getBody());
                    Map<String, Object> mp_StrObj = (Map<string, Object>) jsonParse;
                    System.debug('objectMap: ' + mp_StrObj);
                    if (res.getStatusCode() == 200) {
                        /**set client secret for stripe elements**/
                        piSecret = String.valueOf(mp_StrObj.get('client_secret'));
                        pi = String.valueOf(mp_StrObj.get('id'));
//                        /**update sales order with payment intent id**/
//                        if(so.OrderApi__Posting_Entity__c == 'Receipt') {
//                            so.Payment_Intent_Id__c = String.valueOf(mp_StrObj.get('id'));
//                            update so;
//                        }
                    } else if (res.getStatusCode() == 402) {
                        Object errorCode = mp_StrObj.get('error');
                        System.debug('errorCode: ' + errorCode);
                        Map<String, Object> mp_errorObj = (Map<string, Object>) errorCode;
                        System.debug('mp_errorObj: ' + mp_errorObj);
                        errorMsg = String.valueOf(mp_errorObj.get('message'));
                    } else {
                        errorMsg = 'Unknown Error';
                        System.debug('unknown error');
                    }
                } else {
                    /** get payment intent from id on sales order to retrieve payment intent secret **/
                    System.debug('GET paymentIntent from sales order');

                    Http h = new Http();
                    HttpRequest req = new HttpRequest();
                    HttpResponse res = new HttpResponse();
                    req.setMethod('GET');
                    req.setHeader('Authorization', 'Bearer ' + getStripeSecretKey());
                    req.setHeader('Content-Type', 'application/x-www-form-urlencoded');
                    String endpoint = 'https://api.stripe.com/v1/payment_intents/' + so.Payment_Intent_Id__c;
                    req.setEndpoint(endpoint);

                    res = h.send(req);
                    System.debug('response: ' + res);
                    Object jsonParse = (Object) JSON.deserializeUntyped(res.getBody());
                    Map<String, Object> mp_StrObj = (Map<string, Object>) jsonParse;
                    if (res.getStatusCode() == 200) {
                        //set client secret for stripe elements
                        piSecret = String.valueOf(mp_StrObj.get('client_secret'));
                    } else if (res.getStatusCode() == 402) {
                        Object errorCode = mp_StrObj.get('error');
                        System.debug('errorCode: ' + errorCode);
                        Map<String, Object> mp_errorObj = (Map<string, Object>) errorCode;
                        errorMsg = String.valueOf(mp_errorObj.get('message'));
                    } else {
                        errorMsg = 'Unknown Error';
                        System.debug('unknown error');
                    }
                }
            }
        }
        System.debug('end of createPaymentIntent with piSecret: ' + piSecret + ' and errorMsg: ' + errorMsg);

        return null;
    }

    /**
     * @purpose Finalize payment in salesforce after success from stripe. Close & post sales order, create receipt and lines and post receipt
     */
    public void finalizePayment() {
        System.debug('finalizePayment...');
        /** get payment method id **/
        String pmID = null;
        pmID = Apexpages.currentPage().getParameters().get('pmID');
        System.debug('payment method id: ' + pmID);

        /** get sales order info **/
        OrderApi__Sales_Order__c so = [SELECT Id, OrderApi__Posting_Entity__c, OrderApi__Is_Invoiced__c, OrderApi__Source_Code__c, Name, OrderApi__Contact__c, Payment_Intent_Id__c, OrderApi__Status__c, OrderApi__Total__c, OrderApi__Description__c FROM OrderApi__Sales_Order__c WHERE Id = :salesOrderId];
        List<OrderApi__Sales_Order_Line__c> lines = [SELECT Id, OrderApi__Line_Description__c, OrderApi__GL_Account__c, OrderApi__Item__c, OrderApi__Sale_Price__c, OrderApi__Price_Override__c FROM OrderApi__Sales_Order_Line__c WHERE OrderApi__Sales_Order__c = :salesOrderId];

        /** get invoice info **/
        OrderApi__Invoice__c inv;
        if (so.OrderApi__Posting_Entity__c == 'Invoice') {
            inv = [SELECT Id, OrderApi__Amount_Paid__c, OrderApi__Amount_Refunded__c FROM OrderApi__Invoice__c WHERE OrderApi__Sales_Order__c = :so.Id];
            inv.OrderApi__Amount_Paid__c += amount;
            inv.OrderApi__Amount_Refunded__c = inv.OrderApi__Amount_Refunded__c;
        }

        /** close & post sales order **/
        so.OrderApi__Status__c = 'Closed';
        so.OrderApi__Posting_Status__c = 'Posted';

        /** get billing address **/
        List<OrderApi__Known_Address__c> kas = [SELECT Id, OrderApi__Contact__r.Name, OrderApi__Street__c, OrderApi__City__c, OrderApi__Province__c, OrderApi__Country__c, OrderApi__Postal_Code__c FROM OrderApi__Known_Address__c WHERE Type__c = 'Billing' AND OrderApi__Contact__c = :so.OrderApi__Contact__c];

        /** create ePayment - only needed for credit card info on fonteva receipt **/
        OrderApi__EPayment__c ePay = new OrderApi__EPayment__c();
        if (pmID != null && pmID != '') {
            ePaymentDTO paymentInfo = getPaymentMethod(pmID);
            if (paymentInfo.errorMsg == null) {
                ePay.OrderApi__Contact__c = so.OrderApi__Contact__c;
                ePay.OrderApi__Sales_Order__c = so.Id;
                if (so.OrderApi__Posting_Entity__c == 'Invoice') {
                    ePay.OrderApi__Total__c = amount;
                } else {
                    ePay.OrderApi__Total__c = so.OrderApi__Total__c;
                }
                ePay.OrderApi__Source_Code__c = so.OrderApi__Source_Code__c;
                ePay.OrderApi__Entity__c = 'Contact';
                ePay.OrderApi__Payment_Method_Type__c = 'credit_card';
                ePay.OrderApi__Card_Type__c = paymentInfo.brand;
                ePay.OrderApi__Card_Number__c = 'XXXX-XXXX-XXXX-' + paymentInfo.last4;
                ePay.OrderApi__Number__c = 'XXXX-XXXX-XXXX-' + paymentInfo.last4;
                ePay.OrderApi__Last_4_Digits__c = paymentInfo.last4;
                ePay.OrderApi__Last_Four_Digits__c = paymentInfo.last4;
                insert ePay;
            } else {
                processed = false;
                return;
            }
        }

        /** do updates and create receipt **/
        try {

            update so;

            /** if total not equal to zero, create receipt - zero dollar receipts will automatically be created through fonteva **/
            if (SO.OrderApi__Total__c != 0) {
                OrderApi__Receipt__c rec = new OrderApi__Receipt__c();
                rec.OrderApi__Sales_Order__c = salesOrderId;
                rec.OrderApi__Contact__c = so.OrderApi__Contact__c;
                rec.OrderApi__Type__c = 'Payment';
                rec.OrderApi__Payment_Type__c = 'Credit Card';
                rec.OrderApi__Memo__c = 'Sales Order #' + so.Name;
                rec.OrderApi__Source_Code__c = so.OrderApi__Source_Code__c;
                rec.OrderApi__Calculate_Billing_Details__c = false;
                rec.Stripe_Payment_Intent_Id__c = pi;

                if (so.OrderApi__Posting_Entity__c == 'Invoice') {
                    rec.OrderApi__Total__c = amount;
                } else {
                    rec.OrderApi__Total__c = so.OrderApi__Total__c;
                }

                /** set billing address **/
                if (!kas.isEmpty()) {
                    rec.OrderApi__Billing_Street__c = kas[0].OrderApi__Street__c;
                    rec.OrderApi__Billing_City__c = kas[0].OrderApi__City__c;
                    rec.OrderApi__Billing_State__c = kas[0].OrderApi__Province__c;
                    rec.OrderApi__Billing_Country__c = kas[0].OrderApi__Country__c;
                    rec.OrderApi__Billing_Postal_Code__c = kas[0].OrderApi__Postal_Code__c;
                    rec.OrderApi__Billing_Contact__c = kas[0].OrderApi__Contact__r.Name;
                }

                /** set ePayment **/
                if (pmID != null) {
                    rec.OrderApi__EPayment__c = ePay.Id;
                }


                insert rec;

                List<OrderApi__Receipt_Line__c> recLines = new List<OrderApi__Receipt_Line__c>();
                for (OrderApi__Sales_Order_Line__c line : lines) {
                    OrderApi__Receipt_Line__c recLine = new OrderApi__Receipt_Line__c(
                            OrderApi__Receipt__c = rec.Id,
                            OrderApi__Line_Description__c = line.OrderApi__Line_Description__c,
                            OrderApi__GL_Account__c = line.OrderApi__GL_Account__c,
                            OrderApi__Item__c = line.OrderApi__Item__c,
                            OrderApi__Sale_Price__c = line.OrderApi__Sale_Price__c,
                            OrderApi__Price_Override__c = line.OrderApi__Price_Override__c
                    );
                    if (lines.size() == 1 && so.OrderApi__Posting_Entity__c == 'Invoice') {
                        recLine.OrderApi__Price_Override__c = true;
                        recLine.OrderApi__Sale_Price__c = amount;
                        recLine.OrderApi__Invoice__c = inv.Id;
                        recLine.OrderApi__Total__c = amount;
                    }
                    recLines.add(recLine);
                }

                insert recLines;

                /** needs to happen in separate step for fonteva **/
                rec.OrderApi__Is_Posted__c = true;
                update rec;

                /** update invoice with new paid amount **/
                if (so.OrderApi__Posting_Entity__c == 'Invoice') {
                    update inv;
                }

                /** delete last accessed step if in join process **/
                if (isCommunity() && joinId!=null) {
                    List<contact_last_accessed_step__c> las = [SELECT Id FROM contact_last_accessed_step__c WHERE Contact__c = :so.OrderApi__Contact__c AND JoinId__c = :joinId];
                    if (!las.isEmpty()) {
                        JP_Helper.deleteContactLastAccessedStep(joinId);
                    }
                }
            }

            processed = true;
        } catch (Exception e) {
            System.debug('Exception: ' + e.getMessage());
            new AACRCustomException(salesOrderId, e.getMessage(), e.getStackTraceString(), 'Payment');
        }

    }


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


    public static ePaymentDTO getPaymentMethod(String paymentMethodId) {
        ePaymentDTO ePayment = new ePaymentDTO();

        Http h = new Http();
        HttpRequest req = new HttpRequest();
        HttpResponse res = new HttpResponse();
        req.setMethod('GET');
        req.setHeader('Authorization', 'Bearer ' + getStripeSecretKey());
        req.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        String endpoint = 'https://api.stripe.com/v1/payment_methods/' + paymentMethodId;
        req.setEndpoint(endpoint);

        res = h.send(req);
        System.debug('response: ' + res);
        Object jsonParse = (Object) JSON.deserializeUntyped(res.getBody());
        System.debug('jsonParse: ' + jsonParse);
        Map<String, Object> mp_StrObj = (Map<string, Object>) jsonParse;
        if (res.getStatusCode() == 200) {
            Object card = mp_StrObj.get('card');
            Map<String, Object> mp_cardObj = (Map<string, Object>) card;
            ePayment.last4 = String.valueOf(mp_cardObj.get('last4'));
            ePayment.brand = String.valueOf(mp_cardObj.get('brand'));
            ePayment.exp_year = Decimal.valueOf(String.valueOf(mp_cardObj.get('exp_year')));
            ePayment.exp_month = Decimal.valueOf(String.valueOf(mp_cardObj.get('exp_month')));

        } else if (res.getStatusCode() == 402) {
            Object errorCode = mp_StrObj.get('error');
            System.debug('errorCode: ' + errorCode);
            Map<String, Object> mp_errorObj = (Map<string, Object>) errorCode;
            ePayment.errorMsg = String.valueOf(mp_errorObj.get('message'));
        } else {
            ePayment.errorMsg = 'Could not get payment method.';
        }

        System.debug('ePayment: ' + ePayment);
        return ePayment;
    }


    /**
     * @purpose Creates refund using Stripe API for specific payment intent
     * @param paymentIntentId
     * @param receiptId
     * @param amount
     *
     * @return StripeDTO API Response
     */
    public static StripeDTO createStripeRefund(String paymentIntentId, String receiptId, Decimal amount) {
        StripeDTO paymentResp = new StripeDTO();

        Http h = new Http();
        HttpRequest req = new HttpRequest();
        HttpResponse res = new HttpResponse();
        req.setMethod('POST');
        req.setHeader('Authorization', 'Bearer ' + getStripeSecretKey());
        req.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        String endpoint = 'https://api.stripe.com/v1/refunds';
        req.setEndpoint(endpoint);

        String payload = 'amount=' + EncodingUtil.urlEncode(String.valueOf(Integer.valueOf(amount * 100)), 'UTF-8')
                + '&payment_intent=' + EncodingUtil.urlEncode(paymentIntentId, 'UTF-8')
                + '&reason=' + EncodingUtil.urlEncode('requested_by_customer', 'UTF-8')
                + '&metadata[receiptId]=' + EncodingUtil.urlEncode(receiptId, 'UTF-8');


        System.debug('payload: ' + payload);
        req.setBody(payload);

        res = h.send(req);
        System.debug('response: ' + res);
        Object jsonParse = (Object) JSON.deserializeUntyped(res.getBody());
        Map<String, Object> mp_StrObj = (Map<string, Object>) jsonParse;
        if (res.getStatusCode() == 200) {
            String status = String.valueOf(mp_StrObj.get('status'));
            if (status == 'succeeded') {
                paymentResp.token = String.valueOf(mp_StrObj.get('id'));
                paymentResp.success = true;
            } else {
                paymentResp.success = false;
                paymentResp.errorMsg = String.valueOf(mp_StrObj.get('Refund could not be processed.'));
            }
        } else if (res.getStatusCode() == 402) {
            paymentResp.success = false;
            Object errorCode = mp_StrObj.get('error');
            System.debug('errorCode: ' + errorCode);
            Map<String, Object> mp_errorObj = (Map<string, Object>) errorCode;
            paymentResp.errorMsg = String.valueOf(mp_errorObj.get('message'));
        } else {
            paymentResp.success = false;
            paymentResp.errorMsg = 'Could not process refund.';
        }

        System.debug('paymentresp: ' + paymentResp);
        return paymentResp;
    }

    public static StripeDTO getStripeRefund(String refundId) {
        System.debug('getting stripe refund....');
        StripeDTO paymentResp = new StripeDTO();

        Http h = new Http();
        HttpRequest req = new HttpRequest();
        HttpResponse res = new HttpResponse();
        req.setMethod('GET');
        req.setHeader('Authorization', 'Bearer ' + getStripeSecretKey());
        req.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        String endpoint = 'https://api.stripe.com/v1/refunds/' + refundId;
        req.setEndpoint(endpoint);

        res = h.send(req);
        System.debug('response: ' + res);
        Object jsonParse = (Object) JSON.deserializeUntyped(res.getBody());
        System.debug('jsonParse: ' + jsonParse);
        Map<String, Object> mp_StrObj = (Map<string, Object>) jsonParse;
        if (res.getStatusCode() == 200) {
            String status = String.valueOf(mp_StrObj.get('status'));
            System.debug('status: ' + status);
            if (status == 'succeeded') {
                paymentResp.success = true;
            } else {
                paymentResp.success = false;
                paymentResp.errorMsg = String.valueOf(mp_StrObj.get('Refund could not be processed.'));
            }
        } else if (res.getStatusCode() == 402) {
            paymentResp.success = false;
            Object errorCode = mp_StrObj.get('error');
            System.debug('errorCode: ' + errorCode);
            Map<String, Object> mp_errorObj = (Map<string, Object>) errorCode;
            paymentResp.errorMsg = String.valueOf(mp_errorObj.get('message'));
        } else {
            paymentResp.success = false;
            paymentResp.errorMsg = 'Could not process refund.';
        }

        System.debug('paymentresp: ' + paymentResp);
        return paymentResp;
    }

    public class ePaymentDTO {
        @AuraEnabled
        public String last4;

        @AuraEnabled
        public String brand;

        @AuraEnabled
        public Decimal exp_year;

        @AuraEnabled
        public Decimal exp_month;

        @AuraEnabled
        public String errorMsg;
    }


    public class StripeDTO {
        @AuraEnabled
        public Boolean success;

        @AuraEnabled
        public String errorMsg;

        @AuraEnabled
        public String redirectURL;

        @AuraEnabled
        public String token;

    }


}