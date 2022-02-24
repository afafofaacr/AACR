/**
 * Created by afaf.awad on 2/15/2021.
 */

public without sharing class EC_OrderSchedulerController {

    @AuraEnabled
    public static ScheduleTimes getSchedule(String stepId, String orderId){
        JP_Helper.upsertLastAccessedStep(stepId);
        EC_Event__c globalEvent = EC_Event__c.getOrgDefaults();

//        List<EC_Schedule__c> schedule = null;
//        BR_Event__c event = [SELECT Id FROM BR_Event__c WHERE Name = 'Tumor Heterogeneity: From Single Cells to Clinical Impact'];
        List<EC_Schedule__c>  schedules = [SELECT Id, Name, Start_Date__c, End_Date__c, Event__c FROM EC_Schedule__c WHERE Event__c =: globalEvent.Event_Id__c];
        System.debug('Schedule = ' + schedules);

        Time_Slot__c timeSlot = null;
        List<Time_Slot__c>  timeSlots = [SELECT Id, Start_Time__c, End_Time__c, Delivery_Date__c, EC_Schedule__c FROM Time_Slot__c WHERE EC_Order__c =: orderId];
        System.debug('timeSlots = ' + timeSlots);
        if(!timeSlots.isEmpty()){
            timeSlot = timeSlots[0];
        }

        System.debug('Schedule Times == ' + new ScheduleTimes(schedules, timeSlot, globalEvent.Scheduler_Documentation__c));

        return new ScheduleTimes(schedules, timeSlot, globalEvent.Scheduler_Documentation__c);

    }

    @AuraEnabled
    public static List<Time_Slot__c> getTimeSlots(String scheduleId, String selectedDate){

        System.debug('selectedDate = ' + selectedDate);
        List<Time_Slot__c> timeSlots = [SELECT Id, Start_Time__c, End_Time__c, Blocked__c, EC_Schedule__c FROM Time_Slot__c WHERE Delivery_Date__c =: date.valueOf(selectedDate)
                                            AND EC_Schedule__c =: scheduleId
                                            AND Status__c != 'Cancelled'];


        return timeSlots;

    }

    @AuraEnabled
    public static void saveTimeSlot(String orderId, String scheduleId, String timeSlotId , Integer startHour, Integer startMin, Integer endHour, Integer endMin, String deliveryDate){

        System.debug('creating new Time slot...');

        EC_Email__c email = [SELECT Id FROM EC_Email__c WHERE EC_Order__c =: orderId];

        Time_Slot__c newSlot = new Time_Slot__c();
        if(timeSlotId != null) {
            newSlot.Id = timeSlotId;
        }
        newSlot.EC_Order__c = orderId;
        newSlot.EC_Email__c = email.Id;
        newSlot.EC_Schedule__c = scheduleId;
        newSlot.Start_Time__c = Time.newInstance(startHour, startMin, 0, 0);
        newSlot.End_Time__c = Time.newInstance(endHour, endMin, 0, 0);
        newSlot.Delivery_Date__c = date.valueOf(deliveryDate);

        try{
            upsert newSlot;
            System.debug('new Time Slot created!');
        }catch (Exception e){
            System.debug('Could not save Time Slot:: ' + e.getMessage());
        }

    }

    public class ScheduleTimes{
        @AuraEnabled
        public List<EC_Schedule__c> schedule;
        @AuraEnabled
        public Time_Slot__c timeSlot;
        @AuraEnabled
        public String docUrl;

        public ScheduleTimes(List<EC_Schedule__c> sched, Time_Slot__c timeRange, String url){
            this.schedule = sched;
            this.timeSlot = timeRange;
            this.docUrl = url;
        }
    }





}