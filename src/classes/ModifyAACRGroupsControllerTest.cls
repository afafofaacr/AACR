/**
 * Created by lauren.lezberg on 5/24/2021.
 */

@IsTest
private class ModifyAACRGroupsControllerTest {
    @testSetup
    public static void setup(){
        Account acc = TestDataFactory.buildAccount('Test Account');
        insert acc;

        Contact con = TestDataFactory.buildContact(acc.Id);
        insert con;

        User u = TestDataFactory.buildUser(con.Id);
        insert u;

        OrderApi__Subscription_Plan__c subPlan1 = TestDataFactory.buildsubPlan();
        insert subPlan1;


        OrderApi__Subscription_Plan__c subPlan2 = TestDataFactory.buildsubPlan();
        subPlan2.Name = '2YR Membership';
        subPlan2.Show_In_Portal__c = false;
        subPlan2.OrderApi__Advanced_Calendar_Days__c = 365;
        insert subPlan2;

        OrderApi__Item_Class__c membershipClass = TestDataFactory.buildItemClass('Individual Memberships');
        insert membershipClass;

        OrderApi__Item__c membership = TestDataFactory.buildItem(membershipClass.Id, 'Active Membership');
        membership.Managed__c = true;
        insert membership;

        OrderApi__Item_Class__c wgClass = TestDataFactory.buildItemClass('Working Groups');
        insert wgClass;

        OrderApi__Item__c wg1 = TestDataFactory.buildItem(wgClass.Id, 'Group 1');
        insert wg1;

        OrderApi__Item__c wg2 = TestDataFactory.buildItem(wgClass.Id, 'Group 2');
        insert wg2;

        OrderApi__Item_Subscription_Plan__c memSubPlan = TestDataFactory.buildItemSubPlan(membership.Id, subPlan1.Id);
        memSubPlan.OrderApi__Is_Default__c = true;
        insert memSubPlan;

        OrderApi__Item_Subscription_Plan__c wg1SubPlan = TestDataFactory.buildItemSubPlan(wg1.Id, subPlan1.Id);
        wg1SubPlan.OrderApi__Is_Default__c = true;
        insert wg1SubPlan;

        OrderApi__Item_Subscription_Plan__c wg2SubPlan = TestDataFactory.buildItemSubPlan(wg2.Id, subPlan1.Id);
        wg2SubPlan.OrderApi__Is_Default__c = true;
        insert wg2SubPlan;

        OrderApi__Item_Subscription_Plan__c memSubPlan2 = TestDataFactory.buildItemSubPlan(membership.Id, subPlan2.Id);
        insert memSubPlan2;

        OrderApi__Item_Subscription_Plan__c wg1SubPlan2 = TestDataFactory.buildItemSubPlan(wg1.Id, subPlan2.Id);
        insert wg1SubPlan2;

        OrderApi__Item_Subscription_Plan__c wg2SubPlan2 = TestDataFactory.buildItemSubPlan(wg2.Id, subPlan2.Id);
        insert wg2SubPlan2;



        OrderApi__Subscription__c membershipSub = TestDataFactory.buildSubscription(con.Id, subPlan1.Id, membership.Id, membershipClass.Id);
        membershipSub.OrderApi__Status__c = 'Active';
        insert membershipSub;

        OrderApi__Subscription__c wg1Sub = TestDataFactory.buildSubscription(con.Id, subPlan1.Id, wg1.Id, wgClass.Id);
        wg1Sub.OrderApi__Status__c = 'Active';
        insert wg1Sub;

        OrderApi__Subscription__c wg2Sub = TestDataFactory.buildSubscription(con.Id, subPlan1.Id, wg2.Id, wgClass.Id);
        wg2Sub.OrderApi__Status__c = 'Active';
        insert wg2Sub;

    }

    @IsTest
    static void test_buildGroupSO() {
        Contact con = [SELECT Id FROM Contact WHERE Account.Name='Test Account'];
        User u = [SELECT Id FROM User WHERE ContactId=:con.Id];

        System.runAs(u) {
            Test.startTest();

            String soId = ModifyAACRGroupsController.buildAACRGroupsSO();
            System.assertNotEquals(null, soId);

            Test.stopTest();
        }

    }


    @IsTest
    static void test_completeSalesOrder() {
        Contact con = [SELECT Id FROM Contact WHERE Account.Name='Test Account'];
        User u = [SELECT Id FROM User WHERE ContactId=:con.Id];


        System.runAs(u) {
            Test.startTest();
            String soId = ModifyAACRGroupsController.buildAACRGroupsSO();
            List<OrderApi__Item__c> items = [SELECT Id FROM OrderApi__Item__c WHERE OrderApi__Item_Class__r.Name='Working Groups'];
            List<Id> itemIds = new List<Id>();
            for(OrderApi__Item__c i : items){
                itemIds.add(i.Id);
            }

            Boolean isSuccess = ModifyAACRGroupsController.completeAACRGroupsOrder(soId, itemIds);
            System.assertEquals(true, isSuccess);

            Test.stopTest();
        }

    }
}