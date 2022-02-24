/**
 * Created by lauren.lezberg on 3/13/2019.
 */

public with sharing class JP_FileUploadController {


    @AuraEnabled
    public static String getFileName(String fileId){
        List<ContentVersion> cv = [SELECT Id, Title, FileType FROM ContentVersion WHERE Id=:fileId];
        if(!cv.isEmpty()){
            return cv[0].Title;
        }

        return null;
    }

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
    public static ContentVersion saveChunk(Id parentId, String fileName, String base64Data, String fileId, String fCategory, String contentDocumentId) {
        System.debug('saveChunk - fileId: ' + fileId + ' contentDocumentId: ' + contentDocumentId);
        // check if fileId id ''(Always blank in first chunk), then call the saveTheFile method,
        //  which is save the check data and return the attachment Id after insert,
        //  next time (in else) we are call the appendToFile() method
        //   for update the attachment with remaining chunks
        ContentVersion cv = null;
        if (fileId == '') {
            cv = saveTheFile(parentId, fileName, base64Data, fCategory, contentDocumentId);
        } else {
            cv = appendToFile(fileId, base64Data);
        }

        return cv;
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
    public static ContentVersion saveTheFile(Id parentId, String fileName, String base64Data, String fCategory, String contentDocumentId) {
        System.debug('saveTheFile: ' + contentDocumentId);
        base64Data = EncodingUtil.urlDecode(base64Data, 'UTF-8');

//        if(String.valueOf(parentId).substring(0,3)=='003'){
//            //if contact - append AACR to end of file name
//            Contact con = [SELECT AACR_ID__c FROM Contact WHERE Id=:parentId];
//            fileName = fileName + con.AACR_ID__c;
//        }



        ContentVersion cv = new ContentVersion();
        cv.ContentLocation = 'S';
        cv.VersionData = EncodingUtil.base64Decode(base64Data);
        cv.Title = fileName;
        cv.PathOnClient = filename;
        cv.Description = fCategory;
        cv.IsMajorVersion = false;
        cv.ContentDocumentId = contentDocumentId;

        insert cv;

        if(contentDocumentId==null) {
            ContentDocumentLink cdl = new ContentDocumentLink();
            cdl.ContentDocumentId = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id].ContentDocumentId;
            cdl.LinkedEntityId = parentId;
            cdl.ShareType = 'V';
            insert cdl;

//            //Add public link
//            ContentDistribution cd = new ContentDistribution();
//            cd.Name = fileName;
//            cd.ContentVersionId = cv.id;
//            cd.PreferencesAllowViewInBrowser= true;
//            cd.PreferencesLinkLatestVersion=true;
//            cd.PreferencesNotifyOnVisit=false;
//            cd.PreferencesPasswordRequired=false;
//            cd.PreferencesAllowOriginalDownload= true;
//            insert cd;
        }

        cv = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id=: cv.Id];

        return cv;

    }

    /**
     * @purpose append text to file
     *
     * @param fileId
     * @param base64Data
     */
    private static ContentVersion appendToFile(Id fileId, String base64Data) {
        base64Data = EncodingUtil.urlDecode(base64Data, 'UTF-8');

        ContentVersion cv = [
                SELECT Id, VersionData, ContentDocumentId
                FROM ContentVersion
                WHERE Id =: fileId
        ];

        String existingBody = EncodingUtil.base64Encode(cv.VersionData);

//        cv.IsMajorVersion = false;
        cv.VersionData = EncodingUtil.base64Decode(existingBody + base64Data);

        update cv;

        return cv;
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
    public static Boolean removeFile(String fileId){
        ContentVersion cv = [SELECT ContentDocumentId FROM ContentVersion WHERE Id=:fileId];

            try {
                Database.delete(cv.ContentDocumentId);
                return true;
            } catch (Exception e) {
                System.debug('Could not remove file: ' + e.getMessage());
                return false;
            }
    }
}