/**
 * Created by lauren.lezberg on 5/15/2019.
 */
@isTest
private with sharing class BadgeUtilsTest {

    @testSetup public static void setup(){
        List<OrderApi__Badge_Type__c> badgeTypeList = TestDataFactory.createBadgeType();
        insert badgeTypeList;
        System.assertEquals(9, [SELECT Id FROM OrderApi__Badge_Type__c].size());
    }



    @isTest
    public static void test_ExpireAndActivateDirectoryBadges(){
        Account acc = TestDataFactory.buildAccount('Test Account');
        insert acc;

        Contact con = TestDataFactory.buildContact(acc.Id);

        insert con;

        OrderApi__Badge_Type__c bt = TestDataFactory.buildBadgeType('Directory Access');
        insert bt;

        Set<Id> contactIds = new Set<Id>();
        contactIds.add(con.Id);

        Test.startTest();

        BadgeUtils.enableDirectoryAccess(contactIds);

        List<OrderApi__Badge__c> badges = [SELECT OrderApi__Is_Active__c FROM OrderApi__Badge__c WHERE OrderApi__Contact__c=: con.Id AND OrderApi__Is_Active__c=true AND OrderApi__Badge_Type__r.Name='Directory Access'];
        System.assertEquals(1, badges.size());

        BadgeUtils.expireDirectoryBadges(badges);

        Integer badgeCount = [SELECT COUNT() FROM OrderApi__Badge__c WHERE OrderApi__Contact__c=: con.Id AND OrderApi__Is_Active__c=false AND OrderApi__Badge_Type__r.Name='Directory Access'];

        System.assertEquals(1, badgeCount);

        BadgeUtils.enableDirectoryAccess(contactIds);

        badges = [SELECT OrderApi__Is_Active__c FROM OrderApi__Badge__c WHERE OrderApi__Contact__c=: con.Id AND OrderApi__Is_Active__c=true AND OrderApi__Badge_Type__r.Name='Directory Access'];
        System.assertEquals(1, badges.size());

        Test.stopTest();


    }

    @isTest
    private static void test_DirectoryBadgeAccess(){
        Account acc = TestDataFactory.buildAccount('Test Account');
        insert acc;
        Contact con = TestDataFactory.buildContact(acc.Id);
        insert con;
        OrderApi__Badge_Type__c bt = TestDataFactory.buildBadgeType('Directory Access');
        insert bt;

        Test.startTest();
        Boolean badgeCreated = BadgeUtils.enableDirectoryAccess(con.Id);
        System.assertEquals(true, badgeCreated);

        Boolean badgeRevoked = BadgeUtils.revokeDirectoryAccess(con.Id);
        System.assertEquals(true, badgeRevoked);

        Boolean badgeEnabled = BadgeUtils.enableDirectoryAccess(con.Id);
        System.assertEquals(true, badgeEnabled);

        Test.stopTest();

    }


    @isTest
    private static void test_FellowBadgeAccess(){
        Account acc = TestDataFactory.buildAccount('Test Account');
        insert acc;
        Contact con = TestDataFactory.buildContact(acc.Id);
        insert con;
        OrderApi__Badge_Type__c bt = TestDataFactory.buildBadgeType('AACR Fellow');
        insert bt;

        Test.startTest();
        Boolean badgeCreated = BadgeUtils.enableFellowAccess(con.Id);
        System.assertEquals(true, badgeCreated);

        Boolean badgeRevoked = BadgeUtils.revokeFellowAccess(con.Id);
        System.assertEquals(true, badgeRevoked);

        Boolean badgeEnabled = BadgeUtils.enableFellowAccess(con.Id);
        System.assertEquals(true, badgeEnabled);

        Test.stopTest();

    }
}