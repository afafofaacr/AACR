/**
 * Created by lauren.lezberg on 1/14/2020.
 */

public with sharing class ChairPersonsController {

    /**
     * @purpose Delete selected chair person
     * @param cpId
     */
    @AuraEnabled
    public static void deleteChairperson(String cpId){
        if(cpId!=null) {
            Session_Speaker__c speaker = [SELECT Id FROM Session_Speaker__c WHERE Id = :cpId];

            try {
                delete speaker;
            } catch (Exception e) {
                System.debug('could not delete chairperson: ' + e.getMessage());
                throw new AACRCustomException(cpId, e.getMessage(), e.getStackTraceString(), 'Chair Person');
            }
        }
    }

    /**
     * @purpose Retrieve all chair persons for an event
     *
     * @param eventId
     *
     * @return Chair Persons data instance with list of chair persons 
     */
    @AuraEnabled
    public static ChairPersonsData getChairPersonsData(String eventId){
        if(String.isBlank(eventId)){
            new AACRCustomException('Event Id is null', 'ChairPersonsController.getChairPersonsData', 'Chair Person');
            return null;
        }

        ChairPersonsData cpd = new ChairPersonsData();
        cpd.persons = [SELECT Speaker__r.Name,Use_for_Invite__c, Speaker__c, Roles__c, Status__c, Assistant__c, Assistant__r.Name FROM Session_Speaker__c WHERE Event__c=: eventId AND RecordType.Name='Chair Person'];
        cpd.cpRecordTypeId = Schema.SObjectType.Session_Speaker__c.getRecordTypeInfosByName().get('Chair Person').getRecordTypeId();
        return cpd;
    }

    public class ChairPersonsData{
        @AuraEnabled
        public List<Session_Speaker__c> persons;

        @AuraEnabled
        public String cpRecordTypeId;

    }

}