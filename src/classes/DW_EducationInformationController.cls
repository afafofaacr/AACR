public class DW_EducationInformationController extends PagesApi.DefaultTemplateController {
    public DW_EducationInformationController() {}

    @RemoteAction
    public static DW_ECRMDTO.Response getEducationInformation( String stepId ) {
    	DW_ECRMDTO.Response response = new DW_ECRMDTO.Response();
        
        try {
            response.data = DW_EducationInformationHelper.getPageMetadata( stepId );
            response.message = 'User Contact Data & Page Metadata';
            response.isSuccess = true;
            System.debug('response==>'+response);
        } catch (Exception ex) {  
            System.debug('exp==>'+ex.getStackTraceString());
             System.debug('exp==>'+ex.getMessage());
        	response.message = ex.getMessage();    
        }
        
        return response;
    }

    @RemoteAction
    public static DW_ECRMDTO.Response saveEducationInformation( String strEducationInfo, String stepId ) {
        DW_ECRMDTO.EducationInfoDTO educationInfo = ( DW_ECRMDTO.EducationInfoDTO ) JSON.deserialize( strEducationInfo, DW_ECRMDTO.EducationInfoDTO.class );
        DW_ECRMDTO.Response response = new DW_ECRMDTO.Response();
        // Updating user contact last accessed step
        DW_ECRMUtils.upsertContLastAccessedStep( stepId );
        try {
            DW_EducationInformationHelper.saveEducationInformation( educationInfo );
            response.isSuccess = true;
            response.message = 'User education information updated successfully';
            //update last accessed step order in junction object for progress bar functionality
        } catch (Exception ex) {   
        	response.Message = ex.getMessage();    
        }
        System.debug('response==>'+response);
        return response;
    }
}