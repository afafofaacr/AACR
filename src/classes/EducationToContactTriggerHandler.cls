/**
 * Created by lauren.lezberg on 4/23/2021.
 */

public without sharing class EducationToContactTriggerHandler {

    public static void updateContactGraduationDate(Education__c edu){
        List<Contact> contacts = [SELECT Id, Expected_Completion_Date__c FROM Contact WHERE Id=: edu.Education_Related_to_Contact__c];
        if(!contacts.isEmpty()){
            if(edu.Date_of_Expected_Graduation__c > contacts[0].Expected_Completion_Date__c || contacts[0].Expected_Completion_Date__c==null){
                contacts[0].Expected_Completion_Date__c = edu.Date_of_Expected_Graduation__c;
                update contacts[0];
            }
        }
    }
}