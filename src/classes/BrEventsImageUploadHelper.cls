public with sharing class BrEventsImageUploadHelper {

    public static String getFileUploadId(String type) {
        String recordId = ApexPages.currentPage().getParameters().get('id');
        String fileId = '';

        String fileName = null;
        if (type == 'mainImage') {

            try {
                List<BR_Event__c> events = [
                        SELECT Main_Image_Filename__c
                        FROM BR_Event__c
                        WHERE Id = :recordId];

                if (!events.isEmpty()) {
                    fileName = events[0].Main_Image_Filename__c;
                }

            } catch (Exception e) {
                System.debug(e.getMessage());
            }

        } else if (type == 'listViewImage') {

            try {
                List<BR_Event__c> events = [
                        SELECT List_Image_Filename__c
                        FROM BR_Event__c
                        WHERE Id = :recordId];

                if (!events.isEmpty()) {
                    fileName = events[0].List_Image_Filename__c;
                }

            } catch (Exception e) {
                System.debug(e.getMessage());
            }
        }

        if ((fileName != null) && (fileName.startsWith('http://') || fileName.startsWith('https://'))) {
            return fileName;
        }

        List<ContentDocumentLink> chatterFiles;

        try {
            chatterFiles = [SELECT ContentDocument.LatestPublishedVersionId
            FROM ContentDocumentLink
            WHERE LinkedEntityId = :recordId
            AND ContentDocument.Title = :fileName];
        } catch (Exception e) {
            System.debug(e.getMessage());
        }

        if(!chatterFiles.isEmpty()) {
            fileId = chatterFiles[0].ContentDocument.LatestPublishedVersionId;
        }
        return fileId;
    }

    public static void uploadImage(Blob file, String fileName, Boolean isDeleteImage, String type) {
        if(!BrEventsHelper.performAccessCheck('read', 'BR_Event__c', null)
                || !BrEventsHelper.performAccessCheck('edit', 'BR_Event__c',
                new List<String>{'Main_Image_Filename__c', 'List_Image_Filename__c'})
                || !BrEventsHelper.performAccessCheck('create', 'ContentVersion', new List<String>{'PathOnClient','VersionData'})){
            System.debug('fls error in uploadImage method');
        }
        String recordId = ApexPages.currentPage().getParameters().get('id');

        if (fileName.indexOf('.') > 0) {
            fileName = fileName.substring(0, fileName.lastIndexOf('.'));
        }

        BR_Event__c event;

        if (type == 'mainImage') {

            try {
                event = [   SELECT Main_Image_Filename__c
                FROM BR_Event__c
                WHERE Id = :recordId];
            } catch (Exception e) {
                System.debug(e.getMessage());
            }

            if (isDeleteImage) {
                BrEventsImageUploadHelper.deleteChatterFile(recordId, event.Main_Image_Filename__c);
            }

            event.Main_Image_Filename__c = fileName;
        } else if (type == 'listViewImage') {

            try {
                event = [   SELECT List_Image_Filename__c
                FROM BR_Event__c
                WHERE Id = :recordId];
            } catch (Exception e) {
                System.debug(e.getMessage());
            }

            if (isDeleteImage) {
                BrEventsImageUploadHelper.deleteChatterFile(recordId, event.List_Image_Filename__c);
            }

            event.List_Image_Filename__c = fileName;
        }

        try {
            update event;
        } catch (Exception e) {
            System.debug(e.getMessage());
        }

        ContentVersion version = new ContentVersion();
        version.PathOnClient = fileName;
        version.VersionData = file;

        try {
            insert version;
        } catch (Exception e) {
            System.debug(e.getMessage());
        }

        ContentVersion contentVersion;

        try {
            contentVersion = [  SELECT Id, Title, ContentDocumentId
            FROM ContentVersion
            WHERE Id = :version.Id
            LIMIT 1];
        } catch (Exception e) {
            System.debug(e.getMessage());
        }

        ContentDocumentLink cdl = new ContentDocumentLink();
        cdl.ContentDocumentId = contentVersion.ContentDocumentId;
        cdl.LinkedEntityId = recordId;
        cdl.ShareType = 'V';
        cdl.Visibility = 'AllUsers';

        try {
            insert cdl;
        } catch (Exception e) {
            System.debug(e.getMessage());
        }

        FeedItem post = new FeedItem();
        post.body = 'New post';
        post.ParentId = recordId;
        post.Visibility = 'AllUsers';

        try {
            insert post;
        } catch (Exception e) {
            System.debug(e.getMessage());
        }

        FeedAttachment postAttachment = new FeedAttachment();
        postAttachment.FeedEntityId = post.id;
        postAttachment.Type = 'Content';
        postAttachment.RecordId = version.id;

        try {
            insert postAttachment;
        } catch (Exception e) {
            System.debug(e.getMessage());
        }
    }

    public static void deleteChatterFile(String recordId, String fileName) {
        if(!BrEventsHelper.performAccessCheck('read', 'ContentDocumentLink', new List<String>{'LinkedEntityId'})
                || !BrEventsHelper.performAccessCheck('read', 'ContentDocument', new List<String>{'LatestPublishedVersionId', 'Title'})
                || !BrEventsHelper.performAccessCheck('read', 'FeedAttachment', new List<String>{'FeedEntityId', 'RecordId'})
                || !BrEventsHelper.performAccessCheck('read', 'FeedItem', null)
                || !BrEventsHelper.performAccessCheck('delete', 'ContentDocumentLink', null)
                || !BrEventsHelper.performAccessCheck('delete', 'FeedAttachment', null)
                || !BrEventsHelper.performAccessCheck('delete', 'FeedItem', null)){
            System.debug('fls error in uploadImage method');
            return;
        }

        List<ContentDocumentLink> chatterFiles;
        try {
            chatterFiles = [  SELECT ContentDocument.LatestPublishedVersionId
            FROM ContentDocumentLink
            WHERE LinkedEntityId = :recordId
            AND ContentDocument.Title = :fileName];
        } catch (Exception e) {
            System.debug(e.getMessage());
        }

        if (!chatterFiles.isEmpty()) {
            FeedAttachment attachment;
            try {
                attachment = [  SELECT Id, FeedEntityId
                FROM FeedAttachment
                WHERE RecordId = :chatterFiles[0].ContentDocument.LatestPublishedVersionId
                LIMIT 1];
            } catch (Exception e) {
                System.debug(e.getMessage());
            }

            FeedItem feedItem;
            try {

                feedItem = [    SELECT Id
                FROM FeedItem
                WHERE Id = :attachment.FeedEntityId
                LIMIT 1];
            } catch (Exception e) {
                System.debug(e.getMessage());
            }

            try {
                delete chatterFiles[0];
            } catch (Exception e) {
                System.debug(e.getMessage());
            }
            try {
                delete attachment;
            } catch (Exception e) {
                System.debug(e.getMessage());
            }
            try {
                delete feedItem;
            } catch (Exception e) {
                System.debug(e.getMessage());
            }
        }
    }
}