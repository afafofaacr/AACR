public class DW_EducationInformationHelper { 
	public static DW_ECRMDTO.EducationInfoDTO getPageMetadata( String stepId ) {
        DW_ECRMDTO.EducationInfoDTO pageMeta = new DW_ECRMDTO.EducationInfoDTO();
        String contactId = DW_ECRMUtils.getCurrentLoginUserContactId();
        // Populate Picklist Maps
        pageMeta.AcademicDegreeMap = DW_ECRMUtils.getPicklistEntries('Education__c', 'Degree__c');
        pageMeta.EducationStatusMap = DW_ECRMUtils.getPicklistEntries( 'Education__c', 'Current_Education_Status__c' );
		// Populate Redirect URL's
		pageMeta.NextStepURL = DW_EducationInformationHelper.getNextStepURL(stepId);
        pageMeta.PreviousStepURL = DW_EducationInformationHelper.getPreviousStepURL(stepId);
        pageMeta.CancelStepURL = DW_EducationInformationHelper.getCancelStepURL(stepId);
        // Fetch Related Educations Data
        pageMeta.Educations = DW_EducationInformationHelper.getEducationRelatedList( contactId );
        pageMeta.contactId = contactId;
        return pageMeta;
    }

    public static List<Education__c> getEducationRelatedList( String contactId ) {
    	List<Education__c> educations = new List<Education__c>();
    	educations = [SELECT Id, Name, Current_Education_Status__c, Date_of_Expected_Graduation__c,
                                      Degree__c, Degree_Completion_Year__c, Education_Related_to_Contact__c
                                      FROM Education__c 
                                      WHERE Education_Related_to_Contact__c = :contactId];
        return educations;
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

    public static void saveEducationInformation( DW_ECRMDTO.EducationInfoDTO educationInfo ) {
            
        // Delete Educations
        if (!educationInfo.DeletedEducationIdList.isEmpty()) {
         	List<Education__c> deletedEducationList = [SELECT Id FROM Education__c WHERE Id IN :educationInfo.DeletedEducationIdList];
            DELETE deletedEducationList;
        }        
        
        // Upsert Contact's Educations Data
        if (!educationInfo.Educations.isEmpty()) {
            UPSERT educationInfo.Educations;
        }
    }
}