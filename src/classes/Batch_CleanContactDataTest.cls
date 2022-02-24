/**
 * Created by afaf.awad on 7/27/2020.
 */

@IsTest
private class Batch_CleanContactDataTest {

    @testSetup public static void setup() {
        Account acc = TestDataFactory.buildAccount('Test Account');
        insert acc;

        List<Contact> testContacts = new List<Contact>();

        for(Integer i=0; i<200; i++){
            Contact con = TestDataFactory.buildContact(acc.Id);
            con.LastName = 'TEST CONTACT';
            con.FirstName = 'UPPERCASE';
            con.MiddleName = 'lowercase';
            con.Email = 'testEmail' + i + '@yopmail.com';
            testContacts.add(con);
        }
        insert testContacts;
    }

    @IsTest
    static void test_CleanContactData() {

        Test.startTest();

        database.executeBatch(new Batch_CleanContactData());

        Test.stopTest();

    }
}