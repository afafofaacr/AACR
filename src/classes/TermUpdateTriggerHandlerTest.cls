/**
 * Created by lauren.lezberg on 10/14/2019.
 */
@isTest
private with sharing class TermUpdateTriggerHandlerTest {

    @testSetup
    public static void setup(){
        Account acc = TestDataFactory.buildAccount('Test Account');
        insert acc;

        Contact con = TestDataFactory.buildContact(acc.Id);
        insert con;

        OrderApi__Item_Class__c membershipClass = TestDataFactory.buildItemClass('Individual Memberships');
        insert membershipClass;

        OrderApi__Item__c membership = TestDataFactory.buildItem(membershipClass.Id, 'Associate Membership');
        membership.OrderApi__Price__c = 0.0;
        insert membership;

        OrderApi__Subscription_Plan__c subPlan = TestDataFactory.buildsubPlan();
        insert subPlan;

        Integer currentYear = System.now().year();

        OrderApi__Subscription__c sub = TestDataFactory.buildSubscription(con.Id, subPlan.Id, membership.Id, membershipClass.Id);
        sub.OrderApi__Current_Term_Start_Date__c = Date.newInstance(currentYear - 1, 1, 1);
        sub.OrderApi__Current_Term_End_Date__c = Date.newInstance(currentYear + 1, 12, 31);
        insert sub;


        OrderApi__Sales_Order__c salesOrder = TestDataFactory.buildOpenSalesOrder(acc.Id, con.Id);
        salesOrder.Is2YR__c = true;
        insert salesOrder;

        OrderApi__Subscription_Plan__c subPlan2 = TestDataFactory.buildsubPlan();
        subPlan2.OrderApi__Advanced_Calendar_Days__c = 365;
        subPlan2.Name = '2YR Membership';
        insert subPlan2;


        OrderApi__Sales_Order_Line__c sol = TestDataFactory.buildSOLine(salesOrder.Id, membership.Id, membershipClass.Id);
        sol.OrderApi__Activation_Date__c = Date.newInstance(currentYear + 1, 1, 1);
        sol.OrderApi__Is_Renewal__c = true;
        sol.OrderApi__Subscription__c = sub.Id;
        sol.OrderApi__Subscription_Plan__c = subPlan2.Id;
        insert sol;

    }

    @isTest
    public static void test_termUpdateTrigger(){
        Contact con = [SELECT Id FROM Contact WHERE Account.Name = 'Test Account' LIMIT 1];
        OrderApi__Sales_Order__c SO = [SELECT Id FROM OrderApi__Sales_Order__c WHERE OrderApi__Contact__c=: con.Id];

        Integer currentYear = System.now().year();

        Test.startTest();
        SO.OrderApi__Status__c = 'Closed';
        SO.OrderApi__Posting_Status__c = 'Posted';
        update SO;

        OrderApi__Subscription__c sub = [SELECT Id, OrderApi__Current_Term_End_Date__c FROM OrderApi__Subscription__c WHERE OrderApi__Contact__c=:con.Id];
        OrderApi__Renewal__c term = new OrderApi__Renewal__c(OrderApi__Subscription__c=sub.Id);
        term.OrderApi__Term_Start_Date__c = Date.newInstance(currentYear + 1, 1, 1);
        term.OrderApi__Term_End_Date__c = Date.newInstance(currentYear + 1, 12, 31);
        term.OrderApi__Sales_Order__c = SO.Id;
        insert term;

        term = [SELECT OrderApi__Term_End_Date__c, OrderApi__Term_Start_Date__c FROM OrderApi__Renewal__c WHERE Id=: term.Id];

        System.assertEquals(Date.today(),term.OrderApi__Term_Start_Date__c);

        Test.stopTest();

    }
}