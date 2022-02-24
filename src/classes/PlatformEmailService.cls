/**
 * Created by afaf.awad on 10/20/2020.
 */

public without sharing class PlatformEmailService {
    
    public static Boolean callSendGridAPI(Map<String, String> emailMap, String subject, String fromEmail, String fromWho, String replyTo, String emailContent){
        System.debug('Emailing with SendGrid API...');

        Send_Grid__c sendGrid = Send_Grid__c.getOrgDefaults();
        
        HttpRequest req = new HttpRequest();
        req.setMethod('POST');
        req.setEndpoint(sendGrid.url__c + '/mail/send');
        req.setHeader('Content-Type','application/json');
        req.setHeader('authorization','Bearer ' + sendGrid.API_key__c);
        req.setBody(jsonGenerator(emailMap,subject,fromEmail, fromWho,replyTo,emailContent));

        Boolean emailSent = false;
        try {
            if(!Test.isRunningTest()) {
                Http http = new Http();
                HttpResponse res = http.send(req);
                System.debug(res.getBody());
            }
            emailSent = true;
        }catch (AACRCustomException e){
            System.debug('Error on PlaformEmailService: Line number ====> '+ e.getLineNumber() + '--- Exception Message =====> ' + e.getMessage());
            throw new AACRCustomException(e.getMessage(), e.getStackTraceString(), 'Platform Email Service');
        }

        return emailSent;
    }

    public static String jsonGenerator(Map<String, String> emailMap, String subject, String fromEmail, String fromWho, String replyTo, String content){

        String strJson = '';

            try {
                // Create a JSONGenerator object
                JSONGenerator jsGen = JSON.createGenerator(true);
                // start object ({)
                jsGen.writeStartObject();
                jsGen.writeFieldName('personalizations');
                jsGen.writeStartArray();
                for(String email: emailMap.keySet()) {
                    jsGen.writeStartObject();
                    jsGen.writeFieldName('to');
                    jsGen.writeStartArray();
                    jsGen.writeStartObject();
                    jsGen.writeStringField('email', email);
                    jsGen.writeStringField('name', emailMap.get(email));
                    jsGen.writeEndObject();
                    jsGen.writeEndArray();
                    jsGen.writeStringField('subject', subject);
                    jsGen.writeEndObject();
                }
                jsGen.writeEndArray();
                jsGen.writeFieldName('content');
                jsGen.writeStartArray();
                jsGen.writeStartObject();
                jsGen.writeStringField('type', 'text/plain' );
                jsGen.writeStringField('value', content );
                jsGen.writeEndObject();
                jsGen.writeStartObject();
                jsGen.writeStringField('type', 'text/html' );
                jsGen.writeStringField('value', content );
                jsGen.writeEndObject();
                jsGen.writeEndArray();
                jsGen.writeFieldName('from');
                jsGen.writeStartObject();
                jsGen.writeStringField('email', fromEmail );
                jsGen.writeStringField('name', fromWho );
                jsGen.writeEndObject();
                jsGen.writeFieldName('reply_to');
                jsGen.writeStartObject();
                jsGen.writeStringField('email', replyTo );
                jsGen.writeStringField('name', 'AACR' );
                jsGen.writeEndObject();
                jsGen.writeEndObject();

                strJson = jsGen.getAsString();
//                System.debug('JSON String :: ' + strJson);
            }
            catch(Exception e) {
                System.debug('Line number ====> '+e.getLineNumber() + 'Exception Message =====> '+e.getMessage());
            }

        if(!String.isBlank(strJson)) {
            return strJson;
        }
        else {
            return null;
        }

    }

}