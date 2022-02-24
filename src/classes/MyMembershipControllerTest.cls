/**
 * Created by lauren.lezberg on 5/24/2021.
 */

@IsTest
private class MyMembershipControllerTest {
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

        //BUILD ITEM CLASSES
        OrderApi__Item_Class__c membershipClass = TestDataFactory.buildItemClass('Individual Memberships');
        insert membershipClass;

        OrderApi__Item_Class__c wgClass = TestDataFactory.buildItemClass('Working Groups');
        insert wgClass;

        OrderApi__Item_Class__c journalClass = TestDataFactory.buildItemClass('Journal Subscriptions');
        insert journalClass;


        //BUILD ITEMS
        OrderApi__Item__c membership = TestDataFactory.buildItem(membershipClass.Id, 'Active Membership');
        membership.Managed__c = true;
        insert membership;

        OrderApi__Item__c wg1 = TestDataFactory.buildItem(wgClass.Id, 'Group 1');
        insert wg1;

        OrderApi__Item__c wg2 = TestDataFactory.buildItem(wgClass.Id, 'Group 2');
        insert wg2;

        OrderApi__Item__c j1 = TestDataFactory.buildItem(journalClass.Id, 'Journal 1');
        insert j1;

        OrderApi__Item__c j2 = TestDataFactory.buildItem(journalClass.Id, 'Journal 2');
        insert j2;

        //BUILD ITEM SUBSCRIPTION PLANS
        OrderApi__Item_Subscription_Plan__c memSubPlan = TestDataFactory.buildItemSubPlan(membership.Id, subPlan1.Id);
        memSubPlan.OrderApi__Is_Default__c = true;
        insert memSubPlan;

        OrderApi__Item_Subscription_Plan__c wg1SubPlan = TestDataFactory.buildItemSubPlan(wg1.Id, subPlan1.Id);
        wg1SubPlan.OrderApi__Is_Default__c = true;
        insert wg1SubPlan;

        OrderApi__Item_Subscription_Plan__c wg2SubPlan = TestDataFactory.buildItemSubPlan(wg2.Id, subPlan1.Id);
        wg2SubPlan.OrderApi__Is_Default__c = true;
        insert wg2SubPlan;

        OrderApi__Item_Subscription_Plan__c j1SubPlan = TestDataFactory.buildItemSubPlan(j1.Id, subPlan1.Id);
        j1SubPlan.OrderApi__Is_Default__c = true;
        insert j1SubPlan;

        OrderApi__Item_Subscription_Plan__c j2SubPlan = TestDataFactory.buildItemSubPlan(j2.Id, subPlan1.Id);
        j2SubPlan.OrderApi__Is_Default__c = true;
        insert j2SubPlan;


        //BUILD SUBSCRIPTIONS
        OrderApi__Subscription__c membershipSub = TestDataFactory.buildSubscription(con.Id, subPlan1.Id, membership.Id, membershipClass.Id);
        membershipSub.OrderApi__Status__c = 'Active';
        insert membershipSub;

        OrderApi__Subscription__c wg1Sub = TestDataFactory.buildSubscription(con.Id, subPlan1.Id, wg1.Id, wgClass.Id);
        wg1Sub.OrderApi__Status__c = 'Active';
        insert wg1Sub;

        OrderApi__Subscription__c wg2Sub = TestDataFactory.buildSubscription(con.Id, subPlan1.Id, wg2.Id, wgClass.Id);
        wg2Sub.OrderApi__Status__c = 'Active';
        insert wg2Sub;

        OrderApi__Subscription__c j1Sub = TestDataFactory.buildSubscription(con.Id, subPlan1.Id, j1.Id, journalClass.Id);
        j1Sub.OrderApi__Status__c = 'Active';
        insert j1Sub;

        OrderApi__Subscription__c j2Sub = TestDataFactory.buildSubscription(con.Id, subPlan1.Id, j2.Id, journalClass.Id);
        j2Sub.OrderApi__Status__c = 'Active';
        insert j2Sub;

    }

    @IsTest
    static void test_getJournals() {
        Contact con = [SELECT Id FROM Contact WHERE Account.Name='Test Account'];
        User u = [SELECT Id FROM User WHERE ContactId=:con.Id];

        System.runAs(u){
            Test.startTest();

            List<OrderApi__Subscription__c> journals = MyMembershipController.getJournals(con.Id);
            System.assertEquals(2, journals.size());

            Test.stopTest();
        }
    }

    @IsTest
    static void test_getWorkingGroups() {
        Contact con = [SELECT Id FROM Contact WHERE Account.Name='Test Account'];
        User u = [SELECT Id FROM User WHERE ContactId=:con.Id];

        System.runAs(u){
            Test.startTest();

            List<OrderApi__Subscription__c> wgs = MyMembershipController.getWorkingGroups(con.Id);
            System.assertEquals(2, wgs.size());

            Test.stopTest();
        }
    }
}