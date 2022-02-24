@isTest
public with sharing class BrEventTestUtils {

    public static User testCreateUser() {
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        User user = new User(Alias = 'standt', Email='company@testorg.com',
                EmailEncodingKey='UTF-8', FirstName='Test', LastName='Testing', LanguageLocaleKey='en_US',
                Department = 'G&A - Engineering', Country ='Italy', CompanyName ='Varonis France SAS',
                LocaleSidKey='en_US', ProfileId = p.Id, TimeZoneSidKey='America/Los_Angeles', UserName='company@testorg.com');
        insert user;

        System.assertEquals('company@testorg.com', user.Username, 'get user name value');

        assignPermissionSet(user.Id, 'Live_Events_Admin');

        return user;
    }

    @future
    public static void assignPermissionSet(Id userId, String permissionSet) {
        PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = :permissionSet];
        insert new PermissionSetAssignment(AssigneeId = userId, PermissionSetId = ps.Id);

        System.assertNotEquals(null, ps, 'permission set is not null');
    }

    public static List<BR_Event__c> testCreateEvents() {
        List<BR_Event__c> events = new List<BR_Event__c>();
        DateTime currentDatetime = DateTime.now();

        events.add(new BR_Event__c(
                Name = 'Event after 1 hour',
                Start_Date__c = currentDatetime.addHours(1),
                Send_reminders__c = TRUE,
                Reminder_Hours__c = '1;24;168;',
                Reminder_Message1__c = 'Reminder 1',
                Reminder_Message2__c = 'Reminder 2',
                Reminder_Message3__c = 'Reminder 3',
                Timezone__c = '(GMT+01:00) British Summer Time',
                End_Date__c = currentDatetime.addHours(5),
                Registration_Confirmation_Message__c = 'Test Reg Confirmation'
        ));

        events.add(new BR_Event__c(
                Name = 'Event after 1 day',
                Start_Date__c = currentDatetime.addDays(1),
                Send_reminders__c = TRUE,
                Reminder_Hours__c = '1;24;168;',
                Reminder_Message1__c = 'Reminder 1',
                Reminder_Message2__c = 'Reminder 2',
                Reminder_Message3__c = 'Reminder 3',
                Timezone__c = '(GMT+01:00) British Summer Time',
                End_Date__c = currentDatetime.addDays(5),
                Registration_Confirmation_Message__c = 'Test Reg Confirmation'
        ));

        events.add(new BR_Event__c(
                Name = 'Event after 18 hours',
                Start_Date__c = currentDatetime.addHours(18),
                Send_reminders__c = TRUE,
                Reminder_Hours__c = '1;18;168;',
                Reminder_Message1__c = 'Reminder 1',
                Reminder_Message2__c = 'Reminder 2',
                Reminder_Message3__c = 'Reminder 3',
                Timezone__c = '(GMT+01:00) British Summer Time',
                End_Date__c = currentDatetime.addDays(5),
                Registration_Confirmation_Message__c = 'Test Reg Confirmation'
        ));


        events.add(new BR_Event__c(
                Name = 'Event after 7 days',
                Start_Date__c = currentDatetime.addDays(7),
                End_Date__c = currentDatetime.addDays(8),
                Send_reminders__c = TRUE,
                Reminder_Message1__c = 'Reminder 1',
                Reminder_Message2__c = 'Reminder 2',
                Reminder_Message3__c = 'Reminder 3',
                Timezone__c = '(GMT+01:00) British Summer Time',
                Reminder_Hours__c = '1;24;168;',
                Registration_Confirmation_Message__c = 'Test Reg Confirmation'
        ));


        events.add(new BR_Event__c(
                Name = 'Event with not send reminders',
                Start_Date__c = currentDatetime.addHours(1),
                End_Date__c = currentDatetime.addHours(5),
                Send_reminders__c = FALSE,
                Timezone__c = '(GMT+01:00) British Summer Time',
                Reminder_Hours__c = '1;24;168;',
                Registration_Confirmation_Message__c = 'Test Reg Confirmation'
        ));

        events.add(new BR_Event__c(
                Name = 'Event after 12 hour',
                Start_Date__c = currentDatetime.addHours(12),
                End_Date__c = currentDatetime.addHours(15),
                Send_reminders__c = TRUE,
                Reminder_Message1__c = 'Reminder 1',
                Reminder_Message2__c = 'Reminder 2',
                Reminder_Message3__c = 'Reminder 3',
                Timezone__c = '(GMT+01:00) British Summer Time',
                Reminder_Hours__c = '1;24;168;',
                Registration_Confirmation_Message__c = 'Test Reg Confirmation'
        ));

        insert events;

        System.assertEquals(6, events.size(), 'wrong number of events');

        return events;
    }

    public static ContentVersion getContentVersion() {
        ContentVersion version = new ContentVersion();
        version.PathOnClient = 'Test';
        version.VersionData = Blob.valueOf('Test');
        insert version;

        System.assertEquals('Test', version.PathOnClient, 'wrong version');

        return version;
    }

    public static ContentDocumentLink getContentDocumentLink(ContentVersion contentVersion, String eventId) {
        ContentDocumentLink cdl = new ContentDocumentLink();
        cdl.ContentDocumentId = contentVersion.ContentDocumentId;
        cdl.LinkedEntityId = eventId;
        cdl.ShareType = 'V';
//        cdl.Visibility = 'AllUsers';
        insert cdl;

//        System.assertEquals('AllUsers', cdl.Visibility, 'wrong visibility');

        return cdl;
    }

    public static FeedItem getPost(String eventId) {
        FeedItem post = new FeedITem();
        post.body = 'Test post';
        post.ParentId = eventId;
//        post.Visibility = 'AllUsers';
        insert post;

        System.assertEquals('Test post', post.body, 'wrong name of post');

        return post;
    }

    public static FeedAttachment getAttachment(String postId, String versionId) {
        FeedAttachment postAttachment = new FeedAttachment();
        postAttachment.FeedEntityId = postId;
        postAttachment.Type = 'Content';
        postAttachment.RecordId = versionId;
        insert postAttachment;

        System.assertEquals('Content', postAttachment.Type, 'wrong type of post');

        return postAttachment;
    }

    public static Contact tesCreateContact() {
        Contact contact = new Contact(LastName = 'Test Contact', Email = 'test.event@gmail.com');
        insert contact;

        System.assertEquals('Test Contact', contact.LastName, 'wrong contact name');

        return contact;
    }

    public static List<BR_Participation__c> testCreateParticipations( List<BR_Event__c> events, String contactId, String userId) {
        List<BR_Participation__c> participations = new List<BR_Participation__c>();

        for (Integer i = 0; i < events.size(); i++) {
            if (i == 0 || i == 2) {
                participations.add(new BR_Participation__c(
                        BR_Event__c = events[i].Id,
                        Participate__c = 'Yes',
                        Contact__c = contactId
                ));
            } else if (i == 1){
                participations.add(new BR_Participation__c(
                        BR_Event__c = events[i].Id,
                        Participate__c = 'No',
                        User__c = userId
                ));
            } else {
                participations.add(new BR_Participation__c(
                        BR_Event__c = events[i].Id,
                        Participate__c = 'Yes',
                        User__c = userId
                ));
            }
        }

        insert participations;

        System.assertEquals(6, participations.size(), 'wrong number of participations');

        return participations;
    }
}