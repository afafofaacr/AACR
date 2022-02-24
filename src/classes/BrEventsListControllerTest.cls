@IsTest
private class BrEventsListControllerTest {

    @testSetup static void setup() {
        Profile stdUserProfile = [SELECT Id FROM Profile WHERE Name = 'Standard User'];
        User user = new User(Alias = 'testusr1', Email='testusr100@testorg.com',
                EmailEncodingKey='UTF-8', LastName='Testing1', LanguageLocaleKey='en_US',
                LocaleSidKey='en_US', ProfileId = stdUserProfile.Id,
                TimeZoneSidKey = UserInfo.getTimeZone().getID(), UserName='testusr100@testorg.com');

        insert user;
        User userOwner = new User(Alias = 'testusr2', Email='owner100@testorg.com',
                EmailEncodingKey='UTF-8', LastName='TestingOwner', LanguageLocaleKey='en_US',
                LocaleSidKey='en_US', ProfileId = stdUserProfile.Id,
                TimeZoneSidKey = UserInfo.getTimeZone().getID(), UserName='owner100@testorg.com');

        insert userOwner;

        List<OrgWideEmailAddress> owas = [SELECT Id FROM OrgWideEmailAddress LIMIT 1];
        System.assertEquals(owas.size(), 1);

        insert new BrEvents_Settings__c(Name='org wide email id', Label__c = 'org wide email id', Value__c = owas[0].Id);

        System.assertNotEquals(null, user.Id, 'user is not created');
        System.assertNotEquals(null, userOwner.Id, 'user is not created');
        BrEventsHelper.insertUser(user.Id);

        List<BR_Event__c> events = new List<BR_Event__c>();

        BR_Events_Zone__c zone = new BR_Events_Zone__c(Name = 'testzone');
        insert zone;

        Integer year = System.today().year() + 1;
        for (Integer i=0;i<7;i++) {
            events.add(new BR_Event__c(
                    Name = 'Test event' + i,
                    OwnerId = userOwner.Id,
                    Start_Date__c = datetime.newInstance(year, 10, 15+i, 12, 30, 0),
                    End_Date__c = datetime.newInstance(year, 10, 15+i, 17, 30, 0),
                    Location__Latitude__s = 51.5156950,
                    Location__Longitude__s = -0.0893931,
                    Venue_Address__c = 'Test ave 12/2' + i,
                    List_Image_Filename__c = 'Attachment' + i,
                    BR_Events_Zone__c = zone.Id,
                    Registration_Confirmation_Message__c = 'TEST MESSAGE',
                    Draft__c = false
            ));
        }
        //add not eligible item
        events.add(new BR_Event__c(
                Name = 'Test event8',
                Start_Date__c = datetime.newInstance(2015, 10, 15, 12, 30, 0),
                End_Date__c = datetime.newInstance(year, 10, 15, 17, 30, 0),
                Location__Latitude__s = 51.5156950,
                Location__Longitude__s = -0.0893931,
                Venue_Address__c = 'Test ave 12/2',
                Draft__c = false
        ));

        insert events;
    }

    @isTest
    public static void testGetEvents() {
        User user = [SELECT Id FROM User WHERE Username = 'testusr100@testorg.com'];
        User owner = [SELECT Id FROM User WHERE Username = 'owner100@testorg.com'];
        System.runAs(user){
            Map<String,String> filterData = new Map<String,String>();

            BR_Events_Zone__c zone = [SELECT Id FROM BR_Events_Zone__c WHERE Name = 'testzone' LIMIT 1];
            String zoneId = String.valueOf(zone.Id);
            //get all eligible events

            List<BrEventsWrapper> resultList = BrEventsListController.getEvents(zoneId, JSON.serialize(filterData), 1, 10);
            System.assertEquals(7, resultList.size(), 'Wrong number of eligible items');
            System.assertEquals(datetime.newInstance(System.today().year()+1, 10, 15, 12, 30, 0), resultList[0].item.Start_Date__c, 'Wrong item is first in list');

            //test pagination
            resultList = BrEventsListController.getEvents(zoneId, JSON.serialize(filterData), 1, 5);
            System.assertEquals(5, resultList.size(), 'Wrong number of first page items');

            resultList = BrEventsListController.getEvents(zoneId, JSON.serialize(filterData), 2, 5);
            System.assertEquals(2, resultList.size(), 'Wrong number of second page items');

            //get item attendees count
            BR_Event__c e = [SELECT Id FROM BR_Event__c WHERE Name = 'Test event0'];
            insert new BR_Participation__c(BR_Event__c = e.Id, Participate__c = 'Yes', User__c = UserInfo.getUserId());
            resultList = BrEventsListController.getEvents(zoneId, JSON.serialize(filterData), 1, 5);
            System.assertEquals(1, resultList[0].attendeesCount, 'Wrong number of attendees');

            insert new BR_Participation__c(BR_Event__c = e.Id, Participate__c = 'Yes', User__c = UserInfo.getUserId());
            resultList = BrEventsListController.getEvents(zoneId, JSON.serialize(filterData), 1, 5);
            System.assertEquals(2, resultList[0].attendeesCount, 'Wrong number of attendees');

            //get list image url
            Attachment att = new Attachment(Name='Attachment0', Body = Blob.valueOf('Attachment0'), ParentId = e.Id, ContentType = 'image/jpeg');
            insert att;
            resultList = BrEventsListController.getEvents(zoneId, JSON.serialize(filterData), 1, 5);
            System.assertEquals(owner.Id, resultList[0].item.OwnerId, 'Wrong owner');
//            System.assertNotEquals(null, resultList[0].userImageUrl, 'Wrong profile photo url');

            //test search
            filterData.put('search', 'search');
            resultList = BrEventsListController.getEvents(zoneId, JSON.serialize(filterData), 1, 5);
            System.assertEquals(0, resultList.size(), 'Failed on search test'); //SOSL queries return empty results within test invironment

            //test events I'm attending tab is selected
            filterData.put('search', '');
            filterData.put('tab', 'Attending');
            resultList = BrEventsListController.getEvents(zoneId, JSON.serialize(filterData), 1, 5);
            System.assertEquals(1, resultList.size(), 'Failed on search test');

            //test date is selected on calendar
            Integer year = System.today().year() + 1;
            filterData.put('date', String.valueOf(year) + '-10-15');
            filterData.put('tab', '');
            resultList = BrEventsListController.getEvents(zoneId, JSON.serialize(filterData), 1, 5);
            System.assertEquals(1, resultList.size(), 'Failed on search test');
        }
    }

    @isTest
    public static void testGetEventsCount() {
        User user = [SELECT Id FROM User WHERE Username = 'testusr100@testorg.com'];
        System.runAs(user) {
            Map<String, String> filterData = new Map<String, String>();
            Integer countVal;

            BR_Events_Zone__c zone = [SELECT Id FROM BR_Events_Zone__c WHERE Name = 'testzone' LIMIT 1];
            String zoneId = String.valueOf(zone.Id);

            countVal = BrEventsListController.getEventsCount(zoneId, filterData);
            System.assertEquals(7, countVal, 'Ivalid count without filter');
        }
    }

    @isTest
    public static void testBrEventsWrapper(){
        User user = [SELECT Id FROM User WHERE Username = 'testusr100@testorg.com'];
        System.runAs(user){
            BR_Event__c e = [SELECT Id FROM BR_Event__c WHERE Name = 'Test event0'];

            BrEventsWrapper wr = new BrEventsWrapper();
            wr.attendeesCount = 5;
            wr.item = e;
            wr.listImageURL = 'aaaa';
            wr.userImageUrl = 'url';
            System.assertEquals(e.Id, wr.item.Id, 'BrEventsWrapper is not initialized');
        }
    }
}