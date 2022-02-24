@IsTest
private class BrEventsImageUploadHelperTest {
    @isTest
    public static void testGetFileUploadId() {
        BR_Event__c event = new BR_Event__c(Main_Image_Filename__c = 'Test',
                Start_Date__c = Datetime.now(), End_Date__c=Datetime.now().addDays(1));
        insert event;

        ApexPages.currentPage().getParameters().put('id', event.Id);

        ContentVersion version = BrEventTestUtils.getContentVersion();

        ContentVersion contentVersion = [
                SELECT Id, Title, ContentDocumentId
                FROM ContentVersion
                WHERE Id = :version.Id
                LIMIT 1
        ];

        BrEventTestUtils.getContentDocumentLink(contentVersion, event.Id);

        Test.startTest();

        String fileMainImageId = BrEventsImageUploadHelper.getFileUploadId('mainImage');
        String fileListViewImageId = BrEventsImageUploadHelper.getFileUploadId('listViewImage');

        Test.stopTest();

        System.assertNotEquals(null, fileMainImageId, 'wrong file main image id');
        System.assertNotEquals(null, fileListViewImageId, 'wrong file list view image id');
    }

    @isTest
    public static void testUploadImage() {
        BR_Event__c event = new BR_Event__c(Main_Image_Filename__c = 'Test',
                Start_Date__c = Datetime.now(), End_Date__c=Datetime.now().addDays(1));
        insert event;

        ApexPages.currentPage().getParameters().put('id', event.Id);
        ContentVersion version = BrEventTestUtils.getContentVersion();

        ContentVersion contentVersion = [
                SELECT Id, Title, ContentDocumentId
                FROM ContentVersion
                WHERE Id = :version.Id
                LIMIT 1
        ];

        BrEventTestUtils.getContentDocumentLink(contentVersion, event.Id);

        Test.startTest();

        BrEventsImageUploadHelper.uploadImage(Blob.valueOf('New'), 'newFile.jpg', false, 'mainImage');
        BrEventsImageUploadHelper.uploadImage(Blob.valueOf('New'), 'newFile.jpg', false, 'listViewImage');

        Test.stopTest();

        System.assertEquals(3, [SELECT Id FROM ContentDocumentLink WHERE LinkedEntityId = :event.Id].size(), 'chatter file was not created');
        System.assertEquals(2, [SELECT Id FROM FeedItem LIMIT 1000].size(), 'feed item was not created');
        System.assertEquals(2, [SELECT Id FROM FeedAttachment LIMIT 1000].size(), 'feed attachment was not created');
    }

    @isTest
    public static void testDeleteChatterFile() {
        BR_Event__c event = new BR_Event__c(Main_Image_Filename__c = 'Test',
                Start_Date__c = Datetime.now(), End_Date__c=Datetime.now().addDays(1));
        insert event;

        ApexPages.currentPage().getParameters().put('id', event.Id);
        ContentVersion version = BrEventTestUtils.getContentVersion();

        ContentVersion contentVersion = [
                SELECT Id, Title, ContentDocumentId
                FROM ContentVersion
                WHERE Id = :version.Id
                LIMIT 1
        ];

        BrEventTestUtils.getContentDocumentLink(contentVersion, event.Id);

        Test.startTest();

        BrEventsImageUploadHelper.deleteChatterFile(event.Id, 'Test');

        Test.stopTest();

        System.assertEquals(0, [SELECT Id FROM ContentDocumentLink WHERE LinkedEntityId = :event.Id].size(), 'chatter file was not created');
        System.assertEquals(0, [SELECT Id FROM FeedItem LIMIT 1000].size(), 'feed item was not created');
        System.assertEquals(0, [SELECT Id FROM FeedAttachment LIMIT 1000].size(), 'feed attachment was not created');
    }
}