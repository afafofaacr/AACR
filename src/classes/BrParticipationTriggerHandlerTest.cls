@IsTest
private class BrParticipationTriggerHandlerTest {

    @TestSetup
    static void setup() {
        Account acc = TestDataFactory.buildAccount('Test Account');
        insert acc;

        Contact con = TestDataFactory.buildContact(acc.Id);
        insert con;

        List<BR_Event__c> events = BrEventTestUtils.testCreateEvents();
        List<BR_Participation__c> participations = new List<BR_Participation__c>();
        List<Virtual_Event_Details__c> eventDetails = new List<Virtual_Event_Details__c>();
        Venue__c ven = LiveTestDataFactory.buildVenue('Test Venue');

        Id virtualRecordTypeId = Schema.SObjectType.Venue__c.getRecordTypeInfosByName().get('Virtual').getRecordTypeId();
        Venue__c ven2 = new Venue__c();
        ven2.RecordTypeId= virtualRecordTypeId;
        ven2.Name='Test Virtual Venue';
        ven2.Integration_Controller__c = 'CallableTest';
        ven2.Base_URL__c = 'https://www.google.com';
        insert ven2;

        for(Integer i = 0;i<events.size();i++){
            participations.add(new BR_Participation__c(Contact__c=con.Id, BR_Event__c=events[i].Id, Participate__c='Yes'));
            if(Math.mod(i,2)==0){
                events[i].Venue__c = ven.Id;
            } else {
                Virtual_Event_Details__c ved = new Virtual_Event_Details__c();
                ved.Event__c = events[i].Id;
                ved.External_Event_Id__c = '123' + i;
                eventDetails.add(ved);

                events[i].Virtual_Venue__c = ven2.Id;
            }
        }
        update events;

        insert eventDetails;


        List<OrgWideEmailAddress> owas = [SELECT Id FROM OrgWideEmailAddress LIMIT 1];
        System.assertEquals(owas.size(), 1);

        insert new BrEvents_Settings__c(Name='org wide email id', Label__c = 'org wide email id', Value__c = owas[0].Id);

//        BrEventTestUtils.testCreateParticipations(events, null, UserInfo.getUserId());
        insert participations;
    }

    @isTest
    public static void testOnAfterUpdate() {
        List<BR_Participation__c> participations = [SELECT Id, Participate__c FROM BR_Participation__c];

        Test.startTest();

        participations[0].Participate__c = 'No';
        update participations[0];

        participations[0].Participate__c = 'Yes';
        update participations[0];

        Test.stopTest();

        System.assertEquals('Yes', participations[0].Participate__c, 'wrong participate value');

    }

    @IsTest
    public static void testOnBeforeDelete(){
        List<BR_Participation__c> participations = [SELECT Id, Participate__c FROM BR_Participation__c];

        Test.startTest();

        participations[0].External_Attendee_Id__c = '12345';
        update participations[0];

        delete participations[0];

        Test.stopTest();
    }

    @isTest
    public static void testOnAfterUpdateVirtual() {

        List<BR_Participation__c> participations = [SELECT Id, Participate__c FROM BR_Participation__c];

        Test.startTest();

        participations[1].Participate__c = 'No';
        update participations[1];

        participations[1].Participate__c = 'Yes';
        update participations[1];

        participations[1].Participate__c = 'No';
        update participations[1];

        participations[1].External_Attendee_Id__c = '12345';
        participations[1].Participate__c = 'Yes';
        update participations[1];

        Test.stopTest();

        System.assertEquals('Yes', participations[1].Participate__c, 'wrong participate value');

    }

    @isTest
    public static void testOnAfterUpdateVirtual2() {

        List<BR_Participation__c> participations = [SELECT Id, Participate__c FROM BR_Participation__c];

        Test.startTest();

        participations[1].External_Attendee_Id__c = '12345';
        update participations[1];

        participations[1].Participate__c = 'Yes';
        update participations[1];

        Test.stopTest();

        System.assertEquals('Yes', participations[1].Participate__c, 'wrong participate value');

    }
}