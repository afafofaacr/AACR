/**
 * Created by afaf.awad on 3/23/2021.
 */

@IsTest
public with sharing class ExhibitorTestDataFactory {

    public static EC_Exhibitor_Setting__c buildExhibitorSetting(String accountId){
        return new EC_Exhibitor_Setting__c(Company__c = accountId);
    }

    public static EC_Order__c buildECOrder(String ecSettingId, Contact contact){
        EC_Order__c order = new EC_Order__c();
        order.Order_Name__c = 'Test Order';
        order.Exhibitor_Setting__c = ecSettingId;
        order.Requested_By__c = contact.Id;
        order.Status__c = 'Incomplete';
        order.Order_Date__c = Date.today();
        order.Company__c = contact.AccountId;

        return order;
    }

    public static EC_Email__c buildECEmail(String ecSettingId, String orderId){
        EC_Email__c email = new EC_Email__c();
        email.Exhibitor_Setting__c = ecSettingId;
        email.EC_Order__c = orderId;
        email.Template_Name__c = 'Test Template';
        email.Subject__c = 'Test Class Email';
        email.Call_to_Action__c = 'Click Here';
        email.Action_Link__c = 'www.google.com';
        email.Template_Body__c = 'Lorem ipsum dolor sit amet, consectetur adipisicing elit. Accusamus aliquam assumenda at consequuntur deleniti';

        return email;
    }

    public static EC_Schedule__c buildECSchedule(String eventId){
        EC_Schedule__c schedule = new EC_Schedule__c();
        schedule.Event__c = eventId;
        schedule.Start_Date__c = Date.today();
        schedule.End_Date__c = Date.today().addDays(10);

        return schedule;
    }

    public static Time_Slot__c buildTimeSlot(String orderId, String emailId, String scheduleId){
        Time_Slot__c timeSlot = new Time_Slot__c();
        timeSlot.EC_Order__c = orderId;
        timeSlot.EC_Email__c = emailId;
        timeSlot.EC_Schedule__c = scheduleId;
        timeSlot.Delivery_Date__c = Date.today();
        timeSlot.Start_Time__c = Time.newInstance(8,0,0,0);
        timeSlot.End_Time__c = Time.newInstance(9,0,0,0);

        return timeSlot;
    }


}