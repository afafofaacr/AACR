/**
 * Created by lauren.lezberg on 8/17/2020.
 */

@IsTest
private class UserSegmentHelperTest {

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


    @isTest
    public static void test_getAvailableFields(){
        Profile stdUserProfile = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
        User user = new User(Alias = 'testusr1', Email='testusr100@testorg.com',
                EmailEncodingKey='UTF-8', LastName='Testing1', LanguageLocaleKey='en_US',
                LocaleSidKey='en_US', ProfileId = stdUserProfile.Id,
                TimeZoneSidKey = UserInfo.getTimeZone().getID(), UserName='testusr100@testorg.com');

        insert user;
//        System.assertNotEquals(null, user.Id, 'user is not created');
//        BrEventTestUtils.assignPermissionSet(user.Id, 'Live_Events');

        List<User_Segment_Fields__mdt> segmentFields = new List<User_Segment_Fields__mdt>();
        User_Segment_Fields__mdt segField = new User_Segment_Fields__mdt(API_Name__c='Name', Object_Type__c='Contact');
        segmentFields.add(segField);
        segField = new User_Segment_Fields__mdt(API_Name__c='Name', Object_Type__c='Account');
        segmentFields.add(segField);



        System.runAs(user) {
            Test.startTest();

//            List<User_Segment_Fields__mdt> segmentFields = [SELECT API_Name__c FROM User_Segment_Fields__mdt WHERE Object_Type__c='Contact'];
            UserSegmentHelper.segFields.addAll(segmentFields);
            List<UserSegmentHelper.FieldValuePair> fvps = UserSegmentHelper.getAvailableSegmentFields('Contact');
            System.assert(!fvps.isEmpty());

            Test.stopTest();
        }
    }


    @IsTest
    static void test_buildAndParseQuery() {
        List<UserSegmentHelper.FieldValuePair> contactFvps = new List<UserSegmentHelper.FieldValuePair>();
        UserSegmentHelper.FieldValuePair fvp = new UserSegmentHelper.FieldValuePair();
        fvp.fieldLabel = 'RT_ByName';
        fvp.fieldName = 'RT_ByName__c';
        fvp.operator = '=';
        fvp.fieldValue = 'Member';
        fvp.fieldType = '';

        contactFvps.add(fvp);

        fvp.fieldLabel = 'Number of Soft Credits';
        fvp.fieldName = 'npsp__Number_of_Soft_Credits__c';
        fvp.operator = '>';
        fvp.fieldValue = String.valueOf(1.0);
        fvp.fieldType = 'DOUBLE';

        contactFvps.add(fvp);


        List<UserSegmentHelper.FieldValuePair> accountFvps = new List<UserSegmentHelper.FieldValuePair>();
        fvp = new UserSegmentHelper.FieldValuePair();
        fvp.fieldLabel = 'Institution Type';
        fvp.fieldName = 'Institution_Type__c';
        fvp.operator = '!=';
        fvp.fieldValue = 'Nonprofit Research Institute';
        fvp.fieldType = '';

        accountFvps.add(fvp);

        fvp.fieldLabel = 'Created Date';
        fvp.fieldName = 'CreatedDate';
        fvp.operator = '<';
        fvp.fieldValue = String.valueOf(Date.today());
        fvp.fieldType = 'Date';

        accountFvps.add(fvp);

//        fvp.fieldLabel = 'Last Modified Date';
//        fvp.fieldName = 'LastModifiedDate';
//        fvp.operator = '<=';
//        fvp.fieldValue = String.valueOf(Date.today());
//        fvp.fieldType = 'Date';
//
//        accountFvps.add(fvp);


        Test.startTest();

        String queryString = UserSegmentHelper.buildSegmentQueryString(JSON.serialize(contactFvps), JSON.serialize(accountFvps));
        System.debug('queryString: ' + queryString);
        System.assertNotEquals(null, queryString);

        Map<String,UserSegmentHelper.FieldValuePair> fieldValuePairMap = UserSegmentHelper.parseSegmentQuery(queryString, 'Contact');
        System.assertNotEquals(null, fieldValuePairMap);


        Test.stopTest();


    }

}