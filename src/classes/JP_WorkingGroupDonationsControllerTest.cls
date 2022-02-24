/**
 * Created by lauren.lezberg on 8/28/2019.
 */
@isTest
private with sharing class JP_WorkingGroupDonationsControllerTest {

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

        // adding working group items
        OrderApi__Item_Class__c workingGroupClass = TestDataFactory.buildItemClass('Working Groups');
        insert workingGroupClass;
        OrderApi__Item__c workingGroupItem1 = TestDataFactory.buildItem(workingGroupClass.Id, 'Test Working Group 1');
        insert workingGroupItem1;
        OrderApi__Item__c workingGroupItem2 = TestDataFactory.buildItem(workingGroupClass.Id, 'Test Working Group 2');
        insert workingGroupItem2;

        // adding working group items
        OrderApi__Item_Class__c WGDonationClass1 = TestDataFactory.buildItemClass('Test Working Group 1 Donations');
        insert WGDonationClass1;
//        OrderApi__Item__c donationItem1 = TestDataFactory.buildItem(WGDonationClass1.Id, 'No Donation');
//        donationItem1.OrderApi__Price__c = 0.0;
//        insert donationItem1;
        OrderApi__Item__c donationItem2 = TestDataFactory.buildItem(WGDonationClass1.Id, '$25 Donation');
        donationItem2.OrderApi__Price__c = 25.0;
        insert donationItem2;

        OrderApi__Item_Class__c WGDonationClass2 = TestDataFactory.buildItemClass('Test Working Group 2 Donations');
        insert WGDonationClass2;
//        OrderApi__Item__c donationItem3 = TestDataFactory.buildItem(WGDonationClass2.Id, 'No Donation');
//        donationItem3.OrderApi__Price__c = 0.0;
//        insert donationItem3;
        OrderApi__Item__c donationItem4 = TestDataFactory.buildItem(WGDonationClass2.Id, '$25 Donation');
        donationItem4.OrderApi__Price__c = 25.0;
        insert donationItem4;

        //create sales order and sales order lines
        OrderApi__Sales_Order__c so = TestDataFactory.buildOpenSalesOrder(acc.Id, testContact.Id);
        insert so;
        OrderApi__Sales_Order_Line__c soLine1 = TestDataFactory.buildSOLine(so.Id, item.Id, itemClass.Id);
        insert soLine1;
        OrderApi__Sales_Order_Line__c soLine2  = TestDataFactory.buildSOLine(so.Id, workingGroupItem1.Id, workingGroupClass.Id);
        insert soLine2;
        OrderApi__Sales_Order_Line__c soLine3  = TestDataFactory.buildSOLine(so.Id, donationItem2.Id, WGDonationClass1.Id);
        insert soLine3;
    }


    @isTest
    public static void test_getWorkingGroupDonationItems(){
        Contact con = [SELECT Id FROM Contact WHERE Account.Name='Test Account' LIMIT 1];
        OrderApi__Sales_Order__c so = [SELECT Id FROM OrderApi__Sales_Order__c WHERE OrderApi__Contact__c =: con.Id LIMIT 1];

        User u = [SELECT Id FROM User WHERE ContactId=: con.Id];


        System.runAs(u){
            List<JP_WorkingGroupDonationsController.WorkingGroupDonationItem> wgDonationItems = JP_WorkingGroupDonationsController.getWorkingGroupDonationItems(so.Id, null);
            System.assertNotEquals(null, wgDonationItems);
            System.assertEquals(1, wgDonationItems.size());
            System.assertEquals(1, wgDonationItems[0].donationItems.size());
        }
    }

    @isTest
    public static void test_saveWorkingGroupDonationItems(){
        List<String> selectedIds = new List<String>();
        List<OrderApi__Item__c> items = [SELECT Id FROM OrderApi__Item__c WHERE OrderApi__Item_Class__r.Name='Test Working Group 2 Donations'];
        for(OrderApi__Item__c item: items){
            selectedIds.add(item.Id);
        }

        Contact con = [SELECT Id FROM Contact WHERE Account.Name='Test Account' LIMIT 1];
        OrderApi__Sales_Order__c so = [SELECT Id FROM OrderApi__Sales_Order__c WHERE OrderApi__Contact__c =: con.Id LIMIT 1];

        OrderApi__Item__c wgItem = [SELECT Id, OrderApi__Item_Class__c FROM OrderApi__Item__c WHERE Name='Test Working Group 2'];

        OrderApi__Sales_Order_Line__c soLine4  = TestDataFactory.buildSOLine(so.Id, wgItem.Id, wgItem.OrderApi__Item_Class__c);
        insert soLine4;

        Integer linesCount = [SELECT COUNT() FROM OrderApi__Sales_Order_Line__c WHERE OrderApi__Sales_Order__c=: so.Id];

        User u = [SELECT Id FROM User WHERE ContactId=: con.Id];
        System.runAs(u){
            Boolean success = JP_WorkingGroupDonationsController.saveWorkingGroupDonations(so.Id, selectedIds);
            System.assertEquals(true, success);

            Integer newLineCount = [SELECT COUNT() FROM OrderApi__Sales_Order_Line__c WHERE OrderApi__Sales_Order__c =: so.Id];
            System.assertEquals(linesCount, newLineCount);
        }

    }

}