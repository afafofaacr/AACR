/**
 * Created by lauren.lezberg on 5/23/2019.
 */
@isTest
private with sharing class DirectoryControllerTest {

    @testSetup public static void setup(){
        OrderApi__Badge_Type__c bt = TestDataFactory.buildBadgeType('Directory Access');
        insert bt;
    }

    @isTest
    public static void testGetFilterCriteria(){

        DirectoryController.DirectoryFilters filters = DirectoryController.getFilterCriteria();
        System.assertNotEquals(null, filters);

    }

    @IsTest
    public static void test_getDirectoryLaunchData(){
        Account acc = TestDataFactory.buildAccount('Test Account 2');
        insert acc;

        Contact con = TestDataFactory.buildContactMemberCurrent(acc.Id);
        insert con;

        User u = TestDataFactory.buildUser(con.Id);
        insert u;

        System.runAs(u){
            Test.startTest();
            DirectoryController.DirectoryLaunchData dld = DirectoryController.getDirectoryLaunchData();
            Test.stopTest();

            System.assertEquals(true, dld.showLaunchButton);
            System.assertNotEquals(null, dld.url);

        }
    }

    @isTest
    public static void testGetContactWorkingGroups(){

        Account acc = TestDataFactory.buildAccount('Test Account 2');
        insert acc;

        Contact con = TestDataFactory.buildContact(acc.Id);
        insert con;
        OrderApi__Item_Class__c itemClass = TestDataFactory.buildItemClass('Working Groups');
        insert itemClass;
        OrderApi__Item__c item = TestDataFactory.buildItem(itemClass.Id, 'Chemistry in Cancer Research (CICR)');
        insert item;
        OrderApi__Subscription_Plan__c subPlan = TestDataFactory.buildsubPlan();
        insert subPlan;
        OrderApi__Subscription__c sub = TestDataFactory.buildSubscription(con.Id, subPlan.id, item.Id, itemClass.Id);
        insert sub;

        User u = TestDataFactory.buildUser(con.Id);
        insert u;
        System.runAs(u) {
            Test.startTest();
            String wgs = DirectoryController.getContactWorkingGroups(u.contactId);
            Test.stopTest();

            System.assertNotEquals(null, wgs);
        }

    }

    @isTest
    public static void testCheckDirectoryAccess(){
        Account acc = TestDataFactory.buildAccount('Test Account 2');
        insert acc;

        Contact con = TestDataFactory.buildContact(acc.Id);
        insert con;

        User u = TestDataFactory.buildUser(con.Id);
        insert u;

        System.runAs(u){

            Test.startTest();
            DirectoryController controller = new DirectoryController();
            controller.checkDirectoryAccess();
            System.assertEquals(false, controller.showDirectory);
            BadgeUtils.enableDirectoryAccess(con.Id);
            controller.checkDirectoryAccess();
            System.assertEquals(true, controller.showDirectory);
            Test.stopTest();


        }
    }

    @isTest
    public static void testSendEmailToMember(){
        Account acc = TestDataFactory.buildAccount('Test Account 2');
        insert acc;

        Contact con = TestDataFactory.buildContact(acc.Id);
        insert con;

        User u = TestDataFactory.buildUser(con.Id);
        insert u;
        System.runAs(u){
            Test.startTest();
            Boolean emailSent = DirectoryController.sendEmailToMember('test123@yopmail.com', 'Test Subject', 'Test Body');
            Test.stopTest();

            System.assertEquals(true, emailSent);
        }
    }

    @isTest
    public static void testFetchContacts(){
        Account acc = TestDataFactory.buildAccount('Test Account 2');
        insert acc;

        Contact con = TestDataFactory.buildContact(acc.Id);
        insert con;

        User u = TestDataFactory.buildUser(con.Id);
        insert u;
        System.runAs(u) {
            Test.startTest();
            DirectoryController.DirectoryPagerWrapper wrapper = DirectoryController.fetchContacts(1, 25, new List<String>{'Cancer Therapeutics', 'Biophysics'}, new List<String>{'China', 'France'}, new List<String>{'Massachusetts', 'Texas'}, 'John', acc.Id, 'Name', 'ASC');
            Test.stopTest();

            System.assertNotEquals(null, wrapper);
        }
    }
}