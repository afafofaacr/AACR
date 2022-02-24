global without sharing class BrSendRemindersForEvents implements Schedulable {

    global void execute(SchedulableContext sc) {
        sendEventReminders();
    }

    public void sendEventReminders() {
        Datetime currentDateTime = Datetime.now();
        Set<Id> eventsId = new Set<Id>();
        List<Integer> reminderNum = new List<Integer>();

        for (BR_Event__c event : [
                SELECT Id, Name, Reminder_Hours__c, Start_Date__c
                FROM BR_Event__c
                WHERE Send_reminders__c = TRUE AND
                Start_Date__c > :currentDateTime])  //AND (End_Date__c = NULL OR End_Date__c > :currentDateTime)
        {

            System.debug('----event: ' + event.Name);

            if (event.Reminder_Hours__c != null) {
                List<String> reminderHours = new List<String>();
                String reminderHoursData = event.Reminder_Hours__c;

                if (reminderHoursData.contains(';')) {
                    reminderHours = reminderHoursData.split(';');
                } else if (reminderHoursData.contains(',')) {
                    reminderHours = reminderHoursData.split(',');
                }
                System.debug('----reminderHours: ' + reminderHours);
                System.debug('----reminderHours.size()-1: ' + reminderHours.size());
                if (!reminderHours.isEmpty()) {

                    for (Integer rem = 0; rem <=  reminderHours.size()-1; rem ++) {

                        Datetime reminderDateTime = currentDateTime.addHours(Integer.valueOf(reminderHours[rem]));
                        System.debug('----reminderDateTime: ' + reminderDateTime);
                        System.debug('----reminderHours[rem]: ' + reminderHours[rem]);

                        Datetime startDatetime = event.Start_Date__c;
                        System.debug('----startDatetime: ' + startDatetime);

                        Integer diffMinutes = reminderDateTime.minute() - startDatetime.minute();
                        System.debug('----diffMinutes: ' + diffMinutes);

                        if (startDatetime.date() == reminderDateTime.date() &&
                                startDatetime.hour() == reminderDateTime.hour() &&
                                diffMinutes >= 0 && diffMinutes < 30) {
                            System.debug('----GOTCHA rem: ' + rem);
                            System.debug('----add event: ' + event.name);
                            System.debug('----final rem: ' + rem);

                            reminderNum.add(rem);
                            eventsId.add(event.Id);
                            System.debug('----final reminderNum: ' + reminderNum);
                        }
                    }
                }
            }
        }

        if (!eventsId.isEmpty()) {
            System.debug('----BrSendRemindersForEvents.createEmails( eventsId: ' + eventsId + ', currentDateTime: ' + currentDateTime + ', reminderNum:' + reminderNum.get(0)+ ')');
//            List<Messaging.SingleEmailMessage> emails = BrSendRemindersForEvents.createEmails(eventsId, currentDateTime, reminderNum.get(0));
            List<Messaging.SingleEmailMessage> emails = BrSendRemindersForEvents.createEmails(eventsId, currentDateTime, reminderNum);

            if (!emails.isEmpty()) {
                try {
                    Messaging.sendEmail(emails);
                } catch (EmailException ex) {
                    System.debug(ex.getMessage());
                }
            }
        }
    }

    public static List<Messaging.SingleEmailMessage> createEmails(Set<Id> eventsId, Datetime currentDateTime, List<Integer> reminderNums) {
        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
        EmailTemplate emailTemplate = new emailTemplate();
        System.debug('---- I`m in createEmails ---- ');
        System.debug('----reminderNums (0-2) : ' + reminderNums);



        String orgName = UserInfo.getOrganizationName();
        String emailSetting = '';
        String orgWideEmailId = BrEventsHelper.getConfigValue('org wide email id');
        List<OrgWideEmailAddress> emailAddresses = [
                SELECT Id, Address
                FROM OrgWideEmailAddress
                WHERE Id = :orgWideEmailId
        ];


        for (BR_Participation__c participation : [
                SELECT Id, User__c, User__r.Name, Contact__c, Contact__r.Name, BR_Event__r.Timezone__c,
                        BR_Event__r.Name, BR_Event__r.Start_Date__c, Lead__c, Lead__r.Name,
                        BR_Event__r.Venue_Address__c, BR_Event__r.Reminder_Message1__c, BR_Event__r.Reminder_Message2__c,
                        BR_Event__r.Reminder_Message3__c, BR_Event__r.Registration_Confirmation_Message__c
                FROM BR_Participation__c
                WHERE BR_Event__c IN :eventsId
                AND Participate__c = 'Yes'
        ]) {

            Integer idx = 0;
            Integer i = 0;
            for(Id eventId : eventsId){
                if(eventId == participation.BR_Event__c){
                    idx = i;
                }
                i++; 
            }

            if (reminderNums[idx] == 0){
                emailTemplate = [SELECT Id, HtmlValue FROM EmailTemplate WHERE DeveloperName = 'brEventReminders_1' LIMIT 1];
            } else if (reminderNums[idx] == 1) {
                emailTemplate = [SELECT Id, HtmlValue FROM EmailTemplate WHERE DeveloperName = 'brEventReminders_2' LIMIT 1];
            } else if (reminderNums[idx] == 2) {
                emailTemplate = [SELECT Id, HtmlValue FROM EmailTemplate WHERE DeveloperName = 'brEventReminders_3' LIMIT 1];
            } else {
                emailTemplate = [SELECT Id, HtmlValue FROM EmailTemplate WHERE DeveloperName = 'brEventReminders_1' LIMIT 1];
                System.debug('reminderNum out of range (0-2) and selected 0 by default');
            }

            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            Id targetId = null;
            Id userId = participation.User__c;
            Id contactId = participation.Contact__c;
            Id leadId = participation.Lead__c;

            if (userId != null) {
                targetId = userId;
            } else if (contactId != null) {
                targetId = contactId;
            } else if (leadId != null) {
                targetId = leadId;
            }

            if (targetId != null) {
                String body = emailTemplate.HtmlValue;

                String userName = participation.User__r.Name;
                userName = (userName == null) ? participation.Contact__r.Name : userName;
                userName = (userName == null) ? participation.Lead__r.Name : userName;

                String eventName = participation.BR_Event__r.Name;

                String reminderMsg1 = participation.BR_Event__r.Reminder_Message1__c;
                String reminderMsg2 = participation.BR_Event__r.Reminder_Message2__c;
                String reminderMsg3 = participation.BR_Event__r.Reminder_Message3__c;

                Integer diffMinutes = 0;
                String eventTimezone = participation.BR_Event__r.Timezone__c;
                String userTimezone = UserInfo.getTimeZone().toString();

                if (eventTimezone != null) {
                    diffMinutes = BrEventsReminderHelper.getDiffMinutesBetweenTimezones(eventTimezone, userTimezone);
                } else {
                    eventTimezone = '';
                }

                Datetime startDate = participation.BR_Event__r.Start_Date__c.addMinutes(diffMinutes);

                String address = participation.BR_Event__r.Venue_Address__c;
                String conformationMessage = participation.BR_Event__r.Registration_Confirmation_Message__c;
                address = (address == null) ? '' : address;
                String addressURL =  (address == null) ? '' :'https://www.google.com/maps/place/' + address;

                body = emailTemplate.HtmlValue.replace('{!userName}', userName)
                        .replace('{!reminderMsg1}', reminderMsg1)
                        .replace('{!reminderMsg2}', reminderMsg2)
                        .replace('{!reminderMsg3}', reminderMsg3)
                        .replace('{!eventName}', eventName)
                        .replace('{!startDate}', startDate.format())
                        .replace('{!gmt}', eventTimezone)
                        .replace('{!location}', address)
                        .replace('{!confirmationMessage}',conformationMessage)
                        .replace('{!locationURL}', addressURL);

                String subject = Label.br_lbleventreminder + ': ' + + eventName;

                email.setHtmlBody(body);
                if (emailAddresses.isEmpty()) {
                    email.setSenderDisplayName(orgName);
                } else {
                    email.setOrgWideEmailAddressId(emailAddresses[0].Id);
                }
                email.setTargetObjectId(targetId);
                email.setTemplateId(emailTemplate.Id);
                email.setSubject(subject);
                email.setWhatId(participation.Id);
                email.setSaveAsActivity(false);
                emails.add(email);

            }
        }
        return emails;
    }

//    public static List<Messaging.SingleEmailMessage> createEmails(Set<Id> eventsId, Datetime currentDateTime, Integer reminderNum) {
//        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
//        EmailTemplate emailTemplate = new emailTemplate();
//        System.debug('---- I`m in createEmails ---- ');
//        System.debug('----reminderNum (0-2) : ' + reminderNum);
//
//        if (reminderNum == 0){
//            emailTemplate = [SELECT Id, HtmlValue FROM EmailTemplate WHERE DeveloperName = 'brEventReminders_1' LIMIT 1];
//        } else if (reminderNum == 1) {
//            emailTemplate = [SELECT Id, HtmlValue FROM EmailTemplate WHERE DeveloperName = 'brEventReminders_2' LIMIT 1];
//        } else if (reminderNum == 2) {
//            emailTemplate = [SELECT Id, HtmlValue FROM EmailTemplate WHERE DeveloperName = 'brEventReminders_3' LIMIT 1];
//        } else {
//            emailTemplate = [SELECT Id, HtmlValue FROM EmailTemplate WHERE DeveloperName = 'brEventReminders_1' LIMIT 1];
//            System.debug('reminderNum out of range (0-2) and selected 0 by default');
//        }
//
//        String orgName = UserInfo.getOrganizationName();
//        String emailSetting = '';
//        String orgWideEmailId = BrEventsHelper.getConfigValue('org wide email id');
//        List<OrgWideEmailAddress> emailAddresses = [
//                SELECT Id, Address
//                FROM OrgWideEmailAddress
//                WHERE Id = :orgWideEmailId
//        ];
//
//        for (BR_Participation__c participation : [
//                SELECT Id, User__c, User__r.Name, Contact__c, Contact__r.Name, BR_Event__r.Timezone__c,
//                        BR_Event__r.Name, BR_Event__r.Start_Date__c, Lead__c, Lead__r.Name,
//                        BR_Event__r.Venue_Address__c, BR_Event__r.Reminder_Message1__c, BR_Event__r.Reminder_Message2__c,
//                        BR_Event__r.Reminder_Message3__c, BR_Event__r.Registration_Confirmation_Message__c
//                FROM BR_Participation__c
//                WHERE BR_Event__c IN :eventsId
//                AND Participate__c = 'Yes'
//        ]) {
//
//            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
//            Id targetId = null;
//            Id userId = participation.User__c;
//            Id contactId = participation.Contact__c;
//            Id leadId = participation.Lead__c;
//
//            if (userId != null) {
//                targetId = userId;
//            } else if (contactId != null) {
//                targetId = contactId;
//            } else if (leadId != null) {
//                targetId = leadId;
//            }
//
//            if (targetId != null) {
//                String body = emailTemplate.HtmlValue;
//
//                String userName = participation.User__r.Name;
//                userName = (userName == null) ? participation.Contact__r.Name : userName;
//                userName = (userName == null) ? participation.Lead__r.Name : userName;
//
//                String eventName = participation.BR_Event__r.Name;
//
//                String reminderMsg1 = participation.BR_Event__r.Reminder_Message1__c;
//                String reminderMsg2 = participation.BR_Event__r.Reminder_Message2__c;
//                String reminderMsg3 = participation.BR_Event__r.Reminder_Message3__c;
//
//                Integer diffMinutes = 0;
//                String eventTimezone = participation.BR_Event__r.Timezone__c;
//                String userTimezone = UserInfo.getTimeZone().toString();
//
//                if (eventTimezone != null) {
//                    diffMinutes = BrEventsReminderHelper.getDiffMinutesBetweenTimezones(eventTimezone, userTimezone);
//                } else {
//                    eventTimezone = '';
//                }
//
//                Datetime startDate = participation.BR_Event__r.Start_Date__c.addMinutes(diffMinutes);
//
//                String address = participation.BR_Event__r.Venue_Address__c;
//                String conformationMessage = participation.BR_Event__r.Registration_Confirmation_Message__c;
//                address = (address == null) ? '' : address;
//                String addressURL =  (address == null) ? '' :'https://www.google.com/maps/place/' + address;
//
//                body = emailTemplate.HtmlValue.replace('{!userName}', userName)
//                        .replace('{!reminderMsg1}', reminderMsg1)
//                        .replace('{!reminderMsg2}', reminderMsg2)
//                        .replace('{!reminderMsg3}', reminderMsg3)
//                        .replace('{!eventName}', eventName)
//                        .replace('{!startDate}', startDate.format())
//                        .replace('{!gmt}', eventTimezone)
//                        .replace('{!location}', address)
//                        .replace('{!confirmationMessage}',conformationMessage)
//                        .replace('{!locationURL}', addressURL);
//
//                String subject = Label.br_lbleventreminder + ': ' + + eventName;
//
//                email.setHtmlBody(body);
//                if (emailAddresses.isEmpty()) {
//                    email.setSenderDisplayName(orgName);
//                } else {
//                    email.setOrgWideEmailAddressId(emailAddresses[0].Id);
//                }
//                email.setTargetObjectId(targetId);
//                email.setTemplateId(emailTemplate.Id);
//                email.setSubject(subject);
//                email.setWhatId(participation.Id);
//                email.setSaveAsActivity(false);
//                emails.add(email);
//
//            }
//        }
//        return emails;
//    }
}