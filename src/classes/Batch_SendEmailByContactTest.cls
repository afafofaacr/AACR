/**
 * Created by afaf.awad on 9/30/2020.
 */

@IsTest
private class Batch_SendEmailByContactTest {

    @testSetup public static void setup() {

        Account acc = TestDataFactory.buildAccount('Test Account');
        insert acc;

        List<Contact> contacts = new List<Contact>();
        for (Integer i = 0; i < 200; i++) {
            Contact con = TestDataFactory.buildContact(acc.Id);
            con.LastName = con.LastName + i;
            con.Email = 'testEmail' + i + '@yopmail.com';
            con.Title = 'Tester';
            contacts.add(con);
        }
        insert contacts;

    }

    @isTest
    public static void test_sendEmailsByContact() {

        String body = 'Testing Email Messaging with merge fields : {!Contact.Email} and {!EventApi__Attendee__c.EventApi__Event__c} ' +
                'and {!EventApi__Attendee__c.EventApi__Full_Name__c} ';

        EmailTemplate e = new EmailTemplate (developerName = 'Test_Email', FolderId = userInfo.getUserId(), TemplateType= 'Text', Name = 'Test Email'
                , HtmlValue = body);
        insert e;


        Test.startTest();
        database.executeBatch(new Batch_SendEmailByContact('Test Subject', 'Test Email','where Title = \'Tester\''));
        Test.stopTest();

    }
}