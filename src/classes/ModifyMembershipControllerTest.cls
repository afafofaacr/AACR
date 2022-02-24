/**
 * Created by lauren.lezberg on 2/6/2020.
 */
@isTest
private with sharing class ModifyMembershipControllerTest {
    @testSetup
    public static void setup(){
        Account acc = TestDataFactory.buildAccount('Test Account');
        insert acc;

        Contact con = TestDataFactory.buildContact(acc.Id);
        insert con;

        User u = TestDataFactory.buildUser(con.Id);
        insert u;

        OrderApi__Subscription_Plan__c subPlan1 = TestDataFactory.buildsubPlan();
        insert subPlan1;


        OrderApi__Subscription_Plan__c subPlan2 = TestDataFactory.buildsubPlan();
        subPlan2.Name = '2YR Membership';
        subPlan2.Show_In_Portal__c = false;
        subPlan2.OrderApi__Advanced_Calendar_Days__c = 365;
        insert subPlan2;

        OrderApi__Item_Class__c membershipClass = TestDataFactory.buildItemClass('Individual Memberships');
        insert membershipClass;

        OrderApi__Item__c membership = TestDataFactory.buildItem(membershipClass.Id, 'Active Membership');
        membership.Managed__c = true;
        insert membership;

        OrderApi__Item_Subscription_Plan__c memSubPlan = TestDataFactory.buildItemSubPlan(membership.Id, subPlan1.Id);
        memSubPlan.OrderApi__Is_Default__c = true;
        insert memSubPlan;

        OrderApi__Item_Subscription_Plan__c memSubPlan2 = TestDataFactory.buildItemSubPlan(membership.Id, subPlan2.Id);
        insert memSubPlan2;

        OrderApi__Subscription__c membershipSub = TestDataFactory.buildSubscription(con.Id, subPlan1.Id, membership.Id, membershipClass.Id);
        insert membershipSub;

        Renewal_Settings__c renewalProcess = new Renewal_Settings__c();
        renewalProcess.Term_Year__c = System.now().year() + 1;
        renewalProcess.Is_Active__c = false;
        insert renewalProcess;
    }

    @isTest
    public static void test_getShowModify(){
        Contact con = [SELECT Id, AccountId FROM Contact WHERE Account.Name='Test Account'];

        User u = [SELECT Id FROM User WHERE ContactId=: con.Id];

        PermissionSet ps = new PermissionSet();
        ps.Name = 'Test';
        ps.Label = 'Test';
        insert ps;

        SetupEntityAccess sea = new SetupEntityAccess();
        sea.ParentId = ps.Id;
        sea.SetupEntityId = [SELECT Id, DeveloperName FROM CustomPermission WHERE DeveloperName = 'Modify_Membership'][0].Id;
        insert sea;

        PermissionSetAssignment psa = new PermissionSetAssignment();
        psa.AssigneeId = u.Id;
        psa.PermissionSetId = ps.Id;
        insert psa;


        System.runAs(u) {

            Test.startTest();
                Boolean showModifyButton = ModifyMembershipController.getShowModify(con.Id);
                System.assertEquals(true, showModifyButton);
            Test.stopTest();

        }
    }

    @isTest
    public static void test_createModifySalesOrder(){
        Contact con = [SELECT Id, AccountId FROM Contact WHERE Account.Name='Test Account'];

        Test.startTest();
        Map<String, String> modifySOInfo = ModifyMembershipController.createModifySalesOrder(con.Id);
        Test.stopTest();

        Id jpRecordId = [SELECT Id FROM Join_Process__mdt WHERE DeveloperName='Modify_Membership' LIMIT 1].Id;
        OrderApi__Sales_Order__c SO = [SELECT Id FROM OrderApi__Sales_Order__c WHERE OrderApi__Contact__c=:con.Id ORDER BY CreatedDate LIMIT 1];

        for(String key : modifySOInfo.keySet()){
            System.assertEquals(key, SO.Id);
            System.assertEquals(modifySOInfo.get(key), jpRecordId);
        }

    }

    @isTest
    public static void test_removeMembershipLine(){
        Contact con = [SELECT Id, AccountId FROM Contact WHERE Account.Name='Test Account'];
        OrderApi__Item__c membership = [SELECT Id FROM OrderApi__Item__c WHERE OrderApi__Item_Class__r.Name='Individual Memberships'];
        OrderApi__Subscription_Plan__c subPlan = [SELECT Id FROM OrderApi__Subscription_Plan__c WHERE Show_In_Portal__c = true AND OrderApi__Advanced_Calendar_Days__c = null];

        List<String> subIds = new List<String>();
        for(OrderApi__Subscription__c sub: [SELECT Id FROM OrderApi__Subscription__c WHERE OrderApi__Contact__c=: con.Id]){
            subIds.add(sub.Id);
        }

        OrderApi__Sales_Order__c SO = new OrderApi__Sales_Order__c(OrderApi__Contact__c=con.Id);
        insert SO;

        Test.startTest();
            List<OrderApi__Sales_Order_Line__c> lines = ModifyMembershipController.addSelectedItemToSO(membership.Id, subPlan.Id, SO.Id);
            System.assertEquals(1, lines.size());

            lines = ModifyMembershipController.removeSelectedItemFromSO(membership.Id, SO.Id);
            System.assertEquals(0, lines.size());

            lines = ModifyMembershipController.addSelectedItemToSO(membership.Id, subPlan.Id, SO.Id);
            ModifyMembershipController.removeMembershipFromSO(SO.Id);
        Test.stopTest();

        Integer membershipLines = [SELECT COUNT() FROM OrderApi__Sales_Order_Line__c WHERE OrderApi__Sales_Order__c=: SO.Id AND OrderApi__Item_Class__r.Name='Individual Memberships'];
        System.assertEquals(0, membershipLines);
    }

    @isTest
    public static void test_getModifyInfo(){
        Contact con = [SELECT Id, AccountId FROM Contact WHERE Account.Name='Test Account'];
        OrderApi__Sales_Order__c SO = new OrderApi__Sales_Order__c(OrderApi__Contact__c=con.Id);
        insert SO;
        OrderApi__Subscription_Plan__c subPlan = [SELECT Id FROM OrderApi__Subscription_Plan__c WHERE Show_In_Portal__c = true AND OrderApi__Advanced_Calendar_Days__c = null];

        OrderApi__Subscription__c membershipSub = [SELECT Id FROM OrderApi__Subscription__c WHERE OrderApi__Contact__c=: con.Id AND OrderApi__Item_Class__r.Name='Individual Memberships' LIMIT 1];

        Test.startTest();
        //test with renewals off and 1 yr sub
        ModifyMembershipController.ModifyInfo mInfo = ModifyMembershipController.getModifyInfo(SO.Id);
        System.assertNotEquals(null, mInfo);
        System.assertNotEquals(0, mInfo.soLines.size());
        System.assertEquals(subPlan.Id, mInfo.subPlanId);

        Renewal_Settings__c renewalProcess = [SELECT Is_Active__c, Id, Term_Year__c FROM Renewal_Settings__c LIMIT 1];
        renewalProcess.Is_Active__c = true;
        update renewalProcess;

        //test with renewals on
        mInfo = ModifyMembershipController.getModifyInfo(SO.Id);
        System.assertNotEquals(null, mInfo);
        System.assertNotEquals(0, mInfo.soLines.size());
        System.assertEquals(subPlan.Id, mInfo.subPlanId);

        membershipSub.OrderApi__Paid_Through_Date__c = Date.newInstance((Integer)renewalProcess.Term_Year__c, 12, 31);
        update membershipSub;

        //test with renewals on and 2 yr sub
        mInfo = ModifyMembershipController.getModifyInfo(SO.Id);
        System.assertNotEquals(null, mInfo);
        System.assertNotEquals(0, mInfo.soLines.size());
        System.assertNotEquals(subPlan.Id, mInfo.subPlanId);

        Test.stopTest();
    }


}