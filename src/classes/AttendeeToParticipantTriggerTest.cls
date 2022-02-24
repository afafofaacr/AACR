/**
 * Created by lauren.lezberg on 9/1/2020.
 */

@IsTest
private class AttendeeToParticipantTriggerTest {

    @TestSetup
    public static void setup(){
        EventApi__Event__c evt = TestDataFactory.buildEvent();
        insert evt;

        BR_Event__c liveEVT = LiveTestDataFactory.buildEvent('Test Event', true, false);
        insert liveEVT;

        Account acc = TestDataFactory.buildAccount('Test Account');
        insert acc;

        Contact con = TestDataFactory.buildContact(acc.Id);
        insert con;

        User u = TestDataFactory.buildUser(con.Id);
        insert u;
    }


    @IsTest
    static void testParticipantCreation() {
        BR_Event__c liveevt = [SELECT Id FROM BR_Event__c LIMIT 1];

        EventApi__Event__c evt = [SELECT Id FROM EventApi__Event__c LIMIT 1];

        Contact con = [SELECT Id FROM Contact WHERE Account.Name = 'Test Account'];

        Virtual_Meeting_Links__mdt vml = new Virtual_Meeting_Links__mdt(
                DeveloperName='Test',
                Event_Id__c=evt.Id,
                Live_Event_Id__c = liveevt.Id
        );

        AttendeeToParticipantTriggerHandler.links = new List<Virtual_Meeting_Links__mdt>{vml};

        Test.startTest();

        EventApi__Attendee__c att = new EventApi__Attendee__c(EventApi__Contact__c=con.Id, EventApi__Event__c=evt.Id);
        insert att;

        Test.stopTest();


        Integer pCount = [SELECT COUNT() FROM BR_Participation__c WHERE Contact__c=:con.Id];
        System.assertEquals(1, pCount);
    }
}