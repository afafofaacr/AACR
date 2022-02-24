/**
 * Created by lauren.lezberg on 11/19/2019.
 */
@isTest
private with sharing class TransferMemberControllerTest {
    @testSetup
    public static void setup(){
        Account acc = TestDataFactory.buildAccount('Test Account');
        insert acc;

        Contact con = TestDataFactory.buildContact(acc.Id);
        insert con;

        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User'];



        User u = new User(Alias = 'standt', Email='transferUser@yopmail.com',
                EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                LocaleSidKey='en_US', ProfileId = p.Id,
                TimeZoneSidKey='America/Los_Angeles', UserName='transferUser@yopmail.com');
        insert u;

        OrderApi__Subscription_Plan__c subPlan = TestDataFactory.buildsubPlan();
        subPlan.Name = '2YR Membership';
        subPlan.OrderApi__Advanced_Calendar_Days__c = 365;
        insert subPlan;

        OrderApi__Item_Class__c membershipClass = TestDataFactory.buildItemClass('Individual Memberships');
        insert membershipClass;

        OrderApi__Item__c membership = TestDataFactory.buildItem(membershipClass.Id, 'Active Membership');
        membership.Managed__c = true;
        insert membership;

        OrderApi__Subscription__c membershipSub = TestDataFactory.buildSubscription(con.Id, subPlan.Id, membership.Id, membershipClass.Id);
        insert membershipSub;

    }

    @isTest
    public static void test_showTransferButton(){

        Contact con = [SELECT Id FROM Contact WHERE Account.Name='Test Account'];

        User u = [SELECT Id FROM User WHERE Email ='transferUser@yopmail.com'];

        PermissionSet ps = new PermissionSet();
        ps.Name = 'Test';
        ps.Label = 'Test';
        insert ps;

        SetupEntityAccess sea = new SetupEntityAccess();
        sea.ParentId = ps.Id;
        sea.SetupEntityId = [SELECT Id, DeveloperName FROM CustomPermission WHERE DeveloperName = 'Transfers'][0].Id;
        insert sea;

        PermissionSetAssignment psa = new PermissionSetAssignment();
        psa.AssigneeId = u.Id;
        psa.PermissionSetId = ps.Id;
        insert psa;

        System.runAs(u) {

            Test.startTest();
            con.Paid_thru_date__c = Date.newInstance(System.now().year() - 1 , 12, 31);
            update con; 

            Boolean showTransfer = TransferMemberController.showTransferButton(con.Id);
            System.assertEquals(false, showTransfer);

            con.Paid_thru_date__c = Date.newInstance(System.now().year(), 12, 31);
            update con;

            showTransfer = TransferMemberController.showTransferButton(con.Id);
            System.assertEquals(true, showTransfer);

            con.Paid_thru_date__c = Date.newInstance(System.now().year() + 1,12,31);
            update con;

            showTransfer = TransferMemberController.showTransferButton(con.Id);
            System.assertEquals(true, showTransfer);


            Test.stopTest();

        }

    }


    @isTest
    public static void test_createEmptySO(){
        Contact con = [SELECT Id FROM Contact LIMIT 1];
        List<Join_Process__mdt> joinProcesses = [SELECT Id FROM Join_Process__mdt WHERE DeveloperName = 'Back_Office_Transfer' LIMIT 1];

        Test.startTest();

        TransferMemberController.TransferInfo tInfo = TransferMemberController.createEmptySO(con.Id);
        SYstem.assertNotEquals(null, tInfo);
        System.assertEquals(joinProcesses[0].Id, tInfo.joinId);
        OrderApi__Sales_Order__c SO = [SELECT Id FROM OrderApi__Sales_Order__c WHERE OrderApi__Contact__c=: con.Id];
        System.assertEquals(SO.Id, tInfo.salesOrderId);
        Integer soLines = [SELECT COUNT() FROM OrderApi__Sales_Order_Line__c WHERE OrderApi__Sales_Order__c=: SO.Id];
        System.assertEquals(0, soLines);

        Test.stopTest();
    }

}