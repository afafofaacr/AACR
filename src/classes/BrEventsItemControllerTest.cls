@IsTest
private class BrEventsItemControllerTest {

    @testSetup static void setup() {
        Account acc = TestDataFactory.buildAccount('Test Account');
        insert acc;

        Contact con = TestDataFactory.buildContact(acc.Id);
        insert con;

        Venue__c pVenue = new Venue__c(Street_1__c='123 Main St', City__c='San Francisco', State__c='California', Country__c='UNited States', Name='American Association of Cancer Research');
        insert pVenue;

        BR_Event__c item = new BR_Event__c(
                Name = 'Test event0',
                Start_Date__c = datetime.newInstance(2016, 10, 15, 12, 30, 0),
                End_Date__c = datetime.newInstance(2016, 10, 15, 17, 30, 0),
                Location__Latitude__s = 51.5156950,
                Location__Longitude__s = -0.0893931,
                Venue_Address__c = 'Test ave 12/20',
                Venue__c= pVenue.Id,
                Registration_Confirmation_Message__c = 'TEST REG MESSAGE'
        );
        insert item;

        List<OrgWideEmailAddress> owas = [SELECT Id FROM OrgWideEmailAddress LIMIT 1];
        System.assertEquals(owas.size(), 1);

        insert new BrEvents_Settings__c(Name='org wide email id', Label__c = 'org wide email id', Value__c = owas[0].Id);

        insert new BR_Participation__c(BR_Event__c = item.Id, Contact__c=con.Id, Participate__c = 'Yes', User__c = UserInfo.getUserId());

        Profile portalProfile = [SELECT Id FROM Profile WHERE Name = 'Fonteva Customer Community Login User'];
        User user = new User(Alias = 'testusr1', Email='testusr100@testorg.com',
                EmailEncodingKey='UTF-8', LastName='Testing1', LanguageLocaleKey='en_US',
                LocaleSidKey='en_US', ProfileId = portalProfile.Id, ContactId=con.Id,
                TimeZoneSidKey = UserInfo.getTimeZone().getID(), UserName='testusr100@testorg.com');

        insert user;
        System.assertNotEquals(null, user.Id, 'user is not created');

        insert new BR_Participation__c(BR_Event__c = item.Id, Contact__c=con.Id, Participate__c = 'Yes', User__c = user.Id);

        Profile stdUserProfile = [SELECT Id FROM Profile WHERE Name = 'Standard User'];
        User testUser = new User(Alias = 'testusr', Email='testusr200@testorg.com',
                EmailEncodingKey='UTF-8', LastName='Testing2', LanguageLocaleKey='en_US',
                LocaleSidKey='en_US', ProfileId = stdUserProfile.Id,
                TimeZoneSidKey=UserInfo.getTimeZone().getID(), UserName='testusr200@testorg.com');

        insert testUser;
        System.assertNotEquals(null, testUser.Id, 'user is not created');
        BrEventsHelper.insertUser(testUser.Id);


    }

    @isTest
    public static void testGetEvent() {
        User user = [SELECT Id FROM User WHERE Username = 'testusr100@testorg.com'];

        System.runAs(user){
            Id recordId;
            BrEventsItemWrapper result = BrEventsItemController.getEvent(recordId);
            System.assertEquals(null, result, 'item id is blank');

            String itemName = 'Test event0';
            BR_Event__c item = [SELECT Id FROM BR_Event__c WHERE Name = :itemName];
            recordId = item.Id;
            result = BrEventsItemController.getEvent(recordId);
            System.assertEquals('Test event0', result.item.Name, 'cannot get event item');
//
//            Venue__c vVenue = new Venue__c(Name='Zoom', Integration_Controller__c='V_ZoomIntegration', Base_URL__c='https://aacr.zoom.us/j/');
//            insert vVenue;
//            item.Venue__c=null;
//            item.Virtual_Venue__c = vVenue.Id;
//            update item;
//
//            result = BrEventsItemController.getEvent(item.Id);
//            System.assertEquals('Test event0', result.item.Name, 'cannot get event item');

        }
    }

    @isTest
    public static void testGetAttendeesCount() {
        User user = [SELECT Id FROM User WHERE Username = 'testusr100@testorg.com'];

        System.runAs(user){
            String itemName = 'Test event0';
            BR_Event__c item = [SELECT Id FROM BR_Event__c WHERE Name = :itemName];
            Integer result = BrEventsItemController.getAttendeesCount(item.Id);
            System.assertEquals(2, result, 'wrong number of attendees');
        }
    }

    @isTest
    public static void testGetParticipations() {
        User user = [SELECT Id FROM User WHERE Username = 'testusr100@testorg.com'];

        System.runAs(user){
            Id recordId;
            List<BR_Participation__c> result = BrEventsItemController.getParticipations(recordId);
            System.assertEquals(null, result, 'item id is blank');

            String itemName = 'Test event0';
            BR_Event__c item = [SELECT Id FROM BR_Event__c WHERE Name = :itemName];

            recordId = item.Id;
            result = BrEventsItemController.getParticipations(recordId);
            System.assertEquals(2, result.size(), 'wrong number of participations');

            BrEventsItemWrapper eItem = BrEventsItemController.getEvent(item.Id);
            System.assertEquals('Test event0', eItem.item.Name, 'cannot get event item');
        }
    }

    @IsTest
    public static void test_getLetterToDownload(){
        BR_Event__c event = [SELECT Id, Draft__c FROM BR_Event__c WHERE Name = 'Test event0'];

        User user = [SELECT Id FROM User WHERE Username = 'testusr100@testorg.com'];

        System.runAs(user){
            String resp = BrEventsItemController.getLetterToDownload(event.Id);
            System.assertNotEquals(null, resp);
        }
    }

    @isTest
    public static void testRsvpEvent() {

        Id recordId;
        String rsvpType = 'Yes';
        Integer attendeesLimit = 0; //attendeesLimit is zero, means no limit

        BR_Event__c item = new BR_Event__c(
                Name = 'Test event1',
                Start_Date__c = datetime.newInstance(2015, 10, 15, 12, 30, 0),
                End_Date__c = datetime.newInstance(2016, 10, 15, 17, 30, 0),
                Location__Latitude__s = 51.5156950,
                Location__Longitude__s = -0.0893931,
                Venue_Address__c = 'Test ave 12/2'
        );
        insert item;

        User user = [SELECT Id FROM User WHERE Username = 'testusr100@testorg.com'];

        System.runAs(user){
            //reecord id is null or empty
            String result = BrEventsItemController.rsvpEvent(recordId, rsvpType, attendeesLimit);
            System.assertEquals('error', result, 'item id is empty');

            //rsvpType is empty
            recordId = item.Id;
            rsvpType = '';
            result = BrEventsItemController.rsvpEvent(recordId, rsvpType, attendeesLimit);
            System.assertEquals('error', result, 'rsvpType is empty');


            rsvpType = 'No';
            result = BrEventsItemController.rsvpEvent(recordId, rsvpType, attendeesLimit);
            System.assertEquals('0', result, 'wrong number of attendees');

//            rsvpType = 'Yes';
//            result = BrEventsItemController.rsvpEvent(recordId, rsvpType, attendeesLimit);
//            System.assertEquals('1', result, 'wrong number of attendees');
        }

//        User testUser = [SELECT Id FROM User WHERE Username = 'testusr200@testorg.com'];
//
//        System.runAs(testUser){
//            //attendeesLimit more than current number of attendees, current attendees number is 1
//            recordId = item.Id;
//            attendeesLimit = 1;
//            rsvpType = 'Yes';
//            String result = BrEventsItemController.rsvpEvent(recordId, rsvpType, attendeesLimit);
//            System.assertEquals('limit_exceded', result, 'limit of attendees is exceeded');
//        }
    }

    @isTest
    public static void testGetEventMainImage() {
        User user = [SELECT Id FROM User WHERE Username = 'testusr100@testorg.com'];

        System.runAs(user){
            Id recordId;
            String mainImageName = '';

            //reecord id is null or empty
            String result = BrEventsItemController.getEventMainImage(recordId, mainImageName);
            System.assertEquals(null, result, 'item id is empty');

            String itemName = 'Test event0';
            BR_Event__c item = [SELECT Id FROM BR_Event__c WHERE Name = :itemName];
            recordId = item.Id;
            result = BrEventsItemController.getEventMainImage(recordId, mainImageName);
            System.assertEquals(null, result, 'mainImageName is empty');

            mainImageName = 'Attachment0';
            result = BrEventsItemController.getEventMainImage(recordId, mainImageName);
            System.assertEquals(null, result, 'no attachment for this filename');
        }
    }

    @IsTest
    public static void testPublishEvent() {
        User user = [SELECT Id FROM User WHERE Username = 'testusr200@testorg.com'];

        System.runAs(user) {
            Test.startTest();

            String itemName = 'Test event0';
            BR_Event__c event = [SELECT Id, Draft__c FROM BR_Event__c WHERE Name = :itemName];

            BrEventsItemController.publishEvent(event.Id);

            event = [SELECT Id, Draft__c FROM BR_Event__c WHERE Name = :itemName];

            System.assertEquals(false, event.Draft__c);

            Test.stopTest();
        }
    }

    @IsTest
    public static void test_goToVirtualMeeting(){
        BR_Event__c event = [SELECT Id, Draft__c FROM BR_Event__c WHERE Name = 'Test event0'];
        Venue__c ven = new Venue__c(Integration_Controller__c='V_PathLMSIntegration', Base_URL__c='https://www.pathlms.com/aacr/courses/', Name='Virtual Venue Test');
        insert ven;

        Virtual_Event_Details__c ved = new Virtual_Event_Details__c(Event__c=event.Id, External_Event_Id__c='1234');
        insert ved;

        event.Virtual_Venue__c=ven.Id;
        update event;

        User user = [SELECT Id FROM User WHERE Username = 'testusr100@testorg.com'];

        System.runAs(user) {
            Test.startTest();

            String location = BrEventsItemController.goToVirtualMeeting(event.Id);
            System.assertNotEquals(null, location);

            Test.stopTest();
        }

    }

    @IsTest
    public static void testDraftEvent() {
        User user = [SELECT Id FROM User WHERE Username = 'testusr200@testorg.com'];

        System.runAs(user) {
            Test.startTest();

            String itemName = 'Test event0';
            BR_Event__c event = [SELECT Id, Draft__c FROM BR_Event__c WHERE Name = :itemName];

            BrEventsItemController.publishEvent(event.Id);

            event = [SELECT Id, Draft__c FROM BR_Event__c WHERE Name = :itemName];

            System.assertEquals(false, event.Draft__c);

            BrEventsItemController.draftEvent(event.Id);

            event = [SELECT Id, Draft__c FROM BR_Event__c WHERE Name = :itemName];

            System.assertEquals(true, event.Draft__c);

            Test.stopTest();
        }
    }
}