/*
    DW_QualifyingQuestionsController - v1.0	
    Description: Page controller to Step Page of Become Member Wizard to gather Professional Information, 
    Scientific Research & Educational Information. Serves remote method to fetch & save above data along with User Contact data.	
    Author: Ajit
    CreatedDate: 07/31/2018
    LastModifiedDate: 07/31/2018
*/

global class DW_QualifyingQuestionsController extends PagesApi.DefaultTemplateController {
    public DW_QualifyingQuestionsController () {}
    
    @RemoteAction
    public static DW_DTO.Response getQualifyingQuestionsData(String stepId) {
    	DW_DTO.Response response = new DW_DTO.Response();
        
        try {
            response.Data = DW_QualifyingQuestionsHelper.getCurrentUserContact();
            response.Message = 'User Contact Data & Page Metadata';
            response.Success = true;
            response.Metadata = DW_QualifyingQuestionsHelper.getPageMetadata(stepId);
            System.debug('response==>'+response);
        } catch (Exception ex) {  
            System.debug('exp==>'+ex.getStackTraceString());
             System.debug('exp==>'+ex.getMessage());
        	response.Message = ex.getMessage();    
        }
        
        return response;
    }
    
    @RemoteAction
    public static DW_DTO.Response saveUserContactData( String strUserContactData, String stepId ) {
        DW_DTO.UserContactData userContactData = ( DW_DTO.UserContactData ) JSON.deserialize( strUserContactData, DW_DTO.UserContactData.class );
        DW_DTO.Response response = new DW_DTO.Response();
        // Updating user contact last accessed step
        DW_ECRMUtils.upsertContLastAccessedStep( stepId );
        try {
            DW_QualifyingQuestionsHelper.saveUserContactData( userContactData );
            response.Success = true;
            response.Message = 'User contact data updated successfully';
            //update last accessed step order in junction object for progress bar functionality
        } catch (Exception ex) {   
        	response.Message = ex.getMessage();    
        }
        System.debug('response==>'+response);
        return response;
    }
}