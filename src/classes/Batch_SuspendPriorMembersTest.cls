/**
 * Created by afaf.awad on 12/14/2020.
 */

@IsTest
public with sharing class Batch_SuspendPriorMembersTest {

    @testSetup
    public static void setup(){
        Account acc = TestDataFactory.buildAccount('Test Account');
        insert acc;

        OrderApi__Subscription_Plan__c subPlan = TestDataFactory.buildsubPlan();
        insert subPlan;

        List<Contact> contacts = new List<Contact>();
        //1-YR Suspended Members
        for(Integer i = 0; i<100; i++){
            Contact con = TestDataFactory.buildContactMemberPrior(acc.id);
            contacts.add(con);
        }
        //2-YR Suspended Members
        for(Integer j = 0; j<50; j++){
            Contact con = TestDataFactory.buildContactMemberPrior(acc.id);
            con.Membership_Status__c = '2-YR Suspended';
            con.Paid_thru_date__c = Date.newInstance(System.now().year()-2, 12, 31);
            contacts.add(con);
        }
        //Current Member to catch else statement in batch.
        Contact con = TestDataFactory.buildContactMemberPrior(acc.id);
        con.Paid_thru_date__c = Date.newInstance(System.now().year(), 12, 31);
        contacts.add(con);

        insert contacts;

//        OrderApi__Item_Class__c membershipClass = TestDataFactory.buildItemClass('Individual Memberships');
//        insert membershipClass;
//
//        OrderApi__Item__c membership = TestDataFactory.buildItem(membershipClass.Id, 'Associate Membership');
//        insert membership;
//
//        Renewal_Settings__c renewalProcess = new Renewal_Settings__c(Is_Active__c = true, Term_Year__c = Datetime.now().year() + 1);
//        insert renewalProcess;
//
//        List<OrderApi__Subscription__c> subscriptions = new List<OrderApi__Subscription__c>();
//
//        for(Integer i = 0; i<100; i++){
////        for(Contact contact : contacts){
//            OrderApi__Subscription__c sub = TestDataFactory.buildSubscription(contacts[i].Id, subPlan.Id, membership.Id, membershipClass.Id);
//            sub.OrderApi__Current_Term_Start_Date__c = Date.newInstance(system.today().year()-1, 1, 1);
//            sub.OrderApi__Current_Term_End_Date__c = Date.newInstance(System.today().year() - 1, 12, 31);
//            sub.OrderApi__Is_Active__c = false;
//            sub.OrderApi__Is_Expired__c = true;
//            sub.OrderApi__Paid_Through_Date__c = Date.newInstance(System.today().year() - 1, 12, 31);
//            subscriptions.add(sub);
//        }
//
//        for(Integer i = 100; i<200; i++){
////        for(Contact contact : contacts){
//            OrderApi__Subscription__c sub = TestDataFactory.buildSubscription(contacts[i].Id, subPlan.Id, membership.Id, membershipClass.Id);
//            sub.OrderApi__Current_Term_Start_Date__c = Date.newInstance(system.today().year()-2, 1, 1);
//            sub.OrderApi__Current_Term_End_Date__c = Date.newInstance(System.today().year() - 2, 12, 31);
//            sub.OrderApi__Is_Active__c = false;
//            sub.OrderApi__Is_Expired__c = true;
//            sub.OrderApi__Paid_Through_Date__c = Date.newInstance(System.today().year() - 2, 12, 31);
//            subscriptions.add(sub);
//        }
//
//        insert  subscriptions;


    }

    @IsTest
    public static void testBatch(){
        Date paidThruDate = Date.newInstance(Datetime.now().year(), 12, 31);
        List<Contact> priorMembers = [SELECT AACR_ID__c FROM Contact WHERE RecordType.Name='Prior Member'];
        Set<String> aacrIds = new Set<String>();

        System.debug('priorMembers Count ' + priorMembers.size());

        for(Contact con: priorMembers){
            aacrIds.add(con.AACR_ID__c);
        }

        Test.startTest();
        DataBase.executeBatch(new Batch_SuspendPriorMembers(aacrIds, paidThruDate));
        Test.stopTest();
 
        System.assertEquals(priorMembers.size() - 1, [SELECT COUNT() FROM Contact WHERE RecordType.Name='Prior Member' AND Membership_Status__c IN ('Suspended','Suspended (Delinquent)')]);
    }

}