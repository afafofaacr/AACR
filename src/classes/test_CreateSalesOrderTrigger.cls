@isTest (seeAllData=true)
public class test_CreateSalesOrderTrigger {

     public static testMethod void testingSOCreationFromOpp(){
         Account acc = new Account();
         acc.Name = 'Test Opp';
         insert acc;
        Opportunity opp = new Opportunity();
        opp.Name = 'TestOpp';
        opp.CloseDate = Date.valueOf(System.now());
		opp.StageName = 'TestOpp';
        opp.AccountId = acc.Id;
        insert opp;
        //OpportunityLineItem oppLine = new OpportunityLineItem();
        //oppLine.OpportunityId = opp.Id;
        //oppLine.Quantity = 5;
        //oppLine.TotalPrice = 500.00;
        //insert oppLine;
    }
}