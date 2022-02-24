/**
 * Created by afaf.awad on 8/11/2021.
 */

@IsTest
private class LoginAsCommunityUserControllerTest {
    @IsTest
    static void test_getLoginURL() {

        Account account = TestDataFactory.buildAccount('Setup Account');
        insert account;

        Contact contact = TestDataFactory.buildContact(account.Id);
        contact.FirstName = 'Olivia';
        insert contact;

        User user = TestDataFactory.buildUser(contact.Id);
        insert user;

        LoginAsCommunityUserController.getLoginURL(contact.Id);
    }
    
}