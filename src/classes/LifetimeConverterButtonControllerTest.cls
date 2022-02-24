/**
 * Created by lauren.lezberg on 5/21/2021.
 */

@IsTest
private class LifetimeConverterButtonControllerTest {

    @TestSetup
    public static void setup(){
        Account acc = TestDataFactory.buildAccount('TEST Account');
        insert acc;

        Contact con = TestDataFactory.buildContactMemberPrior(acc.Id);
        insert con;

        User u = TestDataFactory.buildUser(con.Id);
        insert u;


        OrderApi__Item_Class__c journalItemClass = TestDataFactory.buildItemClass('Journal Subscriptions');
        insert journalItemClass;

        OrderApi__Item__c bloodCanceritem = TestDataFactory.buildItem(journalItemClass.Id, 'Blood Cancer Discovery - Online');
        insert bloodCanceritem;

        OrderApi__Item_Class__c membershipItemClass = TestDataFactory.buildItemClass('Individual Memberships');
        insert membershipItemClass;

        OrderApi__Item__c membershipItem = TestDataFactory.buildItem(membershipItemClass.Id, 'Active Membership');
        insert membershipItem;

        OrderApi__Subscription_Plan__c subPlan1 = TestDataFactory.buildsubPlan();
        insert subPlan1;

        OrderApi__Subscription_Plan__c subPlan2 = TestDataFactory.buildsubPlan();
        subPlan2.Name='Lifetime';
        subPlan2.OrderApi__Type__c = 'Lifetime';
        subPlan2.Show_In_Portal__c = false;
        insert subPlan2;

        OrderApi__Subscription__c memSub = TestDataFactory.buildSubscription(con.Id, subPlan1.Id, membershipItem.Id, membershipItemClass.Id);
        insert memSub;

        OrderApi__Renewal__c term = new OrderApi__Renewal__c();
        term.OrderApi__Subscription__c = memSub.Id;
        term.OrderApi__Term_Start_Date__c = Date.newInstance(System.now().year(), 1, 1);
        term.OrderApi__Term_End_Date__c = Date.newInstance(System.now().year(), 12, 31);
        insert term;

        OrderApi__Sales_Order__c SO = TestDataFactory.buildOpenSalesOrder(acc.Id, con.Id );
        insert SO;

        OrderApi__Sales_Order_Line__c sol = TestDataFactory.buildSOLine(SO.Id, membershipItem.Id, membershipItemClass.Id);
        insert sol;

        //set up admin user
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];

        User u2 = TestDataFactory.buildTestUser(p.Id, 'admin', 'user');
        insert u2;
    }


    @IsTest
    static void test_getVisibility() {
        Contact con = [SELECT Id FROM Contact ORDER BY CreatedDate LIMIT 1];

        User u = [SELECT Id FROM User WHERE FirstName = 'admin' AND LastName = 'user'];

        PermissionSet ps = new PermissionSet();
        ps.Name = 'Test';
        ps.Label = 'Test';
        insert ps;

        SetupEntityAccess sea = new SetupEntityAccess();
        sea.ParentId = ps.Id;
        sea.SetupEntityId = [SELECT Id, DeveloperName FROM CustomPermission WHERE DeveloperName = 'Lifetime_Conversion'][0].Id;
        insert sea;

        PermissionSetAssignment psa = new PermissionSetAssignment();
        psa.AssigneeId = u.Id;
        psa.PermissionSetId = ps.Id;
        insert psa;

        Test.startTest();

        System.runAs(u) {
            Boolean showBtn = LifetimeConverterButtonController.getVisibility(con.Id);
            System.assertEquals(true, showBtn);
        }

    }

    @IsTest
    public static void test_doConversion(){
        Contact con = [SELECT Id FROM Contact ORDER BY CreatedDate LIMIT 1];

        User u = [SELECT Id FROM User WHERE FirstName = 'admin' AND LastName = 'user'];

        PermissionSet ps = new PermissionSet();
        ps.Name = 'Test';
        ps.Label = 'Test';
        insert ps;

        SetupEntityAccess sea = new SetupEntityAccess();
        sea.ParentId = ps.Id;
        sea.SetupEntityId = [SELECT Id, DeveloperName FROM CustomPermission WHERE DeveloperName = 'Lifetime_Conversion'][0].Id;
        insert sea;

        PermissionSetAssignment psa = new PermissionSetAssignment();
        psa.AssigneeId = u.Id;
        psa.PermissionSetId = ps.Id;
        insert psa;

        Test.startTest();

        System.runAs(u) {
            LifetimeConverterButtonController.doConversion(con.Id);
        }

    }
}