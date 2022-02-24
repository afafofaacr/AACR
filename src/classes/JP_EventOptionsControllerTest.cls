/**
 * Created by lauren.lezberg on 2/21/2020.
 */
@isTest
private with sharing class JP_EventOptionsControllerTest {

    @testSetup public static void setup(){
        Account acc = LiveTestDataFactory.buildAccount('Test Account');
        insert acc;

        Contact con = LiveTestDataFactory.buildContact(acc.Id);
        insert con;

        BR_Events_Zone__c zone = LiveTestDataFactory.buildZone('Test Zone', true);
        insert zone;

        BR_Event__c event = LiveTestDataFactory.buildEvent('Test Event', false, true);
        event.BR_Events_Zone__c = zone.Id;
        insert event;

        Id mainfileId = CustomFileUploadController.saveChunk(event.Id, 'Main Image File', EncodingUtil.base64Encode(Blob.valueOf('Testing 123..')), 'text/plain', '', 'EventImg');
        System.assertNotEquals(null, mainfileId);


    }

    @IsTest
    public static void test_validateZoomData(){
        Zoom_Session__c zSession = new Zoom_Session__c(Client_Id__c='1234', Client_Secret__c='56789');
        insert zSession;

        BR_Event__c event = [SELECT Id FROM BR_Event__c WHERE Name='Test Event'];

        Venue__c vVenue = new Venue__c(Name='Zoom', Integration_Controller__c = 'V_ZoomIntegration', Base_URL__c = 'https://aacr.zoom.us/j/');
        insert vVenue;
        event.Virtual_Venue__c = vVenue.Id;
        update event;

        Test.startTest();

        Boolean isValid = JP_EventOptionsController.validateZoomData(event.Id, '5555', vVenue.Id);
        System.assertEquals(true, isValid);

        Test.stopTest();

    }

    @isTest
    public static void test_setImageToPublic(){
        BR_Event__c event = [SELECT Id FROM BR_Event__c WHERE Name='Test Event'];

        Id mainFileId = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Title='Main Image File'].ContentDocumentId;

        Test.startTest();

//        JP_EventOptionsController.setImageToPublic(null);

        JP_EventOptionsController.setImageToPublic(mainfileId,event.Id, 'main');

        Test.stopTest();
    }

    @isTest
    public static void test_getFieldsInFieldset(){
        Profile stdUserProfile = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
        User user = new User(Alias = 'testusr1', Email='testusr100@testorg.com',
                EmailEncodingKey='UTF-8', LastName='Testing1', LanguageLocaleKey='en_US',
                LocaleSidKey='en_US', ProfileId = stdUserProfile.Id,
                TimeZoneSidKey = UserInfo.getTimeZone().getID(), UserName='testusr100@testorg.com');

        insert user;
//        System.assertNotEquals(null, user.Id, 'user is not created');
//        BrEventTestUtils.assignPermissionSet(user.Id, 'Live_Events');

        System.runAs(user) {
            Test.startTest();

            List<String> fields = JP_EventOptionsController.getFieldsInFieldset('Registration_Basic');
            System.assert(!fields.isEmpty());

            Test.stopTest();
        }
    }


    @isTest
    public static void test_getAndSetEventImages(){
        BR_Event__c event = [SELECT Id FROM BR_Event__c WHERE Name='Test Event'];

        Id mainfileId = CustomFileUploadController.saveChunk(event.Id, 'Main Image File', EncodingUtil.base64Encode(Blob.valueOf('Testing 123..')), 'text/plain', '', 'EventImg');
        Id lstfileId = CustomFileUploadController.saveChunk(event.Id, 'List Image File', EncodingUtil.base64Encode(Blob.valueOf('Testing 123..')), 'text/plain', '', 'EventImg');

        Id mainCDI = [SELECT ContentDocumentId FROM ContentVersion WHERE Id=: mainFileId].ContentDocumentId;
        Id listCDI = [SELECT ContentDocumentId FROM ContentVersion WHERE Id=: lstFileId].ContentDocumentId;

        Test.startTest();

        JP_EventOptionsController.setEventImage(event.Id, 'Main Image File', 'main');
        JP_EventOptionsController.setEventImage(event.Id, 'List Image File', 'list');

        event = [SELECT Main_Image_Filename__c,List_Image_Filename__c FROM BR_Event__c WHERE Id=: event.Id];
        System.assertEquals(event.Main_Image_Filename__c, 'Main Image File');
        System.assertEquals(event.List_Image_Filename__c, 'List Image File');


        List<String> images = JP_EventOptionsController.getEventImages(null);
        images = JP_EventOptionsController.getEventImages(event.Id);
        System.assertEquals(images[0], mainCDI);
        System.assertEquals(images[1], listCDI);

        Test.stopTest();
    }

    @isTest
    public static void test_saveEvent(){
        BR_Event__c event = [SELECT Id, BR_Events_Zone__c FROM BR_Event__c WHERE Name='Test Event'];
        event.BR_Events_Zone__c = null;
        event.Draft__c = true;

        Test.startTest();
        JP_EventOptionsController.saveEvent(event);
        Test.stopTest();

        event = [SELECT Draft__c FROM BR_Event__c WHERE Id=: event.Id];
        System.assertEquals(true, event.Draft__c);
    }


}