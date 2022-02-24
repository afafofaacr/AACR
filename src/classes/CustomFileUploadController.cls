/**
 * Created by lauren.lezberg on 11/12/2019.
 */

public with sharing class CustomFileUploadController {
/**
     * @purpose save chunk of salesforce file filestream
     *
     * @param parentId
     * @param fileName
     * @param base64Data
     * @param contentType
     * @param fileId
     *
     * @return Id of new or appended file
     */
    @AuraEnabled
    public static Id saveChunk(Id parentId, String fileName, String base64Data, String contentType, String fileId, String fCategory) {
        System.debug('saveChunk being called with parentId: ' + parentId + ' and fileName ' + fileName);
        // check if fileId id ''(Always blank in first chunk), then call the saveTheFile method, which will check data and return the attachment Id after insert,
        //  next time (in else) call the appendToFile() method to update the attachment with remaining file chunks
        if (fileId == '') {
            fileId = saveTheFile(parentId, fileName, base64Data, contentType, fCategory);
        } else {
            appendToFile(fileId, base64Data);
        }

        return Id.valueOf(fileId);
    }

    /**
     * @purpose save new salesforce file
     *
     * @param parentId
     * @param fileName
     * @param base64Data
     * @param contentType
     *
     * @return Id of new file
     */
    public static Id saveTheFile(Id parentId, String fileName, String base64Data, String contentType, String fCategory) {
        System.debug('saveTheFile being called with parentId: ' + parentId + ' and fileName ' + fileName);
        base64Data = EncodingUtil.urlDecode(base64Data, 'UTF-8');

        ContentVersion cv = new ContentVersion();
        cv.ContentLocation = 'S';
        cv.VersionData = EncodingUtil.base64Decode(base64Data);
        cv.Title = fileName;
        cv.PathOnClient = filename;
        cv.Description = fCategory;

        insert cv;

        ContentDocumentLink cdl = new ContentDocumentLink();
        cdl.ContentDocumentId = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id =: cv.Id].ContentDocumentId;
        cdl.LinkedEntityId = parentId;
        cdl.ShareType = 'V';
        insert cdl;

        System.debug('returning :' + cv);

        return cv.Id;

    }

    /**
     * @purpose Append text to file
     *
     * @param fileId
     * @param base64Data
     */
    private static void appendToFile(Id fileId, String base64Data) {
        base64Data = EncodingUtil.urlDecode(base64Data, 'UTF-8');

        ContentVersion cv = [
                SELECT Id, VersionData
                FROM ContentVersion
                WHERE Id =: fileId
        ];

        String existingBody = EncodingUtil.base64Encode(cv.VersionData);

        cv.VersionData = EncodingUtil.base64Decode(existingBody + base64Data);

        update cv;
    }


    /**
     * @purpose Removes file with specified name from specified recordId
     *
     * @param fileName
     * @param recordId
     *
     * @return True for success and false for failure
     */
    @AuraEnabled
    public static Boolean removeFile(String fileName, String recordId){
        List<ContentDocumentLink> cdls = [SELECT ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId=: recordId];
        set<Id> setDocumentIds = new set<Id>();
        for(ContentDocumentLink cdl: cdls){
            setDocumentIds.add(cdl.ContentDocumentId);
        }
        List<ContentDocument> cds = [SELECT Id, Title FROM ContentDocument WHERE Id IN: setDocumentIds AND Description LIKE: '%JoinProcess%' AND Title =: fileName LIMIT 1];
        if(cds.size()==1) {
            try {
                delete cds[0];
                return true;
            } catch (Exception e) {
                System.debug('Could not remove file: ' + e.getMessage());
                return false;
            }
        }
        return false;
    }
}