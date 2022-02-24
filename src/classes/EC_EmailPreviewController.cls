/**
 * Created by afaf.awad on 2/15/2021.
 */

public without sharing class EC_EmailPreviewController {

    @AuraEnabled
    public static String getEmailPreview(String emailId){

       return EC_Helper.buildEmailTemplate(emailId);

    }

}