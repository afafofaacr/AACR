/**
 * Created by lauren.lezberg on 8/17/2020.
 */

@IsTest
private class SegmentBuilderControllerTest {

    @testsetup
    public static void setup(){
        Account acc = TestDataFactory.buildAccount('Test Account');
        acc.Institution_Type__c = 'Government';
        insert acc;

        Id memberRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Member').getRecordTypeId();
        Contact con = TestDataFactory.buildContact(acc.Id);
        con.RecordTypeId = memberRecordTypeId;
        insert con;

        User u = TestDataFactory.buildUser(con.Id);
        insert u;
    }

    @IsTest
    static void test_SegmentBuilderQuery() {
        List<UserSegmentHelper.FieldValuePair> contactFvps = new List<UserSegmentHelper.FieldValuePair>();
        UserSegmentHelper.FieldValuePair fvp = new UserSegmentHelper.FieldValuePair();
        fvp.fieldLabel = 'RT_ByName';
        fvp.fieldName = 'RT_ByName__c';
        fvp.operator = '=';
        fvp.fieldValue = 'Member';
        fvp.fieldType = '';

        contactFvps.add(fvp);

        List<UserSegmentHelper.FieldValuePair> accountFvps = new List<UserSegmentHelper.FieldValuePair>();
        fvp = new UserSegmentHelper.FieldValuePair();
        fvp.fieldLabel = 'Institution Type';
        fvp.fieldName = 'Institution_Type__c';
        fvp.operator = '!=';
        fvp.fieldValue = 'Nonprofit Research Institute';
        fvp.fieldType = '';

        accountFvps.add(fvp);


        Test.startTest();

        String queryString = SegmentBuilderController.getQueryString(JSON.serialize(contactFvps), JSON.serialize(accountFvps));
        System.assertNotEquals(null, queryString);

        List<Contact> contacts = SegmentBuilderController.getQueryResults(JSON.serialize(contactFvps), JSON.serialize(accountFvps));
        System.assert(!contacts.isEmpty());

        Test.stopTest();

    }

    
}