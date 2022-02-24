/**
 * Created by lauren.lezberg on 8/28/2019.
 */
@isTest
private with sharing class BackOfficeOrderControllerTest {

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
        insert membershipItem;

        OrderApi__Sales_Order__c SO = TestDataFactory.buildOpenSalesOrder(acc.Id, con.Id );
        insert SO;
//
        OrderApi__Sales_Order_Line__c sol = TestDataFactory.buildSOLine(SO.Id, membershipItem.Id, membershipItemClass.Id);
        insert sol;

        OrderApi__Subscription_Plan__c subPlan1 = TestDataFactory.buildsubPlan();
        insert subPlan1;

        OrderApi__Item_Subscription_Plan__c memSubPlan = TestDataFactory.buildItemSubPlan(membershipItem.Id, subPlan1.Id);
        memSubPlan.OrderApi__Is_Default__c = true;
        insert memSubPlan;

        OrderApi__Item_Subscription_Plan__c bcjSubPlan = TestDataFactory.buildItemSubPlan(bloodCanceritem.Id, subPlan1.Id);
        insert bcjSubPlan;

        OrderApi__Subscription_Plan__c subPlan2 = TestDataFactory.buildsubPlan();
        subPlan2.Name='2YR Membership';
        subPlan2.OrderApi__Advanced_Calendar_Days__c = 365;
        subPlan2.Show_In_Portal__c = false;
        insert subPlan2;

        OrderApi__Item_Subscription_Plan__c memSubPlan2 = TestDataFactory.buildItemSubPlan(membershipItem.Id, subPlan2.Id);
        insert memSubPlan2;

        OrderApi__Item_Subscription_Plan__c bcjSubPlan2 = TestDataFactory.buildItemSubPlan(bloodCanceritem.Id, subPlan2.Id);
        insert bcjSubPlan2;

        Renewal_Settings__c renewalProcess = new Renewal_Settings__c(Is_Active__c = true, Term_Year__c = Datetime.now().year() + 1);
        insert renewalProcess;

    }


    @isTest
    public static void test_getBackOfficeData(){
        Contact con = [SELECT Id FROM Contact ORDER BY CreatedDate LIMIT 1];
        String salesOrderId = [SELECT Id FROM OrderApi__Sales_Order__c WHERE OrderApi__Contact__c =: con.Id].Id;

        OrderApi__Item__c memItem = [SELECT Id, OrderApi__Item_Class__c FROM OrderApi__Item__c WHERE Name='Active Membership'];
        OrderApi__Subscription_Plan__c subPlan = [SELECt Id FROM OrderApi__Subscription_Plan__c WHERE Show_In_Portal__c = true];
        OrderApi__Subscription__c sub = TestDataFactory.buildSubscription(con.Id, subPlan.Id ,memItem.Id, memItem.OrderApi__Item_Class__c);
        insert sub;

        Test.startTest();
        BackOfficeOrderController.BackOfficeOrderData BOData = BackOfficeOrderController.getBackOfficeData(salesOrderId, false);
        System.assertNotEquals(null, BOData);

        BOData = BackOfficeOrderController.getBackOfficeData(salesOrderId, true);
        System.assertNotEquals(null, BOData);
        Test.stopTest();

        System.assertNotEquals(null, BOData);
    }


    @isTest
    public static void test_addRemoveItem(){
        OrderApi__Item__c memItem = [SELECT Id, OrderApi__Item_Class__r.Name, OrderApi__Item_Class__c FROM OrderApi__Item__c WHERE Name='Active Membership'];

        Contact con = [SELECT Id FROM Contact ORDER BY CreatedDate LIMIT 1];
        String salesOrderId = [SELECT Id FROM OrderApi__Sales_Order__c WHERE OrderApi__Contact__c =: con.Id].Id;
        OrderApi__Subscription_Plan__c subPlan = [SELECT Id FROM OrderApi__Subscription_Plan__c WHERE Name='1YR Membership' LIMIT 1];

        Test.startTest();
        List<OrderApi__Sales_Order_Line__c> lines = BackOfficeOrderController.addSelectedItem(memItem.Id, subPlan.Id, true, salesOrderId);
        System.assertEquals(3, lines.size());
        for(OrderApi__Sales_Order_Line__c line: lines){
            if(line.OrderApi__Item__c == memItem.Id){
                line.OrderApi__Item_Class__c = memItem.OrderApi__Item_Class__c;
            }
        }
        update lines;

        lines = ECRMUtils.getAllSalesOrderLines(salesOrderId);
        System.assertEquals(3, lines.size());

        lines = BackOfficeOrderController.removeItem(memItem.Id, salesOrderId);
        System.assertEquals(0, lines.size());
        lines = ECRMUtils.getAllSalesOrderLines(salesOrderId);
        System.assertEquals(0, lines.size());

        lines = BackOfficeOrderController.addSelectedItem(memItem.Id, subPlan.Id, false, salesOrderId);
        System.assertEquals(2, lines.size());

        lines = ECRMUtils.getAllSalesOrderLines(salesOrderId);
        System.assertEquals(2, lines.size());
        Test.stopTest();
    }
    
    @isTest
    public static void test_changeTerm(){
        Contact con = [SELECT Id FROM Contact ORDER BY CreatedDate LIMIT 1];
        String salesOrderId = [SELECT Id FROM OrderApi__Sales_Order__c WHERE OrderApi__Contact__c =: con.Id].Id;
        OrderApi__Subscription_Plan__c subPlan = [SELECT Id FROM OrderApi__Subscription_Plan__c WHERE Show_In_Portal__c = false LIMIT 1];

        OrderApi__Item__c memItem = [SELECT Id FROM OrderApi__Item__c WHERE Name='Active Membership'];


        Test.startTest();
        List<OrderApi__Sales_Order_Line__c> lines = BackOfficeOrderController.addSelectedItem(memItem.Id, subPlan.Id, true, salesOrderId);
        System.assertEquals(3, lines.size());

        lines = BackOfficeOrderController.changeTerm(subPlan.Id, false, salesOrderId);
        System.assertEquals(3, lines.size());
        System.assertEquals(subPlan.Id, lines[0].OrderApi__Subscription_Plan__c);

        subPlan = [SELECT Id FROM OrderApi__Subscription_Plan__c WHERE Show_In_Portal__c = true LIMIT 1];
        lines = BackOfficeOrderController.changeTerm(subPlan.Id, false, salesOrderId);
        System.assertEquals(3, lines.size());
        System.assertEquals(subPlan.Id, lines[0].OrderApi__Subscription_Plan__c);

        lines = BackOfficeOrderController.changeTerm(subPlan.Id, true, salesOrderId);
        System.assertEquals(3, lines.size());
        System.assertEquals(subPlan.Id, lines[0].OrderApi__Subscription_Plan__c);

        Test.stopTest();
    }

}