/**
 * Created by lauren.lezberg on 2/18/2020.
 */

public with sharing class SpeakerInviteController {

    @AuraEnabled
    public static void uploadDocImage(String fileId, String eventId){
        System.debug('uploadDocIMage: ' + fileId);
        BR_Event__c evt = [SELECT Name, Invite_Image_Id__c FROM BR_Event__c WHERE Id=: eventId];

        List<ContentDocument> cds = [SELECT Id, Description FROM ContentDocument WHERE Id=: fileId OR Description = 'Header Image'];
        for(ContentDocument cd : cds){
            if(cd.Description == 'Header Image' && cd.Id!=fileId){
                try {
                    delete cd;
                } catch(Exception e){
                    throw new AACRCustomException(fileId, e.getMessage(), e.getStackTraceString(), 'Speaker Invitations');
                }
            } else if(cd.Id == fileId){
                cd.Description = 'Header Image';
                try {
                    update cd;
                } catch(Exception e){
                    throw new AACRCustomException(fileId, e.getMessage(), e.getStackTraceString(), 'Speaker Invitations');
                }
            }
        }


        ContentVersion cv = [SELECT VersionData, FileExtension FROM ContentVersion WHERE ContentDocumentId=: fileId];
        Folder eventFolder = [SELECT id FROM Folder WHERE Name='AACR Event Images'];

        Document doc;
        if(evt.Invite_Image_Id__c!=null){
            //TODO: Look for document based off id & replace doc image
            List<Document> docs = [SELECT Body FROM Document WHERE Name=: evt.Name.subString(0,10) + '_Header Image'];
            if(!docs.isEmpty()) {
                doc = docs[0];
                doc.Body = cv.VersionData;
                doc.Type = cv.FileExtension;
                update doc;
            } else {
                doc.IsPublic = true;
                doc.Body = cv.VersionData;
                doc.Name = evt.Name.subString(0,10) + '_Header Image';
                doc.Type = cv.FileExtension;
                doc.FolderId = eventFolder.Id;
                insert doc;
            }

        } else {
            //TODO: Create new document from file & update event with id
            doc = new Document();
            doc.IsPublic = true;
            doc.Body = cv.VersionData;
            doc.Name = evt.Name.subString(0,10) + '_Header Image';
            doc.Type = cv.FileExtension;
            doc.FolderId = eventFolder.Id;
            insert doc;
        }

        evt.Invite_Image_Id__c = doc.Id;
        update evt;
    }

//    @AuraEnabled
//    public static String uploadImageDocument(String imgURL, String eventId){
//        System.debug('uploadImageDocument...');
//        BR_Event__c evt = [SELECT Name FROM BR_Event__c WHERE Id=: eventId];
//        Folder eventFolder = [SELECT id FROM Folder WHERE Name='AACR Event Images'];
//        Document doc = new Document();
//        doc.Name = evt.Name;
//        doc.Url = imgURL;
//        doc.Type = 'URL';
//        doc.FolderId = eventFolder.Id;
//        insert doc;
//
//        evt.Invite_Image_Id__c = doc.Id;
//        update evt;
//
//        return SpeakerInviteHelper.buildEventInviteTemplate(eventId, null);
//    }

    /**
     * @purpose Retrieve speaker invitation join process id
     *
     * @return join process id
     */
    @AuraEnabled
    public static String getSpeakerInviteJPId(){
        return [SELECT Id FROM Join_Process__mdt WHERE DeveloperName='Speaker_Invitations'].Id;
    }

    /**
     * @purpose Get email template body for event with event info and invite message filled in
     *
     * @param eventId
     *
     * @return email content string
     */
    @AuraEnabled
    public static String getEmailTemplate(String eventId){
        return SpeakerInviteHelper.buildEventInviteTemplate(eventId, null);
    }

    /**
     * @purpose Update email content with custom invite message for preview
     *
     * @param eventId
     * @param message
     * @param sig1
     * @param sig2
     * @param sig3
     * @param sig4
     * @param sig5
     * @param sig6
     *
     * @return Email content string
     */
    @AuraEnabled
    public static Boolean updateEventAndPreview(String eventId, String message, String sig1, String sig2, String sig3, String sig4, String sig5, String sig6){
        System.debug('updateEventAndPreview being called with eventId: ' + eventId + ' and message: ' + message);

        BR_Event__c event = [SELECT Signature_1__c, Signature_2__c, Signature_3__c, Signature_4__c, Signature_5__c, Signature_6__c
        FROM BR_Event__c
        WHERE id=: eventId.escapeHtml4()];
        if(sig1!=null) {
            event.Signature_1__c = sig1;
        }
        if(sig2!=null) {
            event.Signature_2__c = sig2;
        }
        if(sig3!=null) {
            event.Signature_3__c = sig3;
        }
        if(sig4!=null) {
            event.Signature_4__c = sig4;
        }
        if(sig5!=null) {
            event.Signature_5__c = sig5;
        }
        if(sig6!=null) {
            event.Signature_6__c = sig6;
        }

        event.Invite_Message__c = message;

        try{
            update event;

            return true;
//            return SpeakerInviteHelper.buildEventInviteTemplate(eventId, message);
        } catch(Exception e){
            System.debug('Could not update event or update template: ' + e.getMessage());

            return false;
//            return null;
        }

    }




/**
     * @purpose Call batch job to email all invited speakers
     *
     * @param speakerIds, eventIdString
     */
    @AuraEnabled
    public static void sendSpeakerInvitations(String eventIdString, List<String> speakerIds){
        SYstem.debug('STRING: ' + eventIdString);
        SYstem.debug('speakerIds: ' + speakerIds);

        //start email batch to workaround email limit
        database.executeBatch(new Batch_SpeakerInviteEmail(speakerIds, eventIdString), 10);
    }

    /**
     * @purpose Get invite confirmation info - email template content with event info filled in and all selected speakers
     *
     * @param eventId
     *
     * @return InviteConfirmationInfo instance
     */
    @AuraEnabled
    public static List<Session_Speaker__c> getInviteConfirmInfo(String eventId){
        System.debug('getInviteConfirmInfo being called ' + eventId);

        List<Session_Speaker__c> speakers = [SELECT Id, cc_assistant__c, Session__r.Name, Speaker__r.Name, Speaker__r.Email FROM Session_Speaker__c WHERE Session__r.Event__c =: eventId AND Status__c = 'Pending'];

        return speakers;

    }


    /**
     * @purpose Sets all selected speakers to pending status
     *
     * @param speakerString
     *
     * @return true or false if job completed
     */
    @AuraEnabled
    public static Boolean setSpeakersToPending(String speakerString ){
        System.debug('setting speakers to pending: ' + speakerString);
        List<SessionSpeaker> sessionSpeakers = (List<SessionSpeaker>)JSON.deserialize(speakerString, List<SessionSpeaker>.class);
        System.debug('speakers: ' + sessionSpeakers);

        Map<Id, SessionSpeaker> speakerMap = new Map<Id, SessionSpeaker>();
        for(SessionSpeaker ss : sessionSpeakers){
            speakerMap.put(ss.id, ss);
        }
        List<Session_Speaker__c> speakers = [SELECT Id, Name, Assistant__r.Email, Speaker__r.Name, Speaker__c, Session__r.Name FROM Session_Speaker__c WHERE Id IN: speakerMap.keySet()];
        for(Session_Speaker__c speaker : speakers){
            speaker.Status__c = 'Pending';
            if(speakerMap.get(speaker.Id).includeAssistant){
                speaker.cc_assistant__c = true;
            }
        }

        System.debug('speakers: ' + speakers);
        try {
            update speakers;

            return true;
        } catch(Exception e){
            System.debug('Could not update session speakers: ' + e.getMessage());
            return false;
        }
    }


    /**
     * @purpose Retrieve all session speakers for a particular event that have a null or pending status
     *
     * @param eventId
     *
     * @return List of session speakers
     */
    @AuraEnabled
    public static List<SessionSpeaker> getSpeakers(String eventId){
        System.debug('getSpeakers being called ' + eventId);
        List<Session_Speaker__c> speakers = [SELECT Id, Name, Roles__c, Assistant__r.Email, Speaker__r.Email, Speaker__r.Name, Speaker__c, Session__r.Name FROM Session_Speaker__c WHERE Session__r.Event__c=: eventId.escapeHtml4() AND (Status__c = null OR Status__c = 'Pending')];
        System.debug('speakers: ' + speakers);
        List<SessionSpeaker> speakerWrappers = new List<SessionSpeaker>();
        for(Session_Speaker__c speaker : speakers){
            speaker.Status__c = null;
            speaker.cc_assistant__c = false;
            SessionSpeaker sp = new SessionSpeaker(speaker.Speaker__r.Name, speaker.Id, speaker.Name, speaker.Speaker__r.Email, speaker.Roles__c, speaker.Assistant__r.Email);
            speakerWrappers.add(sp);
        }
        update speakers;
        return speakerWrappers;
    }

    /**
    * All initial invite confirmation information
    */
    public class InviteConfirmationInfo{

        @AuraEnabled
        public String templateBody;

        @AuraEnabled
        public List<Session_Speaker__c> speakers;

        public InviteConfirmationInfo(String templateBody, List<Session_Speaker__c> speakers){
            this.templateBody = templateBody;
            this.speakers = speakers;
        }
    }

    /**
     * SessionSpeaker wrapper class
     */
    public class SessionSpeaker{
        @AuraEnabled
        public String name;

        @AuraEnabled
        public String id;

        @AuraEnabled
        public String email;

        @AuraEnabled
        public String presentationName;

        @AuraEnabled
        public String roles;

        @AuraEnabled
        public Boolean sendInvite;

        @AuraEnabled
        public Boolean includeAssistant;

        @AuraEnabled
        public String assistantEmail;

        public SessionSpeaker(String name, String id, String presentationName, String email, String roles, String assistantEmail){
            this.name = name;
            this.id = id;
            this.presentationName = presentationName;
            this.email = email;
            this.roles = roles;
            this.assistantEmail = assistantEmail;
            this.sendInvite = email!=null?true:false;
            this.includeAssistant = email!=null&&assistantEmail!=null?true:false;
        }
    }
}