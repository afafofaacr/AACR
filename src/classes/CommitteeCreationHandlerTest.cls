/**
 * Created by afaf.awad on 9/29/2020.
 */
@isTest
private with sharing class CommitteeCreationHandlerTest {

    @testSetup public static void setup() {
        Account acc = TestDataFactory.buildAccount('Test Account');
        insert acc;

        Contact con = TestDataFactory.buildContact(acc.Id);
        insert con;

        User u = TestDataFactory.buildUser(con.Id);
        insert u;

        //Appeal code AND gl for Opportunity
        Appeal_Code__c appealCode = new Appeal_Code__c(Name = 'Test Appeal Code');
        insert appealCode;
        OrderApi__GL_Account__c glAccount = TestDataFactory.buildGLAccount();
        glAccount.Distribution_Code__c = true;
        insert glAccount;

        OrderApi__Item_Class__c itemClass = TestDataFactory.buildItemClass('Working Groups');
        insert itemClass;

        OrderApi__Item__c item = TestDataFactory.buildItem(itemClass.Id, 'Chemistry in Cancer Research (CICR)');
        insert item;

        OrderApi__Sales_Order__c so = TestDataFactory.buildOpenSalesOrder(acc.Id, con.Id);
        insert so;

        OrderApi__Sales_Order_Line__c sol = TestDataFactory.buildSOLine(so.Id, item.Id, itemClass.Id);
        insert sol;
    }

    @isTest
    public static void test_createWGCommittees() {
        OrderApi__Sales_Order__c so = [SELECT Id, OrderApi__Posting_Status__c, OrderApi__Status__c, OrderApi__Contact__c FROM OrderApi__Sales_Order__c];
        User u = [SELECT Id FROM User WHERE ContactId = :so.OrderApi__Contact__c];

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
    }

}