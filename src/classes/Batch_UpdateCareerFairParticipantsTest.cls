/**
 * Created by lauren.lezberg on 3/17/2021.
 */

@IsTest
private class Batch_UpdateCareerFairParticipantsTest {
    @TestSetup
    public static void setup(){
        List<OrgWideEmailAddress> owas = [SELECT Id FROM OrgWideEmailAddress LIMIT 1];
        System.assertEquals(owas.size(), 1);

        insert new BrEvents_Settings__c(Name='org wide email id', Label__c = 'org wide email id', Value__c = owas[0].Id);

        insert new vFairs_Session__c(API_Key__c = '92348u34');

        BR_Event__c event = LiveTestDataFactory.buildEvent('Test Event', false, false);
        insert event;

        Account acc = TestDataFactory.buildAccount('Test Account');
        insert acc;


        List<ContentVersion> cvs = new List<ContentVersion>();
        List<ContentDocumentLink> cdls = new List<ContentDocumentLink>();


        Id recordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(System.Label.Contact_Non_Member_Record_Type).getRecordTypeId();
        List<Contact> contacts = new List<Contact>();
        String yourFilesContent = 'TEST FILE';
        Map<String, String> fileMap = new Map<String, String>();
        for(Integer i = 0 ; i< 5;i++){
            Contact con = new Contact(LastName = 'Test contact' + i,
                    AccountId = acc.Id,
                    RecordTypeId = recordTypeId,
                    Phone ='9878986789',
                    Fax = 'fax',
                    Email = 'testEmail' + i + '@yopmail.com');
            contacts.add(con);

            ContentVersion cv = new ContentVersion(
                    ContentLocation = 'S', // to use S specify this document is in Salesforce, to use E for external files
                    PathOnClient = 'Resume.txt',// The files name, extension is very important here which will help the file in preview.
                    Title = 'Resume.txt',// Display name of the files
                    VersionData = EncodingUtil.base64Decode(yourFilesContent + String.valueOf(i)));
            cvs.add(cv);

        }

        insert contacts;

        insert cvs;
        cvs = [SELECT ContentDocumentId FROM ContentVersion WHERE Id IN: cvs];
        contacts = [SELECT Id FROM Contact];

        for(Integer i =0 ; i<contacts.size();i++){
            cdls.add(New ContentDocumentLink(
                    LinkedEntityId = contacts[i].Id, // Specify RECORD ID here i.e Any Object ID (Standard Object/Custom Object)
                    ContentDocumentId = cvs[0].ContentDocumentId,  //ContentDocumentId Id from ContentVersion
                    shareType = 'V'));
        }

        insert cdls;

        List<BR_Participation__c> participants = new List<BR_Participation__c>();
        Integer counter = 0;
        for(Contact con: contacts){
            participants.add(new BR_Participation__c(
                    Participate__c = 'Yes',
                    External_Attendee_Id__c = '123' + counter,
                    Contact__c=con.Id,
                    BR_Event__c=event.Id,
                    Bypass_Confirmation__c = true)
            );
            counter++;
        }
        insert participants;



    }

    @IsTest
    static void testBatch() {
        BR_Event__c evt = [SELECT Id FROM BR_Event__c];

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new CreateMockHttpResponseGenerator());

        Batch_UpdateCareerFairParticipants btch = new Batch_UpdateCareerFairParticipants(evt.Id);
        database.executeBatch(btch);

        Test.stopTest();
    }

    public class CreateMockHTTPResponseGenerator implements HttpCalloutMock{
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"id": "83459843758947594"}');
            res.setStatusCode(200);
            return res;
        }
    }
}