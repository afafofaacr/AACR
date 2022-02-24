/**
 * Created by lauren.lezberg on 8/17/2020.
 */

@IsTest
private class ObjectFieldSelectorControllerTest {


    @IsTest
    static void test_getFields() {

        BR_Event__c evt = LiveTestDataFactory.buildEvent('Test Events', false, false);
        insert evt;

        List<User_Segment_Fields__mdt> segmentFields = new List<User_Segment_Fields__mdt>();
        User_Segment_Fields__mdt segField = new User_Segment_Fields__mdt(API_Name__c='RT_ByName__c', Object_Type__c='Contact');
        segmentFields.add(segField);

        AC_User_Segment__c segment = LiveTestDataFactory.buildUserSegment('Test Segment');
        segment.Query__c = 'SELECT Id FROM User WHERE ContactId IN (SELECT Id FROM Contact WHERE RT_ByName__c=\'Nonmember\')';
        insert segment;


        Test.startTest();

        UserSegmentHelper.segFields.addAll(segmentFields);
        List<List<UserSegmentHelper.FieldValuePair>> fields = ObjectFieldSelectorController.getFields('Contact', segment.Id);

        System.assert(!fields.isEmpty());
        
        Test.stopTest();
    }
}