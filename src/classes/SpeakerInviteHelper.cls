/**
 * Created by lauren.lezberg on 3/4/2020.
 */

public without sharing class SpeakerInviteHelper {

    public Static String getDocumentRelativeLink(String documentId){

        SYstem.debug('getDocumentRelativeLInk: ' + documentId);
        if(documentId!=null) {
            string baseURL = URL.getSalesforceBaseUrl().toExternalForm();
            SYstem.debug('baseURL: ' + baseURL);

            string instanceName;
            String sfdcUrlStrForImage = '';
            integer i;
            string tempInstance;
            try {
                list<Document> doc = [Select id,Name,SystemModStamp From Document Where Id = :documentId];
                if(!doc.isEmpty()) {
                    System.debug('doc: ' + doc);
                    String id = doc[0].id;
                    System.debug('id: ' + id);
                    String recordId = id.substring(0, 15);
                    System.debug('recordId: ' + recordId);

                    if (baseURL.contains('cs')) {
                        System.debug('url has cs in it');
                        i = baseURL.indexof('cs');
                        tempInstance = baseURL.substring(i, baseURL.length());
                        instanceName = tempInstance.substring(0, tempInstance.indexof('.'));
                        System.debug('instance name: ' + instanceName);
                    } else if (baseURL.contains('na')) {
                        System.debug('url has na in it');
                        i = baseURL.indexof('na');
                        tempInstance = baseURL.substring(i, baseURL.length());
                        instanceName = tempInstance.substring(0, tempInstance.indexof('.'));
                    } else {
                        i = baseURL.indexof('my');
                        instanceName = [select InstanceName from Organization].InstanceName;
                    }


                    System.debug('baseURL substring: ' + baseURL.substring(0, i - 1));
                    System.debug('instance name: ' + instanceName);

                    sfdcUrlStrForImage = baseURL.substring(0, i - 1) + '--c.' + instanceName + '.content.force.com/servlet/servlet.ImageServer?id=' + recordId + '&oid=' + UserInfo.getOrganizationId() + '&lastMod=' + doc[0].SystemModStamp.getTime();
                    System.debug('sfdc url: ' + sfdcUrlStrForImage);
                }
            } Catch (Exception ex) {
                System.debug('exception: ' + ex.getMessage());
                return null;
            }
            return sfdcUrlStrForImage;
        }

        return null;

    }


    public static String buildEventInviteTemplate(String eventId, String message){
        System.debug('buildEventInviteTemplate being called ' + eventId);
        BR_Event__c event = [SELECT Name,Draft_Program__c, Signature_1__c, Signature_2__c, Signature_3__c, Signature_4__c,
                Signature_5__c, Signature_6__c, Invite_Image_Id__c, Invite_Message__c, End_Date__c, Start_Date__c, Category__c,
                Venue__c, Virtual_Venue__c, Venue__r.Name, Venue__r.City__c, Venue__r.State__c, Hide_Date_Time__c
                FROM BR_Event__c
                WHERE id=: eventId.escapeHtml4()];
        System.debug('event: ' + event);



        EmailTemplate emailTemplate = [SELECT Id, HtmlValue, Body  FROM EmailTemplate WHERE Name='Speaker Invite Custom'];

        if(event.Venue__c==null){
            emailTemplate = [SELECT Id, HtmlValue, Body  FROM EmailTemplate WHERE Name='Speaker Invite Virtual'];
        }

        String body = emailTemplate.HtmlValue;

        String inviteMessage;
        if(message!=null){
            inviteMessage = message;
        } else if (event.Invite_Message__c!=null){
            inviteMessage = event.Invite_Message__c;
        } else {
            inviteMessage = null;
        }

        String eventDates = '';
        if(!event.Hide_Date_Time__c){
            if(event.End_Date__c!=null){
                eventDates = event.Start_Date__c.formatLong() + ' - ' +  event.End_Date__c.formatLong() + ',';
            }
        }

        body = emailTemplate.HtmlValue.replace('{!eventName}', event.Name)
                .replace('{!inviteMessage}', inviteMessage!=null?inviteMessage:'{!inviteMessage}')
                .replace('{!signature1}', event.Signature_1__c!=null?event.Signature_1__c:'')
                .replace('{!signature2}', event.Signature_2__c!=null?event.Signature_2__c:'')
                .replace('{!signature3}', event.Signature_3__c!=null?event.Signature_3__c:'')
                .replace('{!signature4}', event.Signature_4__c!=null?event.Signature_4__c:'')
                .replace('{!signature5}', event.Signature_5__c!=null?event.Signature_5__c:'')
                .replace('{!signature6}', event.Signature_6__c!=null?event.Signature_6__c:'')
                .replace('{!venue}', event.Venue__c!=null?event.Venue__r.Name:'')
                .replace('{!draftLink}', event.Draft_Program__c!=null?'A preliminary program of session topics can be found <a href=\"' + event.Draft_Program__c  + '\" target="_blank">here</a>.':'')
                .replace('{!chairString}', buildChairString(eventId)!=null?buildChairString(eventId):'')
//                .replace('{!conferenceChairs}', getChairString(eventId))
//                .replace('{!coChairs}', getCochairString(eventId))
                .replace('{!eventDates}', eventDates)
                .replace('{!venueLocation}', event.Venue__c!=null?event.Venue__r.City__c + ', ' + event.Venue__r.State__c:'')
                .replace('{!imgLocation}', getDocumentRelativeLink(event.Invite_Image_Id__c)!=null?getDocumentRelativeLink(event.Invite_Image_Id__c):'');
        System.debug('returning email template body: ' + body);
        return body;
    }

    public static String buildChairString(String eventId){
        Set<String> inviteRoles = new Set<String>();
        List<Session_Speaker__c> chairPersons = [SELECT Id, Speaker__r.Name, Roles__c FROM Session_Speaker__c WHERE RecordType.Name = 'Chair Person' AND Event__c=:eventId AND Use_for_Invite__c = true ];
        //get all roles
        for(Session_Speaker__c cp : chairPersons){
            System.debug('chair person: ' + cp.Speaker__r.Name);
            List<String> roles = cp.Roles__c.split(';');
            System.debug('roles: ' + roles);
            if(!inviteRoles.contains(roles[0])) {
                inviteRoles.add(roles[0]);
            }
        }

        String chairInviteString = '';

        Integer idx = 0;
        for(String role : inviteRoles){
            System.debug('role: ' + role);
            List<String> personsInRole = new List<String>();
            for(Session_Speaker__c cp : chairPersons){
                if(cp.Roles__c.contains(role)){
                    personsInRole.add(cp.Speaker__r.Name);
                }
            }
            chairInviteString += role;
            if(personsInRole.size()>1){
                chairInviteString += 's ';
                for(String person : personsInRole){
                    if(person == personsInRole[0]){
                        chairInviteString += person;
                    } else if (person==personsInRole[personsInRole.size()-1]){
                        chairInviteString += ' and ' + person;
                    } else {
                        chairInviteString += ' , ' + person;
                    }
                }
            } else {
                chairInviteString += ' ' + personsInRole[0];
            }

            if(inviteRoles.size()>1 && idx!=inviteRoles.size()-1){
                chairInviteString += ' and ';
            }
            idx++;

        }

        System.debug('chairInviteString: ' + chairInviteString);

        return chairInviteString;

    }

//    public static String getChairString(String eventId){
//        String chairString;
//        List<String> chairs = new List<String>();
//        List<Session_Speaker__c> chairPersons = [SELECT Id, Speaker__r.Name, Roles__c FROM Session_Speaker__c WHERE RecordType.Name = 'Chair Person' AND Event__c=:eventId ];
//        System.debug('chair persons: ' + chairPersons);
//        for(Session_Speaker__c speaker : chairPersons){
//            String roles = speaker.Roles__c;
//            System.debug('roles: ' + roles);
//            if(roles.contains('Chair')){
//                chairs.add(speaker.Speaker__r.Name);
//            }
//        }
//        System.debug('chairs: ' + chairs);
//
//        if(chairs.size()>1){
//            chairString = 'Conference Chairs';
//            for(Integer i = 0; i<chairs.size();i++){
//                if(i==0) {
//                    chairString += ', ' + chairs[i];
//                } else {
//                    chairString += ' and ' + chairs[i];
//                }
//            }
//        } else if(chairs.size() ==1) {
//            chairString = 'Conference Chair ' + chairs[0];
//        } else {
//            chairString = '';
//        }
//
//        System.debug('chairString: ' + chairString);
//        return chairString;
//
//
//    }

//    public static String getCochairString(String eventId){
//        String cochairString;
//        List<String> cochairs = new List<String>();
//        List<Session_Speaker__c> chairPersons = [SELECT Id, Speaker__r.Name, Roles__c FROM Session_Speaker__c WHERE RecordType.Name = 'Chair Person' AND Event__c=:eventId ];
//        System.debug('chair persons: ' + chairPersons);
//
//        for(Session_Speaker__c speaker : chairPersons){
//            String roles = speaker.Roles__c;
//            System.debug('roles: ' + roles);
//            if (roles.contains('Cochair')){
//                cochairs.add(speaker.Speaker__r.Name);
//            }
//        }
//
//        if(cochairs.size()>1){
//            cochairString = 'Conference Cochairs';
//            for(Integer i = 0; i<cochairs.size();i++){
//                if(i==0) {
//                    cochairString += ', ' + cochairs[i];
//                } else {
//                    cochairString += ' and ' + cochairs[i];
//                }
//            }
//        } else {
//            cochairString = 'Conference Cochair ' + cochairs[0];
//        }
//
//        System.debug('cochairString: ' + cochairString);
//
//        return cochairString;
//    }
}