/**
 * Created by lauren.lezberg on 7/14/2021.
 */

public without sharing class AdvocateAppConfirmationController {

    public class EventInfo{
        @AuraEnabled
        public String imgUrl;

        @AuraEnabled
        public BR_Event__c evt;

        @AuraEnabled
        public String eventDates;

        public EventInfo(String url, BR_Event__c event, String dates){
            this.imgUrl = url;
            this.evt = event;
            this.eventDates = dates;
        }
    }


    @AuraEnabled
    public static EventInfo getEventInfo(String eventId){
        BR_Event__c item = [SELECT Id, Timezone__c, Event_Stage__c, Hide_Date_Time__c, List_Image_Filename__c, Name, Start_Date__c, End_Date__c FROM BR_Event__c WHERE Id=:eventId];
        Id currentContactId = ECRMUtils.getCurrentLoginUserContactId();

        List<BR_Participation__c> tickets = [SELECT Id, Participate__c FROM BR_Participation__c WHERE Contact__c=:currentContactId AND BR_Event__c=:eventId AND Participate__c = 'Incomplete'];
        if(tickets.size()>0) {
            tickets[0].Participate__c = 'Pending Approval';
            update tickets[0];
        }

        Set<Id> items_ids = new Set<Id>{eventId};
        Map<Id, Map<String, String>> itemsAttachments = BrEventsHelper.getAttachmentsForItems(items_ids);
        String imgURL;
        for (Id item_id : itemsAttachments.keySet()) {
            Map<String, String> itemAttachments = itemsAttachments.get(item_id);
            for (String att : itemAttachments.keySet()) {
                if (item.List_Image_Filename__c == att) {
                    imgURL= itemAttachments.get(att);
                }
            }
        }

        String eventDates;
        Integer diffMinutes = 0;
        String eventTimezone = item.Timezone__c;
//        if(eventTimezone == null){
//            eventTimezone = '';
//        }
        String userTimezone = UserInfo.getTimeZone().toString();

        if (eventTimezone != null) {
            diffMinutes = BrEventsHelper.getDiffMinutesBetweenTimezones(eventTimezone, userTimezone);
        }

        Datetime startDate = item.Start_Date__c.addMinutes(diffMinutes);
        Datetime endDate = item.End_Date__c;

        eventDates = startDate.format('MMMM') + ' ' + startDate.day() + ', ' + startDate.year() + ', ' + startDate.format('h:mm a') + ' to ' + endDate.format('h:mm a');

        Date startDay = Date.newInstance(startDate.year(), startDate.month(), startDate.day());
        Date endDay = Date.newInstance(endDate.year(), endDate.month(), endDate.day());

        if (endDate!=null) {
            if (diffMinutes != 0) {
                endDate = item.End_Date__c.addMinutes(diffMinutes);
            }

            if (endDate > startDate && endDay!=startDay) {
                eventDates = startDate.format('MMMM') + ' ' + startDate.day() + '-' + endDate.day() + ', ' + endDate.year() + ', ' + startDate.format('h:mm a') + ' to ' + endDate.format('h:mm a');
            }
        }

        eventDates = eventDates.replaceAll('AM', 'a.m.').replaceAll('PM', 'p.m.');
        if(eventDates.contains('12:00 a.m.')){
            eventDates = eventDates.replace('12:00 a.m.', 'Midnight');
        } else if(eventDates.contains('12:00 p.m.')) {
            eventDates = eventDates.replace('12:00 p.m.', 'Noon');
        }
        eventDates = eventDates.replaceAll(':00', '');

        return new EventInfo(imgURL, item, eventDates);
    }
}