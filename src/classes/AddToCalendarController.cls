/**
 * Created by afaf.awad on 10/8/2020.
 */

public without sharing class AddToCalendarController {

    public BR_Event__c event {get;set;}
    public String location {get;set;}
    public String eventUrl {get;set;}
    public String longStartDate {get;set;}
    public String longEndDate {get;set;}
    public String StartDate {get;set;}
    public String EndDate {get;set;}
    public String StartDateAM21 {get;set;}
    public String EndDateAM21 {get;set;}

    public void getEvent() {

        String eventId = ApexPages.currentPage().getParameters().get('Id');

        event = [SELECT Id, Name, Start_Date__c, End_Date__c, Venue__c, Virtual_Venue__c, Description__c,
                            Portal_Event_Link__c, Registration_Confirmation_Message__c, Invite_Image_Id__c,
                            Virtual_Venue__r.Virtual_Instructions__c, Venue__r.Name, Draft_Program__c
                    FROM BR_Event__c
        WHERE Id =: eventId];

        if(event.Name == 'AACR Annual Meeting 2021'){
            StartDate = Datetime.newInstance(2021,4,10,8,0,0).format();
            EndDate = Datetime.newInstance(2021, 4, 15,18,30,0).format();

            StartDateAM21 = Datetime.newInstance(2021, 5, 17,8,0,0).format();
            EndDateAM21 = Datetime.newInstance(2021, 5, 21,18,30,0).format();

        }else {
            //Create short datetime format in guest timezone for AddToCalendar cmp
            StartDate = event.Start_Date__c.format();
            EndDate = event.End_Date__c.format();
        }

        //Create long datetime format
        longStartDate = event.Start_Date__c.format('MMMM d,  yyyy h:mm a z');
        longEndDate = event.End_Date__c.format('MMMM d,  yyyy h:mm a z');
        

        if(event.Virtual_Venue__c == null){
            location = event.Venue__r.Name;
        }else{
            location = 'https://' + event.Portal_Event_Link__c;
        }

        eventUrl = 'https://' + event.Portal_Event_Link__c;


    }


}