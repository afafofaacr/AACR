//created By: Samip 
public class CreateIntlShippingTransactionHelper {

    public static void createTransactionLine(List<OrderApi__Transaction__c> transactions) {

        Set<Id> salesOrderIds = new Set<Id>();
        Set<Id> contactIds = new Set<Id>();

        for (OrderApi__Transaction__c transactionSummary : transactions) {
            salesOrderIds.add(transactionSummary.OrderApi__Sales_Order__c);
            contactIds.add(transactionSummary.OrderApi__Contact__c);
        }
        //getting the sales order line list from the inserted salesorder ids
        List<OrderApi__Sales_Order_Line__c> salesOrderLineList = [
                select id
                        ,OrderApi__Item_Class__r.Name
                        ,OrderApi__Item__r.Name
                        ,OrderApi__Item__r.Association_Journals_Type__c
                from OrderApi__Sales_Order_Line__c
                where OrderApi__Sales_Order__c IN:salesOrderIds
        ];

        //getting the contact map for matching country from the set of contact id which we get from the sales order
        Map<Id, Contact> contactMap = new Map<Id, Contact>([
                select id,MailingCountry, OtherCountry, Income_Level__c
                from Contact
                where Id IN:contactIds
        ]);

        //Creat Sales Order Line map in order to match the fields conditions
        Map<Id, OrderApi__Sales_Order_Line__c> salesOrderLineMap = new Map<Id, OrderApi__Sales_Order_Line__c>([
                select id
                        ,OrderApi__Item_Class__r.Name
                        ,OrderApi__Item__r.Association_Journals_Type__c
                        ,OrderApi__Sales_Order_Line__c
                        ,OrderApi__Item__r.International_Shipping_Item__c
                        ,OrderApi__Sales_Order__r.Is2YR__c
                        ,OrderApi__Activation_Date__c
                from OrderApi__Sales_Order_Line__c
                where OrderApi__Sales_Order__c IN:salesOrderIds
        ]);

        Map<Id, OrderApi__Sales_Order__c> salesOrderMap = new Map<Id, OrderApi__Sales_Order__c>([
                SELECT Id, OrderApi__Has_Subscription__c
                FROM OrderApi__Sales_Order__c
                WHERE Id IN:salesOrderIds
        ]);

        System.Debug('Map of Sales Order Lines: ' + salesOrderLineMap);

        //Create list of International Shipping Items (from 'Shipping Items' Item Class) to find the shipping cost per journal.
        List<OrderApi__Item__c> internationalShipping = [
                Select Id
                        ,Name
                        ,OrderApi__Item_Class__c
                        ,OrderApi__Income_Account__c
                        ,Future_Income_Account__c
                        ,OrderApi__Price__c
                        ,OrderApi__Business_Group__c
                FROM OrderApi__Item__c
                WHERE OrderApi__Item_Class__r.Name = 'Shipping Items'
        ];

        List<OrderApi__Transaction_Line__c> transLines =[SELECT Id, OrderApi__Item__r.Name, OrderApi__Transaction__c
                                                        FROM OrderApi__Transaction_Line__c
                                                        WHERE OrderApi__Transaction__c = :transactions
                                                        AND OrderApi__Item__r.Name LIKE 'International Shipping%'];

        if (transLines.isEmpty()) {
            //Create list to insert new transaction line(s)
            List<OrderApi__Transaction_Line__c> transactionLineItems = new List<OrderApi__Transaction_Line__c>();

            for (OrderApi__Transaction__c transactionSummary : transactions) {
                System.debug('Contact Map values:' + contactMap.values());
                System.debug('Contact Id from Transaction Summary: ' + transactionSummary.OrderApi__Contact__c);
                System.debug('sales order of transactionSummary = ' + transactionSummary.OrderApi__Sales_Order__c);
                System.debug('Has Subscription = ' + salesOrderMap.get(transactionSummary.OrderApi__Sales_Order__c).OrderApi__Has_Subscription__c);
                System.debug('Mailing Country = ' + contactMap.get(transactionSummary.OrderApi__Contact__c).MailingCountry);


                //check if the sales order has a subscription and Contact's mailing country is not equal to US
                if ( salesOrderMap.get(transactionSummary.OrderApi__Sales_Order__c).OrderApi__Has_Subscription__c
                        && contactMap.get(transactionSummary.OrderApi__Contact__c).MailingCountry != 'United States'
                        && contactMap.get(transactionSummary.OrderApi__Contact__c).MailingCountry != null
                        && contactMap.get(transactionSummary.OrderApi__Contact__c).Income_Level__c == Label.Fon_Income_Level) {

                    //iterating through the salesOrderLine list to match the conditions
                    for (OrderApi__Sales_Order_Line__c soLine : salesOrderLineList) {
                        System.debug('Sale Order Item Class is "' + salesOrderLineMap.get(soLine.id).OrderApi__Item_Class__r.Name
                                + '" and Association Journal Type is "'
                                + salesOrderLineMap.get(soLine.id).OrderApi__Item__r.Association_Journals_Type__c + '"');

                        //if the item class name equal to 'Complimentary Journals' and Association Journal Type is 'Print & Online'
                        if ( salesOrderLineMap.get(soLine.id).OrderApi__Item_Class__r.Name == 'Complimentary Journals'
                                && salesOrderLineMap.get(soLine.id).OrderApi__Item__r.Association_Journals_Type__c == 'Print & Online' ) {

                            //iterating through the International Shipping items to find the shipping item that matches the journal
                            for (OrderApi__Item__c journalName : internationalShipping) {

                                //if shipping item equals Journal name, then insert the fields into Transaction Line object
                                if ( salesOrderLineMap.get(soLine.id).OrderApi__Item__r.International_Shipping_Item__c == journalName.id ) {
                                    OrderApi__Transaction_Line__c transactionLineItem = new OrderApi__Transaction_Line__c();
                                    transactionLineItem.OrderApi__Transaction__c = transactionSummary.id;
                                    transactionLineItem.OrderApi__Credit__c = journalName.OrderApi__Price__c;
                                    System.debug(Date.today().year() + 1);
                                    System.debug(salesOrderLineMap.get(soLine.id));


                                    if(salesOrderLineMap.get(soLine.id).OrderApi__Activation_Date__c.year()==Date.today().year()+1 && !salesOrderLineMap.get(soLine.id).OrderApi__Sales_Order__r.Is2YR__c){
                                        transactionLineItem.OrderApi__GL_Account__c = journalName.Future_Income_Account__c;
                                    } else {
                                        transactionLineItem.OrderApi__GL_Account__c = journalName.OrderApi__Income_Account__c;
                                    }
                                    transactionLineItem.OrderApi__Memo__c = journalName.Name;
                                    transactionLineItem.OrderApi__Item__c = journalName.Id;
                                    transactionLineItem.OrderApi__Item_Class__c = journalName.OrderApi__Item_Class__c;
                                    transactionLineItem.OrderApi__Sales_Order_Line__c = soLine.id;
                                    transactionLineItem.OrderApi__Business_Group__c = journalName.OrderApi__Business_Group__c;
                                    transactionLineItems.add(transactionLineItem);

                                    //add future GL transaction line for 2 YR subscriptions
                                    if(salesOrderLineMap.get(soLine.id).OrderApi__Sales_Order__r.Is2YR__c){
                                        transactionLineItem = new OrderApi__Transaction_Line__c();
                                        transactionLineItem.OrderApi__Transaction__c = transactionSummary.id;
                                        transactionLineItem.OrderApi__Credit__c = journalName.OrderApi__Price__c;
                                        transactionLineItem.OrderApi__GL_Account__c = journalName.Future_Income_Account__c;
                                        transactionLineItem.OrderApi__Memo__c = journalName.Name;
                                        transactionLineItem.OrderApi__Item__c = journalName.Id;
                                        transactionLineItem.OrderApi__Item_Class__c = journalName.OrderApi__Item_Class__c;
                                        transactionLineItem.OrderApi__Sales_Order_Line__c = soLine.id;
                                        transactionLineItem.OrderApi__Business_Group__c = journalName.OrderApi__Business_Group__c;
                                        transactionLineItems.add(transactionLineItem);
                                    }

                                }


                            }
                        }
                    }
                }
            }

            System.Debug('Count of transactionLineItems = ' + transactionLineItems.size());

            try {
                //insert data if the list has size greater than 0
                if ( transactionLineItems.size() > 0 ) {
                    insert transactionLineItems;
                }
            } catch (Exception Ex) {
                System.debug('Exception ' + Ex.getMessage());
            }
        }
    }
   // }
}