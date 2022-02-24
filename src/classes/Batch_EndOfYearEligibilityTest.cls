/**
 * Created by lauren.lezberg on 5/20/2021.
 */

@IsTest
private class Batch_EndOfYearEligibilityTest {

    @testSetup
    public static void setup() {
        Account acc = TestDataFactory.buildAccount('Test Account');
        insert acc;

        OrderApi__Subscription_Plan__c subPlan = TestDataFactory.buildsubPlan();
        insert subPlan;

        OrderApi__Item_Class__c membershipClass = TestDataFactory.buildItemClass('Individual Memberships');
        insert membershipClass;

        OrderApi__Item__c associateMembership = TestDataFactory.buildItem(membershipClass.Id, 'Associate Membership');
        insert associateMembership;

        OrderApi__Item__c studentMembership = TestDataFactory.buildItem(membershipClass.Id, 'Student Membership');
        insert studentMembership;

        OrderApi__Item__c activeMembership = TestDataFactory.buildItem(membershipClass.Id, 'Active Membership');
        activeMembership.Managed__c = true;
        insert activeMembership;

        List<OrderApi__Subscription__c> subscriptions = new List<OrderApi__Subscription__c>();
        List<Contact> contacts = new List<Contact>();
        //Associate Members
        for (Integer i = 0; i < 50; i++) {
            Contact con = TestDataFactory.buildContactMemberCurrent(acc.id);
            con.Member_Type__c = 'Associate Member';
            contacts.add(con);

        }
        //student Members
        for (Integer j = 0; j < 20; j++) {
            Contact con = TestDataFactory.buildContactMemberCurrent(acc.id);
            con.Expected_Completion_Date__c = Date.newInstance(system.today().year() + 3, 5, 7);
            con.Member_Type__c = 'Student Member';
            contacts.add(con);
        }
        for (Integer j = 0; j < 20; j++) {
            Contact con = TestDataFactory.buildContactMemberCurrent(acc.id);
            con.Expected_Completion_Date__c = Date.newInstance(system.today().year() + 1, 5, 7);
            con.Member_Type__c = 'Student Member';
            contacts.add(con);
        }
        //Catch else statement in batch.
        Contact con = TestDataFactory.buildContactMemberCurrent(acc.id);
        con.Paid_thru_date__c = Date.newInstance(System.now().year(), 12, 31);
        contacts.add(con);

        insert contacts;
        System.assertEquals(91, contacts.size());
        List<Contact> students = [SELECT Id FROM Contact WHERE Member_Type__c='Student Member' AND RecordType.Name = 'Member' AND Membership_Status__c = 'Current'];
        System.assertEquals(40, students.size());

        List<Contact> associates = [SELECT Id FROM Contact WHERE Member_Type__c='Associate Member' AND RecordType.Name = 'Member' AND Membership_Status__c = 'Current'];
        System.assertEquals(50, associates.size());

        for(Contact c: contacts){
            OrderApi__Subscription__c sub;
            if(c.Member_Type__c == 'Associate Member'){
                sub = TestDataFactory.buildSubscription(c.Id, subPlan.Id, associateMembership.Id, membershipClass.Id);
            } else if (c.Member_Type__c == 'Student Member') {
                sub = TestDataFactory.buildSubscription(c.Id, subPlan.Id, studentMembership.Id, membershipClass.Id);
            } else {
                sub = TestDataFactory.buildSubscription(c.Id, subPlan.Id, activeMembership.Id, membershipClass.Id);
            }
            sub.OrderApi__Contact__c = c.Id;
            sub.OrderApi__Current_Term_Start_Date__c = Date.newInstance(system.today().year(), 1, 1);
            sub.OrderApi__Current_Term_End_Date__c = Date.newInstance(System.today().year(), 12, 31);
            sub.OrderApi__Paid_Through_Date__c = Date.newInstance(System.today().year(), 12, 31);
            subscriptions.add(sub);
        }

        insert subscriptions;
        System.assertEquals(91, subscriptions.size());

        System.debug('setup complete');
    }


    @IsTest
    static void test_runBatchAssociates() {

        Test.startTest();
        Database.executeBatch(new Batch_EndOfYearEligibilityJob());
        Test.stopTest();

    }
}