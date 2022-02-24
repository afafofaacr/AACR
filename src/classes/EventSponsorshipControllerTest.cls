/**
 * Created by afaf.awad on 5/10/2021.
 */
@IsTest
public with sharing class EventSponsorshipControllerTest {

    @TestSetup public static void setup() {
        Account account = LiveTestDataFactory.buildAccount('Test Account');
        insert account;

        Contact contact = LiveTestDataFactory.buildContact(account.Id);
        insert contact;

        User user = TestDataFactory.buildUser(contact.Id);
        insert user;

        //Participant Contacts
        Account partAccount = LiveTestDataFactory.buildAccount('Test Participant Account');
        insert partAccount;

        List<Contact> partContacts = new List<Contact>();
        for (Integer i = 0; i < 5; i++) {
            Contact con = LiveTestDataFactory.buildContact(partAccount.Id);
            con.LastName = con.LastName + i;
            con.Email = 'testEmail' + i + '@yopmail.com';
            partContacts.add(con);
        }
        insert partContacts;

        List<User> partUsers = new List<User>();
        for (Integer k = 0; k < partContacts.size(); k++){
            // Create users record
            User u = TestDataFactory.buildUser(partContacts[k].Id);
            u.LastName = 'Test User' + k;
            u.Email = 'test' + k + '@testorg.com';
            partUsers.add(u);
        }

        BR_Events_Zone__c zone = LiveTestDataFactory.buildZone('Default', true);
        insert zone;

        BR_Event__c event = LiveTestDataFactory.buildEvent('Test Event', false, false, zone.Id);
        event.Registration_Confirmation_Message__c = 'You are registered!';
        event.Sponsorship_Level_1__c = 'Gold';
        event.Sponsorship_Level_2__c = 'Silver';
        event.Sponsorship_Level_3__c = 'Bronze';
        event.Display_on_Confirmation_Email__c = true;
        insert event;

        Sponsor__c sponsor1 = new Sponsor__c(Sponsor__c = account.Id,
                                            Display_As__c = 'Test Account',
                                            Logo_URL__c = 'www.google.com',
                                            Event__c = event.Id,
                                            Level__c = '1');
        insert sponsor1;

        Id imageFileId1 = CustomFileUploadController.saveChunk(sponsor1.Id, 'Logo Image File 1', EncodingUtil.base64Encode(Blob.valueOf('Testing 123..')), 'text/plain', '', 'SponsorImg');
        System.assertNotEquals(null, imageFileId1);
        sponsor1.Logo_Image_Id__c = [select id, ContentDocumentId, Title from contentversion where Id = :imageFileId1].ContentDocumentId;
        update sponsor1;
        EventSponsorshipController.setImageToPublic(sponsor1.Logo_Image_Id__c);


        Sponsor__c sponsor2 = new Sponsor__c(Sponsor__c = account.Id,
                Display_As__c = 'Test Account',
                Logo_URL__c = 'www.google.com',
                Event__c = event.Id,
                Level__c = '2');
        insert sponsor2;

        Id imageFileId2 = CustomFileUploadController.saveChunk(sponsor2.Id, 'Logo Image File 2', EncodingUtil.base64Encode(Blob.valueOf('Testing 123..')), 'text/plain', '', 'SponsorImg');
        System.assertNotEquals(null, imageFileId2);
//        EventSponsorshipController.setImageToPublic(sponsor2.Logo_Image_Id__c);
        sponsor2.Logo_Image_Id__c = [select id, ContentDocumentId, Title from contentversion where Id = :imageFileId2].ContentDocumentId;
        update sponsor2;
        system.debug('Logo image id: ' +  sponsor2.Logo_Image_Id__c );

        Sponsor__c sponsor3 = new Sponsor__c(Sponsor__c = account.Id,
                Display_As__c = 'Test Account',
                Logo_URL__c = 'www.google.com',
                Event__c = event.Id,
                Level__c = '3');
        insert sponsor3;

        Id imageFileId3 = CustomFileUploadController.saveChunk(sponsor3.Id, 'Logo Image File 3', EncodingUtil.base64Encode(Blob.valueOf('Testing 123..')), 'text/plain', '', 'SponsorImg');
        System.assertNotEquals(null, imageFileId3);
        EventSponsorshipController.setImageToPublic(sponsor3.Logo_Image_Id__c);

        sponsor3.Logo_Image_Id__c = [select id, ContentDocumentId, Title from contentversion where Id = :imageFileId3].ContentDocumentId;
        update sponsor3;

        List<OrgWideEmailAddress> owas = [SELECT Id FROM OrgWideEmailAddress LIMIT 1];

        insert new BrEvents_Settings__c(Name='org wide email id', Label__c = 'org wide email id', Value__c = owas[0].Id );

        insert new Event_Sponsors__c(Instructions__c = 'Fill out form.');

        List<BR_Participation__c> participations = new List<BR_Participation__c>();
        for(Integer j = 5;j<partContacts.size();j++){
            participations.add(new BR_Participation__c(Contact__c=partContacts[j].Id
                    , BR_Event__c=event.Id
                    , Participate__c='Yes'
                    , Bypass_Confirmation__c= true
                    , GDPR_Certification__c = true));
        }
        insert participations;

    }

    @IsTest
    public static void test_getSponsorSetting(){
            EventSponsorshipController.getSponsorSetting();
    }

    @IsTest
    public static void test_getSponsorInfo(){

        BR_Event__c event = [SELECT Id FROM BR_Event__c];
        List<Sponsor__c> sponsors = [SELECT Id FROM Sponsor__c WHERE Event__c =: event.Id];

        List<Sponsor__c> sponsorList =  EventSponsorshipController.getSponsorInfo(event.Id);

        System.assertEquals(sponsors.size(), sponsorList.size());

    }

    @IsTest
    public static void test_getAccountInfo(){
        Account acc = [SELECT Id, Name FROM Account WHERE Name = 'Test Account'];

        Account returnAcc = EventSponsorshipController.getAccountInfo(acc.Id);

        System.assertEquals(acc.Name, returnAcc.Name);
    }

    @IsTest
    public static void test_getSponsorImages(){
        Sponsor__c sponsor = [SELECT Id, Logo_Image_Id__c FROM Sponsor__c LIMIT 1];
        ContentDocumentLink cdl = [SELECT ContentDocumentId FROM ContentDocumentLink where LinkedEntityId = :sponsor.Id];

        String logoId_Null =  EventSponsorshipController.getSponsorImages('');
        String logoId =  EventSponsorshipController.getSponsorImages(sponsor.Id);

        System.assertEquals(cdl.ContentDocumentId, logoId);

    }

    @isTest
    public static void test_setImageToPublic(){

        Id imageFileId = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Title='Logo Image File 1'].ContentDocumentId;

        EventSponsorshipController.setImageToPublic(imageFileId);

    }

    @IsTest
    public static void test_clearSponsorLevel(){

        BR_Event__c event = [SELECT Id FROM BR_Event__c];
//        List<Sponsor__c> sponsors = [SELECT Id, Logo_Image_Id__c FROM Sponsor__c WHERE Event__c =: event.Id];
//        Id imageFileId = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Title='Logo Image File 2'].ContentDocumentId;
//        EventSponsorshipController.setImageToPublic(imageFileId);

        EventSponsorshipController.clearSponsorLevel(event.Id, '2');

        List<Sponsor__c> lvl2_Sponsors = [SELECT Id FROM Sponsor__c WHERE Event__c =: event.Id and Level__c = '2'];

        System.assertEquals(0, lvl2_Sponsors.size());

    }

    @IsTest
    public static void test_deleteSponsorRecord(){

        List<Sponsor__c> sponsors = [SELECT Id, Logo_Image_Id__c FROM Sponsor__c];

//        Id imageFileId = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Title='Logo Image File 2'].ContentDocumentId;
//        EventSponsorshipController.setImageToPublic(imageFileId);

        EventSponsorshipController.deleteSponsorRecord(sponsors[0].Id);

        List<Sponsor__c> sponsorsPost = [SELECT Id FROM Sponsor__c];

        System.assertEquals(sponsors.size()-1, sponsorsPost.size());

    }

    @IsTest
    public static void test_buildLogosInEmail(){

        BR_Event__c event = [SELECT Id, Display_on_Confirmation_Email__c FROM BR_Event__c];
        List<Sponsor__c> sponsors = [SELECT Id, Logo_Image_Id__c FROM Sponsor__c WHERE Event__c =: event.Id];

        List<ContentVersion> imageFiles = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Title LIKE 'Logo Image File%'];

        for(ContentVersion cv: imageFiles) {
            EventSponsorshipController.setImageToPublic(cv.ContentDocumentId);
        }

        String htmlString =  EventSponsorshipController.buildLogosInEmail(event.Id, event.Display_on_Confirmation_Email__c);
    }

}