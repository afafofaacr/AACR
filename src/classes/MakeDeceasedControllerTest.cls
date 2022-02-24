/**
 * Created by lauren.lezberg on 12/9/2019.
 */
@isTest
private with sharing class MakeDeceasedControllerTest {

    @testSetup
    public static void setup(){
        Account acc = TestDataFactory.buildAccount('Test Account');
        insert acc;

        Contact con = TestDataFactory.buildContact(acc.Id);
        insert con;

        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User'];



        User u = new User(Alias = 'standt', Email='deceasedUser@yopmail.com',
                EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                LocaleSidKey='en_US', ProfileId = p.Id,
                TimeZoneSidKey='America/Los_Angeles', UserName='deceasedUser@yopmail.com');
        insert u;

        OrderApi__Subscription_Plan__c subPlan = TestDataFactory.buildsubPlan();
        insert subPlan;

        OrderApi__Item_Class__c membershipClass = TestDataFactory.buildItemClass('Individual Memberships');
        insert membershipClass;

        OrderApi__Item__c membership = TestDataFactory.buildItem(membershipClass.Id, 'Active Membership');
        insert membership;

        OrderApi__Subscription__c membershipSub = TestDataFactory.buildSubscription(con.Id, subPlan.Id, membership.Id, membershipClass.Id);
        insert membershipSub;

    }


    @isTest
    public static void test_getButtonVisibility(){

        Contact con = [SELECT Id FROM Contact WHERE Account.Name='Test Account'];

        User u = [SELECT Id FROM User WHERE Email ='deceasedUser@yopmail.com'];

        PermissionSet ps = new PermissionSet();
        ps.Name = 'Test';
        ps.Label = 'Test';
        insert ps;

        SetupEntityAccess sea = new SetupEntityAccess();
        sea.ParentId = ps.Id;
        sea.SetupEntityId = [SELECT Id, DeveloperName FROM CustomPermission WHERE DeveloperName = 'Mark_As_Deceased'][0].Id;
        insert sea;

        PermissionSetAssignment psa = new PermissionSetAssignment();
        psa.AssigneeId = u.Id;
        psa.PermissionSetId = ps.Id;
        insert psa;


        System.runAs(u) {
            Test.startTest();

            Boolean showDeceased = MakeDeceasedController.getButtonVisibility(con.Id);
            System.assertEquals(true, showDeceased);

            Test.stopTest();
        }
    }


    @isTest
    public static void test_moveContactToDeceased(){
        Contact con = [SELECT Id FROM Contact WHERE Account.Name='Test Account'];

        User u = [SELECT Id FROM User WHERE Email ='deceasedUser@yopmail.com'];

        PermissionSet ps = new PermissionSet();
        ps.Name = 'Test';
        ps.Label = 'Test';
        insert ps;

        SetupEntityAccess sea = new SetupEntityAccess();
        sea.ParentId = ps.Id;
        sea.SetupEntityId = [SELECT Id, DeveloperName FROM CustomPermission WHERE DeveloperName = 'Mark_As_Deceased'][0].Id;
        insert sea;

        PermissionSetAssignment psa = new PermissionSetAssignment();
        psa.AssigneeId = u.Id;
        psa.PermissionSetId = ps.Id;
        insert psa;

        System.runAs(u) {
            Test.startTest();

            MakeDeceasedController.moveContactToDeceased(con.Id, 'TEST NOTE BODY');

            Test.stopTest();

            con = [SELECT RecordTypeId, Membership_Status__c FROM Contact WHERE Id=: con.Id];
            System.assertEquals(ECRMUtils.deceasedRecordTypeId, con.RecordTypeId);
            System.assertEquals('Deceased', con.Membership_Status__c);

            ContentVersion cv = [SELECT Id FROM ContentVersion WHERE FirstPublishLocationId=: con.Id];
            System.assertNotEquals(null, cv);

            List<OrderApi__Subscription__c> cancelledSubs = [SELECT Id FROM OrderApi__Subscription__c WHERE OrderApi__Contact__c=:con.Id AND OrderApi__Is_Cancelled__c= true];
            System.assertEquals(1, cancelledSubs.size());
        }
    }


}