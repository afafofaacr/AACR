/**
 * Created by lauren.lezberg on 5/15/2019.
 */

@isTest
private with sharing class ApproveAndResignControllerTest { 

    @testSetup public static void setup(){
        Account acc = TestDataFactory.buildAccount('Test Account');
        insert acc;

        Contact con = TestDataFactory.buildContact(acc.Id);
        con.FirstName='TESTY';
        con.Application_Status__c = 'Pending Approval';
        insert con;

        OrderApi__Item_Class__c membershipClass = TestDataFactory.buildItemClass('Individual Memberships');
        insert membershipClass;
        OrderApi__Item__c membershipItem = TestDataFactory.buildItem(membershipClass.Id, 'Affiliate Membership');
        insert membershipItem;

        OrderApi__Item_Class__c itemClass = TestDataFactory.buildItemClass('Working Groups');
        insert itemClass;
        OrderApi__Item__c item = TestDataFactory.buildItem(itemClass.Id, 'Chemistry in Cancer Research (CICR)');
        insert item;
        Committee__c committee = TestDataFactory.buildCommitteeWG('Chemistry in Cancer Research (CICR)');
        insert committee;

        OrderApi__Subscription_Plan__c subPlan = TestDataFactory.buildsubPlan();
        insert subPlan;
        OrderApi__Subscription__c sub = TestDataFactory.buildSubscription(con.Id, subPlan.id, item.Id, itemClass.Id);
        insert sub;
        OrderApi__Subscription__c memSub = TestDataFactory.buildSubscription(con.Id, subPlan.id, membershipItem.Id, membershipClass.Id);
        insert memSub;

        OrderApi__Badge_Type__c bt = TestDataFactory.buildBadgeType('Directory Access');
        insert bt;

        Member_Count__c memCount = new Member_Count__c(Count__c='48000');
        insert memCount;
    }

    @isTest
    private static void test_approveReinstatementTransfer(){

        Contact con = [SELECT Id, Application_Status__c, Account.Id FROM Contact LIMIT 1];
        con.Application_Status__c = 'Pending Reinstatement-Transfer';
        update con;

        OrderApi__Sales_Order__c so = TestDataFactory.buildOpenSalesOrder(con.Account.Id, con.Id);
        so.Is_Reinstatement__c = true;
        so.Is_Transfer__c = true;
        insert so;

        Test.startTest();
        Boolean approved = ApproveAndResignController.approveMember(con.Id);
        System.assertEquals(true, approved);

        Test.stopTest();

    }


    @isTest
    private static void test_approveAndResignMember(){
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        User userRecord = new User(alias = 'test',
                // AccountId = contactRecord1.AccountId,
                ProfileId = p.Id,
                email = 'test@testorg.com',
                emailencodingkey = 'UTF-8',
                lastname = 'Test User2',
                languagelocalekey = 'en_US',
                localesidkey = 'en_US',
                timezonesidkey = 'America/Los_Angeles',
                username = System.now().millisecond() + 'test@testorg2.com');
        insert userRecord;

        Contact con = [SELECT Id, Application_Status__c FROM Contact LIMIT 1];
        System.debug('contact: ' + con);
        System.assertNotEquals(null, con.Application_Status__c);

//        System.runAs(userRecord) {
            Test.startTest();
            ApproveAndResignController.ApproveResignData data = ApproveAndResignController.getButtonVisibility(con.Id);
            System.assertEquals(true, data.showApprove);
            Boolean approved = ApproveAndResignController.approveMember(con.Id);
            System.assertEquals(true, approved);

            List<Committee__c> committees = [SELECT Id, Type__c FROM Committee__c LIMIT 1];

            Committee_Member__c member = new Committee_Member__c();
            member.Committee_Name__c = committees[0].Id;
            member.Committee_Type__c = committees[0].Type__c;
            member.Committee_Member__c = con.Id;
            member.Member_Role__c = 'Member';
            member.Start_Date__c = Date.today();

            insert member;

            List<Committee_Member__c> committeeMemberships = [SELECT Id FROM Committee_Member__c WHERE Committee_Member__c = :con.Id];
            System.assertEquals(true, committeeMemberships.size() == 1);

            data = ApproveAndResignController.getButtonVisibility(con.Id);
            System.assertEquals(true, data.showResign);
            Boolean resigned = ApproveAndResignController.resignMember(con.Id);
            System.assertEquals(true, resigned);

            Test.stopTest();
//        }

    }


    @isTest
    public static void test_GetRecordTypes(){ 
        Test.startTest();
        List<RecordType> types = ApproveAndResignController.getRecordTypes('Contact');

        Test.stopTest();

        System.assert(types.size()>0, 'List should contain record types');
    }


}