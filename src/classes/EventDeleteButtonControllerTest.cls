/**
 * Created by lauren.lezberg on 8/17/2020.
 */

@IsTest
private class EventDeleteButtonControllerTest {

    @testSetup
    public static void setup(){
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

        AACR_Session__c session = new AACR_Session__c(
                Name='Test Session',
                Event__c = testEvent.Id,
                Date__c = Date.newInstance(2016, 10,15),
                Start_Time__c = Time.newInstance(13, 0, 0, 0),
                End_Time__c = Time.newInstance(15, 0, 0, 0)
        );
        insert session;

        Account acc = TestDataFactory.buildAccount('Test Account');
        insert acc;

        Contact con = TestDataFactory.buildContact(acc.Id);
        insert con;

        Session_Speaker__c sp = new Session_Speaker__c(
                Name='speaker 1',
                Session__c = session.Id,
                Speaker__c = con.Id
        );
        insert sp;

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
        sea.SetupEntityId = [SELECT Id, DeveloperName FROM CustomPermission WHERE DeveloperName = 'Event_Delete'][0].Id;
        insert sea;

        PermissionSetAssignment psa = new PermissionSetAssignment();
        psa.AssigneeId = u.Id;
        psa.PermissionSetId = ps.Id;
        insert psa;

        System.runAs(u) {
            Boolean showButton = EventDeleteButtonController.getShowButton(testEvent.Id);
            System.assertEquals(showButton, true);
        }
    }

    @isTest
    public static void test_deleteEvent(){
        BR_Event__c testEvent = [SELECT Id FROM BR_Event__c WHERE Name='Test event0'];

        Test.startTest();

        Map<Boolean, String> deleteMap = EventDeleteButtonController.deleteEvent(testEvent.Id);

        Test.stopTest();

        List<BR_Event__c> evts = [SELECT Name FROM BR_Event__c WHERE Id=: testEvent.Id];
        System.assert(evts.isEmpty(), 'Event Should be deleted');

        List<AACR_Session__c> sessions = [SELECT Id FRom AACR_Session__c WHERE Event__c=: testEvent.Id];
        System.assert(sessions.isEmpty(), 'Sessions Should be deleted');

        List<Session_Speaker__c> speakers = [SELECT Id FROM Session_Speaker__c WHERE Session__r.Event__c=: testEvent.Id];
        System.assert(speakers.isEmpty(), 'speakers Should be deleted');


    }
}