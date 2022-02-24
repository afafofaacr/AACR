/**
 * Created by afaf.awad on 9/4/2020.
 */

@isTest
private with sharing class CreateOpportunitiesHandlerTest{

    @testSetup
    static void setup(){
        Account acc = TestDataFactory.buildAccount('Test Account');
        insert acc;
        Contact testContact = TestDataFactory.buildContact(acc.Id);
        insert testContact;
        User u = TestDataFactory.buildUser(testContact.Id);
        insert u;

        //Appeal codes for Opportunity
        Appeal_Code__c appealCode = new Appeal_Code__c(Name = 'Test Appeal Code');
        insert appealCode;

        OrderApi__GL_Account__c glAccount = TestDataFactory.buildGLAccount();
        glAccount.Distribution_Code__c = true;
        insert glAccount;

        //adding Donation items
        OrderApi__Item_Class__c wicrItemClass = TestDataFactory.buildItemClass('WICR Donations');
        insert wicrItemClass;
        OrderApi__Item__c wicritem = TestDataFactory.buildItem(wicrItemClass.Id, '50 WICR Donation');
        insert wicrItem;
        //adding journal items
        OrderApi__Item_Class__c cinnItemClass = TestDataFactory.buildItemClass('CIMM Donations');
        insert cinnItemClass;
        OrderApi__Item__c cinnItem = TestDataFactory.buildItem(cinnItemClass.Id, '100 CIMM Donation');
        insert cinnItem;

        //create sales order and sales order lines
        OrderApi__Sales_Order__c so = TestDataFactory.buildOpenSalesOrder(acc.Id, testContact.Id);
        insert so;
        OrderApi__Sales_Order_Line__c soLine1 = TestDataFactory.buildSOLine(so.Id, wicrItem.Id, wicrItemClass.Id);
        soLine1.OrderApi__GL_Account__c = glAccount.Id;
        soLine1.OrderApi__Sale_Price__c = 50;
        insert soLine1;
        OrderApi__Sales_Order_Line__c soLine2 = TestDataFactory.buildSOLine(so.Id, cinnItem.Id, cinnItemClass.Id);
        soLine2.OrderApi__GL_Account__c = glAccount.Id;
        soLine2.OrderApi__Sale_Price__c = 100;
        insert soLine2;

    }

    @IsTest static void createDonationOppTest(){
        OrderApi__Sales_Order__c salesOrder = [SELECT Id, OrderApi__Posting_Status__c FROM OrderApi__Sales_Order__c LIMIT 1];

        OrderApi__Sales_Order__c so = [SELECT Id, OrderApi__Posting_Status__c, OrderApi__Status__c, OrderApi__Contact__c FROM OrderApi__Sales_Order__c];
        List<OrderApi__Sales_Order_Line__c> lines = [SELECT Id FROM OrderApi__Sales_Order_Line__c WHERE OrderApi__Sales_Order__c=: so.Id];
        User u = [SELECT Id FROM User WHERE ContactId=: so.OrderApi__Contact__c];

        System.runAs(u) {

            Test.startTest();

            OrderApi__Receipt__c receipt = new OrderApi__Receipt__c(
                    OrderApi__Contact__c = so.OrderApi__Contact__c,
                    OrderApi__Entity__c = 'Contact',
                    OrderApi__Is_Posted__c = true,
                    OrderApi__Sales_Order__c = so.Id
            );
            insert receipt;


            Test.stopTest();
        }

        List<OrderApi__Sales_Order_Line__c> sols = [SELECT Id, Opportunity__c FROM OrderApi__Sales_Order_Line__c WHERE Opportunity__c != NULL];

        System.debug('Sales Order Lines with Opportunity ::::' + sols.size());

        System.assertEquals(2, sols.size());
    }

}