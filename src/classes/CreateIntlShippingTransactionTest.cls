/**
 * Created by afaf.awad on 3/29/2019.
 */

@IsTest
private class CreateIntlShippingTransactionTest {

    @testSetup static void setup() {
        //Build contact
        Account acc = TestDataFactory.buildAccount('Test Account');
        insert acc;
        Contact testContact = TestDataFactory.buildContactMemberCurrent(acc.Id);
        testContact.MailingCountry = 'France';
        insert testContact;
        User u = TestDataFactory.buildUser(testContact.Id);
        insert u;

        //Build Item Classes to create Active Member with a Comp Journal
        OrderApi__Item_Class__c memClass = TestDataFactory.buildItemClass('Individual Memberships');
        insert memClass;
        OrderApi__Item_Class__c compJournalClass = TestDataFactory.buildItemClass('Complimentary Journals');
        insert compJournalClass;
        OrderApi__Item_Class__c shippingClass = TestDataFactory.buildItemClass('Shipping Items');
        insert shippingClass;

        //Build Items to for each Item Class
        OrderApi__Item__c activeMem = TestDataFactory.buildItem(memClass.Id, 'Active Membership');
        insert activeMem;
        OrderApi__Item__c intlShipping = TestDataFactory.buildItem(shippingClass.Id, 'International Shipping - Cancer Research');
        insert intlShipping;
        OrderApi__Item__c journalItem = TestDataFactory.buildItem(compJournalClass.Id, 'Cancer Research');
        journalItem.Association_Journals_Type__c = 'Print & Online';
        journalItem.International_Shipping_Item__c = intlShipping.Id;
        insert journalItem;

        //Build Subscription Plan
        OrderApi__Subscription_Plan__c subPlan =TestDataFactory.buildsubPlan();
        insert subPlan;

        //Build Sale Order and Sale Order Lines (Active Membership and Comp Journal)
        OrderApi__Sales_Order__c so = TestDataFactory.buildOpenSalesOrder(acc.Id, testContact.Id);
        insert so;
        OrderApi__Sales_Order_Line__c soLine1 = TestDataFactory.buildSOLine(so.Id, activeMem.Id, memClass.Id);
        soLine1.OrderApi__Is_Subscription__c = true;
        soLine1.OrderApi__Subscription_Plan__c = subPlan.id;
        soLine1.OrderApi__Activation_Date__c = Date.newInstance(Date.today().year(), Date.today().month(), Date.today().day());
        insert soLine1;
        OrderApi__Sales_Order_Line__c soLine2 = TestDataFactory.buildSOLine(so.Id, journalItem.Id, compJournalClass.Id);
        soLine2.OrderApi__Is_Subscription__c = true;
        soLine2.OrderApi__Subscription_Plan__c = subPlan.id;
        soLine2.OrderApi__Activation_Date__c = Date.newInstance(Date.today().year(), Date.today().month(), Date.today().day());
        insert soLine2;
}


    @IsTest
    static void testIntlShippingTransaction() {
        Contact testContact = [SELECT Id FROM Contact LIMIT 1];
        OrderApi__Sales_Order__c so = [Select Id From OrderApi__Sales_Order__c LIMIT 1];

        //Close and post Sale Order
        so.OrderApi__Status__c = 'Closed';
        so.OrderApi__Posting_Status__c = 'Posted';
        update so;

        //Create Transaction Summary
        OrderApi__Transaction__c transSummary = new OrderApi__Transaction__c();
        transSummary.OrderApi__Contact__c = testContact.Id;
        transSummary.OrderApi__Sales_Order__c = so.Id;
        insert transSummary;

        //Get Transaction Summary from posted Sale Order
        List<OrderApi__Transaction__c> transactions = [Select Id, OrderApi__Contact__c, OrderApi__Sales_Order__c from OrderApi__Transaction__c
                                                        WHERE OrderApi__Sales_Order__c =: so.id];

        test.startTest();
        CreateIntlShippingTransactionHelper.createTransactionLine(transactions);
        test.stopTest();

    }

    @IsTest
    static void testIntlShippingTransaction2YR() {
        Contact testContact = [SELECT Id FROM Contact LIMIT 1];
        OrderApi__Sales_Order__c so = [Select Id From OrderApi__Sales_Order__c LIMIT 1];

        //Close and post Sale Order
        so.OrderApi__Status__c = 'Closed';
        so.OrderApi__Posting_Status__c = 'Posted';
        so.Is2YR__c = true;
        update so;

        //Create Transaction Summary
        OrderApi__Transaction__c transSummary = new OrderApi__Transaction__c();
        transSummary.OrderApi__Contact__c = testContact.Id;
        transSummary.OrderApi__Sales_Order__c = so.Id;
        insert transSummary;

        //Get Transaction Summary from posted Sale Order
        List<OrderApi__Transaction__c> transactions = [Select Id, OrderApi__Contact__c, OrderApi__Sales_Order__c from OrderApi__Transaction__c
        WHERE OrderApi__Sales_Order__c =: so.id];

        test.startTest();
        CreateIntlShippingTransactionHelper.createTransactionLine(transactions);
        test.stopTest();

    }
}