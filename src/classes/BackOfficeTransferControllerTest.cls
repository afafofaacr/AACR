/**
 * Created by lauren.lezberg on 11/19/2019.
 */
@isTest
private with sharing class BackOfficeTransferControllerTest {

    @testSetup
    public static void setup(){
        Account acc = TestDataFactory.buildAccount('TEST Account');
        insert acc;

        Contact con = TestDataFactory.buildContactMemberPrior(acc.Id);
        insert con;

        User u = TestDataFactory.buildUser(con.Id);
        insert u;


        OrderApi__Item_Class__c journalItemClass = TestDataFactory.buildItemClass('Journal Subscriptions');
        insert journalItemClass;

        OrderApi__Item__c bloodCanceritem = TestDataFactory.buildItem(journalItemClass.Id, 'Blood Cancer Discovery - Online');
        insert bloodCanceritem;

        OrderApi__Item_Class__c membershipItemClass = TestDataFactory.buildItemClass('Individual Memberships');
        insert membershipItemClass;

        OrderApi__Item__c membershipItem = TestDataFactory.buildItem(membershipItemClass.Id, 'Active Membership');
        membershipItem.Managed__c = true;
        insert membershipItem;

        OrderApi__Subscription_Plan__c subPlan1 = TestDataFactory.buildsubPlan();
        insert subPlan1;

        OrderApi__Item_Subscription_Plan__c mItemSubPlan1 = new OrderApi__Item_Subscription_Plan__c(OrderApi__Is_Default__c=true, OrderApi__Item__c=membershipItem.Id, OrderApi__Subscription_Plan__c=subPlan1.Id);
        insert mItemSubPlan1;

        OrderApi__Item_Subscription_Plan__c jItemSubPlan1 = new OrderApi__Item_Subscription_Plan__c(OrderApi__Is_Default__c=true, OrderApi__Item__c=bloodCanceritem.Id, OrderApi__Subscription_Plan__c=subPlan1.Id);
        insert jItemSubPlan1;

        OrderApi__Subscription_Plan__c subPlan2 = TestDataFactory.buildsubPlan();
        subPlan2.Name='2YR Membership';
        subPlan2.OrderApi__Advanced_Calendar_Days__c = 365;
        subPlan2.Show_In_Portal__c = false;
        insert subPlan2;

        OrderApi__Item_Subscription_Plan__c mItemSubPlan2 = new OrderApi__Item_Subscription_Plan__c(OrderApi__Item__c=membershipItem.Id, OrderApi__Subscription_Plan__c=subPlan2.Id);
        insert mItemSubPlan2;

        OrderApi__Item_Subscription_Plan__c jItemSubPlan2 = new OrderApi__Item_Subscription_Plan__c(OrderApi__Item__c=bloodCanceritem.Id, OrderApi__Subscription_Plan__c=subPlan2.Id);
        insert jItemSubPlan2;

        OrderApi__Subscription__c memSub = TestDataFactory.buildSubscription(con.Id, subPlan1.Id, membershipItem.Id, membershipItemClass.Id);
        insert memSub;

        OrderApi__Sales_Order__c SO = TestDataFactory.buildOpenSalesOrder(acc.Id, con.Id );
        insert SO;
//
//        OrderApi__Sales_Order_Line__c sol = TestDataFactory.buildSOLine(SO.Id, membershipItem.Id, membershipItemClass.Id);
//        insert sol;

        Renewal_Settings__c renewalProcess = new Renewal_Settings__c(Is_Active__c = true, Term_Year__c = Datetime.now().year() + 1);
        insert renewalProcess;

    }

    @isTest
    public static void test_cancelOldSubscriptionsAndGetSOLines(){
        Contact con = [SELECT Id FROM Contact ORDER BY CreatedDate LIMIT 1];
        String salesOrderId = [SELECT Id FROM OrderApi__Sales_Order__c WHERE OrderApi__Contact__c =: con.Id].Id;

        OrderApi__Subscription__c sub = [SELECT Id, OrderApi__Is_Active__c FROM OrderApi__Subscription__c WHERE OrderApi__Contact__c =: con.Id];
        System.assertEquals(true, sub.OrderApi__Is_Active__c);

        Test.startTest();
        BackOfficeTransferController.TransferInfo tInfo = BackOfficeTransferController.cancelOldSubscriptionsAndGetSOLines(salesOrderId);
        System.assertNotEquals(null, tInfo);

        sub = [SELECT Id, OrderApi__Is_Cancelled__c FROM OrderApi__Subscription__c WHERE Id=: sub.Id];
        System.assertEquals(true, sub.OrderApi__Is_Cancelled__c);

        Integer soLineCount = [SELECT COUNT() FROM OrderApi__Sales_Order_Line__c WHERE OrderApi__Sales_Order__c=: salesOrderId];
        System.assertEquals(0, soLineCount);

        Test.stopTest();


    }
}