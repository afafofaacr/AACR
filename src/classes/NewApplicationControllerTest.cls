/**
 * Created by lauren.lezberg on 8/8/2019.
 */
@isTest
private with sharing class NewApplicationControllerTest { 

    @testSetup
    public static void setup(){
        Account acc = TestDataFactory.buildAccount('Test Account');
        insert acc;

        Contact con = TestDataFactory.buildContact(acc.Id);
        insert con;
    }


    @isTest
    public static void test_hasMembershipSubscription(){
        Contact con = [SELECT Id FROM Contact LIMIT 1];

        Test.startTest();

        Boolean isMember = NewApplicationController.showNewApplicationButton(con.Id);
        System.assertEquals(true, isMember);

        OrderApi__Item_Class__c itemClass = TestDataFactory.buildItemClass('Individual Memberships');
        insert itemClass;

        OrderApi__Item__c item = TestDataFactory.buildItem(itemClass.Id, 'Active Membership');
        insert item;

        OrderApi__Subscription_Plan__c subPlan = TestDataFactory.buildsubPlan();
        insert subPlan;

        OrderApi__Subscription__c sub = TestDataFactory.buildSubscription(con.Id, subPlan.Id, item.Id, itemClass.Id);
        insert sub;


        isMember = NewApplicationController.showNewApplicationButton(con.Id);
        System.assertEquals(false, isMember);

        Test.stopTest();
    }

    @isTest
    public static void test_createNewBackOfficeSO(){
        Contact con = [SELECT Id FROM Contact LIMIT 1];

        Test.startTest();
        NewApplicationController.NewApplicationInfo info = NewApplicationController.createBackOfficeSO(con.Id);
        Test.stopTest();

        OrderApi__Sales_Order__c so = [SELECT Id FROM OrderApi__Sales_Order__c WHERE OrderApi__Contact__c =: con.Id];
        System.assertNotEquals(null, SO);

    }

  
}