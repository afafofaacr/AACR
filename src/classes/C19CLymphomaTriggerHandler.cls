/**
 * Created by lauren.lezberg on 7/14/2020.
 */

public without sharing class C19CLymphomaTriggerHandler {
    public static String lymphomaEventId = Label.Lymphoma_Event_Id;
    public static String covidEventId = Label.C19C_Event_Id;


    public static void updateC19CUserRecords(List<Id> contactIds, List<Id> cancelledContactIds){
        List<User> allC19CUsers = new List<User>();
        List<User> C19CUsers = [SELECT Id, Registered_for_Covid__c FROM User WHERE ContactId IN: contactIds];
        List<User> cancelledUsers = [SELECT Id, Registered_for_Covid__c FROM User WHERE ContactId IN: cancelledContactIds];
        for(User u : C19CUsers){
            if(!u.Registered_for_Covid__c) {
                u.Registered_for_Covid__c = true;
                allC19CUsers.add(u);
            }
        }

        for(User u: cancelledUsers){
            if(u.Registered_for_Covid__c){
                u.Registered_for_Covid__c = false;
                allC19CUsers.add(u);
            }
        }


        try{
            Database.update(allC19CUsers);
        } catch(Exception e){
            System.debug('Exception: ' + e.getMessage());
            new AACRCustomException(e.getMessage(), e.getStackTraceString(), 'C19C User Update');
        }
    }

    public static void updateLymphomaUserRecords(List<Id> contactIds, List<Id> cancelledContactIds){
        List<User> allLymphomaUsers = new List<User>();

        List<User> LymphomaUsers = [SELECT Id, Registered_for_Lymphoma__c FROM User WHERE ContactId IN: contactIds];
        List<User> cancelledUsers = [SELECT Id, Registered_for_Lymphoma__c  FROM User WHERE ContactId IN: cancelledContactIds];

        for(User u : LymphomaUsers){
            if(!u.Registered_for_Lymphoma__c) {
                u.Registered_for_Lymphoma__c = true;
                allLymphomaUsers.add(u);
            }
        }

        for(User u: cancelledUsers){
            if(u.Registered_for_Lymphoma__c){
                u.Registered_for_Lymphoma__c = false;
                allLymphomaUsers.add(u);
            }
        }

        try{
            Database.update(allLymphomaUsers);
        } catch(Exception e){
            new AACRCustomException(e.getMessage(), e.getStackTraceString(), 'Lymphoma User Update');
        }
    }
}