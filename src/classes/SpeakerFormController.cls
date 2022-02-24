/**
 * Created by lauren.lezberg on 1/23/2020.
 */

public with sharing class SpeakerFormController {


    /**
     * @purpose Get assistants for contact record
     *
     * @param contactId
     *
     * @return List of assistants
     */
    @AuraEnabled
    public static List<npe4__Relationship__c> getAssistants(String contactId){
        System.debug('getting assistants for contact: ' + contactId);
        List<npe4__Relationship__c> assistants= [SELECT npe4__RelatedContact__c, npe4__RelatedContact__r.Name FROM npe4__Relationship__c WHERE npe4__Contact__c=: contactId AND npe4__Type__c='Assistant' AND npe4__Status__c='Current' ORDER BY LastModifiedDate];
        System.debug('assistants: ' + assistants);
        if(!assistants.isEmpty()){
            return assistants;
        }
        return null;
    }
}