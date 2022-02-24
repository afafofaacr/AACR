/**
 * Created by afaf.awad on 10/13/2021.
 */

public without sharing class WF_FormFieldEditModalController {

//    @AuraEnabled
//    public static String setImageToPublic(String fileId){
//        System.debug('setImageToPublic...' + fileId);
//
//        if(fileId!=null) {
//            List<ContentDocumentLink> cdls = [SELECT Visibility, Id, ContentDocument.Title FROM ContentDocumentLink WHERE ContentDocumentId = :fileId];
//            for (ContentDocumentLink link : cdls) {
//                link.Visibility = 'AllUsers';
//
//            }
//
//            ContentVersion cv = [select id, ContentDocumentId, Title from contentversion where contentdocumentid = :fileId];
//
//            ContentDistribution cd = new ContentDistribution();
//            cd.Name = cdls[0].ContentDocument.Title;
//            cd.ContentVersionId = cv.id;
//            cd.PreferencesAllowViewInBrowser= true;
//            cd.PreferencesLinkLatestVersion=true;
//            cd.PreferencesNotifyOnVisit=false;
//            cd.PreferencesPasswordRequired=false;
//            cd.PreferencesAllowOriginalDownload= true;
//
//            try {
//                update cdls;
//                insert cd;
//
//                System.debug('contentDistribution: ' + cd);
//                System.debug('contentversion: ' + cv);
//
//            } catch (Exception e) {
//                new AACRCustomException(fileId, e.getMessage(), e.getStackTraceString(), 'Add Header Image in Web Form');
//            }
//            return cv.Id;
//        } else {
//            new AACRCustomException('Null file Id','WF_FormFieldEditModalController.setImagesToPublic()', 'Add Header Image in Web Form');
//            return null;
//        }
//
//    }

    @AuraEnabled
    public static List<String> getPicklistOptions(String fieldApi){
       return ECRMUtils.getPicklistValues('Contact', fieldApi);

    }

}