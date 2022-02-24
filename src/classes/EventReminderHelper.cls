/**
 * Created by afaf.awad on 10/21/2020.
 */

public without sharing class EventReminderHelper {


    public static void sendEventReminder(List<BR_Participation__c> participants, String fromEmail, Boolean is24hour) {

        EmailTemplate emailTemplate = [SELECT Id, HtmlValue, Body FROM EmailTemplate WHERE DeveloperName = 'Event_Reminders'];

        Set<Id> eventIdSet = new Set<Id>();
        eventIdSet.add(participants[0].BR_Event__c);
        Map<String,String> imageMap =  LiveEventsHelper.getEventImageMap(eventIdSet);
        List<String> image = imageMap.values();

        Map<String, String> emailMap = new Map<String, String>();

        for (BR_Participation__c p : participants) {

            String recipientName = p.Contact__r.Salutation != null ? p.Contact__r.Salutation + ' ' : '';
            recipientName += p.Contact__r.FirstName + ' ' + p.Contact__r.LastName;
            emailMap.put(p.Contact__r.Email, recipientName);
        }

        String vlocation = '<a href="https://' + participants[0].BR_Event__r.Portal_Event_Link__c + '">MyAACR</a>';
        String vvInstructions = '<p>Registrants may log into the meeting platform beginning at ' +  participants[0].BR_Event__r.Platform_Open_Time__c + '.</p>' + Label.Virtual_Venue_Instructions;

        String body = '';
        body = emailTemplate.HtmlValue;
        body = body.replace('{!BR_Event__c.Name}', participants[0].BR_Event__r.Name)
                .replace('{!imgLocation}', !imageMap.isEmpty() ? image[0] : '')
                .replace('{!BR_Event_c.Start_Date__c}', participants[0].BR_Event__r.Start_Date__c.format('MMMM d,  yyyy h:mm a z'))
                .replace('{!BR_Event_c.End_Date__c}', participants[0].BR_Event__r.End_Date__c.format('MMMM d,  yyyy h:mm a z'))
                .replace('{!location}', participants[0].BR_Event__r.Event_Stage__c != 'Virtual' ? participants[0].BR_Event__r.Venue__r.Name : vlocation) // Show physical location if type is Physical or Hybrid
                .replace('{!BR_Event__c.Draft_Program__c}', participants[0].BR_Event__r.Draft_Program__c != null ? participants[0].BR_Event__r.Draft_Program__c : '')
                .replace('{!Virtual_Venue_Instructions}', participants[0].BR_Event__r.Event_Stage__c != 'Physical' ? vvInstructions: '') // Show VV Instructions when type is Virtual or Hybrid
                .replace('{!StartTime}', is24hour ? 'in 24 hours.' : 'at ' + participants[0].BR_Event__r.Start_Time__c + '.')
//                .replace('{!Sponsors}', EventSponsorshipController.buildLogosInEmail(participants[0].BR_Event__c));
                .replace('{!Sponsors}', EventSponsorshipController.buildLogosInEmail(participants[0].BR_Event__c, participants[0].BR_Event__r.Display_on_Reminder_Email__c, participants[0].BR_Event__r.Show_Reminder_Email_Logos__c)); // SAVE FOR NEW SPONSOR BUTTONS

        String subject = 'Reminder: Event starts in ' + (is24hour ? '24 hours' : '2 hours');

        if(!Test.isRunningTest()) {
            PlatformEmailService.callSendGridAPI(emailMap, subject, fromEmail, 'AACR', fromEmail, body);
        }
    }
}