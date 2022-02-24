/**
 * Created by lauren.lezberg on 3/4/2021.
 */

public with sharing class vFairsHelper {



    /**
         * @purpose Retrieve vFairs API key from custom setting
         * @return vFairs API key
         */
    private static String get_vFairsKey() {
        vFairs_Session__c vSession = vFairs_Session__c.getOrgDefaults();
        return vSession.API_Key__c;
    }

    public class vFairsAttendee{
        public String email;
        public String first_name;
        public String middle_name;
        public String last_name;
        public String user_type_id = '8';
        public String title;
        public String work_phone;
        public String mobile_phone;
        public String highest_degree;
        public String research_area_of_expertise;
        public String major_focus;
        public String current_education_status;
        public String resume;
    }

    public class vFairsAttendeeUpdate{
        public String first_name;
        public String middle_name;
        public String last_name;
        public String user_type_id = '8';
        public String title;
        public String work_phone;
        public String mobile_phone;
        public String highest_degree;
        public String research_area_of_expertise;
        public String major_focus;
        public String current_education_status;
    }


    public static void updateAttendee(String participantId) {
        BR_Participation__c participant = [
                SELECT Id, External_Attendee_Id__c, User__r.Email, Contact__r.FirstName, Contact__r.Title,
                        Contact__r.OrderApi__Work_Phone__c, Contact__r.MobilePhone, Contact__r.Highest_Degree__c,
                        Contact__r.Primary_Research_Area_of_Expertise__c, Contact__r.Major_Focus__c,
                        Contact__r.Current_Education_Status__c,Contact__r.LastName, Contact__r.MiddleName,
                        Contact__r.OrderApi__Preferred_Email__c
                FROM BR_Participation__c
                WHERE Id = :participantId AND Participate__c = 'Yes' ORDER BY CreatedDate DESC LIMIT 1
        ];

        Http h = new Http();
        HttpResponse res = new HttpResponse();
        HttpRequest req = new HttpRequest();
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/json');
        String endpoint = 'https://api.vfairs.com/v12/users?access_key=' + get_vFairsKey() + '&user_id=' + participant.External_Attendee_Id__c;
        req.setEndpoint(endpoint);

        vFairsAttendeeUpdate attData = new vFairsAttendeeUpdate();
        attData.first_name = participant.Contact__r.FirstName;
        attData.last_name = participant.Contact__r.LastName;
        attData.middle_name = participant.Contact__r.MiddleName!=null?participant.Contact__r.MiddleName:null;
        attData.title = participant.Contact__r.Title!=null?participant.Contact__r.Title:null;
        attData.work_phone = participant.Contact__r.OrderApi__Work_Phone__c!=null?participant.Contact__r.OrderApi__Work_Phone__c:null;
        attData.mobile_phone = participant.Contact__r.MobilePhone!=null?participant.Contact__r.MobilePhone:null;
        attData.highest_degree = participant.Contact__r.Highest_Degree__c!=null?participant.Contact__r.Highest_Degree__c:null;
        attData.research_area_of_expertise = participant.Contact__r.Primary_Research_Area_of_Expertise__c!=null?participant.Contact__r.Primary_Research_Area_of_Expertise__c:null;
        attData.major_focus = participant.Contact__r.Major_Focus__c!=null?participant.Contact__r.Major_Focus__c:null;
        attData.current_education_status = participant.Contact__r.Current_Education_Status__c!=null?participant.Contact__r.Current_Education_Status__c:null;


        String payload = JSON.serialize(attData);

        System.debug('payload: ' + payload);
        req.setBody(payload);

        res = h.send(req);
        System.debug('create attendee response: ' + res);
        Object jsonParse = (Object) JSON.deserializeUntyped(res.getBody());
        Map<String, Object> mp_StrObj = (Map<string, Object>) jsonParse;
        System.debug('objectMap: ' + mp_StrObj);
        if (res.getStatusCode() != 200) {
//            errorMsg = 'Unknown Error';
            System.debug('unknown error');
            new AACRCustomException(participantId, 'Callout Error', String.valueOf(mp_StrObj.get('error')), 'vFairs Update Attendee');
        }


    }




    @Future(callout=true)
    public static void insertAttendee(String participantId) {
        System.debug('insert vFairs attendee');
        BR_Participation__c participant = [
                SELECT Id, External_Attendee_Id__c, User__r.Email, Contact__r.FirstName, Contact__r.Title,
                        Contact__r.OrderApi__Work_Phone__c, Contact__r.MobilePhone, Contact__r.Highest_Degree__c,
                        Contact__r.Primary_Research_Area_of_Expertise__c, Contact__r.Major_Focus__c,
                        Contact__r.Current_Education_Status__c,Contact__r.LastName, Contact__r.MiddleName,
                        Contact__r.OrderApi__Preferred_Email__c
                FROM BR_Participation__c
                WHERE Id = :participantId
        ];



        List<ContentDocumentLink> contactFiles = [SELECT ContentDocumentId, ContentDocument.LatestPublishedVersionId, ContentDocument.Title, LinkedEntityId
        FROM ContentDocumentLink WHERE LinkedEntityId =: participant.Contact__c ANd ContentDocument.Title LIKE '%Resume%' ORDER BY SystemModstamp DESC];

        List<ContentDistribution> distributions = [Select Id, DistributionPublicUrl from ContentDistribution WHERE ContentVersionId =: contactFiles[0].ContentDocument.LatestPublishedVersionId];

        Http h = new Http();
        HttpResponse res = new HttpResponse();
        HttpRequest req = new HttpRequest();
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/json');
        String endpoint = 'https://api.vfairs.com/v12/users?access_key=' + get_vFairsKey();
        req.setEndpoint(endpoint);

        vFairsAttendee attData = new vFairsAttendee();
        attData.email = participant.User__r.Email;
        attData.first_name = participant.Contact__r.FirstName;
        attData.last_name = participant.Contact__r.LastName;
        attData.middle_name = participant.Contact__r.MiddleName!=null?participant.Contact__r.MiddleName:null;
        attData.title = participant.Contact__r.Title!=null?participant.Contact__r.Title:null;
        attData.work_phone = participant.Contact__r.OrderApi__Work_Phone__c!=null?participant.Contact__r.OrderApi__Work_Phone__c:null;
        attData.mobile_phone = participant.Contact__r.MobilePhone!=null?participant.Contact__r.MobilePhone:null;
        attData.highest_degree = participant.Contact__r.Highest_Degree__c!=null?participant.Contact__r.Highest_Degree__c:null;
        attData.research_area_of_expertise = participant.Contact__r.Primary_Research_Area_of_Expertise__c!=null?participant.Contact__r.Primary_Research_Area_of_Expertise__c:null;
        attData.major_focus = participant.Contact__r.Major_Focus__c!=null?participant.Contact__r.Major_Focus__c:null;
        attData.current_education_status = participant.Contact__r.Current_Education_Status__c!=null?participant.Contact__r.Current_Education_Status__c:null;
        attData.resume = distributions.isEmpty()?'':distributions[0].DistributionPublicUrl;


        String payload = JSON.serialize(attData);

        System.debug('payload: ' + payload);
        req.setBody(payload);

        res = h.send(req);
        System.debug('create attendee response: ' + res);
        Object jsonParse = (Object) JSON.deserializeUntyped(res.getBody());
        Map<String, Object> mp_StrObj = (Map<string, Object>) jsonParse;
        System.debug('objectMap: ' + mp_StrObj);
        if (res.getStatusCode() == 200) {
            String attId =String.valueOf(mp_StrObj.get('id'));
//            uploadResume(participantId, attId);
            try {
                participant.External_Attendee_Id__c = attId;
                update participant;
            } catch(Exception e){
                new AACRCustomException(participantId, e.getMessage(), e.getStackTraceString(), 'vFairs Insert Attendee');
            }
        } else {
//            errorMsg = 'Unknown Error';
            System.debug('unknown error');
            new AACRCustomException(participantId, 'Callout Error', String.valueOf(mp_StrObj.get('error')), 'vFairs Insert Attendee');
        }


    }


    public static String synchronousInsertAttendee(String participantId) {
        BR_Participation__c participant = [
                SELECT Id, External_Attendee_Id__c, User__r.Email, Contact__r.FirstName, Contact__r.Title,
                        Contact__r.OrderApi__Work_Phone__c, Contact__r.MobilePhone, Contact__r.Highest_Degree__c,
                        Contact__r.Primary_Research_Area_of_Expertise__c, Contact__r.Major_Focus__c,
                        Contact__r.Current_Education_Status__c,Contact__r.LastName, Contact__r.MiddleName,
                        Contact__r.OrderApi__Preferred_Email__c
                FROM BR_Participation__c
                WHERE Id = :participantId
        ];

        List<ContentDocumentLink> contactFiles = [SELECT ContentDocumentId, ContentDocument.LatestPublishedVersionId, ContentDocument.Title, LinkedEntityId
        FROM ContentDocumentLink WHERE LinkedEntityId =: participant.Contact__c ANd ContentDocument.Title LIKE '%Resume%' ORDER BY SystemModstamp DESC];

        List<ContentDistribution> distributions = [Select Id, DistributionPublicUrl from ContentDistribution WHERE ContentVersionId =: contactFiles[0].ContentDocument.LatestPublishedVersionId];

        Http h = new Http();
        HttpResponse res = new HttpResponse();
        HttpRequest req = new HttpRequest();
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/json');
        String endpoint = 'https://api.vfairs.com/v12/users?access_key=' + get_vFairsKey();
        req.setEndpoint(endpoint);

        vFairsAttendee attData = new vFairsAttendee();
        attData.email = participant.User__r.Email;
        attData.first_name = participant.Contact__r.FirstName;
        attData.last_name = participant.Contact__r.LastName;
        attData.middle_name = participant.Contact__r.MiddleName!=null?participant.Contact__r.MiddleName:null;
        attData.title = participant.Contact__r.Title!=null?participant.Contact__r.Title:null;
        attData.work_phone = participant.Contact__r.OrderApi__Work_Phone__c!=null?participant.Contact__r.OrderApi__Work_Phone__c:null;
        attData.mobile_phone = participant.Contact__r.MobilePhone!=null?participant.Contact__r.MobilePhone:null;
        attData.highest_degree = participant.Contact__r.Highest_Degree__c!=null?participant.Contact__r.Highest_Degree__c:null;
        attData.research_area_of_expertise = participant.Contact__r.Primary_Research_Area_of_Expertise__c!=null?participant.Contact__r.Primary_Research_Area_of_Expertise__c:null;
        attData.major_focus = participant.Contact__r.Major_Focus__c!=null?participant.Contact__r.Major_Focus__c:null;
        attData.current_education_status = participant.Contact__r.Current_Education_Status__c!=null?participant.Contact__r.Current_Education_Status__c:null;
        attData.resume = distributions.isEmpty()?'':distributions[0].DistributionPublicUrl;

        String payload = JSON.serialize(attData);

        System.debug('payload: ' + payload);
        req.setBody(payload);

        res = h.send(req);
        System.debug('create attendee response: ' + res);
        Object jsonParse = (Object) JSON.deserializeUntyped(res.getBody());
        Map<String, Object> mp_StrObj = (Map<string, Object>) jsonParse;
        System.debug('objectMap: ' + mp_StrObj);
        if (res.getStatusCode() == 200) {
            return String.valueOf(mp_StrObj.get('id'));

        } else {
//            errorMsg = 'Unknown Error';
            System.debug('unknown error');
            new AACRCustomException(participantId, 'Callout Error', String.valueOf(mp_StrObj.get('error')), 'vFairs Insert Attendee');
        }

        return null;

    }

    public static String getAttendeeLoginURL(String contactId, String SFEventId){
        BR_Participation__c participant = [
                SELECT Id, External_Attendee_Id__c, User__r.Email, Contact__r.FirstName, Contact__r.Title,
                        Contact__r.OrderApi__Work_Phone__c, Contact__r.MobilePhone, Contact__r.Highest_Degree__c,
                        Contact__r.Primary_Research_Area_of_Expertise__c, Contact__r.Major_Focus__c,
                        Contact__r.Current_Education_Status__c,Contact__r.LastName, Contact__r.MiddleName,
                        Contact__r.OrderApi__Preferred_Email__c
                FROM BR_Participation__c
                WHERE Contact__c=:contactId AND BR_Event__c=:SFEventId
        ];


        Http h = new Http();
        HttpResponse res = new HttpResponse();
        HttpRequest req = new HttpRequest();
        req.setMethod('GET');
        req.setHeader('Content-Type', 'application/json');
        String endpoint = 'https://api.vfairs.com/v12/users?access_key=' + get_vFairsKey() + '&user_id=' + participant.External_Attendee_Id__c;
        req.setEndpoint(endpoint);


        res = h.send(req);
        System.debug('get attendee response: ' + res);
        List<Object> jsonParse = (List<Object>) JSON.deserializeUntyped(res.getBody());
        Map<String, Object> mp_StrObj = (Map<string, Object>) jsonParse[0];
        System.debug('objectMap: ' + mp_StrObj);
        if (res.getStatusCode() == 200) {
            return String.valueOf(mp_StrObj.get('autologin_url'));

        } else {
//            errorMsg = 'Unknown Error';
            System.debug('unknown error');
            new AACRCustomException(contactId, 'Callout Error', String.valueOf(mp_StrObj.get('error')), 'vFairs - Login URL');
        }

        return null;
    }

//    public class ResumeData{
//        public String resume_file_name;
//        public String resume_file_contents;
//    }
//
//    public static void uploadResume(String participantId, String vUser_id){
//        BR_Participation__c participant = [
//                SELECT Id, External_Attendee_Id__c, Contact__c
//                FROM BR_Participation__c
//                WHERE Id = :participantId
//        ];
//
//        List<ContentDocumentLink> contactFiles = [SELECT ContentDocumentId, ContentDocument.LatestPublishedVersionId, ContentDocument.Title, LinkedEntityId
//        FROM ContentDocumentLink WHERE LinkedEntityId =: participant.Contact__c ORDER BY SystemModstamp DESC];
//        System.debug('contact Files: ' + contactFiles);
//
//        if(!contactFiles.isEmpty()) {
//            ContentVersion resume;
//            for (ContentDocumentLink file : contactFiles) {
//                if (file.ContentDocument.Title.contains('Resume') && resume == null) {
//                    resume = [SELECT Id, VersionData, Title FROM ContentVersion WHERE ContentDocumentId = :file.ContentDocumentId AND IsLatest = true];
//                }
//            }
//
//            System.debug('resume: ' + resume);
//
//            Http h = new Http();
//            HttpResponse res = new HttpResponse();
//            HttpRequest req = new HttpRequest();
//            req.setMethod('POST');
//            req.setHeader('Content-Type', 'application/json');
//            String endpoint = 'https://api.vfairs.com/v12/users?access_key=' + get_vFairsKey() + '&user_id=' + vUser_id;
//            req.setEndpoint(endpoint);
//
//            ResumeData rData = new ResumeData();
//            rData.resume_file_name = resume.Title;
//            rData.resume_file_contents = EncodingUtil.base64Encode(resume.VersionData);
//
//            String payload = JSON.serialize(rData);
//
//            System.debug('payload: ' + payload);
//            req.setBody(payload);
//
//            res = h.send(req);
//            System.debug('upload resume response: ' + res);
//            Object jsonParse = (Object) JSON.deserializeUntyped(res.getBody());
//            Map<String, Object> mp_StrObj = (Map<string, Object>) jsonParse;
//            System.debug('objectMap: ' + mp_StrObj);
//            if (res.getStatusCode() == 200) {
//                System.debug('resumeURL: ' + mp_StrObj.get('resume'));
//            } else {
////            errorMsg = 'Unknown Error';
//                System.debug('unknown error');
//                new AACRCustomException(participantId, 'Callout Error', String.valueOf(mp_StrObj.get('error')), 'vFairs Upload Resume');
//            }
//        }
//
//    }

}