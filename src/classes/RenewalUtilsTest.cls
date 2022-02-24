/**
 * Created by lauren.lezberg on 2/6/2019.
 */
@isTest 
private with sharing class RenewalUtilsTest { 
    @testSetup static void setup(){
        Account acc = TestDataFactory.buildAccount('Test Account');
        insert acc;
        Contact testContact = TestDataFactory.buildContactMemberPrior(acc.Id);
        insert testContact;

        User u = TestDataFactory.buildUser(testContact.Id);
        insert u;
        // Build OrderApi__Item_Class__c record
        OrderApi__Item_Class__c itemClass = TestDataFactory.buildItemClass('Individual Memberships');
        insert itemClass;
        // Build Prior Dues OrderApi__Item_Class__c record
        OrderApi__Item_Class__c duesItemClass = TestDataFactory.buildItemClass('Prior Year Dues');
        insert duesItemClass;
        //build journal class
        OrderApi__Item_Class__c journalClass = TestDataFactory.buildItemClass('Journal Subscriptions');
        insert journalClass;


        // Build Business_Group__c record
        OrderApi__Business_Group__c bg = TestDataFactory.buildMasterBusinessGroup();
        insert bg;
        // Build OrderApi__Item__c record
        OrderApi__Item__c item = TestDataFactory.buildItem(itemClass.Id, 'Active Membership');
        item.Managed__c = true;
        item.OrderApi__Business_Group__c = bg.Id;
        insert item;
        // Build Dues OrderApi__Item__c record
        OrderApi__Item__c duesItem = TestDataFactory.buildItem(duesItemClass.Id, '2YR Dues');
        duesItem.OrderApi__Business_Group__c = bg.Id;
        insert duesItem;
        //Build blood cancer journal item
        OrderApi__Item__c bloodCancerItem = TestDataFactory.buildItem(journalClass.Id, 'Blood Cancer Discovery - Online');
        insert bloodCancerItem;
        // Build OrderApi__Subscription_Plan__c record
        OrderApi__Subscription_Plan__c subPlan = TestDataFactory.buildsubPlan();
        insert subPlan;
        System.assertEquals(1, [SELECT Id FROM OrderApi__Subscription_Plan__c].size());

        OrderApi__Item_Subscription_Plan__c mItemSubPlan1 = new OrderApi__Item_Subscription_Plan__c(OrderApi__Is_Default__c=true, OrderApi__Item__c=item.Id, OrderApi__Subscription_Plan__c=subPlan.Id);
        insert mItemSubPlan1;

        OrderApi__Subscription_Plan__c subPlan2 = TestDataFactory.buildsubPlan();
        subPlan2.Name='2YR Membership';
        subPlan2.OrderApi__Advanced_Calendar_Days__c = 365;
        subPlan2.Show_In_Portal__c = false;
        insert subPlan2;
        System.assertEquals(2, [SELECT Id FROM OrderApi__Subscription_Plan__c].size());

        OrderApi__Item_Subscription_Plan__c mItemSubPlan2 = new OrderApi__Item_Subscription_Plan__c(OrderApi__Item__c=item.Id, OrderApi__Subscription_Plan__c=subPlan2.Id);
        insert mItemSubPlan2;

        // Build OrderApi__Subscription__c record
        OrderApi__Subscription__c subscription = TestDataFactory.buildExpiredSubscription(testContact.Id, subPlan.Id, item.Id, itemClass.Id );
        insert subscription;
        System.assertEquals(1, [SELECT Id FROM OrderApi__Subscription__c].size());

        //Build OrderApi__Subscription_Line__c record
        OrderApi__Subscription_Line__c  subscriptionLine = TestDataFactory.buildSubscriptionLine(subscription.Id, item.Id, itemClass.Id);
        insert subscriptionLine;
        System.assertEquals(1, [SELECT Id FROM OrderApi__Subscription_Line__c].size());

        Renewal_Settings__c renewalProcess = new Renewal_Settings__c(Is_Active__c = true, Term_Year__c = Datetime.now().year() + 1);
        insert renewalProcess;

        DW_Manage_Dues_Item__c DWduesItem = new DW_Manage_Dues_Item__c(Delinquent_Years__c=2, Membership_Item_Name__c='2YR Dues', Name='2YR Dues');
        insert DWduesItem;
        
    }

    @isTest
    public static void testCreateSalesOrderLI(){
        Contact priorMember = [SELECT Id, AccountId, Membership_Status__c, RecordType.Name, Paid_thru_date__c FROM Contact ];
        priorMember.Membership_Status__c = '1-YR Suspended';
        update priorMember;

        OrderApi__Sales_Order__c SO = TestDataFactory.buildOpenSalesOrder(priorMember.AccountId, priorMember.Id );
        insert SO;

        OrderApi__Subscription__c sub = [SELECT Id FROM OrderApi__Subscription__c WHERE OrderApi__Contact__c=:priorMember.Id];

        OrderApi__Item__c item = [SELECT Id, OrderApi__Item_Class__c FROM OrderApi__Item__c WHERE Name='Active Membership'];

        Test.startTest();
        OrderApi__Sales_Order_Line__c line = RenewalUtils.createSalesOrderLI(SO.Id, item, sub);
        insert line;
        Test.stopTest();

        Integer solCount = [SELECT COUNT() FROM OrderApi__Sales_Order_Line__c WHERE OrderApi__Sales_Order__c=:SO.Id];
        System.assertEquals(1, solCount);
    }

    @isTest
    public static void testROERenew_RenewalsOff(){
        Renewal_Settings__c renewalProcess = [SELECT Id, Is_Active__c FROM Renewal_Settings__c LIMIT 1];
        renewalProcess.Is_Active__c = false;
        update renewalProcess;

        Contact priorMember = [SELECT Id, Membership_Status__c, RecordType.Name, Paid_thru_date__c FROM Contact];
        priorMember.Membership_Status__c = '2-YR Suspended';
        update priorMember;

        Test.startTest();
        Boolean canRenew = RenewalUtils.canRenew(priorMember.Id);
        System.assertEquals(true, canRenew);

        JP_Helper.JPResponse renewResponse = RenewalUtils.processROERenew(priorMember.Id);
        System.assertNotEquals(null, renewResponse);
        System.assertEquals(true, renewResponse.isSuccess);

        Test.stopTest();
    }

    @isTest
    public static void testROERenew(){
        Contact priorMember = [SELECT Id, Membership_Status__c, RecordType.Name, Paid_thru_date__c FROM Contact];
        priorMember.Membership_Status__c = '2-YR Suspended';
        update priorMember;

        Test.startTest();
        JP_Helper.JPResponse renewResponse = RenewalUtils.processROERenew(priorMember.Id);
        System.assertNotEquals(null, renewResponse);
        System.assertEquals(true, renewResponse.isSuccess);

        Test.stopTest();
    }

    @isTest
    public static void testPortalRenew(){
        Contact priorMember = [SELECT Id, Membership_Status__c, RecordType.Name, Paid_thru_date__c FROM Contact];
        priorMember.Membership_Status__c = '1-YR Suspended';
        update priorMember;

        Test.startTest();
        Boolean canRenewPrior = RenewalUtils.canRenew(priorMember.Id);
        System.assertEquals(true, canRenewPrior);

        DW_ECRMDTO.Response renewResponse = RenewalUtils.renewSubscriptions(priorMember, false);
        System.assertNotEquals(null, renewResponse);
        System.assertEquals(true, renewResponse.isSuccess);

        renewResponse = RenewalUtils.renewSubscriptions(priorMember, true);
        System.assertNotEquals(null, renewResponse);
        System.assertEquals(true, renewResponse.isSuccess);

        Test.stopTest();
    }

    @isTest
    public static void testCanRenew(){
        Contact testContact = [SELECT Id, AccountId FROM Contact LIMIT 1];

        Test.startTest();
        Boolean canRenew = RenewalUtils.canRenew(testContact.Id);
        System.assertEquals(true, canRenew);

        Contact testContact2 = TestDataFactory.buildContactMemberCurrent(testContact.AccountId);
        insert testContact2;

        OrderApi__Item__c membership = [SELECT OrderApi__Item_Class__c, Id FROM OrderApi__Item__c WHERE Name='Active Membership'];
        OrderApi__Subscription_Plan__c subPlan = [SELECT Id FROM OrderApi__Subscription_Plan__c LIMIT 1];

        OrderApi__Subscription__c sub = TestDataFactory.buildSubscription(testContact2.Id, subPlan.Id, membership.Id, membership.OrderApi__Item_Class__c);
        insert sub;

        OrderApi__Subscription_Line__c subLine = TestDataFactory.buildSubscriptionLine(sub.Id, membership.Id, membership.OrderApi__Item_Class__c);
        insert subLine;


        Renewal_Settings__c renewalProcess = [SELECT Id, Term_Year__c, Is_Active__c FROM Renewal_Settings__c LIMIT 1];

        //test canRenew in current year
        canRenew = RenewalUtils.canRenew(testContact2.Id);
        if(renewalProcess.Is_Active__c && renewalProcess.Term_Year__c > System.now().year()){
            System.assertEquals(true, canRenew);
        } else {
            System.assertEquals(false, canRenew);
        }




        Test.stopTest();
    }


    @isTest
    public static void testCanPerformROERenew(){
        User u = [SELECT Id FROM User LIMIT 1];
        Contact testContact = [SELECT Id, AccountId FROM Contact LIMIT 1];

        System.runAs(u){
            Boolean canROERenew = RenewalUtils.canPerformROERenew(testContact.Id);
            System.assertEquals(false, canROERenew);
        }
    }

    @isTest
    public static void testGetRenewalURL(){
        OrderApi__Item__c item = [SELECT Id, OrderApi__Item_Class__c FROM OrderApi__Item__c LIMIT 1];
        Contact testContact = [SELECT Id, AccountId FROM Contact LIMIT 1];

        OrderApi__Sales_Order__c so = TestDataFactory.buildOpenSalesOrder(testContact.AccountId, testContact.Id);
        insert so;
        OrderApi__Sales_Order_Line__c soLine = TestDataFactory.buildSOLine(so.Id, item.Id, item.OrderApi__Item_Class__c);
        insert soLine;

        Test.startTest();
        String renewURL = RenewalUtils.getRenewURL(testContact.Id, so.Id);

        System.assertNotEquals(renewURL, null);
        Test.stopTest();
    }




}