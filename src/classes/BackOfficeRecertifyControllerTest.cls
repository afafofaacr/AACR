/**
 * Created by lauren.lezberg on 5/20/2021.
 */

@IsTest
private class BackOfficeRecertifyControllerTest {

    @testSetup
    public static void setup(){
        //set up contacts & accounts
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

        OrderApi__Item__c membershipItem = TestDataFactory.buildItem(membershipItemClass.Id, 'Associate Membership');
        insert membershipItem;

        OrderApi__Subscription_Plan__c subPlan1 = TestDataFactory.buildsubPlan();
        subPlan1.Name='NDPM Membership';
        insert subPlan1;


        OrderApi__Subscription__c memSub = TestDataFactory.buildSubscription(con.Id, subPlan1.Id, membershipItem.Id, membershipItemClass.Id);
        insert memSub;

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
    static void test_getRecertInfo() {
        Contact con = [SELECT Id FROM Contact ORDER BY CreatedDate LIMIT 1];

        User u = [SELECT Id FROM User WHERE FirstName = 'admin' AND LastName = 'user'];

        PermissionSet ps = new PermissionSet();
        ps.Name = 'Test';
        ps.Label = 'Test';
        insert ps;

        SetupEntityAccess sea = new SetupEntityAccess();
        sea.ParentId = ps.Id;
        sea.SetupEntityId = [SELECT Id, DeveloperName FROM CustomPermission WHERE DeveloperName = 'Recertifications'][0].Id;
        insert sea;

        PermissionSetAssignment psa = new PermissionSetAssignment();
        psa.AssigneeId = u.Id;
        psa.PermissionSetId = ps.Id;
        insert psa;

        Test.startTest();

        System.runAs(u) {
            BackOfficeRecertifyController.RecertInfo rInfo = BackOfficeRecertifyController.getRecertifyInfo(con.Id);
            System.assertEquals(true, rInfo.showRecertButton);
            System.assertNotEquals(null, rInfo.joinId);
        }

    }
}