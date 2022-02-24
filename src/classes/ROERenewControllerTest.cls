/**
 * Created by lauren.lezberg on 8/28/2019.
 */
@isTest
private with sharing class ROERenewControllerTest {

    @testSetup
    public static void setup(){
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
        // Build OrderApi__Item__c record
        OrderApi__Item__c item = TestDataFactory.buildItem(itemClass.Id, 'Active Membership');
        insert item;
        // Build Dues OrderApi__Item__c record
        OrderApi__Item__c duesItem = TestDataFactory.buildItem(duesItemClass.Id, '2YR Dues');
        insert duesItem;
        // Build OrderApi__Subscription_Plan__c record
        OrderApi__Subscription_Plan__c subPlan = TestDataFactory.buildsubPlan();
        insert subPlan;
        System.assertEquals(1, [SELECT Id FROM OrderApi__Subscription_Plan__c].size());

        OrderApi__Subscription_Plan__c subPlan2 = TestDataFactory.buildsubPlan();
        subPlan2.Name='2YR Membership';
        subPlan2.OrderApi__Advanced_Calendar_Days__c = 365;
        subPlan2.Show_In_Portal__c = false;
        insert subPlan2;
        System.assertEquals(2, [SELECT Id FROM OrderApi__Subscription_Plan__c].size());

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
    public static void test_getRenewalInfo(){
        Contact con = [SELECT Id FROM Contact WHERE Account.Name='Test Account'];

        Test.startTest();
        ROERenewController.RenewInfo rInfo = ROERenewController.getRenewalInfo(con.Id);
        System.assertEquals(true, rInfo.showRenewButton);
        System.assertNotEquals(null, rInfo.joinId);
        Test.stopTest();

    }

    @isTest
    public static void test_processROERenew(){
        Contact con = [SELECT Id FROM Contact WHERE Account.Name='Test Account'];

        Test.startTest();
        JP_Helper.JPResponse response = ROERenewController.processROERenew(con.Id);
        System.assertEquals(true, response.isSuccess);

        Test.stopTest();
    }
}