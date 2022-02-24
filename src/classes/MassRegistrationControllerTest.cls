/**
 * Created by afaf.awad on 6/11/2020.
 */

@IsTest
private class MassRegistrationControllerTest {

    @testSetup
    static void setup(){
        Account acc = TestDataFactory.buildAccount('Test Account');
        insert acc;

        List<Contact> contacts = new List<Contact>();
        for(Integer i=0; i<=2 ; i++) {
            Contact testContact = TestDataFactory.buildContact(acc.Id);
            testContact.LastName = 'Test Contact'+ i;
            testContact.Email = 'testEmail' + i + '@yopmail.com';
            contacts.add(testContact);
            System.debug('Test Contact = ' + testContact);
        }

        insert contacts;

        Contact dupContact = TestDataFactory.buildContact(acc.Id);
        dupContact.LastName = 'Test Contact0';
        dupContact.Email = 'testEmail0@yopmail.com';
        insert dupContact;

        EventApi__Event__c testEvt = TestDataFactory.buildEvent();
        testEvt.EventApi__Event_Key__c = '3847294726';
        testEvt.EventApi__Start_Date__c = Date.today();
        testEvt.EventApi__Start_Time__c = '08:00 AM';
        testEvt.EventApi__End_Time__c = '08:00 PM';
        testEvt.EventApi__End_Date__c = Date.today().addDays(2);
        testEvt.EventApi__Logo_Image__c = 'https://www.testImgurl.com';
        testEvt.EventApi__Description__c = 'THIS IS A TEST EVENT.';
        insert testEvt;

        System.debug('Test Contact List: ' + contacts);

        EventApi__Attendee__c testAtt = new EventApi__Attendee__c(EventApi__Event__c = testEvt.Id,
                EventApi__Contact__c = contacts.get(0).Id);
        insert testAtt;
    }

    @isTest
    static void test_isEligibleEvent(){
        String eventId = [Select Id from EventApi__Event__c WHERE Name LIKE 'Test Event' LIMIT 1].Id;

        Test.startTest();
         Boolean eligible = MassRegistrationController.isEligibleEvent(eventId);
        Test.stopTest();

        System.assertEquals(false, eligible);
    }

    @IsTest
    static void test_ValidateData(){
        List<Contact> contacts = [Select AACR_ID__c, Email FROM Contact];
        String eventId = [SELECT Id FROM EventApi__Event__c WHERE Name = 'Test Event'].Id;

        String fileData = 'Email,Id' + '\n'
                + contacts[0].Email + ',' + contacts[0].AACR_ID__c + '\n'
                + contacts[1].Email + ',' + contacts[1].AACR_ID__c;

        String fileDataNoEmail = 'Email,Id' + '\n'
                + contacts[0].Email + ',' + contacts[0].AACR_ID__c + '\n'
                + ' ,' + contacts[1].AACR_ID__c;

        System.debug('fileData = ' + fileData);

        List<String> fields = new List<String>();

        fields.add('Email');
        fields.add('Id');


        Test.startTest();
        Boolean noEmail = MassRegistrationController.validateData(fileDataNoEmail, fields, 'Id', 'Email');
        Boolean withEmail = MassRegistrationController.validateData(fileData, fields, 'Id', 'Email');
        Test.stopTest();
        System.assertEquals(false, noEmail);
        System.assertEquals(true, withEmail);
    }

    @isTest
    static void test_processData(){
        List<Contact> contacts = [Select AACR_ID__c, Email FROM Contact];
        String eventId = [SELECT Id FROM EventApi__Event__c WHERE Name = 'Test Event'].Id;

        String fileData = 'Email,Id' + '\n'
                + contacts[0].Email + ',' + contacts[0].AACR_ID__c + '\n'
                + contacts[1].Email + ',' + contacts[1].AACR_ID__c + '\n'
                + contacts[2].Email + ',' + contacts[2].AACR_ID__c + '\n'
                + 'idontexist@yopmail.com,';

        System.debug('fileData = ' + fileData);

        List<String> fields = new List<String>();

        fields.add('Email');
        fields.add('Id');


        Test.startTest();
        System.debug('FileData: ' + fileData);
        MassRegistrationController.processData(fileData, fields, 'Id', 'Email', eventId);
        Test.stopTest();

    }

    @IsTest
    static void test_GetAACRIds(){

        List<Contact> contacts = [SELECT AACR_ID__c FROM Contact];
        List<String> Ids = new List<String>();

        for(Contact c: contacts){
            Ids.add(c.AACR_ID__c);
        }

        Test.startTest();
        List<Contact> contacts2 = MassRegistrationController.queryContactsByAACRID(Ids);
        Test.stopTest();

        System.assertEquals(4, contacts2.size());

    }

    @isTest
    static void test_CreateAttendees(){

        String eventId = [SELECT Id FROM EventApi__Event__c WHERE Name LIKE 'Test Event' LIMIT 1].Id;
        List<Contact> contacts = [SELECT Id FROM Contact];

        Test.startTest();
        MassRegistrationController.createAttendees(contacts,eventId);
        Test.stopTest();

        List<EventApi__Attendee__c> attendees = [SELECT Id FROM EventApi__Attendee__c WHERE EventApi__Event__c =: eventId];

        System.assertEquals(4,attendees.size());
    }
}