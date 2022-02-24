@IsTest
private class BrEventsHelperTest {

    @TestSetup
    static void setup() {
        Account acc = TestDataFactory.buildAccount('Test Account');
        insert acc;

        Contact con = TestDataFactory.buildContact(acc.Id);
        insert con;

        User u = TestDataFactory.buildUser(con.Id);
        insert u;

        List<OrgWideEmailAddress> owas = [SELECT Id FROM OrgWideEmailAddress LIMIT 1];
        System.assertEquals(owas.size(), 1);

        insert new BrEvents_Settings__c(Name='org wide email id', Label__c = 'org wide email id', Value__c = owas[0].Id);

        String orgWideEmailId = BrEventsHelper.getConfigValue('org wide email id');
        SYstem.assertEquals(orgWideEmailId, owas[0].Id);

        List<BR_Participation__c> participations = new List<BR_Participation__c>();
        List<BR_Event__c> events = BrEventTestUtils.testCreateEvents();
        for(BR_Event__c evt : events){
            participations.add(new BR_Participation__c(User__c=u.Id, Contact__c=con.Id, BR_Event__c=evt.Id, Participate__c='Yes'));
        }
        insert participations;
    }

    @isTest
    public static void testPerformAccessCheck() {

        Profile stdUserProfile = [SELECT Id FROM Profile WHERE Name = 'Standard User'];
        User user = new User(Alias = 'testusr1', Email='testusr100@testorg.com',
                EmailEncodingKey='UTF-8', LastName='Testing1', LanguageLocaleKey='en_US',
                LocaleSidKey='en_US', ProfileId = stdUserProfile.Id,
                TimeZoneSidKey = UserInfo.getTimeZone().getID(), UserName='testusr100@testorg.com');

        insert user;

        System.runAs(user){

            System.assertEquals(false, BrEventsHelper.performAccessCheck('read', 'BR_Event__c', null), 'insufficient user permisssions');
            System.assertEquals(false, BrEventsHelper.performAccessCheck('read', 'BR_Participation__c', null), 'insufficient user permisssions');
            System.assertEquals(false, BrEventsHelper.performAccessCheck('edit', 'BR_Participation__c', null), 'insufficient user permisssions');
            System.assertEquals(false, BrEventsHelper.performAccessCheck('create', 'BR_Participation__c', null), 'insufficient user permisssions');
            List<String> participationFieldsToRead = new List<String>();
            participationFieldsToRead.add('Participate__c');
            System.assertEquals(false, BrEventsHelper.performAccessCheck('read', 'BR_Participation__c', participationFieldsToRead), 'insufficient user permisssions');
            List<String> participationFieldsToUpdate = new List<String>();
            participationFieldsToUpdate.add('Participate__c');
            System.assertEquals(false, BrEventsHelper.performAccessCheck('edit', 'BR_Participation__c', participationFieldsToUpdate), 'insufficient user permisssions');
            List<String> participationFieldsToCreate = new List<String>();
            participationFieldsToCreate.add('BR_Event__c');
            System.assertEquals(false, BrEventsHelper.performAccessCheck('create', 'BR_Participation__c', participationFieldsToCreate), 'insufficient user permisssions');
        }
    }

    @isTest
    public static void test_insertUser(){
        Profile stdUserProfile = [SELECT Id FROM Profile WHERE Name = 'Standard User'];
        User user = new User(Alias = 'testusr1', Email='testusr100@testorg.com',
                EmailEncodingKey='UTF-8', LastName='Testing1', LanguageLocaleKey='en_US',
                LocaleSidKey='en_US', ProfileId = stdUserProfile.Id,
                TimeZoneSidKey = UserInfo.getTimeZone().getID(), UserName='testusr100@testorg.com');

        insert user;

        Test.startTest();
        BrEventsHelper.insertUser(user.Id);
        Test.stopTest();
    }


    @isTest
    public static void test_createLeadParticipation(){
        BR_Event__c event = [SELECT Id FROM BR_Event__c LIMIT 1];
        Account acc = new Account(Name = 'Test Account');
        insert acc;

        insert new BrEvents_Settings__c(Name='guest_account_id', Label__c = 'Account Id', Value__c = acc.Id);

        String jsonData = '[ ' +
                '{"FirstName":"Tim"},' +
                '{"LastName":"Larson"},' +
                '{"Email":"test@gmail.com"},' +
                '{"Phone":"12345678"},' +
                '{"Company":"Test Company"},' +
                '{"Title":"Test"}]';

        Test.startTest();

        BrEventsHelper.createLeadParticipation(jsonData, event.Id);

        Test.stopTest();
    }

    @isTest
    public static void test_createContactParticipation(){
        BR_Event__c event = [SELECT Id FROM BR_Event__c LIMIT 1];
        Account acc = new Account(Name = 'Test Account');
        insert acc;

        insert new BrEvents_Settings__c(Name='guest_account_id', Label__c = 'Account Id', Value__c = acc.Id);


        String jsonData = '[ ' +
                '{"FirstName":"Tim"},' +
                '{"LastName":"Larson"},' +
                '{"Email":"test@gmail.com"},' +
                '{"Phone":"12345678"},' +
                '{"Title":"Test"}]';

        Test.startTest();

        BrEventsHelper.createContactParticipation(jsonData, event.Id);

        Test.stopTest();
    }

    @isTest
    public static void test_getAttachmentsforImages(){
        Set<Id> items_ids = new Set<Id>();
        List<BR_Event__c> events = [SELECT Id FROM BR_Event__c];
        for(BR_Event__c evt : events){
            items_ids.add(evt.Id);
        }

        Test.startTest();
        Map<Id, Map<String,String>> itemsAttachments = BrEventsHelper.getAttachmentsForItems(items_ids);

        System.assertNotEquals(null, itemsAttachments);
        Test.stopTest();

    }


    @isTest
    public static void test_getImageSource(){
        Test.startTest();
        String files = BrEventsHelper.getImageSource();

        System.assertEquals(files, 'files');

        Test.stopTest();
    }

    @isTest
    public static void test_compileWhereStatement(){
        Integer year = System.today().year() + 1;

        Map<String, String> filterData = new Map<String, String>();
        filterData.put('search', 'search');
        filterData.put('tab', 'Attending');
        filterData.put('date', String.valueOf(year) + '-10-15');

        Test.startTest();

        String query = BrEventsHelper.compileWhereStatement(filterData);
        System.assertNotEquals(null, query);

        Test.stopTest();
    }

    @isTest
    public static void testGetEventWithPhotoUrl() {
        Profile stdUserProfile = [SELECT Id FROM Profile WHERE Name = 'Standard User'];
        User testUser1 = new User(Alias = 'testusr1', Email='testusr100@testorg.com',
                EmailEncodingKey='UTF-8', LastName='Testing1', LanguageLocaleKey='en_US',
                LocaleSidKey='en_US', ProfileId = stdUserProfile.Id,
                TimeZoneSidKey = UserInfo.getTimeZone().getID(), UserName='testusr100@testorg.com');

        insert testUser1;
        User testUser2 = new User(Alias = 'testusr2', Email='testusr200@testorg.com',
                EmailEncodingKey='UTF-8', LastName='Testing2', LanguageLocaleKey='en_US',
                LocaleSidKey='en_US', ProfileId = stdUserProfile.Id,
                TimeZoneSidKey = UserInfo.getTimeZone().getID(), UserName='testusr200@testorg.com');

        insert testUser2;

        List<BR_Event__c> events = new List<BR_Event__c>();

        for (Integer i=0;i<4;i++) {
            if (i < 2) {
                events.add(new BR_Event__c(
                        Name = 'Test event' + i,
                        OwnerId = testUser1.Id,
                        Start_Date__c = datetime.newInstance(2018, 10, 15 + i, 12, 30, 0),
                        End_Date__c = datetime.newInstance(2018, 10, 15+i, 17, 30, 0)
                ));
            } else {
                events.add(new BR_Event__c(
                        Name = 'Test event' + i,
                        OwnerId = testUser2.Id,
                        Start_Date__c = datetime.newInstance(2018, 10, 15 + i, 12, 30, 0),
                        End_Date__c = datetime.newInstance(2018, 10, 15+i, 17, 30, 0)

                ));
            }
        }

        insert events;

        Test.startTest();

        Map<BR_Event__c, String> eventWithUserPhotoUrl =
        BrEventsHelper.getEventWithPhotoUrl(new Set<String> {testUser1.Id, testUser2.Id}, events);

        Test.stopTest();

        // Small photo url is not writable and all urls equals by default
        System.assertEquals(true, eventWithUserPhotoUrl.get(events[0]) == eventWithUserPhotoUrl.get(events[1]));
        System.assertEquals(true, eventWithUserPhotoUrl.get(events[2]) == eventWithUserPhotoUrl.get(events[3]));
        System.assertEquals(true, eventWithUserPhotoUrl.get(events[0]) == eventWithUserPhotoUrl.get(events[2]));
    }

    @isTest
    public static void testGetStartDateFormatted() {
        Test.startTest();

        System.assertEquals('dd.MM.yyyy H:mm', BrEventsHelper.getDateTimeFormat('be_BY'), 'wrong date format');

        Test.stopTest();
    }

    @isTest
    public static void testCreateAttachmentBody() {
        String eventId = [SELECT Id FROM BR_Event__c LIMIT 1].Id;

        Test.startTest();

        Blob icsFile = BrEventsHelper.createAttachmentBody(eventId, 'Test event', '20192204T170500Z', '20192304T170500Z', 'Test desc', 'USA, California',
        'Salesforce', 'test@gmail.com', 0);

        Test.stopTest();

        String expectedFileValue =
                'BEGIN:VCALENDAR\n' +
                'VERSION:2.0\n' +
                'METHOD:REQUEST\n' +
                'BEGIN:VEVENT\n' +
                'ORGANIZER;CN=Salesforce:mailto:test@gmail.com\n' +
                'ATTENDEE;CN=Salesforce:mailto:test@gmail.com\n' +
                'DTEND:20192304T170500Z\n' +
                'DTSTART:20192204T170500Z\n' +
                'LOCATION:USA, California\n' +
                'SUMMARY:Test event\n' +
                'DESCRIPTION: Test desc\n' +
                'UID:' + eventId + '\n' +
                'SEQUENCE:0\n' +
                'LANGUAGE=en-us:Event\n' +
                'END:VEVENT\n' +
                'END:VCALENDAR';

        System.assertEquals(expectedFileValue, icsFile.toString(), 'wrong file value');
    }

    @isTest
    public static void testGetParticipationsById() {
        Set<Id> participationIds = (new Map<Id, BR_Participation__c>([SELECT Id FROM BR_Participation__c])).keySet();

        Test.startTest();

        List<BR_Participation__c> retrievedParticipations = BrEventsHelper.getParticipationsById(participationIds);

        Test.stopTest();

        System.assertEquals(6, retrievedParticipations.size(), 'wrong number of participations');

    }

    @isTest
    public static void testGetPaticipationsByEventsIds() {
        Set<Id> eventIds = (new Map<Id, BR_Event__c>([SELECT Id FROM BR_Event__c])).keySet();

        Test.startTest();

        List<BR_Participation__c> retrievedParticipations = BrEventsHelper.getPaticipationsByEventsIds(eventIds);

        Test.stopTest();

        System.assertEquals(6, retrievedParticipations.size(), 'wrong number of participations');

    }

    @isTest
    public static void testSendEmails() {
        List<BR_Participation__c> participations = [
            SELECT Id, User__c, User__r.Name, Lead__c, Contact__c, Contact__r.Name,
                BR_Event__r.Timezone__c,  BR_Event__r.CreatedBy.TimeZoneSidKey,
                BR_Event__r.Name, BR_Event__r.Start_Date__c, BR_Event__r.Venue_Address__c,
                BR_Event__r.End_Date__c, BR_Event__r.Description__c, BR_Event__r.Id, BR_Event__r.Registration_Confirmation_Message__c
            FROM BR_Participation__c
            WHERE  Participate__c = 'Yes'
        ];

        insert new BrEvents_Settings__c(Name='send email', Label__c = 'Send Email', Value__c = 'true');

        Test.startTest();

        BrEventsHelper.sendEmails(participations, 'Welcome event');

        Test.stopTest();

        System.assertEquals(6, participations.size(), 'wrong number of participations');
    }

    @isTest
    public static void testGetDiffMinutesBetweenTimezones() {
        Test.startTest();

        Integer diffMinutes = BrEventsHelper.getDiffMinutesBetweenTimezones('(GMT+01:00) British Summer Time', 'Europe/Minsk');

        Test.stopTest();

        System.assertEquals(-120, diffMinutes, 'wrong minutes');
    }
}