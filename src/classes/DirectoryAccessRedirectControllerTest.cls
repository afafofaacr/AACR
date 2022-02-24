/**
 * Created by lauren.lezberg on 5/8/2019.
 */

@isTest
private with sharing class DirectoryAccessRedirectControllerTest {

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

        DRCTS__Directories__c directory = new DRCTS__Directories__c(Name='American Association for Cancer Research Member Directory');
        insert directory;



    }

    @isTest
    public static void testCheckDirectoryAccess(){

        DirectoryAccessRedirectController controller = new DirectoryAccessRedirectController();
        Contact con = [SELECT Id FROM Contact LIMIT 1];
        User u = [SELECT Id FROM User WHERE ContactId=: con.Id LIMIT 1];
        OrderApi__Badge_Type__c bt = [SELECT Id FROM OrderApi__Badge_Type__c WHERE Name='Directory Access'];

        System.runAs(u) {
            Test.startTest();
            PageReference pageRef = controller.checkDirectoryAccess();
            System.assertEquals(null, pageRef);

            OrderApi__Badge__c badge = TestDataFactory.buildBadge(bt.Id, con.Id);
            insert badge;

            pageRef = controller.checkDirectoryAccess();
            System.assertNotEquals(null, pageRef);

            Test.stopTest();
        }
    }

    @isTest
    public static void testReturnToProfile(){
        Test.startTest();
        DirectoryAccessRedirectController controller = new DirectoryAccessRedirectController();
        PageReference pageRef = controller.returnToProfile();
        System.assertNotEquals(null, pageRef);
        Test.stopTest();
    }
}