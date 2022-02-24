/**
 * Created by lauren.lezberg on 1/16/2019.
 */
 
public with sharing class JP_ScientificInterestsController {

    /**
     * @purpose Gets all scientific interest picklist field values and any selected values
     *
     * @return scientificInterestData wrapper objects
     */
    @AuraEnabled
    public static scientificInterestData getScientificInterestData(Id stepId){
        List<String> majorFocus = ECRMUtils.getPicklistValues('Contact', 'Major_Focus__c');
        List<String> organSites = ECRMUtils.getPicklistValues('Contact', 'Organ_Sites__c');
        List<String> specificResearch = ECRMUtils.getPicklistValues('Contact', 'Specific_Research_Areas__c');
        List<String> addResearch = ECRMUtils.getPicklistValues('Contact', 'Additional_Research_Areas__c');
        List<String> primaryResearch = ECRMUtils.getPicklistValues('Contact', 'Primary_Research_Area_of_Expertise__c');
        JP_Helper.upsertLastAccessedStep(stepId);
        return new scientificInterestData(majorFocus, organSites, specificResearch, addResearch, primaryResearch, ECRMUtils.getCurrentLoginContact());

    }


    /**
     * @purpose Update contact with scientific interest selections from JP_ScientificInterests lighting component
     *
     * @param con
     * @param stepId
     *
     * @return True or false if the contact was updated
     */
    @AuraEnabled
    public static Boolean updateContactRecord(Contact con){
        try{
            update con;
            return true;
        } catch(DmlException e){
            System.debug('Error updating contact: ' + e.getMessage());
            return false;
        }
    }

    /*
    * scientificInterestData wrapper objects
     */
    public class scientificInterestData{
        @AuraEnabled
        public List<String> majorFocusOptions;

        @AuraEnabled
        public List<String> organSiteOptions;

        @AuraEnabled
        public List<String> specificResearchOptions;

        @AuraEnabled
        public List<String> addResearchOptions;

        @AuraEnabled
        public List<String> primaryResearchOptions;

        @AuraEnabled
        public Contact currentContact;


        public scientificInterestData(List<String> majorFocus, List<String> organSite, List<String> specificResearch, List<String> additionalResearch,List<String> primaryResearch, Contact con){
            this.majorFocusOptions = majorFocus;
            this.organSiteOptions = organSite;
            this.specificResearchOptions = specificResearch;
            this.addResearchOptions = additionalResearch;
            this.primaryResearchOptions = primaryResearch;
            this.currentContact = con;
        }
    }


}