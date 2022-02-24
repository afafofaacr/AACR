@IsTest
private class BrEventsListItemControllerTest {

    @testSetup static void setup() {
        Profile stdUserProfile = [SELECT Id FROM Profile WHERE Name = 'Standard User'];
        User user = new User(Alias = 'testusr1', Email='testusr100@testorg.com',
                EmailEncodingKey='UTF-8', LastName='Testing1', LanguageLocaleKey='en_US',
                LocaleSidKey='en_US', ProfileId = stdUserProfile.Id,
                TimeZoneSidKey = UserInfo.getTimeZone().getID(), UserName='testusr100@testorg.com');

        insert user;
        System.assertNotEquals(null, user.Id, 'user is not created');
        BrEventsHelper.insertUser(user.Id);

        User testUser = new User(Alias = 'testusr', Email='testusr200@testorg.com',
                EmailEncodingKey='UTF-8', LastName='Testing2', LanguageLocaleKey='en_US',
                LocaleSidKey='en_US', ProfileId = stdUserProfile.Id,
                TimeZoneSidKey=UserInfo.getTimeZone().getID(), UserName='testusr200@testorg.com');

        insert testUser;
        System.assertNotEquals(null, testUser.Id, 'user is not created');
        BrEventsHelper.insertUser(testUser.Id);

        List<OrgWideEmailAddress> owas = [SELECT Id FROM OrgWideEmailAddress LIMIT 1];
        System.assertEquals(owas.size(), 1);

        insert new BrEvents_Settings__c(Name='org wide email id', Label__c = 'org wide email id', Value__c = owas[0].Id);
    }

    @isTest
    public static void testRsvpEvent() {
        Id recordId;
        String rsvpType = 'Yes';
        Integer attendeesLimit = 0; //attendeesLimit is zero, means no limit

        BR_Event__c item = new BR_Event__c(
                Name = 'Test event1',
                Start_Date__c = datetime.newInstance(2015, 10, 15, 12, 30, 0),
                End_Date__c = datetime.newInstance(2015, 10, 15, 17, 30, 0),
                Location__Latitude__s = 51.5156950,
                Location__Longitude__s = -0.0893931,
                Venue_Address__c = 'Test ave 12/2'
        );
        insert item;

        User user = [SELECT Id FROM User WHERE Username = 'testusr100@testorg.com'];

        System.runAs(user){

            //reecord id is null or empty
            String result = BrEventsListItemController.rsvpEvent(recordId, rsvpType, attendeesLimit);
            System.assertEquals('error', result, 'item id is empty');

            //rsvpType is empty
            recordId = item.Id;
            rsvpType = '';
            result = BrEventsListItemController.rsvpEvent(recordId, rsvpType, attendeesLimit);
            System.assertEquals('error', result, 'rsvpType is empty');

            rsvpType = 'No';
            result = BrEventsListItemController.rsvpEvent(recordId, rsvpType, attendeesLimit);
            System.assertEquals('0', result, 'wrong number of attendees');

            rsvpType = 'Yes';
            result = BrEventsListItemController.rsvpEvent(recordId, rsvpType, attendeesLimit);
            System.assertEquals('1', result, 'wrong number of attendees');
        }

        User testUser = [SELECT Id FROM User WHERE Username = 'testusr200@testorg.com'];

        System.runAs(testUser){
            //attendeesLimit more than current number of attendees, current attendees number is 1
            attendeesLimit = 1;
            recordId = item.Id;
            rsvpType = 'Yes';
            String result = BrEventsListItemController.rsvpEvent(recordId, rsvpType, attendeesLimit);
            System.assertEquals('limit_exceded', result, 'limit of attendees is exceeded');
        }
    }


    @isTest
    public static void testGoTOVirtualMeeting(){
        Id virtualRecordTypeId = Schema.SObjectType.Venue__c.getRecordTypeInfosByName().get('Virtual').getRecordTypeId();
        Venue__c virtualVenue = new Venue__c(Name='Test Venue', RecordTypeId=virtualRecordTypeId, Base_URL__c = 'https://www.google.com', Integration_Controller__c = 'CallableTest');
        insert virtualVenue;

        BR_Event__c item = new BR_Event__c(
                Name = 'Test event1',
                Start_Date__c = datetime.newInstance(2015, 10, 15, 12, 30, 0),
                End_Date__c = datetime.newInstance(2015, 10, 15, 17, 30, 0),
                Location__Latitude__s = 51.5156950,
                Location__Longitude__s = -0.0893931,
                Venue_Address__c = 'Test ave 12/2',
                Virtual_Venue__c = virtualVenue.Id
        );
        insert item;

        Test.startTest();

        String url = BrEventsListItemController.goToVirtualMeeting(item.Id);
        System.assertEquals(url, null);

        Test.stopTest();

    }

}