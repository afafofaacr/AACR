/**
 * Created by lauren.lezberg on 3/18/2021.
 */

@IsTest
private class Schedule_ProcessAM21ParticipantsTest {

    @TestSetup
    static void setup(){
        OrgWideEmailAddress add = [SELECT Id FROM OrgWideEmailAddress LIMIT 1];
        BrEvents_Settings__c settings = new BrEvents_Settings__c(Name='org wide email id', Value__c=add.Id);
        insert settings;

        Id virtualRecordTypeId = Schema.SObjectType.Venue__c.getRecordTypeInfosByName().get('Virtual').getRecordTypeId();
        Venue__c ven = new Venue__c();
        ven.RecordTypeId= virtualRecordTypeId;
        ven.Name='Test Venue';
        ven.Integration_Controller__c = 'CallableTest';
        ven.Base_URL__c = 'https://www.google.com';
        insert ven;

        BR_Event__c item = new BR_Event__c(
                Name = 'AACR Annual Meeting 2021',
                Start_Date__c = Datetime.now().addDays(10),
                End_Date__c = Datetime.now().addDays(11),
                Virtual_Venue__c = ven.Id,
                Location__Latitude__s = 51.5156950,
                Location__Longitude__s = -0.0893931,
                Venue_Address__c = 'Test ave 12/20',
                Registration_Confirmation_Message__c = 'Test Message'
        );
        insert item;

        Virtual_Event_Details__c ved = new Virtual_Event_Details__c();
        ved.Event__c = item.Id;
        ved.External_Event_Id__c = '1234567890';
        insert ved;

        Account acc = TestDataFactory.buildAccount('Test Account');
        insert acc;

        Contact con = TestDataFactory.buildContact(acc.Id);
        insert con;

        User u = TestDataFactory.buildUser(con.Id);
        insert u;

        insert new BR_Participation__c(BR_Event__c = item.Id, Participate__c = 'Yes', User__c = u.Id, Contact__c= con.Id);
    }


    @IsTest
    static void testBatch() {

        Test.startTest();

        SchedulableContext sc = null;
        Schedule_ProcessAM21Participants obj = new Schedule_ProcessAM21Participants();
        obj.execute(sc);

        Test.stopTest();


    }
}