/**
 * Created by lauren.lezberg on 5/12/2020.
 */
@isTest
private with sharing class EventCancelButtonControllerTest {

    @testSetup
    public static void setup(){
        BR_Event__c testEvent = new BR_Event__c(
                Name = 'Test event0',
                Draft__c = false,
                Start_Date__c = Datetime.newInstance(2016, 10, 15, 12, 30, 0),
                End_Date__c = Datetime.newInstance(2016, 10, 15, 17, 30, 0),
                Location__Latitude__s = 51.5156950,
                Location__Longitude__s = -0.0893931,
                Venue_Address__c = 'Test ave 12/20',
                Event_Preferences_Form_Fieldset__c = 'test'
        );
        insert testEvent;

        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        User u = new User(alias = 'test',
                // AccountId = contactRecord1.AccountId,
                ProfileId = p.Id,
                email = 'test@testorg.com',
                emailencodingkey = 'UTF-8',
                lastname = 'Test User2',
                languagelocalekey = 'en_US',
                localesidkey = 'en_US',
                timezonesidkey = 'America/Los_Angeles',
                username = System.now().millisecond() + 'test@testorg2.com');
        insert u;


    }



    @isTest
    public static void test_showButton(){
        BR_Event__c testEvent = [SELECT Id FROM BR_Event__c WHERE Name='Test event0'];

        User u = [SELECT Id FROM User WHERE email= 'test@testorg.com'];

        PermissionSet ps = new PermissionSet();
        ps.Name = 'Test';
        ps.Label = 'Test';
        insert ps;

        SetupEntityAccess sea = new SetupEntityAccess();
        sea.ParentId = ps.Id;
        sea.SetupEntityId = [SELECT Id, DeveloperName FROM CustomPermission WHERE DeveloperName = 'Event_Cancel'][0].Id;
        insert sea;

        PermissionSetAssignment psa = new PermissionSetAssignment();
        psa.AssigneeId = u.Id;
        psa.PermissionSetId = ps.Id;
        insert psa;

        System.runAs(u) {
            Boolean showButton = EventCancelButtonController.getShowButton(testEvent.Id);
            System.assertEquals(showButton, true);
        }
    }

    @isTest
    public static void test_cancelEvent(){
        BR_Event__c testEvent = [SELECT Id FROM BR_Event__c WHERE Name='Test event0'];

        Test.startTest();

        Map<Boolean, String> cancelMap = EventCancelButtonController.cancelEvent(testEvent.Id);

        Test.stopTest();

        List<BR_Event__c> evts = [SELECT Name, Cancelled__c FROM BR_Event__c WHERE Id=: testEvent.Id];
        System.assertEquals(true, evts[0].Cancelled__c);

    }

}