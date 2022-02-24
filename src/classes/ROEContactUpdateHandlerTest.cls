/**
 * Created by lauren.lezberg on 12/13/2018.
 */

@IsTest
private class ROEContactUpdateHandlerTest {

    @IsTest
    static void test_Prior_updateContactToMember() {
        TestDataFactory testData = new TestDataFactory();

        List<RecordType> rTypes = [SELECT Id FROM RecordType WHERE SobjectType = 'Contact' AND Name='Prior Member' ];
        testData.testContact.RecordTypeId = rTypes[0].Id;
        testData.testContact.Paid_Thru_Date__c = Date.newInstance(2017, 12,31);
        testData.testContact.Membership_Status__c = '1-YR Suspended';
        update testData.testContact;

        Test.startTest();
        ROEContactUpdateHandler.updateContactToMember(testData.testContact.Id, null);
        Test.stopTest();

        Contact c = [SELECT Membership_Status__c, Paid_thru_date__c FROM Contact WHERE Id=:testData.testContact.Id LIMIT 1];

        System.assert(c.Membership_Status__c == 'Current', 'Status should be current');
        System.assert(c.Paid_thru_date__c == Date.newInstance(2018, 12,31), 'Paid through date should be 12/31/2018');

    }

    @IsTest
    static void test_Current_updateContactToMember() {
        TestDataFactory testData = new TestDataFactory();

        List<RecordType> rTypes = [SELECT Id FROM RecordType WHERE SobjectType = 'Contact' AND Name='Member' ];
        testData.testContact.RecordTypeId = rTypes[0].Id;
        testData.testContact.Paid_Thru_Date__c = Date.newInstance(2017, 12,31);
        testData.testContact.Membership_Status__c = 'Current';
        update testData.testContact;

        Test.startTest();
        ROEContactUpdateHandler.updateContactToMember(testData.testContact.Id, Date.newInstance(2018, 12,31));
        Test.stopTest();

        Contact c = [SELECT Membership_Status__c, Paid_thru_date__c FROM Contact WHERE Id=:testData.testContact.Id LIMIT 1];

        System.assert(c.Membership_Status__c == 'Current', 'Status should be current');
        System.assert(c.Paid_thru_date__c == Date.newInstance(2018, 12,31), 'Paid through date should be 12/31/2018');

    }

}