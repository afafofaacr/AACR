/**
 * Created by lauren.lezberg on 2/21/2020.
 */
@isTest
private with sharing class DietaryPreferencesSelectorControllerTest {

    @isTest
    public static void test_getFieldsets(){
        BR_Event__c testEvent = new BR_Event__c(
                Name = 'Test event0',
                Start_Date__c = Datetime.newInstance(2016, 10, 15, 12, 30, 0),
                End_Date__c = Datetime.newInstance(2016, 10, 15, 17, 30, 0),
                Location__Latitude__s = 51.5156950,
                Location__Longitude__s = -0.0893931,
                Venue_Address__c = 'Test ave 12/20',
                Event_Preferences_Form_Fieldset__c = 'test'
        );
        insert testEvent;

        Test.startTest();

        Map<String,List<String>> fieldsetMap = DietaryPreferencesSelectorController.getFieldSets(testEvent.Id);
        System.assertNotEquals(null, fieldsetMap);

        Test.stopTest();
    }
}