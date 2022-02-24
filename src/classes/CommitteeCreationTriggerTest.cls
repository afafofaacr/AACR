/**
 * Created by lauren.lezberg on 7/22/2019.
 */
@isTest
private with sharing class CommitteeCreationTriggerTest {

    @testSetup public static void setup(){
        Account acc = TestDataFactory.buildAccount('Test Account');
        insert acc;

        Contact con = TestDataFactory.buildContact(acc.Id);
        insert con;

        User u = TestDataFactory.buildUser(con.Id);
        insert u;

        OrderApi__Item_Class__c itemClass = TestDataFactory.buildItemClass('Working Groups');
        insert itemClass;

        OrderApi__Item__c item = TestDataFactory.buildItem(itemClass.Id, 'Chemistry in Cancer Research (CICR)');
        insert item;

        Committee__c committee = TestDataFactory.buildCommitteeWG('Chemistry in Cancer Research (CICR)');
        insert committee;

        OrderApi__Sales_Order__c so = TestDataFactory.buildOpenSalesOrder(acc.Id, con.Id);
        insert so;

        OrderApi__Sales_Order_Line__c sol = TestDataFactory.buildSOLine(so.Id, item.Id, itemClass.Id);
        insert sol;

    }

    @isTest
    public static void test_CreateCommittees(){
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

            OrderApi__Item_Class__c itemClass = [SELECT Id FROM OrderApi__Item_Class__c WHERE Name='Working Groups'];
            OrderApi__Item__c item2 = TestDataFactory.buildItem(itemClass.Id, 'Women in Cancer Research (WICR)');
            insert item2;
            Committee__c committee2 = TestDataFactory.buildCommitteeWG('Women in Cancer Research (WICR)');
            insert committee2;
            OrderApi__Sales_Order_Line__c sol = TestDataFactory.buildSOLine(so.Id, item2.Id, itemClass.Id);
            insert sol;

            OrderApi__Receipt__c receipt2 = new OrderApi__Receipt__c(
                    OrderApi__Contact__c = so.OrderApi__Contact__c,
                    OrderApi__Entity__c = 'Contact',
                    OrderApi__Is_Posted__c = true,
                    OrderApi__Sales_Order__c = so.Id
            );
            insert receipt2;


            Test.stopTest();

        }
    }

}