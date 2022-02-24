/**
 * Created by lauren.lezberg on 7/12/2021.
 */

@IsTest
private class OfflinePaymentControllerTest {
    @TestSetup
    public static void setup(){
        Account acc = TestDataFactory.buildAccount('Test Account');
        insert acc;

        Contact con = TestDataFactory.buildContact(acc.Id);
        insert con;

        OrderApi__Business_Group__c bg = TestDataFactory.buildMasterBusinessGroup();
        bg.Name = 'American Association for Cancer Research';
        insert bg;

        Appeal_Code__c appealCode = new Appeal_Code__c(Name = 'Test Appeal Code');
        insert appealCode;

        //adding membership item
        OrderApi__Item_Class__c itemClass = TestDataFactory.buildItemClass('Individual Memberships');
        insert itemClass;
        OrderApi__Item__c item = TestDataFactory.buildItem(itemClass.Id, 'Active Membership');
        insert item;

        //create sales order and sales order lines
        OrderApi__Sales_Order__c so = TestDataFactory.buildOpenSalesOrder(acc.Id, con.Id);
        so.OrderApi__Status__c = 'Closed';
        insert so;

        OrderApi__Sales_Order_Line__c soLine1 = TestDataFactory.buildSOLine(so.Id, item.Id, itemClass.Id);
        insert soLine1;

        OrderApi__Invoice__c inv = new OrderApi__Invoice__c(OrderApi__Sales_Order__c=so.Id, OrderApi__Contact__c= so.OrderApi__Contact__c, OrderApi__Amount_Paid__c=0.0);
        insert inv;

        OrderApi__Invoice_Line__c invLine = new OrderApi__Invoice_Line__c(OrderApi__Invoice__c=inv.Id, OrderApi__Item__c=item.Id);
        insert invLine;

    }

    @IsTest
    static void test_getPaymentInfo() {
        Contact con = [SELECT Id FROM Contact WHERE Account.Name = 'Test Account'];
        OrderApi__Sales_Order__c so = [SELECT Id, OrderApi__Contact__c, OrderApi__Total__c FROM OrderApi__Sales_Order__c WHERE OrderApi__Contact__c=:con.Id];

        Test.startTest();

        OfflinePaymentController.OfflinePaymentInfo opi = OfflinePaymentController.getPaymentInfo(so.Id);
        System.assertEquals(opi.so.Id, so.Id);
        System.assertEquals(opi.so.OrderApi__Total__c, so.OrderApi__Total__c);

        Test.stopTest();

    }

    @IsTest
    static void test_finalizePayment() {
        Contact con = [SELECT Id FROM Contact WHERE Account.Name = 'Test Account'];
        OrderApi__Sales_Order__c so = [SELECT Id, OrderApi__Contact__c, OrderApi__Total__c FROM OrderApi__Sales_Order__c WHERE OrderApi__Contact__c=:con.Id];

        OrderApi__Receipt__c receipt = new OrderApi__Receipt__c(OrderApi__Sales_Order__c= so.Id, OrderApi__Contact__c=con.Id);
        insert receipt;

        Test.startTest();

        OfflinePaymentController.finishOfflinePayment(receipt.Id, so.Id, 315.00);

        Test.stopTest();

        Integer recLineCount = [SELECT COUNT() FROM OrderApi__Receipt_Line__c WHERE OrderApi__Receipt__c=:receipt.Id];
        System.assertEquals(1, recLineCount);

        receipt = [SELECT OrderApi__Is_Posted__c FROM OrderApi__Receipt__c WHERE Id=: receipt.Id];
        System.assertEquals(true, receipt.OrderApi__Is_Posted__c);

    }
}