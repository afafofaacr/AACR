/**
 * Created by lauren.lezberg on 3/8/2021.
 */
@IsTest
private with sharing class vFairsHelperTest {

    @TestSetup
    public static void setup(){
        List<OrgWideEmailAddress> owas = [SELECT Id FROM OrgWideEmailAddress LIMIT 1];
        System.assertEquals(owas.size(), 1);

        insert new BrEvents_Settings__c(Name='org wide email id', Label__c = 'org wide email id', Value__c = owas[0].Id);

        Account acc = TestDataFactory.buildAccount('Test Account');
        insert acc;

        Contact con = TestDataFactory.buildContact(acc.Id);
        insert con;

        User u = TestDataFactory.buildUser(con.Id);
        insert u;

        BR_Event__c event = LiveTestDataFactory.buildEvent('Test Event', false, false);
        insert event;

        insert new vFairs_Session__c(API_Key__c = '92348u34');

        BR_Participation__c participation = new BR_Participation__c(Participate__c = 'Yes', User__c=u.Id,Contact__c=con.Id,BR_Event__c=event.Id);
        insert participation;

        String yourFilesContent = 'TEST FILE';

        ContentVersion conVer = new ContentVersion();
        conVer.ContentLocation = 'S'; // to use S specify this document is in Salesforce, to use E for external files
        conVer.PathOnClient = 'Resume.txt'; // The files name, extension is very important here which will help the file in preview.
        conVer.Title = 'Resume.txt'; // Display name of the files
        conVer.VersionData = EncodingUtil.base64Decode(yourFilesContent); // converting your binary string to Blog
        insert conVer;    //Insert ContentVersion


        // First get the Content Document Id from ContentVersion Object
        Id conDoc = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:conVer.Id].ContentDocumentId;
        //create ContentDocumentLink  record
        ContentDocumentLink conDocLink = New ContentDocumentLink();
        conDocLink.LinkedEntityId = con.Id; // Specify RECORD ID here i.e Any Object ID (Standard Object/Custom Object)
        conDocLink.ContentDocumentId = conDoc;  //ContentDocumentId Id from ContentVersion
        conDocLink.shareType = 'V';
        insert conDocLink;

    }

    @IsTest
    public static void test_insertAttendee(){
        BR_Participation__c participant = [SELECT Id FROM BR_Participation__c];

        Test.startTest();

        Test.setMock(HttpCalloutMock.class, new CreateMockHttpResponseGenerator());

        vFairsHelper.insertAttendee(participant.Id);

        Test.stopTest();

        participant = [SELECT Id, External_Attendee_Id__c FROM BR_Participation__c WHERE Id=:participant.Id];
        System.assertNotEquals(null, participant.External_Attendee_Id__c);
    }

    @IsTest
    public static void test_updateAttendee(){
        BR_Participation__c participant = [SELECT Id FROM BR_Participation__c];
        participant.External_Attendee_Id__c = '12345';
        update participant;

        Test.startTest();

        Test.setMock(HttpCalloutMock.class, new CreateMockHttpResponseGenerator());

        vFairsHelper.updateAttendee(participant.Id);

        Test.stopTest();
    }

    @IsTest
    public static void test_insertAttendeeSynchronously(){
        BR_Participation__c participant = [SELECT Id FROM BR_Participation__c];

        Test.startTest();

        Test.setMock(HttpCalloutMock.class, new CreateMockHttpResponseGenerator());

        vFairsHelper.synchronousInsertAttendee(participant.Id);

        Test.stopTest();

    }


    public class CreateMockHTTPResponseGenerator implements HttpCalloutMock{
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"id": "83459843758947594", "resume": "https://www.google.com"}');
            res.setStatusCode(200);
            return res;
        }
    }
}