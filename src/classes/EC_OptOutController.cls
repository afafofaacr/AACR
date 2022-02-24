/**
 * Created by afaf.awad on 3/31/2021.
 */

public without sharing class EC_OptOutController {

    @AuraEnabled
    public static Boolean optOutOfEmails(String eventId, String emailString){
        List<BR_Participation__c> parts = [SELECT Id, GDPR_Certification__c, Contact__r.Name FROM BR_Participation__c
        WHERE BR_Event__c=: eventId
        AND (User__r.Email =: emailString OR Contact__r.Email =: emailString)];

        System.debug('parts before = ' + parts);
        if(!parts.isEmpty()) {
            for (BR_Participation__c p : parts) {
                p.GDPR_Certification__c = false;
            }

            System.debug('parts after = ' + parts);

            try {
                update parts;
                return true;
            } catch (Exception e) {
                System.debug('Could not opt out of emails: ' + e.getMessage());
                return false;
            }
        }else{
            return null;
        }
    }
}