/**
 * Created by afaf.awad on 7/15/2021.
 */
@IsTest
public with sharing class Batch_EmailBadAddressesTest {

    @TestSetup
    public static void setup() {

        Account acc = TestDataFactory.buildAccount('Test Account');
        insert acc;

        List<Contact> contacts = new List<Contact>();
        for(Integer i=0; i<100 ; i++) {
            Contact con = TestDataFactory.buildContact(acc.Id);
            con.FirstName = 'Zono';
            con.LastName = 'TestAddress' + i;
            con.Email = 'testcontact'+i+'@yopmail.com';
            contacts.add(con);
        }
        insert contacts;

        List<OrderApi__Known_Address__c> knownAddresses = new List<OrderApi__Known_Address__c>();
        for(Integer j=0; j< contacts.size(); j++) {
            OrderApi__Known_Address__c ka = new OrderApi__Known_Address__c();
            ka.OrderApi__Street__c = '74'+ j + ' Evergreen Terrace';
            ka.OrderApi__City__c = 'Springfield';
            ka.OrderApi__Province__c = 'Ohio';
            ka.OrderApi__Country__c = 'United States';
            ka.OrderApi__Postal_Code__c = '45501';
            ka.Type__c = 'Other';
            ka.OrderApi__Contact__c = contacts[j].Id;
            ka.Bad_Address__c = true;
            knownAddresses.add(ka);
        }
        insert knownAddresses;

    }

    @isTest
    public static void test_Scheduler() {
        String CRON_EXP = '8 0 0 15 3 ? 2022';

        Test.startTest();
        String jobId = System.schedule('ScheduledApexTest',
                CRON_EXP,
                new Schedule_EmailBadAddress());
        Test.stopTest();

    }

    @IsTest
    public static void test_Batch_EmailBadAddressTest(){

        Test.setMock(HttpCalloutMock.class, new MockHTTPResponseGenerator());

        test.startTest();
        Database.executeBatch(new Batch_EmailBadAddresses());
        test.stopTest();
    }

    public class MockHTTPResponseGenerator implements HttpCalloutMock{
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/x-www-form-urlencoded');
            res.setBody('Success');
            res.setStatusCode(200);
            return res;
        }
    }
}