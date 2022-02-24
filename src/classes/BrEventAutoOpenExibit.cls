/**
 * Created by afaf.awad on 10/19/2020.
 */

public without sharing class BrEventAutoOpenExibit {

    public static void openExibit(){

        List<Virtual_Event_Details__c> openEvents = new List<Virtual_Event_Details__c>();
        String cancel = [SELECT Id FROM RecordType WHERE SobjectType = 'BR_Event__c' AND DeveloperName = 'Cancelled'].Id;
        List<Virtual_Event_Details__c> eventDetails = [SELECT Id, Event__r.Start_Date__c, Event__c, Exhibit_Open__c FROM Virtual_Event_Details__c
                                                    WHERE Event__r.Publicly_available__c = TRUE
                                                    AND Event__r.Event_Stage__c = 'Virtual'
                                                    AND Exhibit_Open__c = FALSE
                                                    AND Event__r.Draft__c = FALSE
                                                    AND Event__r.RecordTypeId !=: cancel];

        for(Virtual_Event_Details__c ved : eventDetails){
            if((ved.Event__r.Start_Date__c.getTime() - System.now().getTime())/60000 <= 30
                    && ved.Event__r.Start_Date__c > System.now()){
                System.debug('Opening Event: ' + ved.Event__c );
                ved.Exhibit_Open__c = true;
                openEvents.add(ved);
            }
        }

        update openEvents;
    }

}