/**
 * Created by lauren.lezberg on 1/2/2020.
 */

public without sharing class AACREventsDashboardController {

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


    /**
     * @purpose Retrieve all published and non-cancelled events for a specified month
     *
     * @param month
     *
     * @return
     */
    @AuraEnabled
    public static List<UpcomingEvent> getEventsPerMonth(String month, Integer year) {
        Date monthStart = Date.newInstance(year, Integer.valueOf(month), 1);
        Date nextMonthStart = Date.newInstance(year, Integer.valueOf(month) + 1, 1);
        List<BR_Event__c> events = [SELECT Id, Name, Limit_of_attendees__c, Budgeted_Attendance__c, Unlisted_Event__c, Start_Date__c, End_Date__c, (Select Id FROM BR_Participations__r WHERE Participate__c = 'Yes') FROM BR_Event__c WHERE Start_Date__c >= :monthStart AND Start_Date__c < :nextMonthStart AND Draft__c = false AND Cancelled__c = false ORDER BY Start_Date__c ASC];

        List<UpcomingEvent> upcomingEvents = new List<UpcomingEvent>();
        for (BR_Event__c evt : events) {
            System.debug('evt: ' + evt);
            UpcomingEvent upEvt = new UpcomingEvent();
            upEvt.eventId = evt.Id;
            upEvt.eventName = evt.Name;
            upEvt.isPrivate = evt.Unlisted_Event__c;
            upEvt.ticketsAllocated = (Integer) evt.Limit_of_attendees__c;
            upEvt.budgetedAttendance = evt.Budgeted_Attendance__c != null ? (Integer) evt.Budgeted_Attendance__c : 0;
            List<BR_Participation__c> ticketsSold = evt.BR_Participations__r;
            upEvt.ticketsSold = evt.BR_Participations__r.size();
            if (evt.BR_Participations__r.size() > 0 && evt.Budgeted_Attendance__c != 0 && evt.Budgeted_Attendance__c != null) {
                upEvt.percentOverUnder = (Integer) (((upEvt.ticketsSold - evt.Budgeted_Attendance__c) / evt.Budgeted_Attendance__c) * 100);
            }
            upEvt.ticketsRemaining = upEvt.ticketsSold >= upEvt.ticketsAllocated ? 0 : upEvt.ticketsAllocated - upEvt.ticketsSold;
            upEvt.dateString = evt.Start_Date__c.format();
            if (evt.End_Date__c != null) {
                upEvt.dateString += ' - ' + evt.End_Date__c.format();
            }
            upcomingEvents.add(upEvt);
        }

        return upcomingEvents;
    }

    public class UpcomingEvent {
        @AuraEnabled
        public String eventId;

        @AuraEnabled
        public String eventName;

        @AuraEnabled
        public Integer ticketsAllocated;

        @AuraEnabled
        public Integer ticketsSold;

        @AuraEnabled
        public Integer ticketsRemaining;

        @AuraEnabled
        public String dateString;

        @AuraEnabled
        public Boolean isPrivate;

        @AuraEnabled
        public Integer budgetedAttendance;

        @AuraEnabled
        public Integer percentOverUnder = 0;

    }
}