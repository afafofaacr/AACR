/**
 * Created by lauren.lezberg on 12/11/2018.
 */

@IsTest
private class MembershipCategoriesControllerTest { 
    @testSetup static void setup(){
        Account acc = TestDataFactory.buildAccount('Test Account');
        insert acc;
        Contact con = TestDataFactory.buildContact(acc.Id);
        insert con;
        User u = TestDataFactory.buildUser(con.Id);
        insert u;

        OrderApi__Item_Class__c itemClass = TestDataFactory.buildItemClass('Individual Memberships');
        insert itemClass;
        OrderApi__Item__c item1 = TestDataFactory.buildItem(itemClass.Id, 'Active Membership');
        item1.Show_In_Portal__c = true;
        insert item1;
        OrderApi__Item__c item2 = TestDataFactory.buildItem(itemClass.Id, 'Affiliate Membership');
        item2.Show_In_Portal__c = true;
        insert item2;
        OrderApi__Item__c item3 = TestDataFactory.buildItem(itemClass.Id, 'Associate Membership');
        item3.Show_In_Portal__c = true;
        insert item3;
        OrderApi__Item__c item4 = TestDataFactory.buildItem(itemClass.Id, 'Student Membership');
        item4.Show_In_Portal__c = true;
        insert item4;
        OrderApi__Item__c item5 = TestDataFactory.buildItem(itemClass.Id, 'Emeritus Membership');
        item5.Show_In_Portal__c = false;
        insert item5;

        OrderApi__Item_Class__c journalClass = TestDataFactory.buildItemClass('Journal Subscriptions');
        insert journalClass;
        OrderApi__Item__c bloodCancerJournal = TestDataFactory.buildItem(journalClass.Id, 'Blood Cancer Discovery - Online');
        insert bloodCancerJournal;

        OrderApi__Subscription_Plan__c subPlan1 = TestDataFactory.buildsubPlan();
        insert subPlan1;

        OrderApi__Subscription__c memSub = TestDataFactory.buildSubscription(con.Id, subPlan1.Id, item1.Id, itemClass.Id);
        insert memSub;


    }


    @isTest
    static void test_getMembershipItems() {
        Contact con = [SELECT Id FROM Contact LIMIT 1];
        User u = [SELECT Id FROM User WHERE ContactId =: con.Id];


        System.runAs(u) {
            Test.startTest();
            List<OrderApi__Item__c> items = MembershipCategoriesController.getMembershipItems(false);
            System.assert(items != null, 'List of items is not null');
            System.assert(items.size() == 4, 'Method should return 4 items');

            items = MembershipCategoriesController.getMembershipItems(true);
            System.assert(items != null, 'List of items is not null');
            System.assert(items.size() == 1, 'Method should return 1 items');

            Test.stopTest();
        }
    }

    @isTest
    static void test_startNewMemberApplication(){
        OrderApi__Item__c membershipItem = [SELECT Id FROM OrderApi__Item__c LIMIT 1];
        Contact con = [SELECT Id FROM Contact LIMIT 1];
        User u = [SELECT Id FROM User WHERE ContactId =: con.Id];

        System.runAs(u){
            String response = MembershipCategoriesController.startNewMemberApplication(membershipItem.Id);
            System.assertNotEquals(null, response);
        }
    }

    @isTest
    static void test_startTransferApplication(){
        OrderApi__Item__c membershipItem = [SELECT Id FROM OrderApi__Item__c LIMIT 1];
        Contact con = [SELECT Id FROM Contact LIMIT 1];
        User u = [SELECT Id FROM User WHERE ContactId =: con.Id];

        System.runAs(u){
            String response = MembershipCategoriesController.startTransferApplication(membershipItem.Id);
            System.assertNotEquals(null, response);
        }
    }
}