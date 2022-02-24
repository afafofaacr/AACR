/**
 * Created by lauren.lezberg on 10/24/2019.
 */
@isTest
private with sharing class OrderEntryFormControllerTest {
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

        OrderApi__Item__c emeritusItem = TestDataFactory.buildItem(membershipItemClass.Id, 'Emeritus Membership');
        insert emeritusItem;


        OrderApi__Sales_Order__c SO = TestDataFactory.buildOpenSalesOrder(acc.Id, con.Id );
        insert SO;
//
//        OrderApi__Sales_Order_Line__c sol = TestDataFactory.buildSOLine(SO.Id, membershipItem.Id, membershipItemClass.Id);
//        insert sol;

        OrderApi__Subscription_Plan__c subPlan1 = TestDataFactory.buildsubPlan();
        insert subPlan1;

        OrderApi__Subscription_Plan__c subPlan2 = TestDataFactory.buildsubPlan();
        subPlan2.Name='2YR Membership';
        subPlan2.OrderApi__Advanced_Calendar_Days__c = 365;
        subPlan2.Show_In_Portal__c = false;
        insert subPlan2;

        OrderApi__Subscription_Plan__c subPlan3 = TestDataFactory.buildsubPlan();
        subPlan3.Name='Lifetime';
        subPlan3.OrderApi__Type__c = 'Lifetime';
        subPlan3.Show_In_Portal__c = false;
        insert subPlan3;

        Renewal_Settings__c renewalProcess = new Renewal_Settings__c(Is_Active__c = true, Term_Year__c = Datetime.now().year() + 1);
        insert renewalProcess;

    }



    @isTest
    public static void test_addRemoveItem(){
        OrderApi__Item__c memItem = [SELECT Id, OrderApi__Item_Class__r.Name, OrderApi__Item_Class__c FROM OrderApi__Item__c WHERE Name='Active Membership'];
        OrderApi__Item__c emeritusItem = [SELECT Id, OrderApi__Item_Class__r.Name, OrderApi__Item_Class__c FROM OrderApi__Item__c WHERE Name='Emeritus Membership'];

        Contact con = [SELECT Id FROM Contact ORDER BY CreatedDate LIMIT 1];
        String salesOrderId = [SELECT Id FROM OrderApi__Sales_Order__c WHERE OrderApi__Contact__c =: con.Id].Id;
        OrderApi__Subscription_Plan__c subPlan = [SELECT Id FROM OrderApi__Subscription_Plan__c WHERE Name='1YR Membership' LIMIT 1];
        OrderApi__Subscription_Plan__c subPlan2 = [SELECT Id FROM OrderApi__Subscription_Plan__c WHERE Name='Lifetime' LIMIT 1];

        Test.startTest();
        List<OrderApi__Sales_Order_Line__c> lines = OrderEntryFormController.addSelectedItem(memItem.Id, subPlan.Id, true, salesOrderId);
        System.assertEquals(2, lines.size());
        for(OrderApi__Sales_Order_Line__c line: lines){
            if(line.OrderApi__Item__c == memItem.Id){
                line.OrderApi__Item_Class__c = memItem.OrderApi__Item_Class__c;
            }
        }
        update lines;

        lines = ECRMUtils.getAllSalesOrderLines(salesOrderId);
        System.assertEquals(2, lines.size());

        //remove membership --> blood cancer will be removed
        lines = OrderEntryFormController.removeItem(memItem.Id, salesOrderId);
        System.assertEquals(0, lines.size());

        //add membership --> blood cancer will be added
        lines = OrderEntryFormController.addSelectedItem(memItem.Id, subPlan.Id, false, salesOrderId);
        System.assertEquals(2, lines.size());

        //remove membership --> blood cancer will be removed
        lines = OrderEntryFormController.removeItem(memItem.Id, salesOrderId);
        lines = ECRMUtils.getAllSalesOrderLines(salesOrderId);
        System.debug('lines: ' + lines);
        //add emeritus membership
        lines = OrderEntryFormController.addSelectedItem(emeritusItem.Id, null, false, salesOrderId);
        System.assertEquals(3, lines.size());
        Test.stopTest();
    }


}