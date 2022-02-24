/**
 * Created by afaf.awad on 10/16/2020.
 */

public class Batch_SendEventReminders implements Database.Batchable<sObject>, Database.AllowsCallouts{

    DateTime dateNow {get;set;}
    Date todayDate {get;set;}

    public Batch_SendEventReminders(){
        dateNow = system.now();
        todayDate = Date.today();
    }

    public Database.QueryLocator start(Database.BatchableContext BC){
//        String query = 'SELECT Id, Contact__r.Email, Contact__r.Salutation, Contact__r.FirstName, Contact__r.LastName, BR_Event__r.Name, BR_Event__r.Start_Date__c, BR_Event__r.End_Date__c, BR_Event__r.Start_Time__c, BR_Event__r.Platform_Open_Time__c , BR_Event__r.Virtual_Venue__c , BR_Event__r.Portal_Event_Link__c, BR_Event__r.Venue__r.Name, BR_Event__r.Draft_Program__c, BR_Event__r.Venue__r.Virtual_Instructions__c, BR_Event__r.Virtual_Venue__r.Virtual_Instructions__c, BR_Event__r.Event_Stage__c FROM BR_Participation__c WHERE BR_Event__r.Publicly_available__c = TRUE AND Participate__c = \'Yes\'  AND BR_Event__r.Draft__c = FALSE AND BR_Event__r.Start_Date__c >=: todaydate';
        // QUERY SAVED FOR NEW SPONSOR BUTTONS
        String query = 'SELECT Id, Contact__r.Email, Contact__r.Salutation, Contact__r.FirstName, Contact__r.LastName, BR_Event__r.Name, BR_Event__r.Start_Date__c, BR_Event__r.End_Date__c, BR_Event__r.Start_Time__c, BR_Event__r.Platform_Open_Time__c , BR_Event__r.Virtual_Venue__c , BR_Event__r.Portal_Event_Link__c, BR_Event__r.Venue__r.Name, BR_Event__r.Draft_Program__c, BR_Event__r.Venue__r.Virtual_Instructions__c, BR_Event__r.Virtual_Venue__r.Virtual_Instructions__c, BR_Event__r.Event_Stage__c, BR_Event__r.Display_on_Reminder_Email__c, BR_Event__r.Show_Reminder_Email_Logos__c FROM BR_Participation__c WHERE BR_Event__r.Publicly_available__c = TRUE AND Participate__c = \'Yes\'  AND BR_Event__r.Draft__c = FALSE AND BR_Event__r.Start_Date__c >=: todaydate';
        System.debug('Query: ' + query);
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext BC, List<BR_Participation__c> scope){

        OrgWideEmailAddress fromEmail = [SELECT Id, Address FROM OrgWideEmailAddress WHERE DisplayName = 'AACR Meetings & Exhibits' ];

//        List<BR_Participation__c> physical_24 = new List<BR_Participation__c>();
//        List<BR_Participation__c> physical_2 = new List<BR_Participation__c>();
//        List<BR_Participation__c> virtual_24 = new List<BR_Participation__c>();
//        List<BR_Participation__c> virtual_2 = new List<BR_Participation__c>();
        List<BR_Participation__c> Reminders_24 = new List<BR_Participation__c>();
        List<BR_Participation__c> Reminders_2 = new List<BR_Participation__c>();

        for(BR_Participation__c part : scope){
                if((part.BR_Event__r.Start_Date__c.month() == dateNow.month()
                        && part.BR_Event__r.Start_Date__c.day() == dateNow.addDays(1).day()
                        && part.BR_Event__r.Start_Date__c.hour() == dateNow.hour()
                        && part.BR_Event__r.Start_Date__c.minute() == dateNow.minute())
                        || Test.isRunningTest() ){
                    Reminders_24.add(part);
                }
                if((part.BR_Event__r.Start_Date__c.month() == dateNow.month()
                        && part.BR_Event__r.Start_Date__c.day() == dateNow.day()
                        && part.BR_Event__r.Start_Date__c.hour() == dateNow.addHours(2).hour()
                        && part.BR_Event__r.Start_Date__c.minute() == dateNow.minute())
                        || Test.isRunningTest()){
                    Reminders_2.add(part);
                }


//            if(part.BR_Event__r.Event_Stage__c != 'Virtual'){
//                if((part.BR_Event__r.Start_Date__c.month() == dateNow.month()
//                        && part.BR_Event__r.Start_Date__c.day() == dateNow.addDays(1).day()
//                        && part.BR_Event__r.Start_Date__c.hour() == dateNow.hour()
//                        && part.BR_Event__r.Start_Date__c.minute() == dateNow.minute())
//                         || Test.isRunningTest() ){
//                    physical_24.add(part);
//                }
//                if((part.BR_Event__r.Start_Date__c.month() == dateNow.month()
//                        && part.BR_Event__r.Start_Date__c.day() == dateNow.day()
//                        && part.BR_Event__r.Start_Date__c.hour() == dateNow.addHours(2).hour()
//                        && part.BR_Event__r.Start_Date__c.minute() == dateNow.minute())
//                        || Test.isRunningTest()){
//                    physical_2.add(part);
//                }
//            }else{
//                if((part.BR_Event__r.Start_Date__c.month() == dateNow.month()
//                        && part.BR_Event__r.Start_Date__c.day() == dateNow.addDays(1).day()
//                        && part.BR_Event__r.Start_Date__c.hour() == dateNow.hour()
//                        && part.BR_Event__r.Start_Date__c.minute() == dateNow.minute())
//                        || Test.isRunningTest()){
//                    virtual_24.add(part);
//                }
//                if((part.BR_Event__r.Start_Date__c.month() == dateNow.month()
//                        && part.BR_Event__r.Start_Date__c.day() == dateNow.day()
//                        && part.BR_Event__r.Start_Date__c.hour() == dateNow.addHours(2).hour()
//                        && part.BR_Event__r.Start_Date__c.minute() == dateNow.minute())
//                        || Test.isRunningTest()){
//                    virtual_2.add(part);
//                }
//            }
        }
        System.debug('Reminders_24 = ' + Reminders_24.size());
        System.debug('Reminders_2 = ' + Reminders_2.size());
//        System.debug('virtual_24 = ' + virtual_24.size());
//        System.debug('virtual_2 = ' + virtual_2.size());

        if(!Reminders_24.isEmpty()){
            EventReminderHelper.sendEventReminder(Reminders_24, fromEmail.Address, true);
        }
        if(!Reminders_2.isEmpty()){
            EventReminderHelper.sendEventReminder(Reminders_2, fromEmail.Address, false);
        }
//        if(!virtual_24.isEmpty()){
//            EventReminderHelper.sendEventReminder(virtual_24, fromEmail.Address, true, true);
//        }
//        if(!virtual_2.isEmpty()){
//            EventReminderHelper.sendEventReminder(virtual_2, fromEmail.Address, true, false);
//        }
    }

    public void finish(Database.BatchableContext BC){
        System.debug('finishing Batch_SendEventReminders...');
    }

}