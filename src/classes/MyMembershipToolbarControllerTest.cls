/**
 * Created by lauren.lezberg on 5/24/2021.
 */

@IsTest
private class MyMembershipToolbarControllerTest {

    @testSetup
    public static void setup(){
        Account acc = TestDataFactory.buildAccount('Test Account');
        insert acc;

        Contact con = TestDataFactory.buildContactMemberCurrent(acc.Id);
        insert con;

        User u = TestDataFactory.buildUser(con.Id);
        insert u;

        OrderApi__Subscription_Plan__c subPlan1 = TestDataFactory.buildsubPlan();
        insert subPlan1;

        OrderApi__Subscription_Plan__c subPlan2 = TestDataFactory.buildsubPlan();
        subPlan2.Name='NDPM Standard';
        insert subPlan2;

        OrderApi__Subscription_Plan__c subPlan3 = TestDataFactory.buildsubPlan();
        subPlan3.Name='2YR Membership';
        subPlan3.OrderApi__Advanced_Calendar_Days__c = 365;
        subPlan3.Show_In_Portal__c = false;
        insert subPlan3;

        OrderApi__Subscription_Plan__c lifetimePlan = TestDataFactory.buildsubPlan();
        lifetimePlan.Name='Lifetime';
        lifetimePlan.Show_In_Portal__c = false;
        lifetimePlan.OrderApi__Type__c = 'Lifetime';
        insert lifetimePlan;

        //BUILD ITEM CLASSES
        OrderApi__Item_Class__c membershipClass = TestDataFactory.buildItemClass('Individual Memberships');
        insert membershipClass;

        OrderApi__Item_Class__c journalClass = TestDataFactory.buildItemClass('Journal Subscriptions');
        insert journalClass;

        //BUILD ITEMS
        OrderApi__Item__c activeMembership = TestDataFactory.buildItem(membershipClass.Id, 'Active Membership');
        activeMembership.Show_In_Portal__c = true;
        activeMembership.OrderApi__Is_Active__c = true;
        activeMembership.Managed__c = true;
        insert activeMembership;
        OrderApi__Item__c associateMembership = TestDataFactory.buildItem(membershipClass.Id, 'Associate Membership');
        associateMembership.OrderApi__Is_Active__c = true;
        associateMembership.Is_Active_Membership_Type__c = false;
        associateMembership.Show_In_Portal__c = true;
        insert associateMembership;
        OrderApi__Item__c emeritusMembership = TestDataFactory.buildItem(membershipClass.Id, 'Emeritus Membership');
        emeritusMembership.OrderApi__Is_Active__c = true;
        emeritusMembership.Is_Active_Membership_Type__c = false;
        insert emeritusMembership;

        OrderApi__Item__c bcj = TestDataFactory.buildItem(journalClass.Id, 'Blood Cancer Discovery - Online');
        bcj.OrderApi__Is_Active__c = true;
        bcj.Is_Active_Membership_Type__c = false;
        bcj.Show_In_Portal__c = true;
        insert bcj;


        //BUILD ITEM SUBSCRIPTION PLANS
        OrderApi__Item_Subscription_Plan__c activeSubPlan = TestDataFactory.buildItemSubPlan(activeMembership.Id, subPlan1.Id);
        activeSubPlan.OrderApi__Is_Default__c = true;
        insert activeSubPlan;

        OrderApi__Item_Subscription_Plan__c activeSubPlan2 = TestDataFactory.buildItemSubPlan(activeMembership.Id, subPlan3.Id);
        insert activeSubPlan2;

        OrderApi__Item_Subscription_Plan__c associateSubPlan = TestDataFactory.buildItemSubPlan(associateMembership.Id, subPlan2.Id);
        associateSubPlan.OrderApi__Is_Default__c = true;
        insert associateSubPlan;

        OrderApi__Item_Subscription_Plan__c emeritusSubPlan = TestDataFactory.buildItemSubPlan(emeritusMembership.Id, lifetimePlan.Id);
        emeritusSubPlan.OrderApi__Is_Default__c = true;
        insert emeritusSubPlan;

        //RENEWAL SETTINGS
        Renewal_Settings__c renewalProcess = new Renewal_Settings__c();
        renewalProcess.Term_Year__c = System.now().year() + 1;
        renewalProcess.Is_Active__c = true;
        insert renewalProcess;

        DW_Manage_Dues_Item__c DWduesItem = new DW_Manage_Dues_Item__c(Delinquent_Years__c=2, Membership_Item_Name__c='2YR Dues', Name='2YR Dues');
        insert DWduesItem;

    }


    @IsTest
    static void test_CurrentActiveMember() {
        Contact con = [SELECT Id FROM Contact WHERE Account.Name='Test Account'];
        User u = [SELECT Id FROM User WHERE ContactId=: con.Id];
        OrderApi__Item_Subscription_Plan__c isp = [SELECT OrderApi__Item__c, OrderApi__Item__r.OrderApi__Item_Class__c, OrderApi__Subscription_Plan__c FROM OrderApi__Item_Subscription_Plan__c WHERE OrderApi__Item__r.Name='Active Membership' AND OrderApi__Is_Default__c = true];

        OrderApi__Subscription__c membershipSub = TestDataFactory.buildSubscription(con.Id, isp.OrderApi__Subscription_Plan__c, isp.OrderApi__Item__c, isp.OrderApi__Item__r.OrderApi__Item_Class__c);
        membershipSub.OrderApi__Status__c = 'Active';
        insert membershipSub;

        OrderApi__Subscription_Line__c  subscriptionLine = TestDataFactory.buildSubscriptionLine(membershipSub.Id, isp.OrderApi__Item__c, isp.OrderApi__Item__r.OrderApi__Item_Class__c);
        insert subscriptionLine;

        System.runAs(u){
            Test.startTest();

            MyMembershipToolbarController.MembershipActions ma = MyMembershipToolbarController.getMembershipActions();
            System.assertEquals(true, ma.canRenew);
            System.assertEquals(false, ma.canCatchUp);
            System.assertEquals(true, ma.renewalsOpen);
            System.assertEquals(true, ma.canTransfer);
            System.assertEquals(false, ma.canReinstate);
            System.assertEquals(false, ma.canReinstateTransfer);
            System.assertEquals(false, ma.pendingApproval);
            System.assertEquals(false, ma.canRecertify);
            System.assertEquals(false, ma.noOperations);

            Test.stopTest();
        }
    }

    @IsTest
    static void test_CurrentAssociateMember() {
        Contact con = [SELECT Id FROM Contact WHERE Account.Name='Test Account'];
        con.Member_Type__c = 'Associate Member';
        update con;

        User u = [SELECT Id FROM User WHERE ContactId=: con.Id];
        OrderApi__Item_Subscription_Plan__c isp = [SELECT OrderApi__Item__c, OrderApi__Item__r.OrderApi__Item_Class__c, OrderApi__Subscription_Plan__c FROM OrderApi__Item_Subscription_Plan__c WHERE OrderApi__Item__r.Name='Associate Membership'];

        OrderApi__Subscription__c membershipSub = TestDataFactory.buildSubscription(con.Id, isp.OrderApi__Subscription_Plan__c, isp.OrderApi__Item__c, isp.OrderApi__Item__r.OrderApi__Item_Class__c);
        membershipSub.OrderApi__Status__c = 'Active';
        membershipSub.OrderApi__Is_Cancelled__c = false;
        membershipSub.OrderApi__Paid_Through_Date__c = Date.newInstance(System.now().year(), 8, 31);
        insert membershipSub;

        OrderApi__Subscription_Line__c  subscriptionLine = TestDataFactory.buildSubscriptionLine(membershipSub.Id, isp.OrderApi__Item__c, isp.OrderApi__Item__r.OrderApi__Item_Class__c);
        insert subscriptionLine;

        membershipSub = [SELECT OrderApi__Paid_Through_Date__c, OrderApi__Item__r.OrderApi__Is_Active__c, OrderApi__Subscription_Plan__r.OrderApi__Is_Active__c, OrderApi__Is_Cancelled__c FROM OrderApi__Subscription__c WHERE OrderApi__Contact__c=:con.Id];
        System.debug('membershipSub: ' + membershipSub);

        System.runAs(u){
            Test.startTest();

            MyMembershipToolbarController.MembershipActions ma = MyMembershipToolbarController.getMembershipActions();
            System.assertEquals(false, ma.canRenew);
            System.assertEquals(false, ma.canCatchUp);
            System.assertEquals(true, ma.renewalsOpen);
            System.assertEquals(true, ma.canTransfer);
            System.assertEquals(false, ma.canReinstate);
            System.assertEquals(false, ma.canReinstateTransfer);
            System.assertEquals(false, ma.pendingApproval);
            System.assertEquals(false, ma.canRecertify);
            System.assertEquals(false, ma.noOperations);

            String resp = MyMembershipToolbarController.startRecertification();
            System.assertNotEquals(null, resp);

            Test.stopTest();
        }
    }

    @IsTest
    static void test_PriorAssociateMember() {
        Id recordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Prior Member').getRecordTypeId();

        Contact con = [SELECT Id FROM Contact WHERE Account.Name='Test Account'];

        User u = [SELECT Id FROM User WHERE ContactId=: con.Id];
        OrderApi__Item_Subscription_Plan__c isp = [SELECT OrderApi__Item__c, OrderApi__Item__r.OrderApi__Item_Class__c, OrderApi__Subscription_Plan__c FROM OrderApi__Item_Subscription_Plan__c WHERE OrderApi__Item__r.Name='Associate Membership'];

        OrderApi__Subscription__c membershipSub = TestDataFactory.buildExpiredSubscription(con.Id, isp.OrderApi__Subscription_Plan__c, isp.OrderApi__Item__c, isp.OrderApi__Item__r.OrderApi__Item_Class__c);
        insert membershipSub;

        OrderApi__Subscription_Line__c  subscriptionLine = TestDataFactory.buildSubscriptionLine(membershipSub.Id, isp.OrderApi__Item__c, isp.OrderApi__Item__r.OrderApi__Item_Class__c);
        insert subscriptionLine;

        con.RecordTypeId = recordTypeId;
        con.Membership_Status__c = 'Ineligible';
        con.Paid_thru_date__c = membershipSub.OrderApi__Paid_Through_Date__c;
        update con;

        System.runAs(u){
            Test.startTest();

            MyMembershipToolbarController.MembershipActions ma = MyMembershipToolbarController.getMembershipActions();
            System.assertEquals(false, ma.canRenew);
            System.assertEquals(false, ma.canCatchUp);
            System.assertEquals(true, ma.renewalsOpen);
            System.assertEquals(false, ma.canTransfer);
            System.assertEquals(true, ma.canReinstate);
            System.assertEquals(true, ma.canReinstateTransfer);
            System.assertEquals(false, ma.pendingApproval);
            System.assertEquals(false, ma.canRecertify);
            System.assertEquals(false, ma.noOperations);

            String resp = MyMembershipToolbarController.startReinstatement();
            System.assertNotEquals(null, resp);

            Test.stopTest();
        }
    }

    @IsTest
    static void test_PriorActiveMember() {
        Id recordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Prior Member').getRecordTypeId();

        Contact con = [SELECT Id FROM Contact WHERE Account.Name='Test Account'];

        OrderApi__Item_Subscription_Plan__c isp = [SELECT OrderApi__Item__c, OrderApi__Item__r.OrderApi__Item_Class__c, OrderApi__Subscription_Plan__c FROM OrderApi__Item_Subscription_Plan__c WHERE OrderApi__Item__r.Name='Active Membership' AND OrderApi__Is_Default__c = true];

        OrderApi__Subscription__c membershipSub = TestDataFactory.buildExpiredSubscription(con.Id, isp.OrderApi__Subscription_Plan__c, isp.OrderApi__Item__c, isp.OrderApi__Item__r.OrderApi__Item_Class__c);
        insert membershipSub;

        OrderApi__Subscription_Line__c  subscriptionLine = TestDataFactory.buildSubscriptionLine(membershipSub.Id, isp.OrderApi__Item__c, isp.OrderApi__Item__r.OrderApi__Item_Class__c);
        insert subscriptionLine;

        con.RecordTypeId = recordTypeId;
        con.Membership_Status__c = 'Suspended';
        con.Paid_thru_date__c = membershipSub.OrderApi__Paid_Through_Date__c;
        update con;

        User u = [SELECT Id FROM User WHERE ContactId=: con.Id];

        System.runAs(u){
            Test.startTest();

            MyMembershipToolbarController.MembershipActions ma = MyMembershipToolbarController.getMembershipActions();
            System.assertEquals(true, ma.canRenew);
            System.assertEquals(true, ma.canCatchUp);
            System.assertEquals(true, ma.renewalsOpen);
            System.assertEquals(false, ma.canTransfer);
            System.assertEquals(false, ma.canReinstate);
            System.assertEquals(false, ma.canReinstateTransfer);
            System.assertEquals(false, ma.pendingApproval);
            System.assertEquals(false, ma.canRecertify);
            System.assertEquals(false, ma.noOperations);

            String resp = MyMembershipToolbarController.catchUpToCurrent();
            System.assertNotEquals(null, resp);

            resp = MyMembershipToolbarController.renewSubscriptions();
            System.assertNotEquals(null, resp);

            Test.stopTest();
        }
    }


}