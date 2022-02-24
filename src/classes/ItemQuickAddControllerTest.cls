/**
 * Created by lauren.lezberg on 10/11/2019.
 */
@isTest
private with sharing class ItemQuickAddControllerTest {

    @testSetup
    public static void setup(){
        OrderApi__Item_Class__c membershipClass = TestDataFactory.buildItemClass('Individual Memberships');
        insert membershipClass;

        OrderApi__Item__c activeItem = TestDataFactory.buildItem(membershipClass.Id, 'Active Membership');
        insert activeItem;

        OrderApi__Item__c affiliateItem = TestDataFactory.buildItem(membershipClass.Id, 'Affiliate Membership');
        insert affiliateItem;

        OrderApi__Item__c associateItem = TestDataFactory.buildItem(membershipClass.Id, 'Associate Membership');
        insert associateItem;

        OrderApi__Item_Class__c journalClass = TestDataFactory.buildItemClass('Journal Subscriptions');
        insert journalClass;

        OrderApi__Item__c cancerDiscoveryO = TestDataFactory.buildItem(journalClass.Id, 'Cancer Discovery Journal - Online');
        insert cancerDiscoveryO;

        OrderApi__Item__c cancerDiscoveryP = TestDataFactory.buildItem(journalClass.Id, 'Cancer Discovery Journal - Print & Online');
        insert cancerDiscoveryP;

        OrderApi__Item__c cancerResearchO = TestDataFactory.buildItem(journalClass.Id, 'Cancer Research Journal - Online');
        insert cancerResearchO;

        OrderApi__Item__c cancerResearchP = TestDataFactory.buildItem(journalClass.Id, 'Cancer Research Journal - Print & Online');
        insert cancerResearchP;

        EventApi__Event__c newEvent = new EventApi__Event__c(Name='Test Event', EventApi__Start_Date__c = Date.valueOf(System.now().addDays(2)), EventApi__End_Date__c= Date.valueOf(System.now().addDays(8)), EventApi__Event_Key__c='289375983475');
        insert newEvent;

        OrderApi__Item_Class__c eventClass = TestDataFactory.buildItemClass('Event Tickets');
        eventClass.EventApi__Event__c = newEvent.Id;
        eventClass.OrderApi__Is_Event__c = true;
        insert eventClass;

        OrderApi__Item__c ticket1 = TestDataFactory.buildItem(eventClass.Id, 'Ticket Type 1');
        insert ticket1;

        OrderApi__Item__c ticket2 = TestDataFactory.buildItem(eventClass.Id, 'Ticket Type 2');
        insert ticket2;
    }


    @isTest
    public static void test_fetchItems(){

        Test.startTest();
        List<OrderApi__Item__c> foundItems = ItemQuickAddController.fetchItems('Membership', 'OrderApi__Is_Active__c = true');
        System.assertEquals(3, foundItems.size());

        foundItems = ItemQuickAddController.fetchItems('Journal', 'OrderApi__Is_Active__c = true');
        System.assertEquals(4, foundItems.size());

        List<OrderApi__Item__c> eventItems = [SELECT ID FROM OrderApi__Item__c WHERE OrderApi__Item_Class__r.OrderApi__Is_Event__c= true];
        SYstem.debug('eventItems: ' + eventItems.size());
        foundItems = ItemQuickAddController.fetchItems('Ticket', 'OrderApi__Item_Class__r.OrderApi__Is_Event__c= true');
        System.assertEquals(2, foundItems.size());

        Test.stopTest();
    }
}