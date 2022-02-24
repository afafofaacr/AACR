/**
 * Created by lauren.lezberg on 12/2/2020.
 */

public with sharing class RefundRequestController {


    @AuraEnabled
    public static List<OrderApi__Receipt_Line__c> getReceiptLines(String receiptId){
        return [SELECT Id, OrderApi__Invoice__c, OrderApi__Item__c, OrderApi__Item__r.Name, OrderApi__Sale_Price__c FROM OrderApi__Receipt_Line__c WHERE OrderApi__Receipt__c=:receiptId];
    }

    @AuraEnabled
    public static StripePaymentController.StripeDTO processPartialRefund(String receiptId, String recLinesJSON){
        System.debug('processPartialRefund was just called with receipt: ' + receiptId);

        /** get payment receipt & lines **/
        OrderApi__Receipt__c paymentReceipt = [SELECT Id, Stripe_Payment_Intent_Id__c, OrderApi__Payment_Gateway__c, OrderApi__Is_Refund__c, OrderApi__Payment_Type__c, OrderApi__Sales_Order__r.OrderApi__Posting_Entity__c, OrderApi__Sales_Order__r.Payment_Intent_Id__c, OrderApi__Total__c, OrderApi__Sales_Order__c, OrderApi__Contact__c FROM OrderApi__Receipt__c WHERE Id=: receiptId];
        List<OrderApi__Receipt_Line__c> lines = (List<OrderApi__Receipt_Line__c>)JSON.deserialize(recLinesJSON, List<OrderApi__Receipt_Line__c>.class);
        System.debug('lines: ' + lines);

        Decimal totalRefundAmnt = 0.0;

        //initialize refund response
        StripePaymentController.StripeDTO refundResponse = new StripePaymentController.StripeDTO();

        //check if order has already been refunded
        if(paymentReceipt.OrderApi__Is_Refund__c){
            refundResponse.success = false;
            refundResponse.errorMsg = 'This order has already been refunded.';
            return refundResponse;
        }

        //check to make sure order was processed through stripe
        if(paymentReceipt.Stripe_Payment_Intent_Id__c!=null && paymentReceipt.OrderApi__Payment_Gateway__c==null) {

            OrderApi__Receipt__c refundReceipt = new OrderApi__Receipt__c();
            List<OrderApi__Receipt_Line__c> recLines = new List<OrderApi__Receipt_Line__c>();

            for(OrderApi__Receipt_Line__c line: lines){
                if(line.OrderApi__Sale_Price__c!=0.0) {
                    totalRefundAmnt += line.OrderApi__Sale_Price__c;
                    recLines.add(new OrderApi__Receipt_Line__c(
                            OrderApi__Invoice__c = line.OrderApi__Invoice__c,
                            OrderApi__Item__c = line.OrderApi__Item__c,
                            OrderApi__Sale_Price__c = line.OrderApi__Sale_Price__c,
                            OrderApi__Price_Override__c = true
                    ));
                }
            }

            System.debug('totalRefundAmnt: ' + totalRefundAmnt);

            refundReceipt.OrderApi__Sales_Order__c = paymentReceipt.OrderApi__Sales_Order__c;
            refundReceipt.OrderApi__Contact__c = paymentReceipt.OrderApi__Contact__c;
            refundReceipt.OrderApi__Type__c = 'Refund';
            refundReceipt.OrderApi__Payment_Type__c = paymentReceipt.OrderApi__Payment_Type__c;
            refundReceipt.OrderApi__Is_Refund__c = true;
            refundReceipt.OrderApi__Total__c = totalRefundAmnt;
            refundReceipt.OrderApi__Calculate_Memo__c = true;
            refundReceipt.OrderApi__Entity__c = 'Contact';



            //call Stripe API
            refundResponse = StripePaymentController.createStripeRefund(paymentReceipt.Stripe_Payment_Intent_Id__c, paymentReceipt.Id, totalRefundAmnt);
            if(refundResponse.success ){
                /**Stripe Workaround: refunds happen asynchronously.
                 * "Note that because refund failures are asynchronous,
                 * the refund will appear to be successful at first
                 * and will only have the failed status on subsequent fetches."
                 * **/
                refundResponse = StripePaymentController.getStripeRefund(refundResponse.token);
            }

            //if successful, insert receipt & lines & post
            /** FONTEVA: we have to insert receipt first and then update to posted in order to automatically create transactions in Fonteva **/
            if (refundResponse.success) {

                OrderApi__Invoice__c inv;
                if(paymentReceipt.OrderApi__Sales_Order__r.OrderApi__Posting_Entity__c=='Invoice'){
                    inv = [SELECT Id, OrderApi__Amount_Paid__c, OrderApi__Amount_Refunded__c FROM OrderApi__Invoice__c WHERE OrderApi__Sales_Order__c=:paymentReceipt.OrderApi__Sales_Order__c];
                    System.debug('invoice: ' + inv);
                    inv.OrderApi__Amount_Refunded__c += totalRefundAmnt;
                    inv.OrderApi__Amount_Paid__c = inv.OrderApi__Amount_Paid__c;

                }

                Database.insert(refundReceipt);

                for(OrderApi__Receipt_Line__c line : recLines){
                    line.OrderApi__Receipt__c = refundReceipt.Id;
                }


                Database.insert(recLines);

                refundReceipt.OrderApi__Is_Posted__c = true;

                try {
                    update refundReceipt;

                    if(paymentReceipt.OrderApi__Sales_Order__r.OrderApi__Posting_Entity__c=='Invoice'){
                        update inv;
                    }

                    //redirect user to new refund receipt
                    refundResponse.redirectURL = '/' + refundReceipt.Id;
                } catch (Exception e) {
                    new AACRCustomException(receiptId, e.getMessage(), e.getStackTraceString(), 'Refund Request');
                }
            }
            //order was not processed through stripe
        } else {
            refundResponse.success = false;
            refundResponse.errorMsg = 'No stripe payment attached. Refund cannot be processed.';
        }


        return refundResponse;

    }



    /**
     * @purpose Creates fonteva refund receipt, processes refund using stripe API and then posts receipt to create associated transaction & lines
     *
     * @param receiptId
     *
     * @return StripeDTO api response
     */
    @AuraEnabled
    public static StripePaymentController.StripeDTO processRefund(String receiptId){
        System.debug('processRefund was just called with receipt: ' + receiptId);
        /** get receipt & lines **/
        OrderApi__Receipt__c paymentReceipt = [SELECT Id,Stripe_Payment_Intent_Id__c, OrderApi__Payment_Gateway__c, OrderApi__Is_Refund__c, OrderApi__Payment_Type__c, OrderApi__Sales_Order__r.OrderApi__Posting_Entity__c, OrderApi__Sales_Order__r.Payment_Intent_Id__c, OrderApi__Total__c, OrderApi__Sales_Order__c, OrderApi__Contact__c FROM OrderApi__Receipt__c WHERE Id=: receiptId];
        List<OrderApi__Receipt_Line__c> lines = [SELECT OrderApi__Invoice__c, OrderApi__Item__c, OrderApi__Sale_Price__c, OrderApi__Price_Override__c FROM OrderApi__Receipt_Line__c WHERE OrderApi__Receipt__c =: receiptId];

        Decimal refundAmount = paymentReceipt.OrderApi__Total__c;

        /** initialize refund response **/
        StripePaymentController.StripeDTO refundResponse = new StripePaymentController.StripeDTO();

        /** check if order has already been refunded **/
        if(paymentReceipt.OrderApi__Is_Refund__c){
            refundResponse.success = false;
            refundResponse.errorMsg = 'This order has already been refunded.';
            return refundResponse;
        }


        /** check to make sure order was processed through stripe **/
        if(paymentReceipt.Stripe_Payment_Intent_Id__c!=null && paymentReceipt.OrderApi__Payment_Gateway__c==null) {
            OrderApi__Receipt__c refundReceipt = new OrderApi__Receipt__c();
            refundReceipt.OrderApi__Sales_Order__c = paymentReceipt.OrderApi__Sales_Order__c;
            refundReceipt.OrderApi__Contact__c = paymentReceipt.OrderApi__Contact__c;
            refundReceipt.OrderApi__Type__c = 'Refund';
            refundReceipt.OrderApi__Payment_Type__c = paymentReceipt.OrderApi__Payment_Type__c;
            refundReceipt.OrderApi__Is_Refund__c = true;
            refundReceipt.OrderApi__Total__c = refundAmount;
            refundReceipt.OrderApi__Calculate_Memo__c = true;
            refundReceipt.OrderApi__Entity__c = 'Contact'; 



            /** process refund through stripe **/
            refundResponse = StripePaymentController.createStripeRefund(paymentReceipt.Stripe_Payment_Intent_Id__c, paymentReceipt.Id, refundAmount);
            if(refundResponse.success ){
                /**Stripe Workaround: refunds happen asynchronously.
                 * "Note that because refund failures are asynchronous,
                 * the refund will appear to be successful at first
                 * and will only have the failed status on subsequent fetches."
                 * **/
                refundResponse = StripePaymentController.getStripeRefund(refundResponse.token);
            }

            /** FONTEVA WORKAROUND: we have to insert receipt first and then update to posted in order to automatically create transactions in Fonteva **/
            if (refundResponse.success) {

                /** Update invoice if sales order is for an invoice **/
                OrderApi__Invoice__c inv;
                if(paymentReceipt.OrderApi__Sales_Order__r.OrderApi__Posting_Entity__c=='Invoice'){
                    inv = [SELECT Id, OrderApi__Amount_Paid__c, OrderApi__Amount_Refunded__c FROM OrderApi__Invoice__c WHERE OrderApi__Sales_Order__c=:paymentReceipt.OrderApi__Sales_Order__c];
                    System.debug('invoice: ' + inv);
                    inv.OrderApi__Amount_Refunded__c += refundAmount;
                    inv.OrderApi__Amount_Paid__c = inv.OrderApi__Amount_Paid__c;

                }

                /** insert refund receipt **/
                Database.insert(refundReceipt);


                /** create receipt lines **/
                List<OrderApi__Receipt_Line__c> recLines = new List<OrderApi__Receipt_Line__c>();
                for(OrderApi__Receipt_Line__c line: lines){
                    recLines.add(new OrderApi__Receipt_Line__c(
                            OrderApi__Receipt__c = refundReceipt.Id,
                            OrderApi__Invoice__c = line.OrderApi__Invoice__c,
                            OrderApi__Item__c = line.OrderApi__Item__c,
                            OrderApi__Sale_Price__c = line.OrderApi__Sale_Price__c,
                            OrderApi__Price_Override__c = line.OrderApi__Price_Override__c
                    ));
                }
                insert recLines;

                /** update receipt to posted --> see fonteva workaround above **/
                refundReceipt.OrderApi__Is_Posted__c = true;

                try {
                    /** update receipt **/
                    update refundReceipt;

                    /** update invoice if necessary **/
                    if(paymentReceipt.OrderApi__Sales_Order__r.OrderApi__Posting_Entity__c=='Invoice'){
                        update inv;
                    }
                    /** redirect user to new refund receipt **/
                    refundResponse.redirectURL = '/' + refundReceipt.Id;
                } catch (Exception e) {
                    new AACRCustomException(receiptId, e.getMessage(), e.getStackTraceString(), 'Refund Request');
                }
            }
        /** order was not processed through stripe **/
        } else {
            refundResponse.success = false;
            refundResponse.errorMsg = 'No stripe payment attached. Refund cannot be processed.';
        }

        return refundResponse;
    }

}