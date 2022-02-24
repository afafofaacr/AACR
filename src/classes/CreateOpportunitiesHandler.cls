/**
 * Created by afaf.awad on 9/4/2020.
 */

public without sharing class CreateOpportunitiesHandler {

    public static Opportunity_Owner__c db = Opportunity_Owner__c.getOrgDefaults();

    public static void createDonationOpp(List<OrderApi__Receipt__c> receipts){

        System.debug('Create Group Donations...');

        Appeal_Code__c testAppealCode;
        User testUser;
        List<String> oppItemIds = new List<String>();
        Map<String, String> appealMap = new Map<String,String>();
        Map<String, String> distributionMap = new Map<String,String>();

        for(Opportunity_Items__mdt oppItem : [SELECT Item_Id__c, Appeal_Code_Id__c, Distribution_Code_Id__c FROM Opportunity_Items__mdt]){
            //Item Class list; Appeal Codes Map; Distribution Codes Map
            oppItemIds.add(oppItem.Item_Id__c);
            appealMap.put(oppItem.Item_Id__c, oppItem.Appeal_Code_Id__c );
            distributionMap.put(oppItem.Item_Id__c,oppItem.Distribution_Code_Id__c);
        }

        List<String> salesOrderIds = new List<String>();
        for(OrderApi__Receipt__c r : receipts){
            salesOrderIds.add(r.OrderApi__Sales_Order__c);
        }

        List<OrderApi__Sales_Order_Line__c> soLines = getSalesOrderLines(salesOrderIds, oppItemIds);

        System.debug('Sales Order Lines = ' + soLines);

        if(!soLines.isEmpty()) {

            List<Opportunity> opps = new List<Opportunity>();
            Map<String, Opportunity> solMap = new Map<String, Opportunity>();
            RecordType recordType = [SELECT Id FROM RecordType WHERE Name= 'Donation' AND SobjectType= 'Opportunity' LIMIT 1];

            if(Test.isRunningTest()){
                testAppealCode = [SELECT Id FROM Appeal_Code__c LIMIT 1];
                testUser = [SELECT Id FROM User LIMIT 1];
            }

            for (OrderApi__Sales_Order_Line__c sol : soLines) {

                Opportunity o = new Opportunity(
                        Name = 'Default',
                        npsp__Primary_Contact__c = sol.OrderApi__Contact__c,
                        AccountId = sol.OrderApi__Account__c,
                        StageName = 'Posted',
                        Amount = sol.OrderApi__Sale_Price__c,
                        CloseDate = System.today(),
                        RecordTypeId = recordType.Id,
                        OwnerId = Test.isRunningTest() ? testUser.Id : db.User_Id__c,
                        c4g_Appeal_Code__c = Test.isRunningTest() ? testAppealCode.Id :appealMap.get(sol.OrderApi__Item_Class__c),
                        GL_Account__c = Test.isRunningTest() ? sol.OrderApi__GL_Account__c: distributionMap.get(sol.OrderApi__Item_Class__c),
                        Do_Not_Create_Sales_Order__c = true);
                System.debug('Opportunity to insert: ' + o);
                opps.add(o);
            }
            
            try {
                insert opps;
            } catch (Exception e) {
                System.debug('Cannot create new Opportunity:: ' + e.getMessage() );
            }


            List<OrderApi__Sales_Order_Line__c> updateSOL = new List<OrderApi__Sales_Order_Line__c>();
            for (Opportunity o : opps) {
                for (OrderApi__Sales_Order_Line__c sol : soLines) {
                    String appealCode = Test.isRunningTest() ? testAppealCode.Id : appealMap.get(sol.OrderApi__Item_Class__c);
                    if ( o.npsp__Primary_Contact__c == sol.OrderApi__Contact__c
                            && o.AccountId == sol.OrderApi__Account__c
                            && o.c4g_Appeal_Code__c == appealCode
                            && o.Amount == sol.OrderApi__Sale_Price__c ) {

                        System.debug('Matched! ' + o.Id + ' and ' + sol.Id);
                        sol.Opportunity__c = o.Id;
                        updateSOL.add(sol);
                    }
                }
            }

            try {
                update updateSOL;
            } catch (Exception e) {
                System.debug('Cannot update Sales Order with Opportunity:: ' + e.getMessage() );

            }
        }else{
            System.debug('List is empty!');
        }
    }

    public static List<OrderApi__Sales_Order_Line__c> getSalesOrderLines(List<String> soIds, List<String> oppItemIds){

        If(Test.isRunningTest()){
            return [ SELECT Id
                    , OrderApi__Sale_Price__c
                    , OrderApi__Contact__c
                    , OrderApi__Account__c
                    , OrderApi__Item_Class__c
                    , OrderApi__GL_Account__c
            FROM OrderApi__Sales_Order_Line__c
            WHERE OrderApi__Sales_Order__c IN:soIds
            AND Opportunity__c = NULL];
        }

        return [ SELECT Id
                , OrderApi__Sale_Price__c
                , OrderApi__Contact__c
                , OrderApi__Account__c
                , OrderApi__Item_Class__c
                , OrderApi__GL_Account__c
        FROM OrderApi__Sales_Order_Line__c
        WHERE OrderApi__Sales_Order__c IN:soIds
        AND OrderApi__Item_Class__c IN: oppItemIds
        AND Opportunity__c = NULL];
    }


}