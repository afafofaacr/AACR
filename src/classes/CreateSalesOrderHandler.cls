/**
 * Created by afaf.awad on 1/7/2019.
 */

public with sharing class CreateSalesOrderHandler {

    public static Boolean isFirstTime = true;

    public static void CreateSalesOrder(Opportunity opportunity) {

        System.debug('Starting SalesOrderHandler...');
        //Requery Opportunity Record to grab Lookup Values for GL and Appeal Code.
        Opportunity opp = [SELECT Id, AccountId, npsp__Primary_Contact__c, CloseDate, StageName, c4g_Pledge_Type__c, GL_Account__c,
                            Amount, c4g_Payment_Method__c, c4g_Check_Number__c,GL_Account__r.Distribution_GL_Mapping__c, c4g_Appeal_Code__c,
                            Do_Not_Create_Sales_Order__c,c4g_Appeal_Code__r.c4g_Description__c
                            FROM Opportunity WHERE Id =: opportunity.Id];

        List<OrderApi__Item__c> donationItem = [Select Id, Name, OrderApi__Item_Class__c, OrderApi__Description__c, OrderApi__Business_Group__c From OrderApi__Item__c WHERE Name = '*General Donation'];
        String businessGroup = donationItem[0].OrderApi__Business_Group__c;

        //Create New open Sales Order
        OrderApi__Sales_Order__c newSO = new OrderApi__Sales_Order__c();
        newSO.OrderApi__Account__c = opp.AccountId;
        newSO.OrderApi__Contact__c = opp.npsp__Primary_Contact__c;
        newSO.OrderApi__Date__c = opp.CloseDate;
        newSO.OrderApi__Status__c = 'Open';
        newSO.OrderApi__Business_Group__c = businessGroup;
        newSO.Opportunity__c = opp.Id;
        //Posting entity is receipt or invoice
        if ( opp.stageName == 'Closed Won' || opp.stageName == 'Awarded' || opp.stageName == 'Posted' ) {
            newSO.OrderApi__Posting_Entity__c = 'Receipt';
        } else if ( opp.stageName == 'Pledged' && opp.c4g_Pledge_Type__c == 'Organization' ) {
            newSO.OrderApi__Posting_Entity__c = 'Invoice';
        }

        try {
            insert newSO;
        } catch (Exception e) {
            System.debug('Cannot insert Sales Order:: ' + e.getMessage());
        }

//        Create Sales Order Line
        OrderApi__Sales_Order_Line__c newSOL = new OrderApi__Sales_Order_Line__c();
        newSOL.OrderApi__Sales_Order__c = newSO.Id;
        newSOL.OrderApi__Line_Description__c = opp.c4g_Appeal_Code__r.c4g_Description__c;
        newSOL.OrderApi__Quantity__c = 1;
        newSOL.OrderApi__Sale_Price__c = opp.Amount;
        newSOL.OrderApi__Account__c = opp.AccountId;
        newSOL.OrderApi__Contact__c = opp.npsp__Primary_Contact__c;
        newSOL.OrderApi__GL_Account__c = opp.GL_Account__r.Distribution_GL_Mapping__c;
        newSOL.OrderApi__Item__c = donationItem[0].Id;
        newSOL.OrderApi__Item_Class__c = donationItem[0].OrderApi__Item_Class__c;
        newSOL.OrderApi__Business_Group__c = businessGroup;
        newSOL.OrderApi__Price_Override__c = true;
        newSOL.Opportunity__c = opp.Id;

        try {
            System.debug('SalesOrderLine: ' + newSOL);
            insert newSOL;
        } catch (Exception e) {
            System.debug('Cannot insert Sales Order Line:: ' + e.getMessage());
        }

        System.debug('SalesOrderLine AFTER insert: ' + newSOL);
        //Update SalesOrder to "Closed" after SalesOrderLines are Created
        newSO.OrderApi__Status__c = 'Closed';
        try {
            update newSO;
        } catch (Exception e) {
            System.debug('Cannot Close Sales Order:: ' + e.getMessage());
        }

        //Update SalesOrder to "Posted" for Pledged Stages to trigger creation of an invoice.
        if(opp.stageName=='Pledged') {
            newSO.OrderApi__Posting_Status__c ='Posted';
        }
        update newSO;

        System.debug('SalesOrderLine AFTER SO Update: ' + newSOL);


        //For closed Opportunities, create Receipt and ReceiptLines for closed SalesOrder
        if ( opp.stageName == 'Closed Won' || opp.stageName == 'Awarded' || opp.stageName == 'Posted' ) {

            //Create Receipt
            OrderApi__Receipt__c receipt = new OrderApi__Receipt__c();
            receipt.OrderApi__Account__c = opp.AccountId;
            receipt.OrderApi__Contact__c = opp.npsp__Primary_Contact__c;
            receipt.OrderApi__Date__c = opp.CloseDate;
            receipt.OrderApi__Sales_Order__c = newSO.Id;
            receipt.OrderApi__Business_Group__c = businessGroup;
            receipt.OrderApi__Total__c = newSO.OrderApi__Total__c;
            receipt.OrderApi__Type__c = 'Payment';
            receipt.Is_Contribution__c = true;
            if ( opp.c4g_Payment_Method__c == null || opp.c4g_Payment_Method__c == 'CC' ) {
                receipt.OrderApi__Payment_Type__c = 'Credit Card';
            }
            receipt.OrderApi__Payment_Type__c = opp.c4g_Payment_Method__c;
            if ( opp.c4g_Payment_Method__c == 'Check' ) {
                receipt.OrderApi__Reference_Number__c = opp.c4g_Check_Number__c;
            }
            if ( opp.c4g_Payment_Method__c == 'Wire' ) {
                receipt.OrderApi__Payment_Type__c = 'EFT';
            }
            insert receipt;

            //Create ReceiptLines
            OrderApi__Receipt_Line__c rline = new OrderApi__Receipt_Line__c();
            rline.OrderApi__Receipt__c = receipt.Id;
            rline.OrderApi__Quantity__c = newsol.OrderApi__Quantity__c;
            rline.OrderApi__Sale_Price__c = newsol.OrderApi__Sale_Price__c;
            rline.OrderApi__Line_Description__c = newsol.OrderApi__Line_Description__c;
            rline.OrderApi__Contact__c = newsol.OrderApi__Contact__c;
            rline.OrderApi__Business_Group__c = newsol.OrderApi__Business_Group__c;
            rline.OrderApi__Item__c = newsol.OrderApi__Item__c;
            rline.OrderApi__GL_Account__c = newsol.OrderApi__GL_Account__c;
            rline.OrderApi__Total__c = newsol.OrderApi__Quantity__c * newsol.OrderApi__Sale_Price__c;

            //Update Receipt to "Posted" after ReceiptLines are created
            insert rline;
            receipt.OrderApi__Is_Posted__c = true;
            receipt.OrderApi__Posted_Date__c = opp.CloseDate;
            receipt.OrderApi__Total__c = opp.Amount;
            update receipt;
        }

        //UPDATING OPPORTUNITY TO PREVENT RE-TRIGGER
        opp.Do_Not_Create_Sales_Order__c = true;
        try {
            update opp;
        }catch(Exception e){
            System.debug('Cannot update Opportunity after creation of Sales Order: ' + e.getMessage());
        }

    }
}