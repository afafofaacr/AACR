/**
 * Created by lauren.lezberg on 3/18/2020.
 */

public with sharing class SpeakerInviteEmailPreviewController {

    @AuraEnabled
    public static String getEmailTemplateBody(String eventId){
        return SpeakerInviteHelper.buildEventInviteTemplate(eventId, null);
    }

}