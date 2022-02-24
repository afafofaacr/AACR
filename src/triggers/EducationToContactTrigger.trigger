/**
 * Created by lauren.lezberg on 4/23/2021.
 */

trigger EducationToContactTrigger on Education__c (after insert, after update) {

    if(Trigger.isAfter){
        //update contact with education
        if(Trigger.isUpdate){
            if(Trigger.old[0].Date_of_Expected_Graduation__c!=Trigger.new[0].Date_of_Expected_Graduation__c){
                EducationToContactTriggerHandler.updateContactGraduationDate(Trigger.new[0]);
            }
        } else if(Trigger.isInsert){
            if(Trigger.new[0].Date_of_Expected_Graduation__c!=null){
                EducationToContactTriggerHandler.updateContactGraduationDate(Trigger.new[0]);
            }
        }
    }
}