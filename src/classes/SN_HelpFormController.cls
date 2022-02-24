/**
 * Created by lauren.lezberg on 9/3/2019.
 */

public without sharing class SN_HelpFormController {

    public final static String cmpName = 'SN_HelpForm';
    public final static String ITHelpPage = 'https://www.aacr.org/professionals/meetings/myaacr-support/';

    public static String getMaintenanceMessage(){
        List<Maintenance_Mode_Config__mdt> configs = [SELECT Id, Maintenance_Message__c FROM Maintenance_Mode_Config__mdt WHERE Is_Active__c = true AND Page_API_Name__c =: cmpName];
        if(configs.size() == 1){
            return configs[0].Maintenance_Message__c;
        }
        return null;
    }

    /**
     * @purpose Retrieve initial help form data: current contact and list of available incident types
     *
     * @return HelpFormData object instance
     */
    @AuraEnabled
    public static HelpFormData getInitialHelpFormData(){
        return new HelpFormData();
    }

    @AuraEnabled
    public static String saveNewErrorLog(String newLogString){
        AACR_Error_Log__c newLog = (AACR_Error_Log__c)JSON.deserialize(newLogString, AACR_Error_Log__c.class);
        System.debug('newLog: ' + newLog);
        try {
            insert newLog;
            System.debug('newLog Id: ' + newLog.Id);
            return newLog.Id;
        } catch(Exception e){
            System.debug('Error creating error log: ' + e.getMessage());
            return null;
        }


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
    public static Id saveChunk(Id parentId, String fileName, String base64Data, String contentType, String fileId, String fCategory) {
        // ***Community guest users cannot create salesforce files attached to record even if they have access to that record. For this case, attachments will be created instead of salesforce files.
        //  For all other users, check if fileId id is equal to ''(Always blank in first chunk), then call the saveTheFile method
        //  Next time once file is created, call the appendTOFile() method to update the file with remaining chunks
        if (fileId == '') {
            Profile pfile = [Select Id from Profile WHERE UserLicense.Name = 'Guest' AND Name='AACR Community Profile' LIMIT 1];
            if(UserInfo.getProfileid()!=pfile.Id || Test.isRunningTest() ) {
                fileId = saveTheFile(parentId, fileName, base64Data, contentType, fCategory);
            } else {
                fileId = saveTheAttachment(parentId, fileName, base64Data, contentType, fCategory);
            }
        } else {
            appendToFile(fileId, base64Data);
        }

        return Id.valueOf(fileId);
    }

    /**
     * @purpose Save new salesforce file
     *
     * @param parentId
     * @param fileName
     * @param base64Data
     * @param contentType
     *
     * @return Id of new file
     */
    public static Id saveTheFile(Id parentId, String fileName, String base64Data, String contentType, String fCategory) {
        base64Data = EncodingUtil.urlDecode(base64Data, 'UTF-8');

        ContentVersion cv = new ContentVersion();
        cv.ContentLocation = 'S';
        cv.VersionData = EncodingUtil.base64Decode(base64Data);
        cv.Title = fileName;
        cv.PathOnClient = filename;
        cv.Description = fCategory;
        cv.Origin = 'C';
        cv.IsMajorVersion = false;
        if(Test.isRunningTest()){
            cv.FirstPublishLocationId = UserInfo.getUserId();
        }

        insert cv;

        ContentDocumentLink cdl = new ContentDocumentLink();
        cdl.ContentDocumentId = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id =: cv.Id].ContentDocumentId;
        cdl.LinkedEntityId = parentId;
        cdl.ShareType = 'V';
        cdl.Visibility = 'AllUsers';
        insert cdl;

        return cv.Id;

    }

    /**
     * @purpose Save new attachment for community guest users
     *
     * @param parentId
     * @param fileName
     * @param base64Data
     * @param contentType
     * @param fCategory
     *
     * @return Id of attachment
     */
    @AuraEnabled
    public static Id saveTheAttachment(Id parentId, String fileName, String base64Data, String contentType, String fCategory){
        System.debug('saving attachment...');
        Attachment a = new Attachment();
        if(fileName!='') {
            base64Data = EncodingUtil.urlDecode(base64Data, 'UTF-8');


            a.parentId = parentId;
            a.Body = EncodingUtil.base64Decode(base64Data);
            a.Name = fileName;
            a.ContentType = contentType;
            a.Description = fCategory;

            try {
                insert a;
                return a.Id;
            } catch (Exception e) {
                System.debug('error inserting attachment' + e.getMessage());
            }

        }
        return null;
    }

    /**
     * @purpose Append text stored in chunks to file
     *
     * @param fileId
     * @param base64Data
     */
    private static void appendToFile(Id fileId, String base64Data) {
        System.debug('appendToFile: ' + fileId + ' base64Data: ' + base64Data);

        Profile pfile = [Select Id from Profile WHERE UserLicense.Name = 'Guest' AND Name='AACR Community Profile' LIMIT 1];
        if(UserInfo.getProfileid()!=pfile.Id || Test.isRunningTest() ) {
            base64Data = EncodingUtil.urlDecode(base64Data, 'UTF-8');

            ContentVersion cv = [
                    SELECT Id, VersionData
                    FROM ContentVersion
                    WHERE Id = :fileId
            ];

            String existingBody = EncodingUtil.base64Encode(cv.VersionData);

            cv.VersionData = EncodingUtil.base64Decode(existingBody + base64Data);

            update cv;
        } else {
            base64Data = EncodingUtil.urlDecode(base64Data, 'UTF-8');
            Attachment attach = [SELECT Id, Body FROM Attachment WHERE Id=: fileId];
            String existingBody = EncodingUtil.base64Encode(attach.Body);
            attach.Body = EncodingUtil.base64Decode(existingBody + base64Data);

            update attach;
        }
    }


    /**
     * @purpose Send info email to service now
     *
     * @param contactId
     * @param logId
     * @param fileId
     */
    @AuraEnabled
    public static void sendInfoEmail(Id contactId, Id logId, Id fileId){
        ErrorHelper.sendServiceNowRequestEmail(contactId, logId, fileId);
    }


    /**
     * @purpose Look for contact record based on name and email to see if it exists in the system
     *
     * @param name
     * @param email
     *
     * @return
     */
    @AuraEnabled
    public static Contact findContact(String name, String email){
        List<Contact> con = [SELECT Id,Name, AACR_ID__c, Account.Name FROM Contact WHERE Name=: name AND (npe01__Preferred_Email__c =: email OR OrderApi__Preferred_Email__c=: email OR Email=:email)];
        if(!con.isEmpty()){
            return con[0];
        }
        return null;
    }


    public class HelpFormData{
        @AuraEnabled
        public Contact currentContact;

        @AuraEnabled
        public List<ServiceNow_Incident_Type__mdt> incidentTypes;

        @AuraEnabled
        public String maintenanceMessage;

        @AuraEnabled
        public String helpFormLink;


        public HelpFormData(){
            currentContact = ECRMUtils.getCurrentLoginContact();
            incidentTypes = new List<ServiceNow_Incident_Type__mdt>();
            incidentTypes.addAll([SELECT Id, Type__c FROM ServiceNow_Incident_Type__mdt WHERE Is_Active__c = true ORDER BY Type__c]);
            maintenanceMessage = SN_HelpFormController.getMaintenanceMessage();
            helpFormLink = ITHelpPage;
        }
    }
}