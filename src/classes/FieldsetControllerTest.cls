/**
 * Created by lauren.lezberg on 8/17/2020.
 */

@IsTest
private class FieldsetControllerTest {


    @IsTest
    static void test_getStateList() {

        Test.startTest();

        Map<string, String> stateMap = FieldsetController.getStateList('US');
        System.assertNotEquals(null, stateMap);

        Test.stopTest();
    }

    @isTest
    public static void test_getFieldsInFieldset(){
        Test.startTest();

        FieldsetController.FieldsetInfo fieldsetInfo = FieldsetController.getFieldsInFieldset('BR_Participation__c', 'Dietary_Preferences');
        System.assert(!fieldsetInfo.fields.isEmpty());

        Test.stopTest();
    }
}