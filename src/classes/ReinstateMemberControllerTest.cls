/**
 * Created by lauren.lezberg on 2/6/2020.
 */
@isTest
private with sharing class ReinstateMemberControllerTest {

    @testSetup
    public static void setup(){
        Account acc = TestDataFactory.buildAccount('Test Account');
        insert acc;

        Contact con = TestDataFactory.buildContact(acc.Id);
        insert con;

        User u = TestDataFactory.buildUser(con.Id);
        insert u;
    }


    @isTest
    public static void test_getShowReinstate(){
        Contact con = [SELECT Id FROM Contact WHERE Account.Name='Test Account'];

        User u = [SELECT Id FROM User WHERE ContactId=: con.Id];

        PermissionSet ps = new PermissionSet();
        ps.Name = 'Test';
        ps.Label = 'Test';
        insert ps;

        SetupEntityAccess sea = new SetupEntityAccess();
        sea.ParentId = ps.Id;
        sea.SetupEntityId = [SELECT Id, DeveloperName FROM CustomPermission WHERE DeveloperName = 'Reinstatements'][0].Id;
        insert sea;

        PermissionSetAssignment psa = new PermissionSetAssignment();
        psa.AssigneeId = u.Id;
        psa.PermissionSetId = ps.Id;
        insert psa;


        System.runAs(u) {

            Test.startTest();
            Boolean showReinstate = ReinstateMemberController.getShowReinstate(con.Id);
            System.assertEquals(false, showReinstate);

            OrderApi__Item_Class__c itemClass = TestDataFactory.buildItemClass('Individual Memberships');
            insert itemClass;

            OrderApi__Item__c item = TestDataFactory.buildItem(itemClass.Id, 'Active Membership');
            insert item;

            OrderApi__Subscription_Plan__c subPlan = TestDataFactory.buildsubPlan();
            insert subPlan;

            OrderApi__Subscription__c sub = TestDataFactory.buildSubscription(con.Id, subPlan.Id, item.Id, itemClass.Id);
            sub.OrderApi__Paid_Through_Date__c = Date.newInstance(System.now().year() - 4, 12, 31);
            sub.OrderApi__Current_Term_End_Date__c = Date.newInstance(System.now().year() - 4, 12, 31);
            sub.OrderApi__Current_Term_Start_Date__c = Date.newInstance(System.now().year() - 4, 1, 1);
            sub.OrderApi__Is_Active__c = false;
            insert sub;

            showReinstate = ReinstateMemberController.getShowReinstate(con.Id);
            System.assertEquals(true, showReinstate);

            Test.stopTest();
        }
    }

    @isTest
    public static void test_createReinstatementSO(){
        Contact con = [SELECT Id FROM Contact WHERE Account.Name='Test Account'];
        Id jpId = [SELECT Id FROM Join_Process__mdt WHERE DeveloperName='Back_Office_Order'].Id;

        Test.startTest();
        NewApplicationController.NewApplicationInfo newAppInfo = ReinstateMemberController.createReinstatementSO(con.Id);

        System.assertEquals(jpId, newAppInfo.joinId);

        Integer soCount = [SELECT COUNT() FROM OrderApi__Sales_Order__c WHERE OrderApi__Contact__c=: con.Id];
        System.assertEquals(1, soCount);

        Test.stopTest();
    }
}