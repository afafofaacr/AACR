/**
 * Created by lauren.lezberg on 2/6/2020.
 */
@isTest
private with sharing class PaymentFormControllerTest {

    @testSetup static void setup(){
        Account acc = TestDataFactory.buildAccount('Test Account');
        insert acc;
        Contact testContact = TestDataFactory.buildContactMemberCurrent(acc.Id);
        insert testContact;
        User u = TestDataFactory.buildUser(testContact.Id);
        insert u;
        //adding membership item
        OrderApi__Item_Class__c itemClass = TestDataFactory.buildItemClass('Individual Memberships');
        insert itemClass;
        OrderApi__Item__c item = TestDataFactory.buildItem(itemClass.Id, 'Active Membership');
        insert item;
        //adding journal items
        OrderApi__Item_Class__c journalClass = TestDataFactory.buildItemClass('Journal Subscriptions');
        insert journalClass;
        OrderApi__Item__c journalItem1 = TestDataFactory.buildItem(journalClass.Id, 'Test Journal 1');
        insert journalItem1;
        OrderApi__Item__c journalItem2 = TestDataFactory.buildItem(journalClass.Id, 'Test Journal 2');
        insert journalItem2;
        //adding comp journal item
        OrderApi__Item_Class__c compJournalClass = TestDataFactory.buildItemClass('Complimentary Journals');
        insert compJournalClass;
        OrderApi__Item__c compJournalItem = TestDataFactory.buildItem(compJournalClass.Id, 'COMP-O-Test Comp Journal');
        insert compJournalItem;
        //adding decline journal item
        OrderApi__Item_Class__c declineClass = TestDataFactory.buildItemClass('zDecline of the Journals');
        insert declineClass;
        OrderApi__Item__c declineItem = TestDataFactory.buildItem(declineClass.Id, 'Declined Free Journal');
        insert declineItem;
        // adding working group items
        OrderApi__Item_Class__c workingGroupClass = TestDataFactory.buildItemClass('Working Groups');
        insert workingGroupClass;
        OrderApi__Item__c workingGroupItem1 = TestDataFactory.buildItem(workingGroupClass.Id, 'Test Working Group 1');
        insert workingGroupItem1;
        OrderApi__Item__c workingGroupItem2 = TestDataFactory.buildItem(workingGroupClass.Id, 'Test Working Group 2');
        insert workingGroupItem2;
        // adding merchandise items
        OrderApi__Item_Class__c merchClass = TestDataFactory.buildItemClass('Merchandise');
        insert merchClass;
        OrderApi__Item__c merchItem1 = TestDataFactory.buildItem(merchClass.Id, 'Test Merchandise 1');
        insert merchItem1;
        OrderApi__Item__c merchItem2 = TestDataFactory.buildItem(merchClass.Id, 'Test Merchandise 2');
        insert merchItem2;

        //create sales order and sales order lines
        OrderApi__Sales_Order__c so = TestDataFactory.buildOpenSalesOrder(acc.Id, testContact.Id);
        insert so;
        OrderApi__Sales_Order_Line__c soLine1 = TestDataFactory.buildSOLine(so.Id, item.Id, itemClass.Id);
        insert soLine1;
        OrderApi__Sales_Order_Line__c soLine2 = TestDataFactory.buildSOLine(so.Id, journalItem1.Id, journalClass.Id);
        insert soLine2;
        OrderApi__Sales_Order_Line__c soLine3  = TestDataFactory.buildSOLine(so.Id, compJournalItem.Id, compJournalClass.Id);
        insert soLine3;
        OrderApi__Sales_Order_Line__c soLine4  = TestDataFactory.buildSOLine(so.Id, workingGroupItem1.Id, workingGroupClass.Id);
        insert soLine4;
        OrderApi__Sales_Order_Line__c soLine5  = TestDataFactory.buildSOLine(so.Id, merchItem1.Id, merchClass.Id);
        insert soLine5;

        OrderApi__Store__c eStore = new OrderApi__Store__c(Name='AACR eStore');
        insert eStore;
        OrderApi__Source_Code__c sourceCode = new OrderApi__Source_Code__c(OrderApi__Active__c = true, Name='waive');
        insert sourceCode;
    }

    @isTest
    public static void test_processZeroDollarPayment(){
        Account acc = [SELECT Id FROM Account];
        Contact testContact = [SELECT Id FROM Contact];
        OrderApi__Sales_Order__c so = TestDataFactory.buildOpenSalesOrder(acc.Id, testContact.Id);
        insert so;
        OrderApi__Receipt__c receipt = new OrderApi__Receipt__c(OrderApi__Sales_Order__c= so.Id, OrderApi__Contact__c=testContact.Id);
        insert receipt;

        Join_Process__mdt jp = [SELECT Id FROM Join_Process__mdt WHERE Item__c LIKE: '%Active Membership%' AND Is_Renewal__c = false];
        Process_Steps__mdt step = [SELECT Id, Step_Order__c FROM Process_Steps__mdt WHERE Process__c =: jp.Id AND Join_Step__r.DeveloperName ='Checkout'];

        Test.startTest();
        PaymentFormController.processZeroDollarPayment(so.Id, step.Id);
        Test.stopTest();

        so = [SELECT OrderApi__Status__c FROM OrderApi__Sales_Order__c WHERE Id=: so.Id];
        System.assertEquals('Closed', so.OrderApi__Status__c);
    }

    @isTest
    public static void test_closeSalesOrder(){
        Contact con = [SELECT Id FROM Contact LIMIT 1];
        OrderApi__Sales_Order__c SO = [SELECT Id FROM OrderApi__Sales_Order__c WHERE OrderApi__Contact__c =: con.Id];

        Test.startTest();

        PaymentFormController.closeSalesOrder(SO.Id);

        SO = [SELECT OrderApi__Status__c, OrderApi__Posting_Entity__c FROM OrderApi__Sales_Order__c WHERE Id=:SO.Id];
        System.assertEquals('Closed', SO.OrderApi__Status__c);
        System.assertEquals('Receipt', SO.OrderApi__Posting_Entity__c);

        Test.stopTest();
    }

    @isTest
    public static void test_payNow(){
        OrderApi__Sales_Order__c so = [SELECT Id FROM OrderApi__Sales_Order__c LIMIT 1];
        Join_Process__mdt jp = [SELECT Id FROM Join_Process__mdt WHERE Item__c LIKE: '%Active Membership%' AND Is_Renewal__c = false];
        Process_Steps__mdt step = [SELECT Id, Step_Order__c FROM Process_Steps__mdt WHERE Process__c =: jp.Id AND Join_Step__r.DeveloperName ='Checkout'];

        Test.startTest();
        PaymentFormController.payNow(so.Id, step.Id);
        Test.stopTest();
    }

    @isTest
    public static void test_getPayNowData(){
        Contact con = [SELECT Id FROM Contact LIMIT 1];
        Join_Process__mdt jp = [SELECT Id FROM Join_Process__mdt WHERE Item__c LIKE: '%Active Membership%' AND Is_Renewal__c = false];

        OrderApi__Sales_Order__c SO = [SELECT Id FROM OrderApi__Sales_Order__c WHERE OrderApi__Contact__c =: con.Id];

        PaymentFormController.PayNowData data = PaymentFormController.getPayNowData(SO.Id, jp.Id);
        System.assertNotEquals(null, data);
    }

    @isTest static void testDeleteSO(){
        OrderApi__Sales_Order__c so = [SELECT Id FROM OrderApi__Sales_Order__c LIMIT 1];
        Join_Process__mdt jp = [SELECT Id FROM Join_Process__mdt WHERE Item__c LIKE: '%Active Membership%' AND Is_Renewal__c = false];
        Process_Steps__mdt step = [SELECT Id, Step_Order__c FROM Process_Steps__mdt WHERE Process__c =: jp.Id AND Join_Step__r.DeveloperName ='Checkout'];
        Test.startTest();
        PaymentFormController.deleteSalesOrder(so.Id, step.Id);
        Test.stopTest();

    }
}