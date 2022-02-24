/**
 * Created by lauren.lezberg on 8/17/2020.
 */

@IsTest
private class SegmentFieldSelectorControllerTest {


    @IsTest
    static void test_getFields() {
        List<UserSegmentHelper.FieldValuePair> contactFvps = new List<UserSegmentHelper.FieldValuePair>();
        UserSegmentHelper.FieldValuePair fvp = new UserSegmentHelper.FieldValuePair();
        fvp.fieldLabel = 'RT_ByName';
        fvp.fieldName = 'RT_ByName__c';
        fvp.operator = '=';
        fvp.fieldValue = 'Member';
        fvp.fieldType = '';

        contactFvps.add(fvp);


        Test.startTest();

        List<List<UserSegmentHelper.FieldValuePair>> fvps = SegmentFieldSelectorController.getFields('Contact');
        System.assert(!fvps.isEmpty());

        SegmentFieldSelectorController.saveSegmentFields('Contact', JSON.serialize(contactFvps));

        Test.stopTest();
    }
}