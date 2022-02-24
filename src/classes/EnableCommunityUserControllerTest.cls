/**
 * Created by afaf.awad on 8/10/2021.
 */

@IsTest
private class EnableCommunityUserControllerTest {
    @TestSetup
    public static void setup() {
        Account account = TestDataFactory.buildAccount('Setup Account');
        insert account;

        Contact contact = TestDataFactory.buildContact(account.Id);
        contact.FirstName = 'Olivia';
        insert contact;

        User user = TestDataFactory.buildUser(contact.Id);
        user.isActive = false;
        insert user;

        Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
        User admin = new User(alias = 'admin',
                ProfileId = p.Id,
                email = 'testadmin@testorg.com',
                emailencodingkey = 'UTF-8',
                lastname = 'Testadmin',
                languagelocalekey = 'en_US',
                localesidkey = 'en_US',
                timezonesidkey = 'America/Los_Angeles',
                username = System.now().millisecond() + 'testadmin@testorg2.com');
        insert admin;
    }

    @IsTest
    public static void test_enableExistingUser() {
        Contact contact = [SELECT Id FROM Contact LIMIT 1];
        User admin = [SELECT Id FROM User WHERE Alias = 'admin'];
        System.runAs(admin) {
            Test.startTest();
            EnableCommunityUserController.activateUser(contact.Id);
            Test.stopTest();
        }

        User user2 = [SELECT Id, Email, IsActive FROM User WHERE ContactId = :contact.Id];
        System.assertEquals(true, user2.IsActive);
    }

    @IsTest
    public static void test_enableExistingUser_Error() {
        Contact contact = [SELECT Id FROM Contact LIMIT 1];

        Test.startTest();
        EnableCommunityUserController.activateUser(contact.Id);
        Test.stopTest();
    }


    @IsTest
    public static void test_enableNewUser() {
        Account account = TestDataFactory.buildAccount('Test Account');
        insert account;

        Contact contact = TestDataFactory.buildContact(account.Id);
        contact.FirstName = 'Annie';
        contact.LastName = 'Tester';
        contact.Email = 'annietester@yopmail.com';
        insert contact;

        Test.startTest();
        EnableCommunityUserController.activateUser(contact.Id);
        Test.stopTest();

        List<User> user = [SELECT Id, IsActive FROM User WHERE ContactId = :contact.Id];
        System.assertEquals(1, user.size());
    }
}