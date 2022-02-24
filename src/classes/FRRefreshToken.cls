//This class is used to refresh the FluidReview token. 
//It has been moved outside the FluidReview controller to ensure that the updated token is saved 
//as soon as it is received. Any exceptions in FluidReview controller make the tokens stale 
//
public class FRRefreshToken {
	@future(callout=true)
    public static void refreshtoken() {
        Http h;
    	HttpRequest reqAuth;
        HttpResponse resAuth;
        FRSession__c fr_session;
		String apiURL;
    	String payLoad; 
        
        fr_session = FRSession__c.getOrgDefaults();
        apiURL = fr_session.FR_ConnectURL__c;
        h = new Http();
        reqAuth = new HttpRequest();
        
        System.debug('Start Refresh Token');
        // Update token. This assumes the call was made 2 hours ago
        //if (fr_session.FR_LastUpdate__c == null || (fr_session.FR_LastUpdate__c.addHours(2) <= System.now()) ) {                           
            reqAuth.setEndpoint(apiURL + '/api/v2/o/token/');
            reqAuth.setMethod('POST');
            reqAuth.setHeader('Content-Type', 'application/x-www-form-urlencoded');
            reqAuth.setHeader('Authorization', 'Bearer ' + fr_session.FR_AccessToken__c);
        	reqAuth.setHeader('accept', 'text/html');
        
            payLoad = 'grant_type=' + EncodingUtil.urlEncode('refresh_token', 'UTF-8') +
                	   '&client_id=' + EncodingUtil.urlEncode(fr_session.FR_ClientID__c, 'UTF-8') +
                	   '&client_secret=' + EncodingUtil.urlEncode(fr_session.FR_ClientSecret__c, 'UTF-8')+
                		'&refresh_token=' + EncodingUtil.urlEncode(fr_session.FR_RefreshToken__c, 'UTF-8');
            reqAuth.setBody(payLoad);
        	System.debug('payload = ' + payLoad);              
        	try{
                resAuth= h.send(reqAuth);
                System.debug('Response body received = ' + resAuth.getBody());
                System.debug('Response status received = ' + resAuth.getStatus());
                if (resAuth.getStatusCode() == 200){
                    // Deserialize the JSON string into collections of primitive data types.
                    Map<String, Object> result2 = (Map<String, Object>) JSON.deserializeUntyped(resAuth.getBody());
                    fr_session.FR_RefreshToken__c =  (String)result2.get('refresh_token');
                    fr_session.FR_AccessToken__c =  (String)result2.get('access_token'); 
                    fr_session.FR_LastUpdate__c = System.now();
                    update fr_session;
                    System.debug('Frsession updated');
                }
                if (resAuth.getStatusCode() == 401 && resAuth.getStatus() == 'Unauthorized') {   
                    throw new FluidReviewException('Please generate new access token credentials');
                }
            }
        catch(Exception e){
            System.debug('Exception block');
            System.debug(e.getMessage());
            System.debug(e.getLineNumber());
            System.debug(e.getStackTraceString());
            //Enable when Email Deliverability set
            List<ApexEmailNotification> apList = [SELECT  Email, user.email from ApexEmailNotification];
            String[] toAddresses = new String[apList.size()];
                Integer count = 0;
            for (ApexEmailNotification ap : apList){
                if (ap.Email != null)
                    toAddresses[count] = ap.Email;
                else{
                    toAddresses[count] = ap.User.Email;
                }
                count++;
            }
            
            Messaging.SingleEmailMessage mail=new Messaging.SingleEmailMessage();
            
            mail.setToAddresses(toAddresses);            
            mail.setSenderDisplayName('Apex error message ');
            mail.setSubject('FluidReview Connection Error from Org : ' + UserInfo.getOrganizationName() + UserInfo.getUserId());
            mail.setPlainTextBody('Error message: ' + e.getMessage() + 'Stack Trace: '+ e.getStackTraceString() + 'Line No.: ' + e.getLineNumber());
            
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });   
        }

                    
    }
}