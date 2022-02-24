/**
 * Created by lauren.lezberg on 8/17/2020.
 */

@IsTest
private class Batch_ProcessVirtualParticipationsTest {

    @testsetup
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
                Name = 'Test event0',
                Start_Date__c = Datetime.now().addDays(10),
                End_Date__c = Datetime.now().addDays(11),
                Virtual_Venue__c = ven.Id,
                Location__Latitude__s = 51.5156950,
                Location__Longitude__s = -0.0893931,
                Venue_Address__c = 'Test ave 12/20',
                Registration_Confirmation_Message__c= 'TEST'
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
    static void test_ProcessParticipations() {
        BR_Event__c evt = [SELECT Id, (SELECT Id FROM BR_Participations__r) FROM BR_Event__c WHERE Name = 'Test event0'];
        Set<Id> partIds = new Set<Id>();
        Set<Id> eventIds = new Set<Id>();
        eventIds.add(evt.Id);
        for(BR_Participation__c p : evt.BR_Participations__r){
            partIds.add(p.Id);
        }

        Test.startTest();

        database.executeBatch(new Batch_ProcessVirtualParticipations(partIds, eventIds));

        Test.stopTest();


    }
}