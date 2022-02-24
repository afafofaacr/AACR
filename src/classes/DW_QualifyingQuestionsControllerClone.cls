/*
    DW_QualifyingQuestionsControllerClone - v1.0    
    Description: Page controller to Step Page of Become Member Wizard to gather Professional Information, 
    Scientific Research & Educational Information. Serves remote method to fetch & save above data along with User Contact data.    
    Author: Ajit
    CreatedDate: 07/31/2018
    LastModifiedDate: 07/31/2018
*/

global class DW_QualifyingQuestionsControllerClone extends PagesApi.DefaultTemplateController {
    public DW_QualifyingQuestionsControllerClone () {}
    
    @RemoteAction
    public static DW_DTOClone.Response getQualifyingQuestionsData(String stepId) {
        DW_DTOClone.Response response = new DW_DTOClone.Response();
        
        try {
            response.Data = DW_QualifyingQuestionsHelperClone.getCurrentUserContact();
            response.Message = 'User Contact Data & Page Metadata';
            response.Success = true;
            response.Metadata = DW_QualifyingQuestionsHelperClone.getPageMetadata(stepId);
            System.debug('response==>'+response);
        } catch (Exception ex) {  
            System.debug('exp==>'+ex.getStackTraceString());
             System.debug('exp==>'+ex.getMessage());
            response.Message = ex.getMessage();    
        }
        
        return response;
    }
    
    @RemoteAction
    public static DW_DTOClone.Response saveUserContactData( String strUserContactData, String stepId ) {
        DW_DTOClone.UserContactData userContactData = ( DW_DTOClone.UserContactData ) JSON.deserialize( strUserContactData, DW_DTOClone.UserContactData.class );
        DW_DTOClone.Response response = new DW_DTOClone.Response();
        //update last accessed step order in junction object for progress bar functionality
        DW_ECRMUtils.upsertContLastAccessedStep( stepId );
        try {
            DW_QualifyingQuestionsHelperClone.saveUserContactData( userContactData, stepId );
            response.Success = true;
            response.Message = 'User contact data updated successfully';
            
			//set cookies required for navigation
            /*System.debug( 'stepId:::'+stepId );
            joinApi.JoinUtils joinUtil = new joinApi.JoinUtils(stepId);
            JSONGenerator gen = JSON.createGenerator(true);
            gen.writeStartObject();
            gen.writeStringField('stepId', stepId);
            String redirectURL = joinUtil.navStepsMap.get('Next');
            system.debug('===redirectURL '+redirectURL);
            gen.writeStringField('redirectURL', redirectURL);
            gen.writeEndObject();
            system.debug('gen='+gen);
            
            try{
                if(gen.getAsString()!=null) {
                    system.debug('in st cookie='+gen.getAsString());
                    joinUtil.setRedirectURLCookie(gen.getAsString());
                }
            }
            catch(Exception e){system.debug('====exception in navigation code'+e);}
            return new PageReference(redirectURL);*/
            
        } catch (Exception ex) {   
            response.Message = ex.getMessage();    
        }
        System.debug('response==>'+response);
        return response;
    }
}