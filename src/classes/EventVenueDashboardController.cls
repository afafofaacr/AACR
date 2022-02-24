/**
 * Created by afaf.awad on 5/17/2021.
 */

public with sharing class EventVenueDashboardController {

    @AuraEnabled
    public static List<Integer> getAvailableYears(){
        List<Integer> years = new List<Integer>();
        list<Schema.AggregateResult> results = [SELECT COUNT(Id), Calendar_Year(Start_Date__c) startYear
                                                FROM BR_Event__c
                                                WHERE Draft__c = false AND Cancelled__c = false AND End_Date__c>=: System.now()
                                                GROUP BY Calendar_Year(Start_Date__c)
                                                ORDER BY Calendar_Year(Start_Date__c) ASC];
        if(!results.isEmpty()) {
            for (AggregateResult r : results) {
                years.add((Integer) r.get('startYear'));
            }
        } else {
            years.add(System.now().year());
        }

        return years;
    }

    @AuraEnabled
    public static EventVenueInfo getEventsPerMonth(String month, Integer year) {

        Date monthStart = Date.newInstance(year, Integer.valueOf(month), 1);
        Date nextMonthStart = Date.newInstance(year, Integer.valueOf(month) + 1, 1);
        List<BR_Event__c> events = [SELECT Id, Name, Virtual_Venue__r.Name, Virtual_Venue__c ,Start_Date__c, End_Date__c
                                        FROM BR_Event__c WHERE Start_Date__c >= :monthStart
                                        AND Start_Date__c < :nextMonthStart
                                        AND Draft__c = false
                                        AND Cancelled__c = false
                                        AND Virtual_Venue__c != NULL
                                        ORDER BY Start_Date__c ASC];

        List<Id> eventIds = new List<Id>();
        for(BR_Event__c evt: events){
            eventIds.add(evt.Id);
        }

        List<Virtual_Event_Details__c> details = [SELECT Id, Exhibit_Open__c, Event__c FROM Virtual_Event_Details__c WHERE Event__c IN: eventIds];
        Map<Id, Virtual_Event_Details__c> vedMap = new Map<Id, Virtual_Event_Details__c>();

        for(Virtual_Event_Details__c ved : details){
            vedMap.put(ved.Event__c, ved);
        }

        List<EventInfo> evtInfoList = new List<EventInfo>();
        for(BR_Event__c e : events) {
            EventInfo evt = new EventInfo();
            evt.eventId = e.Id;
            evt.Name = e.Name;
            evt.venueId = e.Virtual_Venue__c;
            evt.detailsId = vedMap.containsKey(e.Id) ? vedMap.get(e.Id).Id : null ;
            evt.exhibitOpen = vedMap.containsKey(e.Id) ? vedMap.get(e.Id).Exhibit_Open__c : false ;
            evt.dateString = e.Start_Date__c.format();
            if (e.End_Date__c != null) {
                evt.dateString += ' - ' + e.End_Date__c.format();
            }
            evtInfoList.add(evt);
        }

        EventVenueInfo venueInfo = new EventVenueInfo();
        venueInfo.events = evtInfoList;
        venueInfo.venues = [SELECT Id, Name FROM Venue__c WHERE Show_in_Dashboard__c = TRUE];

        return venueInfo;
    }

    @AuraEnabled
    public static Boolean updateExhibit(String detailsId) {
        return VirtualEventDetailsController.updateExhibit(detailsId);
    }

    public class EventVenueInfo {
        @AuraEnabled
        public List<EventInfo> events;

        @AuraEnabled
        public List<Venue__c> venues;
    }

    public class EventInfo {
        @AuraEnabled
        public Id eventId;

        @AuraEnabled
        public String Name;

        @AuraEnabled
        public String dateString;

        @AuraEnabled
        public String venueId;

        @AuraEnabled
        public Id detailsId;

        @AuraEnabled
        public Boolean exhibitOpen;


    }
}