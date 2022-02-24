/**
 * Created by lauren.lezberg on 2/1/2019.
 */
@isTest 
private with sharing class JP_HelperTest {

    @testSetup static void setup(){ 
        Account acc = TestDataFactory.buildAccount('Test Account');
        insert acc;
        Contact testContact = TestDataFactory.buildContactMemberCurrent(acc.Id);
        insert testContact;
        User u = TestDataFactory.buildUser(testContact.Id);
        insert u;
        OrderApi__Sales_Order__c so = TestDataFactory.buildOpenSalesOrder(acc.Id, testContact.Id);
        insert so;

        OrderApi__Item_Class__c itemClass = TestDataFactory.buildItemClass('Individual Memberships');
        insert itemClass;
        OrderApi__Item__c item = TestDataFactory.buildItem(itemClass.Id, 'Active Membership');
        insert item;
        OrderApi__Item__c item2 = TestDataFactory.buildItem(itemClass.Id, 'Associate Membership');
        insert item2;

        OrderApi__Item_Class__c wgClass = TestDataFactory.buildItemClass('Working Groups');
        insert wgClass;
        OrderApi__Item__c wgItem = TestDataFactory.buildItem(wgClass.Id, 'Test Working Group');
        insert wgItem;

        OrderApi__Sales_Order_Line__c soLine = TestDataFactory.buildSOLine(so.Id, item.Id, itemClass.Id);
        insert soLine;
        OrderApi__Sales_Order_Line__c wgLine = TestDataFactory.buildSOLine(so.Id, wgItem.Id, wgClass.Id);
        insert wgLine;

        OrderApi__Badge_Type__c bt = TestDataFactory.buildBadgeType('Active Membership');
        insert bt;

        OrderApi__Price_Rule__c pr = new OrderApi__Price_Rule__c(OrderApi__Item__c = wgItem.Id, OrderApi__Required_Badge_Types__c = bt.Id, OrderApi__Price__c = 0.0, OrderApi__Is_Active__c = true);
        insert pr;

    }

    


    @isTest
    public static void testHandleLastAccessedStep(){
        Join_Process__mdt jp = [SELECT Id FROM Join_Process__mdt WHERE Item__c LIKE '%Active Membership%' AND Is_Renewal__c = false];
        Contact testContact = [SELECT Id FROM Contact LIMIT 1];
        User userRecord = [SELECT Id FROM User WHERE ContactId =: testContact.Id LIMIT 1];
        System.runAs(userRecord){
            Decimal lasStepOrder = JP_Helper.getLastAccessedStepOrder(jp.Id);
            System.assertEquals(lasStepOrder,1.0);

            JP_Helper.deleteContactLastAccessedStep(jp.Id);
            List<contact_last_accessed_step__c> las = [SELECT Id FROM contact_last_accessed_step__c WHERE Contact__c=: testContact.Id AND JoinId__c =: jp.Id];
            System.assert(las.isEmpty(), 'Last accessed step should be empty');

            List<Process_Steps__mdt> steps = [SELECT Id FROM Process_Steps__mdt WHERE Process__c =: jp.Id ORDER BY Step_Order__c ];
            JP_Helper.upsertLastAccessedStep(steps[0].Id);
            las = [SELECT Id, Step_Order__c FROM contact_last_accessed_step__c WHERE Contact__c=: testContact.Id AND JoinId__c =: jp.Id];
            System.assert(!las.isEmpty(), 'Last accessed step should not be empty');
            System.assertEquals(1.0, las[0].Step_Order__c);

        }

    }


    @isTest
    public static void testGetMostRecentSO(){
        Contact testContact = [SELECT Id, AccountId FROM Contact LIMIT 1];
        OrderApi__Sales_Order__c so = [SELECT Id FROM OrderApi__Sales_Order__c LIMIT 1];

        Test.startTest();
        OrderApi__Sales_Order__c recentSO = JP_Helper.getMostRecentSO(testContact.Id);
        Test.stopTest();

        System.assertEquals(so.Id, recentSO.Id);
    }


    @isTest
    public static void testGetAndSavePortalItems(){
        Contact testContact = [SELECT Id, AccountId, MailingCountryCode FROM Contact LIMIT 1];
        OrderApi__Sales_Order__c so = [SELECT Id FROM OrderApi__Sales_Order__c LIMIT 1];
        Set<String> classNames = new Set<String>();
        classNames.add('Individual Memberships');
        List<Id> selectedItems = new List<Id>();

        OrderApi__Subscription_Plan__c subPlan = TestDataFactory.buildsubPlan();
        insert subPlan;



        Test.startTest();
        //get all portal items
        List<OrderApi__Item__c> items = JP_Helper.getPortalItemsByClass(classNames);
        System.assertEquals(2, items.size());

        OrderApi__Subscription__c sub = TestDataFactory.buildSubscription(testContact.Id, subPlan.Id, items[0].Id, items[0].OrderApi__Item_Class__c );
        insert sub;

        //get items price map
        Map<Id, Decimal> priceMap = JP_Helper.getItemPriceMap(items, testContact, null, null, null, so.Id);
        System.assertNotEquals(priceMap, null);

        //add items to selected list
        selectedItems.add(items[0].Id);
        selectedItems.add(items[1].Id);

        //save item selections as sales order lines
        JP_Helper.JPError returnMessage = JP_Helper.saveItemSelections(classNames, so.Id, selectedItems);
        Integer lines = [SELECT COUNT() FROM OrderApi__Sales_Order_Line__c WHERE OrderApi__Sales_Order__c=: so.Id];
        System.assertEquals(returnMessage.isSuccess, true);
        System.assertEquals(3, lines);

        Test.stopTest();

    }

    @isTest
    public static void testCreateNewMemberSO(){
        Contact testContact = [SELECT Id, AccountId FROM Contact LIMIT 1];
        OrderApi__Item__c item = [SELECT Id, OrderApi__Business_Group__c, OrderApi__Item_Class__c FROM OrderApi__Item__c LIMIT 1];

        OrderApi__Sales_Order__c newSO = JP_Helper.createNewMemberSOWithLine(testContact, item);

        System.assertNotEquals(newSO, null);
    }

    @isTest
    public static void testCreateReinstateTransferSO(){
        Contact testContact = [SELECT Id, AccountId FROM Contact LIMIT 1];
        OrderApi__Item__c item = [SELECT Id, OrderApi__Business_Group__c, OrderApi__Item_Class__c FROM OrderApi__Item__c LIMIT 1];

        OrderApi__Sales_Order__c newSO = JP_Helper.createReinstateTransferSOWithLine(testContact, item);

        System.assertNotEquals(newSO, null);
    }

    @isTest
    public static void testCreateTransferSO(){
        Contact testContact = [SELECT Id, AccountId FROM Contact LIMIT 1];
        OrderApi__Item__c item = [SELECT Id, OrderApi__Business_Group__c, OrderApi__Item_Class__c FROM OrderApi__Item__c LIMIT 1];

        OrderApi__Sales_Order__c newSO = JP_Helper.createTransferSOWithLine(testContact, item);

        System.assertNotEquals(newSO, null);
    }



}