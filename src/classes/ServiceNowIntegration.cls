/**
 * Created by afaf.awad on 8/17/2021.
 */

public without sharing class ServiceNowIntegration {

    public static void sendSNCase(Id logId, Id attachmentId) {
        System.debug('sendSNCase...');

        Id targetId = UserInfo.getUserId();
        System.debug('targetId: ' + targetId);

        AACR_Error_Log__c log = [SELECT Issue_Description__c, URL__c, CreatedDate, Contact_Name__c, Contact_Email__c, Contact_Phone__c, Contact_Method__c, Contact__c, Contact__r.Name, Contact__r.AACR_ID__c, Contact__r.Member_Type__c, Affiliation__c, Incident_Type__c, Incident_Id__c, Name FROM AACR_Error_Log__c WHERE Id = :logId];

        if (targetId != null) {
            try {
                callServiceNowApi(log, attachmentId);
            } catch (EmailException ex) {
                System.debug('error creating case in Service Now: ' + ex.getMessage());
            }
        }
    }

    public static void callServiceNowApi(AACR_Error_Log__c errorLog, Id attachmentId){
        ServiceNow__c serviceNow = ServiceNow__c.getOrgDefaults();

        try {
            Http http = new Http();
            HttpRequest req = new HttpRequest();

            Blob headerValue = Blob.valueOf(serviceNow.Username__c + ':' + serviceNow.Password__c);
            String authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(headerValue);

            req.setMethod('POST');
            req.setEndpoint(serviceNow.Host__c + '/table/sn_customerservice_case');
            req.setHeader('Authorization', authorizationHeader);
            req.setHeader('Content-Type', 'application/json');
            req.setBody(buildRequestBody(errorLog));

            HttpResponse res = http.send(req);
            System.debug(res.getBody());
            System.debug('statusCode == ' + res.getStatusCode());
            ServiceNow2Apex snObj = ServiceNow2Apex.parse(res.getBody());
            if ( res.getStatusCode() == 201 ) {
                System.debug('success!');
                ServiceNow2Apex.Result result = snObj.result;

                if(attachmentId !=null){
                    postAttachmentToCase(attachmentId, result.sys_id);
                }

                ServiceNow_Case__c snc = new ServiceNow_Case__c();
                snc.Name = result.number_Z;
                snc.Contact__c = result.u_salesforce_ref;
                snc.Description__c = result.description;
                snc.Open_Date__c = Date.valueOf(result.opened_at.left(10));
                snc.Is_Active__c = Boolean.valueOf(result.active);
                snc.Short_Description__c = result.short_description;
                snc.System_Id__c = result.sys_id;
                System.debug('snc== ' + snc);
                insert snc;
                delete errorLog;

            } else {
                System.debug('Error: ' + res.getBody());
                System.debug('ErrorCode: ' + res.getStatusCode());
            }
        }catch(Exception ex){
            System.debug('Error calling Service API: ' + ex.getMessage());
        }
    }

    public static String buildRequestBody(AACR_Error_Log__c log){

        //Build JSON Body
        JSONGenerator gen = JSON.createGenerator(true);
        gen.writeStartObject();
        gen.writeStringField('u_salesforce_ref' , log.Contact__c != null ? log.Contact__c: '');
        gen.writeStringField('u_external_user_full_name' , log.Contact_Name__c != null ? log.Contact_Name__c: '');
        gen.writeStringField('u_external_phone_number' , log.Contact_Phone__c != null ? log.Contact_Phone__c : '');
        gen.writeStringField('u_external_user_s_email' , log.Contact_Email__c!=null?log.Contact_Email__c:'');
        gen.writeStringField('u_preferred_contact_method' , log.Contact_Method__c != null ? log.Contact_Method__c:'');
        gen.writeStringField('u_membership_id' , log.Contact__c != null ? log.Contact__r.AACR_ID__c : '');
        gen.writeStringField('short_description' , log.Incident_Type__c!=null?log.Incident_Type__c:'');
        gen.writeStringField('description' , log.Issue_Description__c!=null?log.Issue_Description__c:'');
        gen.writeStringField('u_reference_page_url' , log.URL__c!=null?log.URL__c:'');
        gen.writeStringField('u_salesforce_error_log' , log.Id);
        gen.writeEndObject();

        return gen.getAsString();

    }

    public static void postAttachmentToCase(Id attachmentId, String caseSysId){
        ServiceNow__c serviceNow = ServiceNow__c.getOrgDefaults();

        try{
            ContentVersion cv = [SELECT Id, VersionData, Title, PathOnClient, Description, FileType FROM ContentVersion WHERE Id =: attachmentId];
            Http http = new Http();
            HttpRequest req = new HttpRequest();

            Blob headerValue = Blob.valueOf(serviceNow.Username__c + ':' + serviceNow.Password__c);
            String authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(headerValue);


            req.setMethod('POST');
            req.setEndpoint(serviceNow.Host__c + '/attachment/file?table_name=sn_customerservice_case&table_sys_id=' + caseSysId + '&file_name=' + cv.Title.replace(' ', '_'));
            req.setHeader('Authorization', authorizationHeader);
            req.setHeader('Accept', 'application/json');
            req.setHeader('Content-Type', cv.FileType);
            req.setBodyAsBlob(cv.VersionData);

            HttpResponse res = http.send(req);
            System.debug(res.getBody());
            System.debug('statusCode == ' + res.getStatusCode());
            System.debug('get error == ' + res.getStatus());
        }catch(Exception ex){
            System.debug('Error calling Service API: ' + ex.getMessage());
        }
    }


//
//    public static void getSNCases(){
//        Service_Now__c serviceNow = Service_Now__c.getOrgDefaults();
//
//        try {
//            Http http = new Http();
//            HttpRequest req = new HttpRequest();
//
//            Blob headerValue = Blob.valueOf(serviceNow.Username__c + ':' + serviceNow.Password__c);
//            String authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(headerValue);
//
//            req.setMethod('GET');
//            req.setEndpoint(serviceNow.Host__c + '/table/sn_customerservice_case');
//            req.setHeader('Authorization', authorizationHeader);
//            req.setHeader('Content-Type', 'application/json');
////            req.setBody(buildRequestBody(errorLog));
//
//            HttpResponse res = http.send(req);
//            System.debug(res.getBody());
//            System.debug('statusCode == ' + res.getStatusCode());
//
//            if ( res.getStatusCode() == 200 ) {
//                System.debug('success!');
//                ServiceNow2ApexArray snObj = ServiceNow2ApexArray.parse(res.getBody());
//                System.debug('snObj: ' + snObj.Result);
//
//                Set<ServiceNow_Case__c> sncSet = new Set<ServiceNow_Case__c>(); //to avoid dups in list so we can upsert without duplicate error
//                for(ServiceNow2ApexArray.Result result: snObj.Result){
//                    if(result.u_salesforce_ref != null) {
//                        if (result.u_salesforce_ref.left(3) == '003') {
//                                ServiceNow_Case__c snc = new ServiceNow_Case__c();
//                                snc.Name = result.number_Z;
//                                snc.Contact__c = result.u_salesforce_ref;
//                                snc.Description__c = result.description;
//                                snc.Due_Date__c = Date.valueOf(result.due_date.left(10));
//                                snc.Is_Active__c = Boolean.valueOf(result.active);
//                                snc.Short_Description__c = result.short_description;
//                                snc.System_Id__c = result.sys_id;
//                                snc.Open_Date__c = Date.valueOf(result.opened_at.left(10));
//                                System.debug('snc== ' + snc);
//                                sncSet.add(snc);
//                        }
//                    }
//                }
//                List<ServiceNow_Case__c> sncList = new List<ServiceNow_Case__c>();
//                sncList.addAll(sncSet);
//                upsert sncList System_Id__c;
//
//            } else {
//                System.debug('Error: ' + res.getBody());
//                System.debug('ErrorCode: ' + res.getStatusCode());
//            }
//        }catch(Exception ex){
//            System.debug('Error calling Service API: ' + ex.getMessage());
//        }
//    }

}