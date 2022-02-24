/**
 * Created by mitfity on 28.08.2019.
 */

@IsTest
private class brEventDietaryPreferencesControllerTest {

    @IsTest
    static void testGetFieldSetOptions() {
        Test.startTest();

        List<Map<String, String>> options = brEventDietaryPreferencesController.getFieldSetOptions();

        System.assertNotEquals(null, options);

        Test.stopTest();
    }

    @IsTest
    static void testGetSelectedFieldSetName() {
        Test.startTest();

        BR_Event__c testEvent = new BR_Event__c(
                Name = 'Test event0',
                Start_Date__c = Datetime.newInstance(2016, 10, 15, 12, 30, 0),
                End_Date__c = Datetime.newInstance(2016, 10, 15, 17, 0, 0),
                Location__Latitude__s = 51.5156950,
                Location__Longitude__s = -0.0893931,
                Venue_Address__c = 'Test ave 12/20'
        );
        insert testEvent;

        Id currentUserId = UserInfo.getUserId();

        AC_User_Segment__c employees = new AC_User_Segment__c();
        employees.Name = 'Employees';
        employees.Description__c = 'Test';
        employees.Query__c = 'SELECT Id FROM User WHERE Id = \'' + currentUserId + '\'';
        insert employees;

        AC_Event_User_Segment__c eventEmployees = new AC_Event_User_Segment__c();

        eventEmployees.AC_Event__c = testEvent.Id;
        eventEmployees.AC_User_Segment__c = employees.Id;
        eventEmployees.Price__c = 3.88;
        eventEmployees.Priority__c = 10;
        eventEmployees.Event_Preferences_Form_Fieldset__c = 'test';

        insert eventEmployees;

        String fieldSetName = brEventDietaryPreferencesController.getSelectedFieldSetName(eventEmployees.Id);

        System.assertEquals(fieldSetName, eventEmployees.Event_Preferences_Form_Fieldset__c);

        Test.stopTest();
    }

    @IsTest
    static void testSaveFieldSetName() {
        Test.startTest();
        
        BR_Event__c testEvent = new BR_Event__c(
                Name = 'Test event0',
                Start_Date__c = Datetime.newInstance(2016, 10, 15, 12, 30, 0),
                End_Date__c = Datetime.newInstance(2016, 10, 15, 17, 0, 0),
                Location__Latitude__s = 51.5156950,
                Location__Longitude__s = -0.0893931,
                Venue_Address__c = 'Test ave 12/20'
        );
        insert testEvent;

        Id currentUserId = UserInfo.getUserId();

        AC_User_Segment__c employees = new AC_User_Segment__c();
        employees.Name = 'Employees';
        employees.Description__c = 'Test';
        employees.Query__c = 'SELECT Id FROM User WHERE Id = \'' + currentUserId + '\'';
        insert employees;

        AC_Event_User_Segment__c eventEmployees = new AC_Event_User_Segment__c();

        eventEmployees.AC_Event__c = testEvent.Id;
        eventEmployees.AC_User_Segment__c = employees.Id;
        eventEmployees.Price__c = 3.88;
        eventEmployees.Priority__c = 10;
        eventEmployees.Event_Preferences_Form_Fieldset__c = 'test';

        insert eventEmployees;

        String anotherFieldSetName = 'another test';

        brEventDietaryPreferencesController.saveFieldSetName(eventEmployees.Id, anotherFieldSetName);

        String fieldSetName = brEventDietaryPreferencesController.getSelectedFieldSetName(eventEmployees.Id);
        System.assertEquals(fieldSetName, anotherFieldSetName);

        Test.stopTest();
    }
}