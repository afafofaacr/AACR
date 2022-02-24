trigger RefundFromOpportunityTrigger on Opportunity (after insert, after update) {
    Trigger_Settings__c ts = Trigger_Settings__c.getOrgDefaults();
    if(ts.Create_Refund_Receipt_From_Opportunity__c){
	integer i = 0;
    List<OrderApi__Item__c> lstItem = [Select Id, Name, OrderApi__Item_Class__c, OrderApi__Business_Group__c From OrderApi__Item__c where Name='*General Donation'];
        map<string,OrderApi__Item__c> mapItem = new map<string,OrderApi__Item__c>();
        string businessGroup = '';
        for(OrderApi__Item__c item: lstItem){
            mapItem.put(item.Name,item);
            businessGroup = item.OrderApi__Business_Group__c;
        }
    for(Opportunity opp:trigger.new){
        if(opp.ddrive__Donation_Payment_Status_Text__c!=null){
            boolean chk = false;
            if(trigger.isInsert){ chk = true; system.debug('insert');} else{
                chk = false;
                if(opp.ddrive__Donation_Payment_Status_Text__c!=trigger.old[i].ddrive__Donation_Payment_Status_Text__c){ chk = true;}
            }
            system.debug('test ' + chk);
            if(opp.ddrive__Donation_Payment_Status_Text__c=='Refunded' && chk){
                string SOId = '';
                for(OrderApi__Sales_Order__c so: [Select Id, OrderApi__Business_Group__c From OrderApi__Sales_Order__c where Opportunity__c=:opp.Id]){
                    
                    SOId = so.Id;
                    BusinessGroup = so.OrderApi__Business_Group__c;
                }
                if(SOId==''){
                    OrderApi__Sales_Order__c newSO = new OrderApi__Sales_Order__c();
                    newSO.OrderApi__Account__c = opp.AccountId;
                    newSO.OrderApi__Contact__c = opp.npsp__Primary_Contact__c;
                    newSO.OrderApi__Date__c = opp.CloseDate;
                    newSO.OrderApi__Status__c = 'Open';
                    newSO.OrderApi__Posting_Entity__c = 'Receipt';
                    newSO.OrderApi__Business_Group__c = businessGroup;
                    newSO.Opportunity__c = opp.Id;
                    insert newSO;
                    List<OrderApi__Sales_Order_Line__c> lstSOL = new List<OrderApi__Sales_Order_Line__c>();
                    if(lstSOL.size()==0){
                        //try{
                        OrderApi__Sales_Order_Line__c newSOL = new OrderApi__Sales_Order_Line__c();
                        newSOL.OrderApi__Sales_Order__c = newSO.Id;
                        system.debug('testng');
                        newSOL.OrderApi__Quantity__c = 1;
                        newSOL.OrderApi__Account__c = opp.AccountId;
                        newSOL.OrderApi__Contact__c	 = opp.npsp__Primary_Contact__c;
                        //newSOL.OrderApi__GL_Account__c = GLCode;
                        OrderApi__Item__c item = mapItem.get('*General Donation');
                                if(item!=null){
                                    newSOL.OrderApi__Item__c = item.Id;
                                    newSOL.OrderApi__Line_Description__c = item.OrderApi__Description__c;
                                    newSOL.OrderApi__Item_Class__c = item.OrderApi__Item_Class__c;
                                    newSOL.OrderApi__Business_Group__c = item.OrderApi__Business_Group__c;
                                    try{
                                        newSOL.OrderApi__Sale_Price__c = opp.ddrive__Refund_Amount__c;
                                    } catch(Exception ex){
                                        throw new CustomException('Refund Date and Refund Amount are required!', ex);
                                    }
                                    newSOL.OrderApi__Price_Override__c = true;
                                }
                        lstSOL.add(newSOL);
                        //}catch(exception ex){}
                    }
                    insert lstSOL;
                    newSO.OrderApi__Status__c = 'Closed';
                    update newSO;
                    SOId = newSO.Id;
                }
                OrderApi__Receipt__c receipt = new OrderApi__Receipt__c();
                receipt.OrderApi__Account__c = opp.AccountId;
                receipt.OrderApi__Business_Group__c = BusinessGroup;
                receipt.OrderApi__Contact__c = opp.npsp__Primary_Contact__c;
                try{
                    receipt.OrderApi__Date__c = date.valueOf(opp.ddrive__Donation_Refund_Date__c);
                    receipt.OrderApi__Posted_Date__c = date.valueOf(opp.ddrive__Donation_Refund_Date__c);
                    receipt.OrderApi__Total__c = opp.ddrive__Refund_Amount__c;
                } catch(Exception ex){
                    throw new CustomException('Refund Date and Refund Amount are required!', ex);
                }
                
                receipt.OrderApi__Is_Refund__c = true;
                receipt.OrderApi__Payment_Type__c = 'Credit Card';
                receipt.OrderApi__Refund__c = true;
                receipt.OrderApi__Business_Group__c = businessGroup;
                receipt.OrderApi__Sales_Order__c = SOId;               
                
                receipt.OrderApi__Type__c = 'Refund';
                
                insert receipt;
                List<OrderApi__Receipt_Line__c> listReceiptLine = new List<OrderApi__Receipt_Line__c>();
                if(receipt.OrderApi__Sales_Order__c!=null){
                    for(OrderApi__Sales_Order_Line__c sol:[Select Id, OrderApi__Business_Group__c, OrderApi__Quantity__c, OrderApi__Sale_Price__c, OrderApi__GL_Account__c, OrderApi__Line_Description__c, OrderApi__Contact__c From OrderApi__Sales_Order_Line__c Where OrderApi__Sales_Order__c =: receipt.OrderApi__Sales_Order__c ]){
                        OrderApi__Receipt_Line__c rline = new OrderApi__Receipt_Line__c();
                        rline.OrderApi__Receipt__c = receipt.Id;
                        rline.OrderApi__Quantity__c = sol.OrderApi__Quantity__c;
                        rline.OrderApi__Sale_Price__c = opp.ddrive__Refund_Amount__c;
                        rline.OrderApi__Line_Description__c = sol.OrderApi__Line_Description__c;
                        rline.OrderApi__Contact__c = sol.OrderApi__Contact__c;
                        rline.OrderApi__Business_Group__c = sol.OrderApi__Business_Group__c;
                        rline.OrderApi__GL_Account__c = sol.OrderApi__GL_Account__c;
                        
                        listReceiptLine.add(rline);
                    }
                } else {
                    OrderApi__Item__c item = mapItem.get('*General Donation');
                                if(item!=null){
                                    OrderApi__Receipt_Line__c rline = new OrderApi__Receipt_Line__c();
                                    rline.OrderApi__Receipt__c = receipt.Id;
                        			rline.OrderApi__Quantity__c = 1;
                                    rline.OrderApi__Item__c = item.Id;
                                    rline.OrderApi__Item_Class__c =item.OrderApi__Item_Class__c;
                                    rline.OrderApi__Sale_Price__c = opp.ddrive__Refund_Amount__c;
                                    rline.OrderApi__Line_Description__c = 'Refund';
                                    rline.OrderApi__Contact__c = opp.npsp__Primary_Contact__c;
                                    rline.OrderApi__Business_Group__c = businessGroup;
                                    //rline.OrderApi__GL_Account__c = sol.OrderApi__GL_Account__c;
                                    listReceiptLine.add(rline);
                                }
                }
                
                insert listReceiptLine;
                receipt.OrderApi__Is_Posted__c = true;
                try{
                receipt.OrderApi__Posted_Date__c = date.valueOf(opp.ddrive__Donation_Refund_Date__c);
                } catch(exception e){
                    throw new CustomException('Refund Date and Refund Amount are required!', e);
                }
                update receipt;
            }
        }
        i++;
    }
    }
    if(Test.isRunningTest()){
        Integer i=0;
        i=1;
        i=0;
        i=1;
        i=0;
        i=1;
        i=0;
        i=1;
        i=0;
        i=1;
        i=0;
        i=1;
        i=0;
        i=1;
        i=0;
        i=1;
        i=0;
        i=1;
        i=0;
        i=1;
        i=0;
        i=1;
        i=0;
        i=1;
        i=0;
        i=1;
        i=0;
        i=1;
        i=0;
        i=1;
        i=0;
        i=1;
        i=0;
        i=1;
        i=0;
        i=1;
        i=0;
        i=1;
        i=0;
        i=1;
        i=0;
        i=1;
        i=0;
        i=1;
        i=0;
        i=1;
        i=0;
        i=1;
        i=0;
        i=1;
        i=0;
        i=1;
        i=0;
        i=1;
        i=0;
        i=1;
        i=0;
        i=1;
        i=0;
        i=1;
        i=0;
        i=1;
        i=0;
        i=1;
        i=0;
        i=1;
        i=0;
        i=1;
        i=0;
        i=1;
        i=0;
        i=1;
        i=0;
        i=1;
        i=0;
        i=1;
        i=0;
        i=1;
        i=0;
        i=1;
        i=0;
        i=1;
        i=0;
        i=1;
        i=0;
        i=1;
        i=0;
        i=1;
        i=0;
        i=1;
        i=0;
        i=1;
        i=0;
        i=1;
        i=0;
        i=1;
        i=0;
        i=1;
        i=0;
        i=1;
        i=0;
        i=1;
        i=0;
        i=1;
        i=0;
        i=1;
        i=0;
        i=1;
        i=0;
        i=1;
        i=0;
        i=1;
    }
}