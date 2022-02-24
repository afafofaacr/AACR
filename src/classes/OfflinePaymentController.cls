/**
 * Created by lauren.lezberg on 7/7/2021.
 */

public without sharing class OfflinePaymentController {

    public class OfflinePaymentInfo{
        @AuraEnabled
        public OrderApi__Sales_Order__c so;

        @AuraEnabled
        public Decimal balanceDue;

        @AuraEnabled
        public String defaultDepositAccount;

    }

    /**
     * @purpose Gets payment info including sales order
     * @param salesOrderId
     *
     * @return
     */
    @AuraEnabled
    public static OfflinePaymentInfo getPaymentInfo (String salesOrderId){
        OfflinePaymentInfo opi = new OfflinePaymentInfo();
        opi.so = [SELECT Id, OrderApi__Is_Invoiced__c, OrderApi__Status__c,OrderApi__Contact__c, OrderApi__Account__c, OrderApi__Payment_Terms__c,OrderApi__Total__c, OrderApi__Entity__c, OrderApi__Schedule_Type__c, OrderApi__Shipping_Country__c, OrderApi__Posting_Status__c, OrderApi__Posting_Entity__c, OrderApi__Business_Group__c FROM OrderApi__Sales_Order__c WHERE Id=: salesOrderId];
        List<OrderApi__Invoice__c> inv = [SELECT OrderApi__Balance_Due__c FROM OrderApi__Invoice__c WHERE OrderApi__Sales_Order__c = :opi.so.Id];
        if(!inv.isEmpty()) {
            opi.balanceDue = inv[0].OrderApi__Balance_Due__c;
        } else {
            opi.balanceDue = opi.so.OrderApi__Total__c;
        }
        OrderApi__Business_Group__c bg = [SELECT OrderApi__Deposit_Account__c FROM OrderApi__Business_Group__c WHERE Name='American Association for Cancer Research'];
        opi.defaultDepositAccount = bg.OrderApi__Deposit_Account__c;
        return opi;
    }

    @AuraEnabled
    public static void finishOfflinePayment(String receiptId, String salesOrderId, Decimal amount){
        System.debug('finishOfflinePayment with receipt: ' + receiptId + ' and salesOrder: ' + salesOrderId + ' with amount: ' + amount);
        /** close & post sales order **/
        OrderApi__Sales_Order__c so = [SELECT OrderApi__Is_Invoiced__c, OrderApi__Posting_Status__c, OrderApi__Status__c, OrderApi__Posting_Entity__c, OrderApi__Contact__c, OrderApi__Account__c FROM OrderApi__Sales_Order__c WHERE Id=: salesOrderId];
        so.OrderApi__Status__c = 'Closed';
        so.OrderApi__Posting_Status__c = 'Posted';

        update so;

        OrderApi__Invoice__c inv;
        if(amount!=null){
            List<OrderApi__Invoice__c> invs = [SELECT  Id, OrderApi__Amount_Paid__c, OrderApi__Amount_Refunded__c FROM OrderApi__Invoice__c WHERE OrderApi__Sales_Order__c = :so.Id];
            if(!invs.isEmpty()) {
                inv = invs[0];
                inv.OrderApi__Amount_Paid__c += amount;
                inv.OrderApi__Amount_Refunded__c = inv.OrderApi__Amount_Refunded__c;
            }
        }


        /** create receipt lines **/
        List<OrderApi__Sales_Order_Line__c> lines = [SELECT Id, OrderApi__Line_Description__c, OrderApi__GL_Account__c, OrderApi__Item__c, OrderApi__Sale_Price__c, OrderApi__Price_Override__c FROM OrderApi__Sales_Order_Line__c WHERE OrderApi__Sales_Order__c = :salesOrderId];
        List<OrderApi__Receipt_Line__c> recLines = new List<OrderApi__Receipt_Line__c>();
        for (OrderApi__Sales_Order_Line__c line : lines) {
            OrderApi__Receipt_Line__c recLine = new OrderApi__Receipt_Line__c(
                    OrderApi__Receipt__c = receiptId,
                    OrderApi__GL_Account__c = line.OrderApi__GL_Account__c,
                    OrderApi__Item__c = line.OrderApi__Item__c,
                    OrderApi__Line_Description__c = line.OrderApi__Line_Description__c,
                    OrderApi__Sale_Price__c = line.OrderApi__Sale_Price__c,
                    OrderApi__Price_Override__c = line.OrderApi__Price_Override__c
            );
            if(lines.size()==1 && amount!=null && amount!=0.0){
                recLine.OrderApi__Price_Override__c = true;
                recLine.OrderApi__Sale_Price__c = amount;
                if(inv!=null) {
                    recLine.OrderApi__Invoice__c = inv.Id;
                }
                recLine.OrderApi__Total__c = amount;
            }
            recLines.add(recLine);
        }

        insert recLines;


        OrderApi__Receipt__c rec = [SELECT Id FROM OrderApi__Receipt__c WHERE Id=:receiptId];
        if(amount!=null && inv!=null){
            rec.OrderApi__Contact__c = so.OrderApi__Contact__c;
            rec.OrderApi__Account__c = so.OrderApi__Account__c;
            rec.OrderApi__Is_Posted__c = true;
            update rec;

            update inv;
        } else {
            rec.OrderApi__Is_Posted__c = true;
            update rec;
        }
    }
}