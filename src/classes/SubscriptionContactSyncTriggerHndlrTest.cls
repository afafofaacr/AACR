/**
 * Created by lauren.lezberg on 10/11/2019.
 */
@isTest
private with sharing class SubscriptionContactSyncTriggerHndlrTest {

    @testSetup
    public static void setup(){
        Account acc = TestDataFactory.buildAccount('Test Account');
        insert acc;

        Contact con = TestDataFactory.buildContact(acc.Id);
        insert con;

        User u = TestDataFactory.buildUser(con.Id);
        insert u;
        // Build OrderApi__Item_Class__c record
        OrderApi__Item_Class__c itemClass = TestDataFactory.buildItemClass('Individual Memberships');
        insert itemClass;
        // Build OrderApi__Item__c record
        OrderApi__Item__c item = TestDataFactory.buildItem(itemClass.Id, 'Active Membership');
        insert item;

    }



    @isTest
    public static void test_SubscriptionContactTrigger(){
        Contact con = [SELECT AccountId, Id, RecordType.Name FROM Contact WHERE Account.Name='Test Account'];
        con.Application_Status__c = 'Pending Approval';
        update con;

        OrderApi__Item__c membership = [SELECT Id, OrderApi__Item_Class__c, Name FROM OrderApi__Item__c WHERE Name='Active Membership'];
        // Build OrderApi__Subscription_Plan__c record
        OrderApi__Subscription_Plan__c subPlan = TestDataFactory.buildsubPlan();
        insert subPlan;

        Test.startTest();

        OrderApi__Subscription__c sub = TestDataFactory.buildSubscription(con.Id, subPlan.Id, membership.Id, membership.OrderApi__Item_Class__c);
        insert sub;

        con = [SELECT RecordType.Name, Paid_thru_date__c, Member_Type__c FROM Contact WHERE Id=:con.Id];


        System.assertEquals('Nonmember', con.RecordType.Name);
        System.assertEquals(membership.Name.remove('ship'), con.Member_Type__c);
        sub = [SELECT Id, OrderApi__Current_Term_End_Date__c FROM OrderApi__Subscription__c WHERE Id=: sub.Id];
        System.assertEquals(sub.OrderApi__Current_Term_End_Date__c, con.Paid_thru_date__c);

        con.Application_Status__c = null;
        update con;

        Integer currentYear = System.now().year();
        Integer nextYear = currentYear + 1;


        sub.OrderApi__Current_Term_End_Date__c = Date.newInstance(nextYear, 12, 31);
        sub.OrderApi__Is_Active__c = true;
        update sub;

        con = [SELECT RecordType.Name, Paid_thru_date__c FROM Contact WHERE Id=:con.Id];

        System.assertEquals(Date.newInstance(nextYear, 12, 31), con.Paid_thru_date__c);

        Test.stopTest();

    }

}