/*
    DW_QualifyingQuestionsHelperClone - v1.0    
    Description: Helper class for Page controller DW_QualifyingQuestionsController    
    Author: Ajit
    CreatedDate: 07/31/2018
    LastModifiedDate: 07/31/2018
*/

public class DW_QualifyingQuestionsHelperClone {
    public static QualifyingQuestionsPageDTO getPageMetadata(String stepId) {
        QualifyingQuestionsPageDTO pageMeta = new QualifyingQuestionsPageDTO();
        
        // Populate all Contact Object Picklist Maps
        pageMeta.MajorFocusMap = DW_ECRMUtils.getPicklistEntries('Contact', 'Major_Focus__c');
        pageMeta.OrganSiteMap = DW_ECRMUtils.getPicklistEntries('Contact', 'Organ_Sites__c');
        pageMeta.PrimaryResearchAreaMap = DW_ECRMUtils.getPicklistEntries('Contact', 'Primary_Research_Area_of_Expertise__c');
        pageMeta.SpecificResearchAreaMap = DW_ECRMUtils.getPicklistEntries('Contact', 'Specific_Research_Areas__c');
        pageMeta.AdditionalResearchAreaMap = DW_ECRMUtils.getPicklistEntries('Contact', 'Additional_Research_Areas__c');

        // Populate Redirect URL's
        pageMeta.NextStepURL = DW_QualifyingQuestionsHelperClone.getNextStepURL(stepId);
        pageMeta.PreviousStepURL = DW_QualifyingQuestionsHelperClone.getPreviousStepURL(stepId);
        pageMeta.CancelStepURL = DW_QualifyingQuestionsHelperClone.getCancelStepURL(stepId);
        
        return pageMeta;
    }
    
    public static DW_DTOClone.UserContactData getCurrentUserContact() {
        DW_DTOClone.UserContactData userContactData = new DW_DTOClone.UserContactData();
        
        // Fetch Contact Data
        userContactData.Contact = [SELECT Id, Name, AccountId, Account.Name, Phone, Fax,
                                   Major_Focus__c, Organ_Sites__c, Primary_Research_Area_of_Expertise__c, 
                                   Specific_Research_Areas__c, Additional_Research_Areas__c, Other_Research_Areas__c
                                   FROM Contact 
                                   WHERE Id IN (SELECT ContactId FROM User WHERE Id = :UserInfo.getUserId())];
            
        return userContactData;
    }
    
    public static String getNextStepURL(String currentStepId) {
        return new joinApi.JoinUtils(currentStepId).navStepsMap.get('Next');
    }
    
    public static String getPreviousStepURL(String currentStepId) {
        return new joinApi.JoinUtils(currentStepId).navStepsMap.get('Previous');
    }
    
    public static String getCancelStepURL(String currentStepId) {
        return new joinApi.JoinUtils(currentStepId).navStepsMap.get('First');
    }
    
    public static void saveUserContactData(DW_DTOClone.UserContactData userContactData, String stepId) {
        // Update User Contact
        UPDATE userContactData.Contact;       
    }
    
    public class QualifyingQuestionsPageDTO {
        public String PreviousStepURL;
        
        public String NextStepURL;
        
        public String CancelStepURL;
        
        public Map<String, String> MajorFocusMap;
        
        public Map<String, String> OrganSiteMap;
        
        public Map<String, String> PrimaryResearchAreaMap;
        
        public Map<String, String> SpecificResearchAreaMap;
        
        public Map<String, String> AdditionalResearchAreaMap;
    }
}