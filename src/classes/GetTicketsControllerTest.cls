/**
 * Created by lauren.lezberg on 10/11/2019.
 */
@isTest
private with sharing class GetTicketsControllerTest {

    @testSetup
    public static void setup(){
        Account acc = TestDataFactory.buildAccount('Test Account');
        insert acc;

        Contact con = TestDataFactory.buildContact(acc.Id);
        insert con;

        User u = TestDataFactory.buildUser(con.Id);
        insert u;



    }

    @isTest
    public static void test_checkAccess(){
        Contact con = [SELECT Id FROM Contact WHERE Account.Name='Test Account'];
        User u = [SELECT Id FROM User WHERE ContactId=:con.Id];

        Test.startTest();

        Boolean hasAccess = GetTicketsController.checkAccess();
        System.assertEquals(true, hasAccess);

        System.runAs(u){
            hasAccess = GetTicketsController.checkAccess();
            System.assertEquals(false, hasAccess);
        }

        Test.stopTest();

    }

    @isTest
    public static void test_createTicketSalesOrder(){
        Contact con = [SELECT Id FROM Contact WHERE Account.Name='Test Account'];

        Test.startTest();
        GetTicketsController.TicketingInfo tInfo = GetTicketsController.createBackOfficeTicketSO(con.Id);
        System.assert(tInfo!=null,'Ticket Info should not be null');
        System.assert(tInfo.salesOrderId!=null,'SalesOrderId should not be null');
        System.assert(tInfo.joinId!=null,'JoinId should not be null');

        OrderApi__Sales_Order__c SO = [SELECT Id FROM OrderApi__Sales_Order__c WHERE OrderApi__Contact__c=:con.Id];
        System.assert(SO!=null, 'Contact should have a sales order');
        System.assertEquals(SO.Id, tInfo.salesOrderId);

        Test.stopTest();
    }
}