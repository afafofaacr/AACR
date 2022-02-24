/**
 * Created by afaf.awad on 5/8/2020.
 */

public with sharing class EventLetterController {

    public String bodyContent { get; set; }
    public Object event {get; set;}
    public String eventId {get; set;}

    public EventLetterController(ApexPages.StandardController controller) {}

    public void getLetterContents() {

        eventId = ApexPages.currentPage().getParameters().get('eventId');

        BR_Event__c brEvent = [SELECT Id, Name, Start_Date__c, End_Date__c FROM BR_Event__c WHERE Id =: eventId];

        event = brEvent;
        bodyContent = brEvent.Name;

    }

//    public void getFontevaEvents(){
//
//        EventApi__Event__c ftEvent = [SELECT Id, Letter_of_Participation__c, EventApi__Display_Name__c, EventApi__Start_Date__c, EventApi__End_Date__c FROM EventApi__Event__c WHERE Id =: eventId];
//
//        event = ftEvent;
//        bodyContent = ftEvent.Letter_of_Participation__c;
//    }

}