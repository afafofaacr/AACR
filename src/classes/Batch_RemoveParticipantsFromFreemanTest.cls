/**
 * Created by lauren.lezberg on 3/17/2021.
 */

@IsTest
private class Batch_RemoveParticipantsFromFreemanTest {
    @testsetup
    static void setup(){
        insert new Fuzion_Session__c(Client_Id__c = '92348u34', Client_Secret__c='4580568406856');


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
                Registration_Confirmation_Message__c = 'TEST'
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

        insert new BR_Participation__c(BR_Event__c = item.Id, External_Attendee_Id__c='12345', Participate__c = 'Yes', User__c = u.Id, Contact__c= con.Id);
    }

    @IsTest
    static void test_deleteAttendees() {
        BR_Event__c evt = [SELECT Id FROM BR_Event__c WHERE Name = 'Test event0'];
        Virtual_Event_Details__c ved = [SELECT External_Event_Id__c FROM Virtual_Event_Details__c WHERE Event__c=:evt.Id];

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new CreateMockHttpResponseGenerator());

        database.executeBatch(new Batch_RemoveParticipantsFromFreeman(evt.Id, ved.External_Event_Id__c));

        Test.stopTest();


    }

    public class CreateMockHTTPResponseGenerator implements HttpCalloutMock{
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"message": "Request was successful", "error": "false", "payload":[{"fuzion_attendee_id":"12345"}]}');
            res.setStatusCode(200);
            return res;
        }
    }
}