/**
 * Created by lauren.lezberg on 9/25/2020.
 */

public with sharing class ResendConfirmationEmailController {

    @AuraEnabled
    public static void resendEmail(String participantId, String ccJSON){
        List<String> ccEmails = (List<String>)JSON.deserialize(ccJSON, List<String>.class);

        List<BR_Participation__c> participations = new List<BR_Participation__c>();
        participations = [SELECT Id FROM BR_Participation__c WHERE Id=:participantId];
        if(!participations.isEmpty()) {
            LiveEventsHelper.sendRegistrationConfirmationEmail(participations,ccEmails);
        }
    }

}