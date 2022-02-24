/**
 * Created by lauren.lezberg on 6/4/2020.
 */

public class AACRCustomException extends Exception{

    public AACRCustomException(String recordId, String errorMsg, String details, String category){
        try {
            AACR_Error_Log__c ae = ErrorHelper.buildErrorExceptionLog(errorMsg, details);
            ae.Incident_Type__c = category;
            ae.User__c = UserInfo.getUserId();
            insert ae;

            ErrorHelper.sendExceptionEmail(recordId, ae.Id, category, errorMsg, details);

            System.debug('success');
        } catch(Exception e){
            System.debug(e.getMessage() + ' ' + e.getStackTraceString());
        }
    }


    public AACRCustomException(String errorMsg, String details, String category){
        try {
            AACR_Error_Log__c ae = ErrorHelper.buildErrorExceptionLog(errorMsg, details);
            ae.Incident_Type__c = category;
            ae.User__c = UserInfo.getUserId();
            insert ae;

            ErrorHelper.sendExceptionEmail(ae.Id, category, errorMsg, details);

            System.debug('success');
        } catch(Exception e){
            System.debug(e.getMessage() + ' ' + e.getStackTraceString());
        }
    }

}