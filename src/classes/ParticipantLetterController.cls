/**
 * Created by afaf.awad on 9/24/2020.
 */

public with sharing class ParticipantLetterController {

    public String bodyContent { get; set; }
    public String eventId {get; set;}
    public String eventName {get; set;}
    public Date startDate {get; set;}
    public Date endDate {get; set;}
    public Boolean isLive {get;set;}

    public ParticipantLetterController(ApexPages.StandardController controller) {}

    public void getLetterContents() {

        eventId = ApexPages.currentPage().getParameters().get('eventId');
        isLive = Boolean.valueOf(ApexPages.currentPage().getParameters().get('isLive'));

        if ( isLive ) {
            getLiveEvents();
        } else {
            getFontevaEvents();
        }

    }

    public void getLiveEvents(){

        BR_Event__c brEvent = [SELECT Id, Name, Letter_Participation__c, Start_Date__c, End_Date__c FROM BR_Event__c WHERE Id =: eventId];

        eventName = brEvent.Name;
        bodyContent = '<div style="font-family:\'Arial Narrow\' !important; font-size:14px;">' + brEvent.Letter_Participation__c + '</div>';
        startDate =  date.newinstance(brEvent.Start_Date__c.year(), brEvent.Start_Date__c.month(), brEvent.Start_Date__c.day());
        endDate = date.newinstance(brEvent.End_Date__c.year(), brEvent.End_Date__c.month(), brEvent.End_Date__c.day());

    }

    public void getFontevaEvents(){

        EventApi__Event__c ftEvent = [SELECT Id, Letter_of_Participation__c, EventApi__Display_Name__c, EventApi__Start_Date__c, EventApi__End_Date__c FROM EventApi__Event__c WHERE Id =: eventId];

        eventName = ftEvent.EventApi__Display_Name__c;
        bodyContent = ftEvent.Letter_of_Participation__c;
        startDate = ftEvent.EventApi__Start_Date__c;
        endDate = ftEvent.EventApi__End_Date__c;
    }

}