/**
 * Created by lauren.lezberg on 5/22/2020.
 */
@isTest
global with sharing class Batch_SendRegConfirmationEmailsTest {


    @testSetup
    global static void setup(){
        Account testAcc = TestDataFactory.buildAccount('Test Account');
        insert testAcc;

        EventApi__Event__c testEvt = TestDataFactory.buildEvent();
        testEvt.Calendar_Invite_Msg__c = 'TEST';
        testEvt.EventApi__Start_Date__c = Date.today();
        testEvt.EventApi__Start_Date_Time__c = System.now();
        testEvt.EventApi__End_Date_Time__c = SYstem.now().addDays(2);
        testEvt.EventApi__End_Date__c = Date.today().addDays(2);
        testEvt.EventApi__Logo_Image__c = 'https://www.testImgurl.com';
        testEvt.EventApi__Description__c = 'THIS IS A TEST EVENT.';
        insert testEvt;


        List<Contact> contacts = new List<Contact>();
        List<EventApi__Attendee__c> attendees = new List<EventApi__Attendee__c>();
        for(Integer i=0;i<100;i++){
            Contact con = new Contact(FirstName = 'Test', LastName ='BatchTest' + i, Email='test.batch' + i + '@yopmail.com', AccountId=testAcc.Id);
            contacts.add(con);

        }
        insert contacts;
        System.assertEquals(100, contacts.size());

        contacts = [SELECT Id, Email FROM COntact];

        List<User> users = new List<User>();

        Profile profileRecord = [SELECT Id
        FROM Profile
        WHERE Name =: 'Fonteva Customer Community Login User'
        LIMIT 1];


        for(Contact con : contacts){
            // Create users record
            User userRecord = new User(alias = String.valueOf(con.Id).substring(0,7),
                    ContactId = con.Id,
                    // AccountId = contactRecord1.AccountId,
                    ProfileId = profileRecord.Id,
                    email = con.Email,
                    emailencodingkey = 'UTF-8',
                    lastname = 'Test User2',
                    CommunityNickname = con.Id,
                    languagelocalekey = 'en_US',
                    localesidkey = 'en_US',
                    timezonesidkey = 'America/Los_Angeles',
                    username = System.now().millisecond() + con.Email);
            users.add(userRecord);
            EventApi__Attendee__c att = new EventApi__Attendee__c();
            att.EventApi__Event__c = testEvt.Id;
            att.EventApi__Contact__c = con.Id;
            attendees.add(att);
        }

        insert attendees;
        SYstem.assertEquals(100, attendees.size());

        insert users;

    }


    @isTest
    global static void test_runBatch(){
        EventApi__Event__c evt = [SELECT id FROM EventApi__Event__c WHERE Name='Test Event'];

        EmailTemplate et = new EmailTemplate();
        et.IsActive = true;
        et.Description = 'test description';
        et.DeveloperName = 'Test_Template';
        et.TemplateType = 'text';
        et.Name='Test Template';
        et.FolderId = UserInfo.getUserId();
        insert et;

        Test.startTest();

        System.assertEquals(100, [SELECT Id FROM COntact].size());

        System.assertEquals(100, [SELECT Id FROM EventApi__Attendee__c WHERE EventApi__Event__c=:evt.Id AND EventApi__Contact__c IN (SELECT Id FROM Contact)].size());

        System.assertEquals(100, [SELECT Id FROM Contact WHERE Id IN (SELECT EventApi__Contact__c FROM EventApi__Attendee__c WHERE EventApi__Event__c=:evt.Id)].size());

        Batch_SendRegConfirmationEmails bclass = new Batch_SendRegConfirmationEmails(evt.Id, 'Mass Mail: ' + et.Description, et.Id);
        Database.executeBatch(bclass);

        Test.stopTest();
    }
}