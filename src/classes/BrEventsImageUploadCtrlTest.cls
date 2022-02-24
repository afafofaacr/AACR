@IsTest
private class BrEventsImageUploadCtrlTest {
    @isTest
    public static void testGetFileMainImageWithoutNullId() {
        BR_Event__c event = new BR_Event__c(Main_Image_Filename__c = 'Test',
                                                                Start_Date__c = Datetime.now(),End_Date__c=Datetime.now().addDays(1));
        insert event;

        ApexPages.currentPage().getParameters().put('id', event.Id);

        ContentVersion version = BrEventTestUtils.getContentVersion();

        ContentVersion contentVersion = [   SELECT Id, Title, ContentDocumentId
                                            FROM ContentVersion
                                            WHERE Id = :version.Id
                                            LIMIT 1];

        ContentDocumentLink cdl = BrEventTestUtils.getContentDocumentLink(contentVersion, event.Id);

        Test.startTest();

        BrEventsImageUploadCtrl uploadCtrl = new BrEventsImageUploadCtrl();
        String fileId = uploadCtrl.getFileMainImageId();

        Test.stopTest();

        System.assertNotEquals(null, fileId, 'result contains id');
    }

    @isTest
    public static void testGetFileMainImageWithNullId() {
        BR_Event__c event = new BR_Event__c(Main_Image_Filename__c = 'Test',
                                                                Start_Date__c = Datetime.now(), End_Date__c=Datetime.now().addDays(1));
        insert event;

        ApexPages.currentPage().getParameters().put('id', event.Id);

        Test.startTest();

        BrEventsImageUploadCtrl uploadCtrl = new BrEventsImageUploadCtrl();
        String fileId = uploadCtrl.getFileMainImageId();

        Test.stopTest();

        System.assertEquals('', fileId, 'result contains empty value');
    }

    @isTest
    public static void testGetExternalFileMainImage() {
        BR_Event__c event = new BR_Event__c(Main_Image_Filename__c = 'http://test.com',
                                                                Start_Date__c = Datetime.now(), End_Date__c=Datetime.now().addDays(1));
        insert event;

        ApexPages.currentPage().getParameters().put('id', event.Id);

        Test.startTest();

        BrEventsImageUploadCtrl uploadCtrl = new BrEventsImageUploadCtrl();
        String externalImage = uploadCtrl.getFileMainImageId();

        Test.stopTest();

        System.assertEquals('http://test.com', externalImage, 'result contains external image link');
    }

    @isTest
    public static void testGetFileListViewWithoutNullId() {
        BR_Event__c event = new BR_Event__c(List_Image_Filename__c = 'Test',
                                                                Start_Date__c = Datetime.now(), End_Date__c=Datetime.now().addDays(1));
        insert event;

        ApexPages.currentPage().getParameters().put('id', event.Id);

        ContentVersion version = BrEventTestUtils.getContentVersion();

        ContentVersion contentVersion = [   SELECT Id, Title, ContentDocumentId
                                            FROM ContentVersion
                                            WHERE Id = :version.Id
                                            LIMIT 1];

        ContentDocumentLink cdl = BrEventTestUtils.getContentDocumentLink(contentVersion, event.Id);

        Test.startTest();

        BrEventsImageUploadCtrl uploadCtrl = new BrEventsImageUploadCtrl();
        String fileId = uploadCtrl.getFileListViewId();

        Test.stopTest();

        System.assertNotEquals(null, fileId, 'result contains id');
    }

    @isTest
    public static void testGetFileListViewWithNullId() {
        BR_Event__c event = new BR_Event__c(List_Image_Filename__c = 'Test',
                                                                Start_Date__c = Datetime.now(), End_Date__c=Datetime.now().addDays(1));
        insert event;

        ApexPages.currentPage().getParameters().put('id', event.Id);

        Test.startTest();

        BrEventsImageUploadCtrl uploadCtrl = new BrEventsImageUploadCtrl();
        String fileId = uploadCtrl.getFileListViewId();

        Test.stopTest();

        System.assertEquals('', fileId, 'result contains empty value');
    }

    @isTest
    public static void testGetExternalFileListViewImage() {
        BR_Event__c event = new BR_Event__c(List_Image_Filename__c = 'https://test.com',
                                                                Start_Date__c = Datetime.now(), End_Date__c=Datetime.now().addDays(1));
        insert event;

        ApexPages.currentPage().getParameters().put('id', event.Id);

        Test.startTest();

        BrEventsImageUploadCtrl uploadCtrl = new BrEventsImageUploadCtrl();
        String externalImage = uploadCtrl.getFileListViewId();

        Test.stopTest();

        System.assertEquals('https://test.com', externalImage, 'result contains external image link');
    }

    @isTest
    public static void testSaveMainImageWithDeleteOldPost() {
        BR_Event__c event = new BR_Event__c(Main_Image_Filename__c = 'Test',
                Start_Date__c = Datetime.now(), End_Date__c=Datetime.now().addDays(1));
        insert event;

        ApexPages.currentPage().getParameters().put('id', event.Id);

        ContentVersion version = BrEventTestUtils.getContentVersion();

        ContentVersion contentVersion = [   SELECT Id, Title, ContentDocumentId
                                            FROM ContentVersion
                                            WHERE Id = :version.Id
                                            LIMIT 1];

        ContentDocumentLink cdl = BrEventTestUtils.getContentDocumentLink(contentVersion, event.Id);

        FeedItem post = BrEventTestUtils.getPost(event.Id);

        FeedAttachment postAttachment = BrEventTestUtils.getAttachment(post.Id, version.Id);

        BrEventsImageUploadCtrl uploadCtrl = new BrEventsImageUploadCtrl();

        uploadCtrl.mainImageFile = Blob.valueOf('New');
        uploadCtrl.mainImageFileName = 'newFile.jpg';
        uploadCtrl.isDeletePrevMainImage = true;

        Test.startTest();

        PageReference pageReference = uploadCtrl.saveMainImage();

        Test.stopTest();

        List<FeedAttachment> attachment = [SELECT Id FROM FeedAttachment];
        List<FeedItem> postAfterUploadImage = [SELECT Id FROM FeedItem];
        List<ContentDocumentLink> docLinkAfterUploadImage = [   SELECT Id
                                                                FROM ContentDocumentLink
                                                                WHERE LinkedEntityId = :event.Id];

        BR_Event__c eventAfterUploadImage = [ SELECT Main_Image_Filename__c
                                                        FROM BR_Event__c
                                                        LIMIT 1];

        System.assertEquals(1, attachment.size(), 'result contains one feed attachment');
        System.assertNotEquals(postAttachment.Id, attachment[0].Id, 'result contains new attachment');
        System.assertEquals(1, postAfterUploadImage.size(), 'result contains one post');
        System.assertNotEquals(post.Id, postAfterUploadImage[0].Id, 'result contains new post');
        System.assertEquals(1, docLinkAfterUploadImage.size(), 'result contains one document link');
        System.assertNotEquals(cdl.Id, docLinkAfterUploadImage[0].Id, 'result contains new document link');
        System.assertEquals(null, pageReference, 'result contains null page references');
        System.assertEquals('newFile', eventAfterUploadImage.Main_Image_Filename__c, 'wrong main image file name');
    }

    @isTest
    public static void testSaveMainImageWithoutDeleteOldPost() {
        BR_Event__c event = new BR_Event__c(Main_Image_Filename__c = 'Test',
                Start_Date__c = Datetime.now(), End_Date__c=Datetime.now().addDays(1));
        insert event;

        ApexPages.currentPage().getParameters().put('id', event.Id);

        ContentVersion version = BrEventTestUtils.getContentVersion();

        ContentVersion contentVersion = [   SELECT Id, Title, ContentDocumentId
                                            FROM ContentVersion
                                            WHERE Id = :version.Id
                                            LIMIT 1];

        BrEventTestUtils.getContentDocumentLink(contentVersion, event.Id);

        FeedItem post = BrEventTestUtils.getPost(event.Id);

        BrEventTestUtils.getAttachment(post.Id, version.Id);

        BrEventsImageUploadCtrl uploadCtrl = new BrEventsImageUploadCtrl();

        uploadCtrl.mainImageFile = Blob.valueOf('New');
        uploadCtrl.mainImageFileName = 'newFile.jpg';
        uploadCtrl.isDeletePrevMainImage = false;

        Test.startTest();

        PageReference pageReference = uploadCtrl.saveMainImage();

        Test.stopTest();

        List<FeedAttachment> attachment = [SELECT Id FROM FeedAttachment];
        List<FeedItem> postAfterUploadImage = [SELECT Id FROM FeedItem];
        List<ContentDocumentLink> docLinkAfterUploadImage = [ SELECT Id
                                                                FROM ContentDocumentLink
                                                                WHERE LinkedEntityId = :event.Id];

        BR_Event__c eventAfterUploadImage = [ SELECT Main_Image_Filename__c
                                                        FROM BR_Event__c
                                                        LIMIT 1];

        System.assertEquals(2, attachment.size(), 'result contains two feed attachments');
        System.assertEquals(2, postAfterUploadImage.size(), 'result contains two posts');
        System.assertEquals(2, docLinkAfterUploadImage.size(), 'result contains two document links');
        System.assertEquals(null, pageReference, 'result contains null page references');
        System.assertEquals('newFile', eventAfterUploadImage.Main_Image_Filename__c, 'wrong main image file name');
    }

    @isTest
    public static void testSaveListViewImageWithDeleteOldPost() {
        BR_Event__c event = new BR_Event__c(List_Image_Filename__c = 'Test',
                                                                Start_Date__c = Datetime.now(), End_Date__c=Datetime.now().addDays(1));
        insert event;

        ApexPages.currentPage().getParameters().put('id', event.Id);

        ContentVersion version = BrEventTestUtils.getContentVersion();

        ContentVersion contentVersion = [   SELECT Id, Title, ContentDocumentId
                                            FROM ContentVersion
                                            WHERE Id = :version.Id
                                            LIMIT 1];

        ContentDocumentLink cdl = BrEventTestUtils.getContentDocumentLink(contentVersion, event.Id);

        FeedItem post = BrEventTestUtils.getPost(event.Id);

        FeedAttachment postAttachment = BrEventTestUtils.getAttachment(post.Id, version.Id);

        BrEventsImageUploadCtrl uploadCtrl = new BrEventsImageUploadCtrl();

        uploadCtrl.fileListViewImage = Blob.valueOf('New');
        uploadCtrl.fileListViewImageName = 'newFile.jpg';
        uploadCtrl.isDeletePrevListViewImage = true;

        Test.startTest();

        PageReference pageReference = uploadCtrl.saveListViewImage();

        Test.stopTest();

        List<FeedAttachment> attachment = [SELECT Id FROM FeedAttachment];
        List<FeedItem> postAfterUploadImage = [SELECT Id FROM FeedItem];
        List<ContentDocumentLink> docLinkAfterUploadImage = [   SELECT Id
                                                                FROM ContentDocumentLink
                                                                WHERE LinkedEntityId = :event.Id];

        BR_Event__c eventAfterUploadImage = [ SELECT List_Image_Filename__c
                                                        FROM BR_Event__c
                                                        LIMIT 1];

        System.assertEquals(1, attachment.size(), 'result contains one feed attachment');
        System.assertNotEquals(postAttachment.Id, attachment[0].Id, 'result contains new attachment');
        System.assertEquals(1, postAfterUploadImage.size(), 'result contains one post');
        System.assertNotEquals(post.Id, postAfterUploadImage[0].Id, 'result contains new post');
        System.assertEquals(1, docLinkAfterUploadImage.size(), 'result contains one document link');
        System.assertNotEquals(cdl.Id, docLinkAfterUploadImage[0].Id, 'result contains new document link');
        System.assertEquals(null, pageReference, 'result contains null page references');
        System.assertEquals('newFile', eventAfterUploadImage.List_Image_Filename__c, 'wrong list image file name');
    }

    @isTest
    public static void testSaveListViewImageWithoutDeleteOldPost() {
        BR_Event__c event = new BR_Event__c(List_Image_Filename__c = 'Test',
                Start_Date__c = Datetime.now(), End_Date__c=Datetime.now().addDays(1));
        insert event;

        ContentVersion version = BrEventTestUtils.getContentVersion();

        ContentVersion contentVersion = [   SELECT Id, Title, ContentDocumentId
                                            FROM ContentVersion
                                            WHERE Id = :version.Id
                                            LIMIT 1];

        BrEventTestUtils.getContentDocumentLink(contentVersion, event.Id);

        FeedItem post = BrEventTestUtils.getPost(event.Id);

        BrEventTestUtils.getAttachment(post.Id, version.Id);

        ApexPages.currentPage().getParameters().put('id', event.Id);
        BrEventsImageUploadCtrl uploadCtrl = new BrEventsImageUploadCtrl();

        uploadCtrl.fileListViewImage = Blob.valueOf('New');
        uploadCtrl.fileListViewImageName = 'newFile.jpg';
        uploadCtrl.isDeletePrevListViewImage = false;

        Test.startTest();

        PageReference pageReference = uploadCtrl.saveListViewImage();

        Test.stopTest();

        List<FeedAttachment> attachment = [SELECT Id FROM FeedAttachment];
        List<FeedItem> postAfterUploadImage = [SELECT Id FROM FeedItem];
        List<ContentDocumentLink> docLinkAfterUploadImage = [   SELECT Id
                                                                FROM ContentDocumentLink
                                                                WHERE LinkedEntityId = :event.Id];

        BR_Event__c eventAfterUploadImage = [ SELECT List_Image_Filename__c
                                                        FROM BR_Event__c
                                                        LIMIT 1];

        System.assertEquals(2, attachment.size(), 'result contains two feed attachments');
        System.assertEquals(2, postAfterUploadImage.size(), 'result contains two posts');
        System.assertEquals(2, docLinkAfterUploadImage.size(), 'result contains two document links');
        System.assertEquals(null, pageReference, 'result contains null page references');
        System.assertEquals('newFile', eventAfterUploadImage.List_Image_Filename__c, 'wrong list image file name');
    }
}