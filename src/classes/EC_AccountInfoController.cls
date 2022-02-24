/**
 * Created by afaf.awad on 2/3/2021.
 */

public without sharing class EC_AccountInfoController {

    @AuraEnabled
    public static ExhibitorSetting getExhibitorSettings(){

        Id contactId = ECRMUtils.getCurrentLoginUserContactId();

        System.debug('contactId = ' +  contactId);

        EC_Exhibitor_Setting__c exSetting = EC_Helper.getECSettingFromContact(contactId);

//        List<ContentDocumentLink> cdls = [SELECT ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId=: exSetting.Id];
//        if(!cdls.isEmpty()) {
//            ContentDocument cds = [SELECT Id, Title FROM ContentDocument WHERE Id = :cdls[0].ContentDocumentId LIMIT 1];
//
//            System.debug('cds == ' + cds);
//
//            return new ExhibitorSetting(cds, exSetting);
//        }else{
//            return new ExhibitorSetting(null,exSetting);
//        }

        return new ExhibitorSetting(null,exSetting);

    }

    @AuraEnabled
    public static Boolean verifyExhibitorEmail(String emailString, String ecSettingId){

        try {
            Contact contact = ECRMUtils.getCurrentLoginContact();

            EC_Exhibitor_Setting__c ecSetting = [SELECT Id, Name FROM EC_Exhibitor_Setting__c WHERE Id=: ecSettingId];

            String url = System.URL.getOrgDomainURL().gethost().removeEndIgnoreCase('.my.salesforce.com');

            url = 'https://' + url + '.lightning.force.com/lightning/r/EC_Exhibitor_Setting__c/' + ecSetting.Id + '/view';

            ServiceNow_Incident_Type__mdt incidentType = [SELECT Id,Type__c FROM ServiceNow_Incident_Type__mdt WHERE DeveloperName = 'Exhibitor_Connect_Domain_Request'];

            system.debug('incidentType: ' + incidentType);
            String description = 'Technician Instructions: Add the ' +  emailString + ' domain to Send Grid Domain Sender Authentication and forward DNS settings to requester. '
                    + 'Please ensure that they notify you once the domain change has been made.'
                    + 'When requester has confirmed verification, please log into Salesforce and add the new domain to Verified Domain for this record: ' + url;


            AACR_Error_Log__c eLog = ErrorHelper.buildErrorLog(contact, incidentType.Id, incidentType.Type__c, description);
            insert eLog;
            //This should be updated to use ServiceNow API if we still need to send requests this way.
            ErrorHelper.sendServiceNowRequestEmail(contact.Id, eLog.Id, null, 'New EC Domain Request');
            return true;

        }catch(Exception e){
            System.debug(e.getMessage());
            return false;
        }

//        Boolean isSuccess = false;
//        Contact con = ECRMUtils.getCurrentLoginContact();
////        EmailTemplate emailTemplate = [SELECT Id, HtmlValue, Body FROM EmailTemplate WHERE Name = 'Verify Email'];
//        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
//
////        String body = emailTemplate.HtmlValue;
////        body = emailTemplate.HtmlValue.replace('{!Contact.Name}', part.Contact__r.Name)
////                .replace('{!BR_Event__c.Id}',part.BR_Event__c);
//
//        String body = 'Email to verify : ' + emailString;
//
//        email.setHtmlBody(body);
//        email.setSubject('Verify Email');
//        email.setTargetObjectId(con.Id);
////        email.setTemplateId(emailTemplate.Id);
//        email.setWhatId(con.Id);
//        email.setSaveAsActivity(false);
//        email.setSenderDisplayName(senderName);
//        email.setToAddresses(new List<String>{'platformautomation@yopmail.com'});
//
//         try {
//             Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{email});
//             isSuccess = true;
//            } catch (EmailException ex) {
//                System.debug(ex.getMessage());
//                throw new AACRCustomException(ex.getMessage(), ex.getStackTraceString(), 'EC: Verify Email');
//            }

    }

//    @AuraEnabled
//    public static Id uploadLogoImage(Id exhibitorId, String fileId, String fileName, String base64Data, String contentType, String fCategory, String contentDocumentId) {
//
//        System.debug('exId = ' + exhibitorId);
//        SYstem.debug('fileId = ' + fileId);
//        System.debug('fileName = ' + fileName);
//        System.debug('base64Data = ' + base64Data);
//        System.debug('contentType = ' + contentType);
//        System.debug('fCategory= ' + fCategory);
//
//        ContentVersion cv = JP_FileUploadController.saveChunk(exhibitorId, fileName, base64Data, fileId, fCategory, contentDocumentId);
//
//        System.debug('uploadLogoImage...cvId = ' + cv.Id);
//        String conDocId = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id =: cv.Id].ContentDocumentId;
//
//        System.debug('conDocId = ' + conDocId);
//
//        uploadDocImage(conDocId, exhibitorId);
//
//        return conDocId;
//    }
//
//    @AuraEnabled
//    public static void uploadDocImage(String fileId, String exhibitorId){
//
//        EC_Exhibitor_Setting__c exh = [SELECT Name, Logo_Image_Id__c FROM EC_Exhibitor_Setting__c WHERE Id=: exhibitorId];
//
//        List<ContentDocument> cds = [SELECT Id, Description FROM ContentDocument WHERE Id=: fileId OR Description = 'Exhibitor Logo Image'];
//        System.debug('ContentDocument == ' + cds);
//        for(ContentDocument cd : cds){
//            if(cd.Description == 'Exhibitor Logo Image' && cd.Id!=fileId){
//                try {
//                    System.debug('deleting cd : ' + cd);
//                    delete cd;
//                } catch(Exception e){
//                    throw new AACRCustomException(fileId, e.getMessage(), e.getStackTraceString(), 'EC Account Info - upload Image');
//                }
//            } else if(cd.Id == fileId){
//                cd.Description = 'Exhibitor Logo Image';
//                try {
//                    update cd;
//                } catch(Exception e){
//                    throw new AACRCustomException(fileId, e.getMessage(), e.getStackTraceString(), 'EC Account Info - upload Image');
//                }
//            }
//        }
//
//        System.debug('ContentDocumentId: ' + fileId);
//        ContentVersion cv = [SELECT VersionData, FileExtension FROM ContentVersion WHERE ContentDocumentId=: fileId];
//        Folder eventFolder = [SELECT id FROM Folder WHERE Name='Exhibitor Logo Images'];
//
//        String docName = exh.Name.length() > 10 ? exh.Name.subString(0,10) + '_Logo Image' : exh.Name + '_Logo Image';
//
//        Document doc;
//        if(exh.Logo_Image_Id__c !=null){
//            List<Document> docs = [SELECT Body FROM Document WHERE Name=: docName];
//            if(!docs.isEmpty()) {
//                doc = docs[0];
//                doc.Body = cv.VersionData;
//                doc.Type = cv.FileExtension;
//                update doc;
//            } else {
//                doc.IsPublic = true;
//                doc.Body = cv.VersionData;
//                doc.Name = docName;
//                doc.Type = cv.FileExtension;
//                doc.FolderId = eventFolder.Id;
//                insert doc;
//            }
//        } else {
//            doc = new Document();
//            doc.IsPublic = true;
//            doc.Body = cv.VersionData;
//            doc.Name = docName;
//            doc.Type = cv.FileExtension;
//            doc.FolderId = eventFolder.Id;
//            insert doc;
//        }
//
//        exh.Logo_Image_Id__c = doc.Id;
//        update exh;
//    }

//    @AuraEnabled
//    public static Boolean removeFile(String fileName, String recordId){
//        List<ContentDocumentLink> cdls = [SELECT ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId=: recordId];
//        set<Id> setDocumentIds = new set<Id>();
//        for(ContentDocumentLink cdl: cdls){
//            setDocumentIds.add(cdl.ContentDocumentId);
//        }
//        List<ContentDocument> cds = [SELECT Id, Title FROM ContentDocument WHERE Id IN: setDocumentIds AND Title =: fileName LIMIT 1];
//        if(cds.size()==1) {
//            try {
//                delete cds[0];
//                return true;
//            } catch (Exception e) {
//                System.debug('Could not remove file: ' + e.getMessage());
//                return false;
//            }
//        }
//        return false;
//    }

    /**
     * @purpose Update exhibitor signatures
     *
     * @param exSetId
     * @param message
     * @param sig1
     * @param sig2
     * @param sig3
     * @param sig4
     * @param sig5
     * @param sig6
     *
     * @return success or fail
     */
    @AuraEnabled
    public static Boolean updateExhibitorSigs(String exSetId, String message, String sig1, String sig2, String sig3, String sig4, String sig5, String sig6){
        System.debug('updateExhibitorSigs being called with exSetId: ' + exSetId + ' and message: ' + message);

        EC_Exhibitor_Setting__c exSetting = [SELECT Signature_1__c, Signature_2__c, Signature_3__c, Signature_4__c, Signature_5__c, Signature_6__c
                                                FROM EC_Exhibitor_Setting__c
                                                WHERE Id=: exSetId];
        if(sig1!=null) {
            exSetting.Signature_1__c = sig1;
        }
        if(sig2!=null) {
            exSetting.Signature_2__c = sig2;
        }
        if(sig3!=null) {
            exSetting.Signature_3__c = sig3;
        }
        if(sig4!=null) {
            exSetting.Signature_4__c = sig4;
        }
        if(sig5!=null) {
            exSetting.Signature_5__c = sig5;
        }
        if(sig6!=null) {
            exSetting.Signature_6__c = sig6;
        }

        try{

            update exSetting;

            return true;
        } catch(Exception e){
            System.debug('Could not update exhibitor settings: ' + e.getMessage());
            return false;
        }

    }

    public class ExhibitorSetting {
        @AuraEnabled
        public ContentDocument conDoc;
        @AuraEnabled
        public EC_Exhibitor_Setting__c exSet;

        public ExhibitorSetting(ContentDocument contentDocument, EC_Exhibitor_Setting__c exhibitorSetting) {
            conDoc = contentDocument;
            exSet = exhibitorSetting;

        }
    }


}