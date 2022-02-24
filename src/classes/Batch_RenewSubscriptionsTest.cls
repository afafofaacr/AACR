/**
 * Created by afaf.awad on 12/14/2020.
 */

@IsTest
public with sharing class Batch_RenewSubscriptionsTest{

        @testSetup
        public static void setup(){
            Account acc = TestDataFactory.buildAccount('Test Account');
            insert acc;

            OrderApi__Subscription_Plan__c subPlan = TestDataFactory.buildsubPlan();
            insert subPlan;

            List<Contact> contacts = new List<Contact>();
            for(Integer i = 0; i<200; i++){
                Contact con = TestDataFactory.buildContactMemberCurrent(acc.id);
                con.Member_Type__c = 'Associate Member';
                contacts.add(con);
            }
            insert contacts;

            OrderApi__Item_Class__c membershipClass = TestDataFactory.buildItemClass('Individual Memberships');
            insert membershipClass;

            OrderApi__Item__c membership = TestDataFactory.buildItem(membershipClass.Id, 'Associate Membership');
            insert membership;

            Renewal_Settings__c renewalProcess = new Renewal_Settings__c(Is_Active__c = true, Term_Year__c = Datetime.now().year() + 1);
            insert renewalProcess;

            List<OrderApi__Subscription__c> subscriptions = new List<OrderApi__Subscription__c>();

            for(Contact contact : contacts){
                OrderApi__Subscription__c sub = TestDataFactory.buildSubscription(contact.Id, subPlan.Id, membership.Id, membershipClass.Id);
                sub.OrderApi__Current_Term_Start_Date__c = Date.newInstance(system.today().year(), 1, 1);
                sub.OrderApi__Current_Term_End_Date__c = Date.newInstance(System.today().year(), 12, 31);
                sub.OrderApi__Is_Active__c = true;
                sub.OrderApi__Paid_Through_Date__c = Date.newInstance(System.today().year(), 12, 31);
                subscriptions.add(sub);
            }

            insert  subscriptions;

        }

    @IsTest
    public static void testBatch(){

        Date paidThruDate = Date.newInstance(System.today().year(), 12, 31);
        List<OrderApi__Subscription_Plan__c> subPlans = [SELECT Id FROM OrderApi__Subscription_Plan__c WHERE (Show_In_Portal__c = true OR OrderApi__Advanced_Calendar_Days__c = 365) AND OrderApi__Is_Active__c = true AND OrderApi__Type__c = 'Calendar' ORDER BY OrderApi__Advanced_Calendar_Days__c];
        OrderApi__Item_Class__c itemClass = [SELECT Id FROM OrderApi__Item_Class__c WHERE Name = 'Individual Memberships'];
        List<Contact> renewMembers = [SELECT AACR_ID__c FROM Contact WHERE RecordType.Name='Member' AND Paid_thru_date__c =: paidThruDate];
        Set<String> aacrIds = new Set<String>();

        for(Contact con: renewMembers){
            aacrIds.add(con.AACR_ID__c);
        }

        Test.startTest();
        DataBase.executeBatch(new Batch_RenewSubscriptions(aacrIds, paidThruDate, subPlans[0].Id, itemClass.Id));
        Test.stopTest();

        paidThruDate = paidThruDate.addYears(1);

        System.assertEquals(renewMembers.size(), [SELECT COUNT() FROM Contact WHERE RecordType.Name='Member' AND Paid_thru_date__c =: paidThruDate]);
    }

}