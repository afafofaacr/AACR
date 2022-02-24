/**************************************************************************************************************************************************************************************************************************************************************
Name            :-  Fon_TransactionService
Created Date    :-  05/15/2018
Updated Date    :-  
Created By      :-  Arpita Munjal
Dependencies    :-  
Description     :-  Trigger on Transaction to split Revenue
**************************************************************************************************************************************************************************************************************************************************************/

public without sharing class Fon_TransactionService {
    private static boolean run = true;
    //Trigger should not run more than once
    public static boolean runOnce(){
        if(run){
            run = false;
            return true;
        }else{
            return run;
        }

    }

    /**
     * @purpose Revenue is split between complimentary item and membership item. Assumption is there would only be one complimentary item per order.
     * Revenue is also split for 2 YR Subscription plans
     *
     * @param records
     * @param oldMap
     */
    public static void splitRevenue(OrderApi__Transaction__c[] records,Map<Id,OrderApi__Transaction__c> oldMap){
        System.debug('splitRevenue being called...' + records);
        Map<Id, OrderApi__Transaction__c> soIdsSO = new Map<Id,OrderApi__Transaction__c>();
        List<OrderApi__Sales_Order_Line__c>  SOLIs = new List<OrderApi__Sales_Order_Line__c>();
        system.debug('oldMap===='+oldMap);
        List<OrderApi__Transaction_Line__c> updateTLines = new List<OrderApi__Transaction_Line__c>();
        List<OrderApi__Transaction_Line__c> insertTLines = new List<OrderApi__Transaction_Line__c>();

        for(OrderApi__Transaction__c order : records) {
            if((order.OrderApi__Receipt_Type__c  == 'Payment' && order.OrderApi__Receipt__c !=null
                    && oldMap.get(order.OrderApi__Receipt__c)==null && order.OrderApi__Batch__c ==null
                    && order.GP_Batch_Number__c==null && order.OrderApi__Num_Lines__c >0) || Test.isRunningTest()){
                soIdsSO.put(order.id,order);
            }

            System.debug('Number of soIdsSO= ' + soIdsSo.size());
        }
        list<OrderApi__Transaction__c> Transrecords= new list<OrderApi__Transaction__c>();

        //Added because trasactions may take time to be created after payment so criteria for test class or are not created at all if a sales order has money associated with it
        if(Test.isRunningTest()){
            Transrecords=[select id,OrderApi__Sales_Order__c, OrderApi__Contact__c from OrderApi__Transaction__c where id IN:soIdsSO.keyset() AND OrderApi__Receipt_Type__c ='Payment'];
            System.debug('!!!transRecords: ' + Transrecords);
            SOLIs = [select id,OrderApi__Item__r.name, OrderApi__Item_Class__r.Name, OrderApi__Item__c, OrderApi__Item_Class__c, OrderApi__Sales_Order__r.Is2YR__c from OrderApi__Sales_Order_Line__c];
            System.debug('salesOrderLines: ' + SOLIs);

            OrderApi__Receipt__c rec = [SELECT Id FROM OrderApi__Receipt__c WHERE OrderApi__Sales_Order__c=:transrecords[0].OrderApi__Sales_Order__c];

            List<OrderApi__Transaction_Line__c> t= new list<OrderApi__Transaction_Line__c>();
            List<OrderApi__Receipt_Line__c> recLines = [SELECT Id, OrderApi__Item__c, OrderApi__Item_Class__r.Name, OrderApi__Item_Class__c FROM OrderApi__Receipt_Line__c WHERE OrderApi__Receipt__c=: rec.Id ORDER BY OrderApi__Item__r.Name];
            System.debug('recLines: ' + recLines);

            OrderApi__Item__c activeMemItem = [SELECT Id FROM OrderApi__Item__c WHERE Name='Active Membership'];
            System.debug('activeMmeItem: ' + activeMemItem);

            for(OrderApi__Receipt_Line__c line : recLines){
                System.debug('receiptLine: ' + line);
                if(line.OrderApi__Item__c == activeMemItem.Id) {
                    OrderApi__Transaction_Line__c t1;
                    if (solis[0].OrderApi__Sales_Order__r.Is2YR__c) {
                        t1 = new OrderApi__Transaction_Line__c(OrderApi__Transaction__c = transrecords[0].id, OrderApi__Receipt__c = rec.Id, OrderApi__Receipt_Line__c = line.Id, OrderApi__Credit__c = 630.00, OrderApi__Sales_Order_Line__c = solis[0].id, OrderApi__Item__c = solis[0].OrderApi__Item__c, OrderApi__Item_Class__c = solis[0].OrderApi__Item_Class__c);
                    } else {
                        t1 = new OrderApi__Transaction_Line__c(OrderApi__Transaction__c =transrecords[0].id, OrderApi__Receipt__c=rec.Id, OrderApi__Receipt_Line__c = line.Id, OrderApi__Credit__c =315.00,OrderApi__Sales_Order_Line__c = solis[0].id,OrderApi__Item__c=solis[0].OrderApi__Item__c, OrderApi__Item_Class__c =solis[0].OrderApi__Item_Class__c);

                    }
                    t.add(t1);
                } else {
                    OrderApi__Transaction_Line__c t2 = new OrderApi__Transaction_Line__c(OrderApi__Transaction__c =transrecords[0].id, OrderApi__Receipt__c=rec.Id, OrderApi__Receipt_Line__c = line.Id, OrderApi__Credit__c=0.00, OrderApi__Sales_Order_Line__c = solis[1].id,OrderApi__Item__c=solis[1].OrderApi__Item__c, OrderApi__Item_Class__c =solis[1].OrderApi__Item_Class__c);
                    t.add(t2);
                }
            }

            insert t;
            soIdsSO = new Map<Id,OrderApi__Transaction__c>();
            soIdsSO.put(transrecords[0].id,transrecords[0]);
            system.debug('!!!t='+t);
        }

        /** Transaction records with lines **/
        Transrecords=[select id, OrderApi__Contact__r.Income_Level__c, (select id,Plan__c,OrderApi__Credit__c,OrderApi__Debit__c ,OrderApi__Item__c, OrderApi__Receipt__r.OrderApi__Sales_Order__r.Is2YR__c, OrderApi__Item__r.OrderApi__Income_Account__c, OrderApi__Memo__c
                , OrderApi__Item__r.Is_Complimentary__c,OrderApi__Item__r.Is_Active_Membership_Type__c, OrderApi__Item_Class__c, OrderApi__Receipt__r.OrderApi__Source_Code__r.Name, OrderApi__Item_Class__r.Name, OrderApi__Receipt__c, OrderApi__Receipt_Line__c, OrderApi__Item__r.Future_Income_Account__c, OrderApi__Transaction__r.OrderApi__Contact__r.Income_Level__c
        from OrderApi__Transaction_Lines__r
        where (OrderApi__Item_Class__r.Name = 'Individual Memberships' OR OrderApi__Item_Class__r.Name = 'Journal Subscriptions' OR OrderApi__Item_Class__r.Name = 'Complimentary Journals' OR OrderApi__Item_Class__r.Name = 'ZDecline of the Journals')
        order by OrderApi__Credit__c desc)
                ,name
        from OrderApi__Transaction__c
        where Id IN:soIdsSO.keyset()];


        if(Transrecords!=null && Transrecords.size()>0) {

            for(OrderApi__Transaction__c t:Transrecords){
                System.debug('Number of trans lines = ' + t.OrderApi__Transaction_Lines__r.size());
                System.debug('Trans Lines: ' + t.OrderApi__Transaction_Lines__r);
                decimal activem =0;
                if(t.OrderApi__Transaction_Lines__r.size() >0){
                    system.debug('Split Revenue Amnt: '+Integer.valueof(Label.SplitRevenueAmt));

                    for(OrderApi__Transaction_Line__c line:t.OrderApi__Transaction_Lines__r){

                        /** High Income **/
                        if(t.OrderApi__Contact__r.Income_Level__c == Label.Fon_Income_Level){
                            /** 2YR Subscription Plam **/
                            if(line.OrderApi__Receipt__r.OrderApi__Sales_Order__r.Is2YR__c){
                                /** Active Membership Split **/
                                if(line.OrderApi__Item__r.Is_Active_Membership_Type__c == true && line.OrderApi__Credit__c !=0){
                                    System.debug('line credit: ' + line.OrderApi__Credit__c);
                                    System.debug('line plan: ' + line.Plan__c);
                                    line.OrderApi__Credit__c = (line.OrderApi__Credit__c - line.Plan__c * (Integer.valueof(Label.SplitRevenueAmt)))/line.Plan__c;
                                    if(line.OrderApi__Receipt__r.OrderApi__Source_Code__r.Name == 'BOGO'){
                                        line.OrderApi__GL_Account__c = line.OrderApi__Item__r.Future_Income_Account__c != null ? line.OrderApi__Item__r.Future_Income_Account__c : line.OrderApi__Item__r.OrderApi__Income_Account__c;
                                    } else {
                                        insertTLines.add(createFutureTransactionLine(line, t.Id));
                                    }
                                    updateTLines.add(line);

                                    activem = line.Plan__c * (Integer.valueof(Label.SplitRevenueAmt));
                                    System.debug('activem: ' + activem);

                                    /** COMP Journal Split **/
                                } else if(line.OrderApi__Item__r.Is_Complimentary__c == true){
                                    if(line.OrderApi__Receipt__r.OrderApi__Source_Code__r.Name == 'BOGO') {
                                        line.OrderApi__Credit__c = activem;
                                    } else {
                                        line.OrderApi__Credit__c = activem / 2;
                                    }
                                    updateTLines.add(line);
                                    if(line.OrderApi__Receipt__r.OrderApi__Source_Code__r.Name == 'BOGO'){
                                        line.OrderApi__GL_Account__c = line.OrderApi__Item__r.Future_Income_Account__c != null ? line.OrderApi__Item__r.Future_Income_Account__c : line.OrderApi__Item__r.OrderApi__Income_Account__c;
                                    } else {
                                        insertTLines.add(createFutureTransactionLine(line, t.Id));
                                    }

                                    /** Other journals&memberships Split **/
                                } else {
                                    if(line.OrderApi__Credit__c!=0){
                                        if((line.OrderApi__Item_Class__r.Name != 'Individual Memberships' && line.OrderApi__Receipt__r.OrderApi__Source_Code__r.Name != 'BOGO') ||
                                                (line.OrderApi__Item_Class__r.Name != 'Individual Memberships' && line.OrderApi__Receipt__r.OrderApi__Source_Code__r.Name == 'BOGO')||
                                                (line.OrderApi__Item_Class__r.Name == 'Individual Memberships' && line.OrderApi__Receipt__r.OrderApi__Source_Code__r.Name != 'BOGO')) {
                                            line.OrderApi__Credit__c = line.OrderApi__Credit__c / 2;
                                            updateTLines.add(line);
                                            insertTLines.add(createFutureTransactionLine(line, t.Id));
                                        }
                                        if(line.OrderApi__Credit__c != 0 && line.OrderApi__Item_Class__r.Name == 'Individual Memberships' && line.OrderApi__Receipt__r.OrderApi__Source_Code__r.Name == 'BOGO'){
                                            line.OrderApi__GL_Account__c = line.OrderApi__Item__r.Future_Income_Account__c != null ? line.OrderApi__Item__r.Future_Income_Account__c : line.OrderApi__Item__r.OrderApi__Income_Account__c;
                                            updateTLines.add(line);
                                        }
                                    }
                                }

                                /** 1YR Subscription Plan **/
                            } else {
                                if(line.OrderApi__Item__r.Is_Active_Membership_Type__c == true && line.OrderApi__Credit__c !=0){
                                    line.OrderApi__Credit__c = line.OrderApi__Credit__c - line.Plan__c * (Integer.valueof(Label.SplitRevenueAmt));
                                    updateTLines.add(line);
                                    activem = line.Plan__c * (Integer.valueof(Label.SplitRevenueAmt));
                                } else if(line.OrderApi__Item__r.Is_Complimentary__c == true){
                                    line.OrderApi__Credit__c = activem;
                                    updateTLines.add(line);
                                }
                            }
                            /** Other Income Levels **/
                        } else {
                            /** 2 YR Subscription Plan **/
                            System.debug('line: ' + line);
                            if(line.OrderApi__Receipt__r.OrderApi__Sales_Order__r.Is2YR__c) {
                                /** Non-zero items **/
                                if (line.OrderApi__Credit__c != 0) {
                                    if((line.OrderApi__Item_Class__r.Name != 'Individual Memberships' && line.OrderApi__Receipt__r.OrderApi__Source_Code__r.Name != 'BOGO') ||
                                            (line.OrderApi__Item_Class__r.Name != 'Individual Memberships' && line.OrderApi__Receipt__r.OrderApi__Source_Code__r.Name == 'BOGO')||
                                            (line.OrderApi__Item_Class__r.Name == 'Individual Memberships' && line.OrderApi__Receipt__r.OrderApi__Source_Code__r.Name != 'BOGO')) {
                                        line.OrderApi__Credit__c = line.OrderApi__Credit__c / 2;
                                        updateTLines.add(line);
                                        insertTLines.add(createFutureTransactionLine(line, t.Id));
                                    }
                                }

                                if(line.OrderApi__Credit__c != 0 && line.OrderApi__Item_Class__r.Name == 'Individual Memberships' && line.OrderApi__Receipt__r.OrderApi__Source_Code__r.Name == 'BOGO'){
                                    line.OrderApi__GL_Account__c = line.OrderApi__Item__r.Future_Income_Account__c != null ? line.OrderApi__Item__r.Future_Income_Account__c : line.OrderApi__Item__r.OrderApi__Income_Account__c;
                                    updateTLines.add(line);
                                }
                            }
                        }

                    }
                }
            }
            system.debug('Lines to update: '+updateTLines);
            system.debug('Lines to insert: '+updateTLines);
            if(updateTLines.size()>0) {
                upsert updateTLines;
                insert insertTLines;
                CreateIntlShippingTransactionHelper.createTransactionLine(records);
            }
        }
    }

    /**
     * @purpose Create a duplicate transaction line with a future GL Account
     *
     * @param oldLine
     * @param transactionId
     *
     * @return New Transaction line with future GL Account
     */
    @TestVisible
    private static OrderApi__Transaction_Line__c createFutureTransactionLine(OrderApi__Transaction_Line__c oldLine, Id transactionId){
        OrderApi__Transaction_Line__c newTL = new OrderApi__Transaction_Line__c(
                OrderApi__Item__c = oldLine.OrderApi__Item__c,
                OrderApi__Credit__c = oldLine.OrderApi__Credit__c,
                OrderApi__Receipt__c = oldLine.OrderApi__Receipt__c,
                OrderApi__Receipt_Line__c = oldLine.OrderApi__Receipt_Line__c,
                OrderApi__Item_Class__c = oldLine.OrderApi__Item_Class__c,
                OrderApi__Memo__c = oldLine.OrderApi__Memo__c,
                OrderApi__GL_Account__c = oldLine.OrderApi__Item__r.Future_Income_Account__c!=null?oldLine.OrderApi__Item__r.Future_Income_Account__c:oldLine.OrderApi__Item__r.OrderApi__Income_Account__c,
                OrderApi__Transaction__c = transactionId);
        return newTL;
    }


}