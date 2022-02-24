/**
 * Created by afaf.awad on 1/9/2019.
 */

@IsTest (seeAllData = true)
public class CreateSalesOrderTest {

    @IsTest public static void CreateClosedWonOpportunityTest() {

        Account acc = [Select Id from Account where Name = 'AACR Test Accounts' Limit 1];
        Contact cont = [Select Id from Contact where Accountid =:acc.id Limit 1];
        Id OppRecId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('DD Donations').getRecordTypeId();
        Appeal_Code__c appCode = [Select Id From Appeal_Code__c Limit 1];
        OrderApi__GL_Account__c GLCode = [Select Id From OrderApi__GL_Account__c where Distribution_Code__c=true LImit 1];

        Opportunity opptest = new Opportunity();
        opptest.Recordtypeid = OppRecId;
        opptest.Name = 'Test Opportunity';
        opptest.AccountId = acc.id;
        opptest.npsp__Primary_Contact__c = cont.id;
        opptest.CloseDate = date.today();
        opptest.stageName ='Closed Won';
        opptest.c4g_Appeal_Code__c = appCode.id;
        opptest.GL_Account__c = GLCode.id;
        opptest.Amount = 100;
        opptest.c4g_Payment_Method__c='CC';

        insert opptest;

        GLCode = [Select Id From OrderApi__GL_Account__c where Name = 'DIRECT_MAIL' LImit 1];
        opptest.GL_Account__c = GLCode.id;

        Update opptest;

        Opportunity opp = [SELECT Id, (SELECT Id FROM Sales_Orders__r) FROM Opportunity WHERE Id =: opptest.Id];

        System.assertEquals(1, opp.Sales_Orders__r.size());


    }

    @IsTest public static void CreatePledgedOpportunityTest() {

        Account acc = [Select Id from Account where Name = 'AACR Test Accounts' Limit 1];
        Contact cont = [Select Id from Contact where Accountid =:acc.id Limit 1];
        Id OppRecId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Pledge').getRecordTypeId();
        Appeal_Code__c appCode = [Select Id From Appeal_Code__c Limit 1];
        OrderApi__GL_Account__c GLCode = [Select Id From OrderApi__GL_Account__c where Distribution_Code__c=true LImit 1];

        Test.startTest();
        Opportunity opptest = new Opportunity();
        opptest.Recordtypeid = OppRecId;
        opptest.Name = 'Test Opportunity';
        opptest.AccountId = acc.id;
        opptest.npsp__Primary_Contact__c = cont.id;
        opptest.CloseDate = date.today();
        opptest.stageName ='Prospecting';
        opptest.c4g_Pledge_Type__c = 'Organization';
        opptest.c4g_Appeal_Code__c = appCode.id;
        opptest.GL_Account__c = GLCode.id;
        opptest.Amount = 1000;
        opptest.stageName = 'Pledged';

        insert opptest;

        Test.stopTest();

        Opportunity opp = [SELECT Id, (SELECT Id FROM Sales_Orders__r) FROM Opportunity WHERE Id =: opptest.Id];

        System.assertEquals(1, opp.Sales_Orders__r.size());

    }
}