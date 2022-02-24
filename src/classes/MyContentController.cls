/**
 * Created by lauren.lezberg on 4/8/2020.
 */

public without sharing class MyContentController {
    public static List<Virtual_Meeting_Links__mdt> virtualMeetings = new List<Virtual_Meeting_Links__mdt>();

    @AuraEnabled
    public static MyContent_Settings__c getLiveRedirectMessage(){
        MyContent_Settings__c settings = MyContent_Settings__c.getOrgDefaults();
        return settings;
    }

    @AuraEnabled
    public static List<EventRegContent> getContent(){
        Id contactId = ECRMUtils.getCurrentLoginUserContactId();

        List<EventRegContent> contents = new List<EventRegContent>();

        //get all virtual meeting records
        List<Virtual_Meeting_Links__mdt> meetings = new List<Virtual_Meeting_Links__mdt>();
        if(Test.isRunningTest()){
            System.debug('running test: ' + virtualMeetings);
            meetings = virtualMeetings;
        } else{
            meetings = [SELECT Event_Id__c, My_Content_Image__c FROM Virtual_Meeting_Links__mdt];
        }
        Set<Id> eventIds = new Set<Id>();
        Map<Id, String> eventImageMap = new Map<Id, String>();
        //get all events with virtual meetings
        for(Virtual_Meeting_Links__mdt vml : meetings){
            eventIds.add(vml.Event_Id__c);
            eventImageMap.put(vml.Event_Id__c, vml.My_Content_Image__c);
        }

        if(!eventIds.isEmpty()) {

            List<EventApi__Attendee__c> tickets = [
                    SELECT Id, EventApi__Event__c, EventApi__Event__r.EventApi__Display_Name__c, EventApi__Event__r.EventApi__Location_And_Date_Text__c,
                            EventApi__Event__r.EventApi__Logo_Image__c, EventApi__Event__r.EventApi__Description__c, EventApi__Contact__c, EventApi__Contact__r.RecordType.Name, EventApi__Contact__r.Membership_Status__c,
                            EventApi__Event__r.EventApi__Start_Date__c,EventApi__Event__r.EventApi__End_Date__c, EventApi__Contact__r.Member_Type__c
                    FROM EventApi__Attendee__c
                    WHERE EventApi__Contact__c = :contactId AND EventApi__Status__c!='Cancelled' AND EventApi__Event__c IN:eventImageMap.keySet()
            ];
            Set<Id> uniqueEventIds = new Set<Id>();
            if (!tickets.isEmpty()) {
                for (EventApi__Attendee__c ticket : tickets) {
                    if(!uniqueEventIds.contains(ticket.EventApi__Event__c)) {
//                    if (ticket.EventApi__Event__r.EventApi__Start_Date__c >= Date.today()) {
                        EventRegContent erc = new EventRegContent();
                        erc.eventId = ticket.EventApi__Event__c;
                        erc.contactId = ticket.EventApi__Contact__c;
                        erc.imgURL = eventImageMap.get(ticket.EventApi__Event__c);
                        erc.eventName = ticket.EventApi__Event__r.EventApi__Display_Name__c;
                        erc.description = ticket.EventApi__Event__r.EventApi__Description__c;
                        erc.dateString = ticket.EventApi__Event__r.EventApi__Location_And_Date_Text__c;
                        erc.attendeeId = ticket.Id;
                        erc.showBusinessMessage = ticket.EventApi__Event__r.EventApi__Display_Name__c == '2020 Virtual Annual Meeting: Selected Presentations' && ticket.EventApi__Contact__r.RecordType.Name == 'Member' && ticket.EventApi__Contact__r.Membership_Status__c == 'Current' && ticket.EventApi__Contact__r.Member_Type__c!= 'Associate Member' && ticket.EventApi__Contact__r.Member_Type__c!= 'Student Member';
//                        erc.dateString = getDateString(ticket.EventApi__Event__r.EventApi__Start_Date__c, ticket.EventApi__Event__r.EventApi__End_Date__c);
                        contents.add(erc);
//                    }
                        uniqueEventIds.add(ticket.EventApi__Event__c);
                    }

                }
            }
        }

        return contents;

    }

    @AuraEnabled
    public static Virtual_Meeting_Links__mdt getVirtualEventLinks(String eventId){
        List<Virtual_Meeting_Links__mdt> meetings = new List<Virtual_Meeting_Links__mdt>();
        if(Test.isRunningTest()){
            System.debug('running test: ' + virtualMeetings);
            meetings = virtualMeetings;
        } else{
            meetings = [SELECT Computer_Check_Link__c, Registration_Open__c, Check_IsActive__c, Event_IsActive__c, View_Link__c, isCME__c, CME_Link__c FROM Virtual_Meeting_Links__mdt WHERE Event_Id__c=: eventId];
        }
        if(!meetings.isEmpty()){
            return meetings[0];
        }
//
        return null;
    }

//    private static String getDateString(Date startDate, Date endDate){
//        Map<Integer,String> monthNameMap=new Map<Integer, String>{1 =>'January', 2=>'February', 3=>'March', 4=>'April', 5=>'May',
//        6=>'June', 7=>'July', 8=>'August', 9=>'September',10=>'October',
//        11=>'November', 12=>'December'};
//        String dateString = monthNameMap.get(startDate.month()) + ' ' + startDate.day() + '-';
//        if(startDate.month() == endDate.month()){
//            dateString += endDate.day();
//        } else {
//            dateString += monthNameMap.get(endDate.month()) + ' ' + endDate.day();
//        }
//
//        dateString += ' ' + startDate.year();
//
//        return dateString;
//
//
//    }

    @AuraEnabled
    public static String getRegisterUrl(String eventId){
        List<Virtual_Meeting_Links__mdt> links = new List<Virtual_Meeting_Links__mdt>();
        if(Test.isRunningTest()){
            System.debug('running test: ' + virtualMeetings);
            links = virtualMeetings;
        } else{
            links = [SELECT Freeman_Event_Id__c FROM Virtual_Meeting_Links__mdt WHERE Event_Id__c=: eventId];
        }

        return '/VirtualRegisterForm?id=' + links[0].Freeman_Event_Id__c;
    }

    @AuraEnabled
    public static List<EventRegContent> getOpenRegistrations(){
        List<Virtual_Meeting_Links__mdt> links = new List<Virtual_Meeting_Links__mdt>();
        if(Test.isRunningTest()){
            System.debug('running test: ' + virtualMeetings);
            links = virtualMeetings;
        } else{
            links = [SELECT Event_Id__c, My_Content_Image__c FROM Virtual_Meeting_Links__mdt WHERE Registration_Open__c = true];
        }
        Set<Id> eventIds = new Set<Id>();
        Map<Id, String> eventImageMap = new Map<Id, String>();
        //get all events with virtual meetings
        for(Virtual_Meeting_Links__mdt vml : links){
            eventIds.add(vml.Event_Id__c);
            eventImageMap.put(vml.Event_Id__c, vml.My_Content_Image__c);
        }

        Id contactId = ECRMUtils.getCurrentLoginUserContactId();
        List<EventApi__Attendee__c> attendeeRecs = [SELECT Id, EventApi__Event__c FROM EventApi__Attendee__c WHERE EventApi__Event__c IN: eventIds AND EventApi__Contact__c=:contactId];
        Set<Id> attendingEvtIds = new Set<Id>();
        for(EventApi__Attendee__c att : attendeeRecs){
            attendingEvtIds.add(att.EventApi__Event__c);
        }

        List<EventApi__Event__c> events = [SELECT Id, EventApi__Description__c, EventApi__Logo_Image__c,EventApi__Display_Name__c, EventApi__Location_And_Date_Text__c FROM EventApi__Event__c WHERE Id IN: eventIds];
        List<EventRegContent> registrations = new List<EventRegContent>();
        for(EventApi__Event__c evt : events){
            if(!attendingEvtIds.contains(evt.Id)) {
                EventRegContent erc = new EventRegContent();
                erc.eventId = evt.Id;
                erc.imgURL = eventImageMap.get(evt.Id);
                erc.dateString = evt.EventApi__Location_And_Date_Text__c;
                erc.eventName = evt.EventApi__Display_Name__c;
                erc.description = evt.EventApi__Description__c;
                registrations.add(erc);
            } 
        }

        return registrations;

    }

    @AuraEnabled
    public static Contact getContactInfo(){

        String contactId = Apexpages.currentPage().getParameters().get('ContactID');

        Contact con = [Select Id, Name, Salutation, Title FROM Contact where Id =: contactId];

        return con;
    }


    @AuraEnabled
    public static String getLetterToDownload(String attendeeId){ 

        String servUrl = Url.getSalesforceBaseUrl().toExternalForm();

        List<EventApi__Attendee__c> attendees = [SELECT Id,EventApi__Contact__c, EventApi__Event__c FROM EventApi__Attendee__c WHERE Id =: attendeeId];

        for (EventApi__Attendee__c a : attendees) {
            if ( a.EventApi__Contact__c != null ) {
                servUrl += '/LetterOfParticipation?Id=' + a.EventApi__Contact__c + '&eventId=' + a.EventApi__Event__c;
            } else {
                system.debug('*** Contact is null ');
                servUrl += '/myAACRHelpCustom';
            }
        }

        system.debug('*** servUrl ' + servUrl);
        return servUrl;
    }


    public class EventRegContent{
        @AuraEnabled
        public String eventId;

        @AuraEnabled
        public String contactId;

        @AuraEnabled
        public String imgURL;

        @AuraEnabled
        public String dateString;

        @AuraEnabled
        public String eventName;

        @AuraEnabled
        public String description;

        @AuraEnabled
        public String attendeeId;

        @AuraEnabled
        public Boolean showBusinessMessage;
    }

}