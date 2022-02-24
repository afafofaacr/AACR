/**
 * Created by lauren.lezberg on 1/23/2020.
 */
@isTest
private with sharing class Schedule_SuspendMembersAfterGPTest {

    @testSetup
    public static void setup(){
        Account acc = TestDataFactory.buildAccount('Test Account');
        insert acc;
        System.assertEquals(1, [SELECT Id FROM Account].size());

        // Build OrderApi__Subscription_Plan__c record
        OrderApi__Subscription_Plan__c subPlan = TestDataFactory.buildsubPlan();
        insert subPlan;
        System.assertEquals(1, [SELECT Id FROM OrderApi__Subscription_Plan__c].size());

        List<Contact> contacts = new List<Contact>();
        for(Integer i = 0; i<50; i++){
            Contact con = TestDataFactory.buildContactMemberCurrent(acc.id);
            contacts.add(con);
        }
        insert contacts;

        OrderApi__Item_Class__c membershipClass = TestDataFactory.buildItemClass('Individual Memberships');
        insert membershipClass;

        OrderApi__Item__c membership = TestDataFactory.buildItem(membershipClass.Id, 'Active Membership');
        insert membership;

        List<OrderApi__Subscription__c> subscriptions = new List<OrderApi__Subscription__c>();

        for(Contact contact : contacts){
            OrderApi__Subscription__c sub = TestDataFactory.buildSubscription(contact.Id, subPlan.Id, membership.Id, membershipClass.Id);
            sub.OrderApi__Current_Term_Start_Date__c = Date.newInstance(system.today().year()-1, 1, 1);
            sub.OrderApi__Current_Term_End_Date__c = Date.newInstance(System.today().year() - 1, System.today().month()-1, System.today().day());
            sub.OrderApi__Is_Active__c = false;
            sub.OrderApi__Is_Expired__c = true;
            sub.OrderApi__Grace_Period_End_Date__c = Date.newInstance(System.today().year() - 1, System.today().month(), System.today().day() - 1);
            sub.OrderApi__Paid_Through_Date__c = Date.newInstance(System.today().year() - 1, System.today().month(), System.today().day() - 1);
            subscriptions.add(sub);
        }

        insert  subscriptions;

    }


    @isTest
    public static void testScheduledJob(){
        Integer memberCount = [SELECT COUNT() FROM Contact WHERE RecordType.Name='Member' AND Membership_Status__c = 'Current'];
        Test.StartTest();
        SchedulableContext sc = null;
        Schedule_SuspendMembersAfterGracePeriod obj = new Schedule_SuspendMembersAfterGracePeriod();
        obj.execute(sc);
        Test.stopTest();
        System.assertEquals(memberCount, [SELECT COUNT() FROM Contact WHERE RecordType.Name = 'Prior Member' AND Membership_Status__c = '1-YR Suspended']);

    }
}