/**
 * Created by lauren.lezberg on 7/12/2021.
 */

@IsTest
private class InvoicePaymentControllerTest {
    @TestSetup
    public static void setup(){
        Account acc = TestDataFactory.buildAccount('Test Account');
        insert acc;

        Contact con = TestDataFactory.buildContact(acc.Id);
        insert con;

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
    static void test_getInvoice() {
        Contact con = [SELECT Id FROM Contact WHERE Account.Name = 'Test Account'];
        OrderApi__Sales_Order__c so = [SELECT Id, OrderApi__Contact__c, OrderApi__Total__c FROM OrderApi__Sales_Order__c WHERE OrderApi__Contact__c=:con.Id];
        OrderApi__Invoice__c inv = [SELECT Id FROM OrderApi__Invoice__c WHERE OrderApi__Sales_Order__c=:so.Id];

        Test.startTest();

        OrderApi__Invoice__c newInv = InvoicePaymentController.getInvoice(inv.Id);
        System.assertNotEquals(null, newInv);

        Test.stopTest();
    }
}