/**
 * Created by lauren.lezberg on 2/13/2020.
 */
@isTest
public with sharing class CurrentSubscriptionsControllerTest {

    @testSetup public static void setup(){
        TestDataFactory.setupCurrentMember();

    }

    @isTest
    public static void test_getCurrentSubs(){
        Contact con = [SELECT Id FROM Contact WHERE Account.Name='Test Account1'];
        Integer subCount = [SELECT COUNT() FROM OrderApi__Subscription__c WHERE OrderApi__Is_Active__c= true AND OrderApi__Contact__c=: con.Id];

        Test.startTest();

        List<OrderApi__Subscription__c> subs = CurrentSubscriptionsController.getAllCurrentSubscriptions(con.Id);
        System.assert(!subs.isEmpty(), 'Subscriptions list should not be empty');
        System.assertEquals(subCount, subs.size());

        Test.stopTest();
    }

    @isTest
    public static void test_cancelSubscriptions(){
        Contact con = [SELECT Id FROM Contact WHERE Account.Name='Test Account1'];
        List<OrderApi__Subscription__c> subs = [SELECT Id FROM OrderApi__Subscription__c WHERE OrderApi__Is_Active__c= true AND OrderApi__Contact__c=: con.Id];
        List<Id> subsToCancel = new List<Id>();
        for(OrderApi__Subscription__c sub : subs){
            subsToCancel.add(sub.id);
        }

        Test.startTest();

        CurrentSubscriptionsController.cancelSubscriptions(subsToCancel);

        subs = CurrentSubscriptionsController.getAllCurrentSubscriptions(con.Id);
        System.assert(subs.isEmpty());

        Test.stopTest();
    }
}