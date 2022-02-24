/**
 * Created by lauren.lezberg on 1/10/2020.
 */

public with sharing class EventScheduleViewerController {


    @AuraEnabled
    public static void deleteRecord(String recordId){

        try{
            Database.delete(recordId);
        }catch(Exception e){
            System.debug('Could not delete record: ' + e.getMessage());
            throw new AACRCustomException(recordId, e.getMessage(), e.getStackTraceString(), 'Event Schedule');
        }
    }


    /**
     * @purpose Retrieve full schedule for specified event. Creates a wrapper object of each daily schedule based of event dates.
     *
     * @param eventId
     *
     * @return ScheduleData wrapper object
     */
    @AuraEnabled
    public static ScheduleData getEventSchedule(String eventId){
        System.debug('getEventSchedule for event: ' + eventId);

        if(String.isBlank(eventId)){
            new AACRCustomException('EventId is null', 'EventScheduleViewerController.getEventSchedule', 'Event Schedule');
        }

        List<EventDaySchedule> eventSchedules = new List<EventDaySchedule>();
        //get all sessions and speakers for event
        List<AACR_Session__c> sessions = [SELECT Id, Date__c, Name, Start_Time__c, End_Time__c, Description__c, Event__r.Start_Date__c, Event__r.End_Date__c,
                                        (SELECT Id, Name,Speaker__c, Speaker__r.Name, Roles__c,Status__c, Presentation_Time__c FROM Session_Speakers__r WHERE RecordType.Name!='Chair Person' ORDER BY Presentation_Time__c ASC)
                                    FROM AACR_Session__c
                                    WHERE Event__c=: String.escapeSingleQuotes(eventId)
                                    ORDER BY Date__c, Start_Time__c];
//                                    AND RecordType.Name != 'CME Session'

        if(!sessions.isEmpty()) {
            List<Date> eventDates = new List<Date>();
            //get dates for event
            Date startDate = Date.newInstance(sessions[0].Event__r.Start_Date__c.year(),sessions[0].Event__r.Start_Date__c.month(), sessions[0].Event__r.Start_Date__c.day() );
            Date endDate = Date.newInstance(sessions[0].Event__r.End_Date__c.year(), sessions[0].Event__r.End_Date__c.month(), sessions[0].Event__r.End_Date__c.day());

            eventDates.add(startDate);

            if(endDate!=null) {
                Integer daysInBetween = startDate.daysBetween(endDate);

                for(Integer i=1; i<=daysInBetween;i++){
                    Date nextDay = startDate.addDays(i);
                    eventDates.add(nextDay);
                }

            }

            System.debug('Event Dates: ' + eventDates);

            //build list of schedules per day of sessions and speakers
            Integer idx =  0;
            for(Date evtDate : eventDates){
                EventDaySchedule daySchedule = new EventDaySchedule();
                daySchedule.eventDay = evtDate;
                daySchedule.sessionIdx = String.valueOf(idx);
                List<EventSession> daySessions = new List<EventSession>();

                    for (AACR_Session__c session : sessions) {
                        if (session.Date__c.format() == evtDate.format()) {
                            //build session wrapper object
                            EventSession eSession = new EventSession();
                            eSession.sessionId = session.Id;
                            eSession.sessionName = session.Name;
                            eSession.startTime = DateTime.newInstance(evtDate, session.Start_Time__c);
                            eSession.endTime = DateTime.newInstance(evtDate, session.End_Time__c);
                            eSession.description = session.Description__c;

                            List<Session_Speaker__c> speakerSessions = session.Session_Speakers__r;
                            List<SessionPanel> panels = new List<SessionPanel>();
                            for (Session_Speaker__c speaker : speakerSessions) {
                                //build presentation wrapper object
                                SessionPanel panel = new SessionPanel();
                                panel.panelId = speaker.Id;
                                panel.panelName = speaker.Name;
                                panel.speakerName = speaker.Speaker__r.Name;
                                panel.speakerRoles = speaker.Roles__c;
                                panel.speakerStatus = speaker.Status__c;
                                panel.speakerId = speaker.Speaker__c;
                                if (speaker.Presentation_Time__c != null) {
                                    panel.panelTime = DateTime.newInstance(evtDate, speaker.Presentation_Time__c);
                                }
                                panels.add(panel);
                            }

                            System.debug('presentations/panels: ' + panels);
                            eSession.panels = panels;
                            daySessions.add(eSession);
                        }
                        System.debug('sessions: ' + daySessions);
                        daySchedule.sessions = daySessions;
                    }

                eventSchedules.add(daySchedule);
                idx++;
            }

        } else { //if there are no sessions, get event dates
            List<Date> eventDates = new List<Date>();

            BR_Event__c evt = [SELECT Start_Date__c, End_Date__c FROM BR_Event__c WHERE Id=: eventId];

            Date startDate = Date.newInstance(evt.Start_Date__c.year(),evt.Start_Date__c.month(), evt.Start_Date__c.day() );
            eventDates.add(startDate);

            if(evt.End_Date__c!=null){
                Date endDate = Date.newInstance(evt.End_Date__c.year(),evt.End_Date__c.month(), evt.End_Date__c.day());
                Integer daysInBetween = startDate.daysBetween(endDate);

                for(Integer i=1; i<=daysInBetween;i++){
                    Date nextDay = startDate.addDays(i);
                    eventDates.add(nextDay);
                }
            }

            for(Date evtDate : eventDates) {
                EventDaySchedule daySchedule = new EventDaySchedule();
                daySchedule.eventDay = evtDate;
                List<EventSession> daySessions = new List<EventSession>();
                daySchedule.sessions = daySessions;

                eventSchedules.add(daySchedule);
            }
        }

        BR_Event__c event = [SELECT Id, Start_Date__c, End_Date__c FROM BR_Event__c WHERE Id=: eventId];

        return new ScheduleData(event,eventSchedules);

    }
    

    /**
     * Wrapper object for list of daily schedules for event
     */
    public class ScheduleData{
        @AuraEnabled
        public BR_Event__c event;

        @AuraEnabled
        public List<EventDaySchedule> schedule;


        public ScheduleData(BR_Event__c evt, List<EventDaySchedule> sched){
            this.event = evt;
            this.schedule = sched;
        }
    }


    /**
     * Wrapper object for an event daily schedule
     */
    public class EventDaySchedule{
        @AuraEnabled
        public Date eventDay;

        @AuraEnabled
        public String sessionIdx;

        @AuraEnabled
        public List<EventSession> sessions;

    }

    /**
     * Wrapper object for event session
     *
     * Needed to convert times to datetime in order to display in lightning component with correct formatting.
     */
    public class EventSession{
        @AuraEnabled
        public String sessionName;

        @AuraEnabled
        public Datetime startTime;

        @AuraEnabled
        public Datetime endTime;

        @AuraEnabled
        public String description;

        @AuraEnabled
        public String sessionId;

        @AuraEnabled
        public List<SessionPanel> panels;
    }

    /**
     * Wrapper object for event session speaker/presentation/panel
     *
     * Needed to convert presentation time to datetime in order to display in lightning component with correct formatting.
     */
    public class SessionPanel{
        @AuraEnabled
        public String speakerId;

        @AuraEnabled
        public String panelId;

        @AuraEnabled
        public String speakerName;

        @AuraEnabled
        public String speakerRoles;

        @AuraEnabled
        public String speakerStatus;

        @AuraEnabled
        public Datetime panelTime;

        @AuraEnabled
        public String panelName;
    }

}