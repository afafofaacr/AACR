/**
 * Created by lauren.lezberg on 5/12/2020.
 */
@isTest
private with sharing class BackOfficeTicketPurchaseControllerTest {


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

        BackOfficeTicketPurchaseController.TicketAccess ta = BackOfficeTicketPurchaseController.checkAccess(con.Id);
        System.assertEquals(true, ta.hasAccess);
        System.assertEquals(false, ta.hasDisabledAccess);


        System.runAs(u){
            ta = BackOfficeTicketPurchaseController.checkAccess(con.Id);
            System.assertEquals(false, ta.hasAccess);
        }

        Test.stopTest();

    }

    @isTest
    public static void test_createBackOfficeTicketSO(){
        Contact con = [SELECT Id FROM Contact WHERE Account.Name='Test Account'];

        Test.startTest();
        BackOfficeTicketPurchaseController.TicketingInfo tInfo = BackOfficeTicketPurchaseController.createBackOfficeTicketSO(con.Id);
        System.assert(tInfo!=null,'Ticket Info should not be null');
        System.assert(tInfo.salesOrderId!=null,'SalesOrderId should not be null');
        System.assert(tInfo.joinId!=null,'JoinId should not be null');

        OrderApi__Sales_Order__c SO = [SELECT Id FROM OrderApi__Sales_Order__c WHERE OrderApi__Contact__c=:con.Id];
        System.assert(SO!=null, 'Contact should have a sales order');
        System.assertEquals(SO.Id, tInfo.salesOrderId);

        Test.stopTest();
    }

    @isTest
    public static void test_exception(){
        Account acc = LiveTestDataFactory.buildAccount('Test Account');
        insert acc;

        Test.startTest();

        BackOfficeTicketPurchaseController.TicketingInfo tInfo = BackOfficeTicketPurchaseController.createBackOfficeTicketSO(acc.Id);

        Test.stopTest();
    }
}