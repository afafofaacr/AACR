/**
 * Created by afaf.awad on 1/27/2021.
 */

@IsTest
private class BrEventsMassRegistrationControllerTest {

    @testSetup
    static void setup() {
        Account acc = LiveTestDataFactory.buildAccount('Test Account');
        insert acc;

        List<Contact> contactUsers = new List<Contact>();
        for (Integer i = 0; i < 50; i++) {
            Contact testContact = LiveTestDataFactory.buildContact(acc.Id);
            testContact.LastName = 'Test Contact' + i;
            testContact.Email = 'testEmail' + i + '@yopmail.com';
            contactUsers.add(testContact);
        }
        insert contactUsers;

        List<Contact> contactNoUsers = new List<Contact>();
        for (Integer i = 0; i < 5; i++) {
            Contact testContact = LiveTestDataFactory.buildContact(acc.Id);
            testContact.LastName = 'Test NonUser' + i;
            testContact.Email = 'testNonUser' + i + '@yopmail.com';
            contactNoUsers.add(testContact);
        }
        insert contactNoUsers;

        Contact dupContact = LiveTestDataFactory.buildContact(acc.Id);
        dupContact.LastName = 'Test Contact0';
        dupContact.Email = 'testEmail0@yopmail.com';
        insert dupContact;

        List<User> users = new List<User>();
        Profile profileRecord = [SELECT Id FROM Profile WHERE Name =: 'Fonteva Customer Community Login User' LIMIT 1];

        for (Integer i = 0; i < contactUsers.size(); i++) {
        User userRecord = new User(alias = 'test',
                ProfileId = profileRecord.Id,
                email = contactUsers[i].Email,
                emailencodingkey = 'UTF-8',
                lastname = contactUsers[i].LastName,
                CommunityNickname = contactUsers[i].Id,
                languagelocalekey = 'en_US',
                localesidkey = 'en_US',
                timezonesidkey = 'America/Los_Angeles',
                username = System.now().millisecond() + contactUsers[i].Email,
                ContactId = contactUsers[i].Id);
            users.add(userRecord);
        }
        insert users;


        System.debug('Users Inserted = ' + users.size());

        User dupUser = LiveTestDataFactory.buildStandardUser(dupContact.Id);
        dupUser.email = dupContact.Email;
        dupUser.lastname = dupContact.LastName;
        dupUser.username = System.now().millisecond() + dupContact.Email;
        dupUser.ProfileId = profileRecord.Id;
        dupUser.ContactId = dupContact.Id;
        insert dupUser;

        System.debug('OriginalUser = ' + users[0]);
        System.debug('DupUser = ' + dupUser);

        List<OrgWideEmailAddress> owas = [SELECT Id FROM OrgWideEmailAddress LIMIT 1];

        insert new BrEvents_Settings__c(Name = 'org wide email id', Label__c = 'org wide email id', Value__c = owas[0].Id);

        BR_Events_Zone__c zone = LiveTestDataFactory.buildZone('Test Zone', true);
        insert zone;

        Venue__c ven = LiveTestDataFactory.buildVenue('Test Venue');
        ven.Virtual_Instructions__c = 'Testing Instructions.';
        insert ven;

        BR_Event__c event = LiveTestDataFactory.buildEvent('Test Event', false, false);
        event.Draft_Program__c = 'Test Draft Program';
        event.Venue__c = ven.Id;
        event.Publicly_available__c = TRUE;
        event.Draft__c = FALSE;
        event.Registration_Confirmation_Message__c = 'You Registered!';
        event.Event_Stage__c = 'In Person';
        event.Start_Date__c = Date.today();
        insert event;

        User partUser1 = [SELECT Id FROM User WHERE Email =: contactUsers[1].Email];
        User partUser2 = [SELECT Id FROM User WHERE Email =: contactUsers[2].Email];

        List<BR_Participation__c> parts = new List<BR_Participation__c>();
        parts.add(new BR_Participation__c(Contact__c = contactUsers[1].Id, BR_Event__c = event.Id, Participate__c = 'Yes', User__c = partUser1.Id));
        parts.add(new BR_Participation__c(Contact__c = contactUsers[2].Id, BR_Event__c = event.Id, Participate__c = 'Incomplete', User__c = partUser2.Id));
        insert parts;

        System.debug('Participants = ' + parts);

        OrderApi__Source_Code__c sourceCode = new OrderApi__Source_Code__c(Name='TEST', OrderApi__Active__c=TRUE);
        insert sourceCode;
    }

    @IsTest
    static void test_ValidateData() {
        List<Contact> contacts = [Select AACR_ID__c, Email FROM Contact];
        String eventId = [SELECT Id FROM BR_Event__c WHERE Name = 'Test Event'].Id;

        String fileData = 'Email,Id';
        for(Contact contact: contacts) {
            fileData += '\n' + contact.Email + ',' + contact.AACR_ID__c ;
        }

        String fileDataNoEmail = 'Email,Id' + '\n'
                + contacts[0].Email + ',' + contacts[0].AACR_ID__c + '\n'
                + ' ,' + contacts[1].AACR_ID__c;

        List<String> fields = new List<String>();
        fields.add('Email');
        fields.add('Id');

        Test.startTest();
        Boolean noEmail = BrEventsMassRegistrationController.validateData(fileDataNoEmail, fields, 'Email');
        Boolean withEmail = BrEventsMassRegistrationController.validateData(fileData, fields,'Email');
        Test.stopTest();
        System.assertEquals(false, noEmail);
        System.assertEquals(true, withEmail);
    }

    @isTest
    static void test_processData_Comp() {
        List<Contact> contacts = [Select AACR_ID__c, Email FROM Contact];
        String eventId = [SELECT Id FROM BR_Event__c WHERE Name = 'Test Event'].Id;

        String fileData = 'Email,Id,Comp';
        for(Contact contact: contacts) {
            fileData += '\n' + contact.Email + ',' + contact.AACR_ID__c + ', TEST' ;
        }
        fileData += '\n' + contacts[0].Email + ',123456, BADTEST' ; //trigger InvalidEmialCode Object
        fileData += '\n' + 'idontexist@yopmail.com,';

        System.debug('fileData = ' + fileData);

        List<String> fields = new List<String>();
        fields.add('Email');
        fields.add('Id');
        fields.add('Comp');

        Test.startTest();
        BrEventsMassRegistrationController.processData(fileData, fields, 'Email', eventId);
        Test.stopTest();

    }

    @isTest
    static void test_processData_NoComp() {
        List<Contact> contacts = [Select AACR_ID__c, Email FROM Contact];
        String eventId = [SELECT Id FROM BR_Event__c WHERE Name = 'Test Event'].Id;

        String fileData = 'Email,Id';
        for(Contact contact: contacts) {
            fileData += '\n' + contact.Email + ',' + contact.AACR_ID__c ;
        }
        fileData += '\n' + 'idontexist@yopmail.com,';

        System.debug('fileData = ' + fileData);

        List<String> fields = new List<String>();
        fields.add('Email');
        fields.add('Id');

        Test.startTest();
        BrEventsMassRegistrationController.processData(fileData, fields, 'Email', eventId);
        Test.stopTest();

    }

    @IsTest
    static void test_GetAACRIds() {

        List<Contact> contacts = [SELECT AACR_ID__c FROM Contact];
        List<String> Ids = new List<String>();

        for (Contact c : contacts) {
            Ids.add(c.AACR_ID__c);
        }

        Test.startTest();
        List<Contact> contacts2 = BrEventsMassRegistrationController.queryContactsByAACRID(Ids);
        Test.stopTest();

        System.assertEquals(56, contacts2.size());

    }

    @IsTest
    static void test_CreateParticipiants(){

        List<Contact> contacts = [Select Id, AACR_ID__c, Email FROM Contact];
        String eventId = [SELECT Id FROM BR_Event__c WHERE Name = 'Test Event'].Id;

        System.debug('# of Users = ' + [Select Id, ContactId, Contact.FirstName, Contact.LastName, Contact.Email, Contact.AACR_ID__c FROM User WHERE ContactId IN: contacts].size());

        String compMapString = '[{"key":"123456","value":""}' ;
        for(Contact con : contacts) {
          compMapString += ',{"key":"' + con.AACR_ID__c + '","value":"TEST"}';
        }
          compMapString += ']';

        System.debug('compMapString Test: ' + compMapString);

        Test.startTest();
        Id jobId = BrEventsMassRegistrationController.createParticipants(contacts, eventId, false, compMapString );
        AsyncApexJob BatchJobInfo = BrEventsMassRegistrationController.getMassReg_BatchJobStatus(jobId);
        Test.stopTest();

        List<BR_Participation__c> participations = [SELECT Id FROM BR_Participation__c WHERE BR_Event__c =: eventId];

        System.assertEquals(51, participations.size());
        System.assertEquals(JobId, BatchJobInfo.Id);

    }

    @IsTest
    static void test_sendErrorsEmail(){
        List<User> users = [Select Id, ContactId, Contact.FirstName, Contact.LastName, Contact.Email, Contact.AACR_ID__c FROM User LIMIT 5];

        Test.startTest();
        BrEventsMassRegistrationController.sendRecordErrors_Contacts(users, users.size(), '7070200000BHFrm');
        Test.stopTest();

    }
}