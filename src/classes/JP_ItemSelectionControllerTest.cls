/**
 * Created by lauren.lezberg on 2/5/2019.
 */
@isTest
private with sharing class JP_ItemSelectionControllerTest { 

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


    }


    @isTest
    static void testJournals(){
        Contact testContact = [SELECT Id FROM Contact LIMIT 1];
        User u = [SELECT Id FROM User WHERE ContactId =: testContact.Id];
        OrderApi__Sales_Order__c so = [SELECT Id FROM OrderApi__Sales_Order__c LIMIT 1];

        Join_Process__mdt jp = [SELECT Id FROM Join_Process__mdt WHERE Item__c LIKE: '%Active Membership%' AND Is_Renewal__c = false];
        Process_Steps__mdt step = [SELECT Id FROM Process_Steps__mdt WHERE Process__c =: jp.Id AND Join_Step__r.DeveloperName ='Journal_Selections'];

        System.runAs(u) {
            Test.startTest();
            List<JP_ItemSelectionController.JournalItemData> journals = JP_ItemSelectionController.getJournals(so.Id);
            System.assert(journals.size()>0, 'List of journals should have at least one');
            JP_ItemSelectionController.JournalData journalData = JP_ItemSelectionController.getJournalData(so.Id, step.Id);
            JP_ItemSelectionController.CompJournalData compData = JP_ItemSelectionController.getCompJournalOptions(so.Id);
            //make item selections
            List<OrderApi__Item__c> items = [SELECT Id FROM OrderApi__Item__c WHERE OrderApi__Item_Class__r.Name = 'Journal Subscriptions' OR OrderApi__Item_Class__r.Name='Complimentary Journals'];
            List<Id> selectedItems = new List<Id>();
            for(OrderApi__Item__c item : items){
                selectedItems.add(item.Id);
            }
            //save new selection
            JP_Helper.JPError response = JP_ItemSelectionController.saveJournalSelections(so.Id, selectedItems, step.Id);
            Test.stopTest();

            List<OrderApi__Sales_Order_Line__c> lines = [SELECT Id FROM OrderApi__Sales_Order_Line__c WHERE OrderApi__Sales_Order__c =: so.Id];

            System.assertNotEquals(null, journalData);
            System.assertNotEquals(null, compData);
            System.assertNotEquals(null, response);
            System.assertEquals(true, response.isSuccess);
            System.assertEquals(6, lines.size());
        }
    }

    @isTest
    static void testWorkingGroups(){
        Contact testContact = [SELECT Id FROM Contact LIMIT 1];
        User u = [SELECT Id FROM User WHERE ContactId =: testContact.Id];
        OrderApi__Sales_Order__c so = [SELECT Id FROM OrderApi__Sales_Order__c LIMIT 1];

        Join_Process__mdt jp = [SELECT Id FROM Join_Process__mdt WHERE Item__c LIKE: '%Active Membership%' AND Is_Renewal__c = false];
        Process_Steps__mdt step = [SELECT Id FROM Process_Steps__mdt WHERE Process__c =: jp.Id AND Join_Step__r.DeveloperName ='Working_Groups'];

        System.runAs(u) {
            Test.startTest();
            List<JP_ItemSelectionController.AddOnItem> workingGroupData = JP_ItemSelectionController.getWorkingGroupData(so.Id, step.Id);

            //make item selections
            List<OrderApi__Item__c> items = [SELECT Id FROM OrderApi__Item__c WHERE OrderApi__Item_Class__r.Name = 'Working Groups'];
            List<Id> selectedItems = new List<Id>();
            for(OrderApi__Item__c item : items){
                selectedItems.add(item.Id);
            }
            //save new selection
            JP_Helper.JPError response = JP_ItemSelectionController.saveWorkingGroupSelections(so.Id, selectedItems, step.Id);
            Test.stopTest();

            List<OrderApi__Sales_Order_Line__c> lines = [SELECT Id FROM OrderApi__Sales_Order_Line__c WHERE OrderApi__Sales_Order__c =: so.Id];

            System.assertNotEquals(null, workingGroupData);
            System.assertEquals(2, workingGroupData.size());
            System.assertEquals(true, response.isSuccess);
            System.assertEquals(6, lines.size());
        }
    }

    @isTest
    static void testOptionalItems(){
        Contact testContact = [SELECT Id FROM Contact LIMIT 1];
        User u = [SELECT Id FROM User WHERE ContactId =: testContact.Id];
        OrderApi__Sales_Order__c so = [SELECT Id FROM OrderApi__Sales_Order__c LIMIT 1];

        Join_Process__mdt jp = [SELECT Id FROM Join_Process__mdt WHERE Item__c LIKE: '%Active Membership%' AND Is_Renewal__c = false];
        Process_Steps__mdt step = [SELECT Id FROM Process_Steps__mdt WHERE Process__c =: jp.Id AND Join_Step__r.DeveloperName ='Optional_Items'];

        System.runAs(u) {
            Test.startTest();
            List<JP_ItemSelectionController.AddOnItem> optionalItemData = JP_ItemSelectionController.getOptionalItemData(so.Id, step.Id);

            //make item selections
            List<OrderApi__Item__c> items = [SELECT Id FROM OrderApi__Item__c WHERE OrderApi__Item_Class__r.Name = 'Merchandise'];
            List<Id> selectedItems = new List<Id>();
            for(OrderApi__Item__c item : items){
                selectedItems.add(item.Id);
            }
            //save new selection
            JP_Helper.JPError response = JP_ItemSelectionController.saveOptionalItemSelections(so.Id, selectedItems, step.Id);
            Test.stopTest();

            List<OrderApi__Sales_Order_Line__c> lines = [SELECT Id FROM OrderApi__Sales_Order_Line__c WHERE OrderApi__Sales_Order__c =: so.Id];

            System.assertNotEquals(null, optionalItemData);
            System.assertEquals(2, optionalItemData.size());
            System.assertEquals(true, response.isSuccess);
            System.assertEquals(6, lines.size());

        }
    }
}