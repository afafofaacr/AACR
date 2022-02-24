/**
 * Created by lauren.lezberg on 12/9/2019.
 */

public with sharing class MakeDeceasedController {


    @AuraEnabled
    public static Boolean getButtonVisibility(String contactId){
        if(FeatureManagement.checkPermission('Mark_As_Deceased')) {
            Id deceasedRecordType = ECRMUtils.deceasedRecordTypeId;
            Contact con = [SELECT RecordTypeId, Id FROM Contact WHERE Id = :contactId];
            if (con.RecordTypeId != deceasedRecordType) {
                return true;
            }
        }

        return false;
    }


    @AuraEnabled
    public static void moveContactToDeceased(String contactId, String noteContent){
        Id deceasedRecordType = ECRMUtils.deceasedRecordTypeId;
        //flip contact to deceased
        Contact con = [SELECT RecordTypeId, Id FROM Contact WHERE Id=: contactId];
        if(con.RecordTypeId != deceasedRecordType){
            con.RecordTypeId = deceasedRecordType;
            con.Membership_Status__c = 'Deceased';
            update con;
        }

        //deactivate user
        ECRMUtils.deactivatePortalUser(con.Id);

        //cancel all subscriptions
        ECRMUtils.cancelAllSubscriptions(contactId, 'Deceased');

        //add note to contact
        if(noteContent!=null) {
            addNoteToContact(contactId, noteContent, 'Deceased Note');
        }
    }




    public static void addNoteToContact(String contactId, String noteContent, String noteTitle){
        ContentVersion objCntNote = new ContentVersion();
        objCntNote.Title = noteTitle;
        objCntNote.PathOnClient = objCntNote.Title + '.snote';
        objCntNote.VersionData = Blob.valueOf(noteContent);
        objCntNote.FirstPublishLocationId = contactId;

        try {
            insert objCntNote;
        } catch (Exception e){
            System.debug('Could not attach note to contact ' + e.getMessage());
        }
    }

}