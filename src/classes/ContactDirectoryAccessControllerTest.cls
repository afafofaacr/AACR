/**
 * Created by lauren.lezberg on 5/8/2019.
 */
@isTest
private with sharing class ContactDirectoryAccessControllerTest {
    @testSetup
    public static void setup(){
        Account acc = TestDataFactory.buildAccount('Test Account');
        insert acc;

        Contact con = TestDataFactory.buildContact(acc.Id);
        insert con;

        User u = TestDataFactory.buildUser(con.Id);
        insert u;

        OrderApi__Badge_Type__c badgeType = TestDataFactory.buildBadgeType('Directory Access');
        insert badgeType;

        OrderApi__Badge__c badge = TestDataFactory.buildBadge(badgeType.Id, con.Id);
        insert badge;

        DRCTS__Directories__c directory = new DRCTS__Directories__c(Name='American Association for Cancer Research Member Directory');
        insert directory;

    }

    @isTest
    public static void testGetDirectoryAccessBadge(){
        Contact con = [SELECT Id FROM Contact LIMIT 1];

        Test.startTest();
        ContactDirectoryAccessController.DirectoryBadgeInfo badgeInfo = ContactDirectoryAccessController.getDirectoryAccessBadge(con.Id);
        System.assertNotEquals(null, badgeInfo);
        System.assertNotEquals(null, badgeInfo.dirBadge);
        System.assertEquals(true, badgeInfo.canEdit);
        Test.stopTest();
    }

    @isTest
    public static void testEnableAndDisableDirectoryBadge(){
        Contact con = [SELECT Id FROM Contact LIMIT 1];

        Test.startTest();
        Boolean success = ContactDirectoryAccessController.revokeDirectoryForContact(con.Id);
        System.assertEquals(true, success);
        OrderApi__Badge__c dirBadge = [SELECT OrderApi__Is_Active__c FROM OrderApi__Badge__c WHERE OrderApi__Contact__c=:con.Id AND OrderApi__Badge_Type__r.Name='Directory Access'];
        System.assertEquals(false, dirBadge.OrderApi__Is_Active__c);

        success = ContactDirectoryAccessController.enableDirectoryForContact(con.Id);
        System.assertEquals(true, success);
        dirBadge = [SELECT OrderApi__Is_Active__c FROM OrderApi__Badge__c WHERE OrderApi__Contact__c=:con.Id AND OrderApi__Badge_Type__r.Name='Directory Access'];
        System.assertEquals(true, dirBadge.OrderApi__Is_Active__c);

        Test.stopTest();
    }
}