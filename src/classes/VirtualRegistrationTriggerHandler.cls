/**
 * Created by lauren.lezberg on 4/10/2020.
 */

public with sharing class VirtualRegistrationTriggerHandler {
    public static List<Virtual_Meeting_Links__mdt> virtualMeetings = new List<Virtual_Meeting_Links__mdt>();

    public static void sendRegistrationEmails(List<Id> attendeeIds) {

        List<Messaging.MassEmailMessage> emails = new List<Messaging.MassEmailMessage>();

        //get all events with virtual meetings
        List<Virtual_Meeting_Links__mdt> meetings = new List<Virtual_Meeting_Links__mdt>();
        if(Test.isRunningTest()){
            System.debug('running test: ' + virtualMeetings);
            meetings = virtualMeetings;
        } else{
            meetings = [SELECT Event_Id__c, Email_Template_Id__c FROM Virtual_Meeting_Links__mdt];
        }
        Map<Id, Id> eventIds = new Map<Id, Id>();
        //get all events with virtual meetings
        for(Virtual_Meeting_Links__mdt vml : meetings){
            if (vml.Email_Template_Id__c != null) {
                eventIds.put(vml.Event_Id__c, vml.Email_Template_Id__c);
            }
        }

        if(!eventIds.isEmpty()) {
            //get all attendee records associate with virtual meeting
            List<EventApi__Attendee__c> attendees = [
                    SELECT Id, EventApi__Contact__c, EventApi__Email__c, EventApi__Event__c, EventApi__First_Name__c, EventApi__Last_Name__c
                    FROM EventApi__Attendee__c
                    WHERE EventApi__Event__c IN:eventIds.keySet() AND Id IN:attendeeIds AND EventApi__Email__c != null
            ];
            System.debug('attendees: ' + attendees.size());


            Set<Id> attendeeContactIds = new Set<Id>();
            //map of templateId
            Map<Id, List<Id>> templateMap = new Map<Id, List<Id>>();
            List<Id> contactIds;
            if (!eventIds.isEmpty()) {
                for (EventApi__Attendee__c att : attendees) {
                    attendeeContactIds.add(att.EventApi__Contact__c);
                    if (att.EventApi__Contact__c != null) {
                        contactIds = new List<Id>();
                        //if event is already in map
                        if (templateMap.keySet().contains(eventIds.get(att.EventApi__Event__c))) {
                            contactIds = templateMap.get(eventIds.get(att.EventApi__Event__c));
                            contactIds.add(att.EventApi__Contact__c);

                            templateMap.remove(eventIds.get(att.EventApi__Event__c));
                            templateMap.put(eventIds.get(att.EventApi__Event__c), contactIds);
                        } else {
                            contactIds.add(att.EventApi__Contact__c);
                            templateMap.put(eventIds.get(att.EventApi__Event__c), contactIds);
                        }
                    }
                }
            }
            System.debug('templateMap: ' + templateMap);


//            List<User> toUpdate = new List<User>();
//
//            Set<Id> userContactIds = new Set<Id>();
//            //check for users
//            List<User> users = [SELECT Id, IsActive, ContactId FROM User WHERE ContactId IN: attendeeContactIds];
//            //get inactive users
//            for(User u : users){
//                if(!u.IsActive){
//                    u.IsActive=true;
//                    toUpdate.add(u);
//                } else {
//                    userContactIds.add(u.ContactId);
//                }
//            }
//
//            String profileId = [Select Id from Profile where name = 'Fonteva Customer Community Login User'].Id;
//            //check for contacts without user
//            List<Id> contactNeedsUser = new List<Id>();
//            for(EventApi__Attendee__c attendee : attendees){
//                if(!userContactIds.contains(attendee.EventApi__Contact__c)){
//                    String nickname = ((attendee.EventApi__First_Name__c != null && attendee.EventApi__First_Name__c.length() > 0) ? attendee.EventApi__First_Name__c.substring(0,1) : '' ) + attendee.EventApi__Last_Name__c.substring(0,1);
//                    nickname += String.valueOf(Crypto.getRandomInteger()).substring(1,7);
//                    User u = new User();
//                    u.FirstName = attendee.EventApi__First_Name__c;
//                    u.LastName = attendee.EventApi__Last_Name__c;
//                    u.ProfileId = profileId;
//                    u.Username = attendee.EventApi__Email__c;
//                    u.Alias = attendee.EventApi__First_Name__c.substring(0,1) + '.' + attendee.EventApi__Last_Name__c.substring(0,3);
//                    u.CommunityNickname = nickname;
//                    u.ContactId = attendee.EventApi__Contact__c;
//                    u.Email= attendee.EventApi__Email__c;
//                    u.EmailEncodingKey='UTF-8';
//                    u.LanguageLocaleKey='en_US';
//                    u.LocaleSidKey='en_US';
//                    u.TimeZoneSidKey='America/New_York';
//                    toUpdate.add(u);
//                }
//            }
//
            //create emails
            for (Id key : templateMap.keySet()) {
                Messaging.MassEmailMessage email = new Messaging.MassEmailMessage();
                email.setTargetObjectIds(templateMap.get(key));
                email.setTemplateId(key);
                email.setSenderDisplayName('American Association for Cancer Research');
                email.setReplyTo('myaacr@aacr.org');
                emails.add(email);
            }

            try {
                List<Messaging.SendEmailResult> resultMail = Messaging.sendEmail(emails);

                //activate users in future method
                //activateUsers(toUpdate);

                //create users
//                Database.insert(createUsersFromContact(contactNeedsUser));

//                Database.upsert(toUpdate);

                for (Messaging.SendEmailResult result : resultMail) {
                    if (!result.isSuccess()) {
                        System.debug('errors: ' + result.getErrors());
                    }
                }
            } catch (exception e) {
                System.debug('Could not send emails: ' + e.getMessage());

            }
        }

    }


//    @Future
//    public static void activateUsers(List<Id> userIds){
//        List<User> toUpdate = [SELECT Id, IsActive FROM User WHERE Id IN: userIds];
//        for(User u: toUpdate){
//            u.IsActive = true;
//        }
//
//
//        Database.update(toUpdate);
//    }
//
//
//    public static List<User> createUsersFromContact(List<Id> contactIds){
//        List<User> toInsert = new List<User>();
//        String profileId = [Select Id from Profile where name = 'Fonteva Customer Community Login User'].Id;
//
//        List<Contact> contacts = [SELECT Id,FirstName, Email, LastName FROM Contact WHERE Id IN: contactIds];
//        for(Contact con : contacts){
//            String nickname = ((con.FirstName != null && con.FirstName.length() > 0) ? con.FirstName.substring(0,1) : '' ) + con.LastName.substring(0,1);
//            nickname += String.valueOf(Crypto.getRandomInteger()).substring(1,7);
//            User u = new User();
//            u.FirstName = con.FirstName;
//            u.IsActive = true;
//            u.LastName = con.LastName;
//            u.ProfileId = profileId;
//            u.Username = con.Email;
//            u.Alias = nickname.substring(0,7);
//            u.CommunityNickname = nickname;
//            u.ContactId = con.Id;
//            u.Email= con.Email;
//            u.EmailEncodingKey='UTF-8';
//            u.LanguageLocaleKey='en_US';
//            u.LocaleSidKey='en_US';
//            u.TimeZoneSidKey='America/New_York';
//            toInsert.add(u);
//        }
//
//       return toInsert;
//    }


}