/**
 * Created by afaf.awad on 5/11/2021.
 */

global class Schedule_EC_EmailActivity implements Schedulable {

    
    global void execute(SchedulableContext SC) {

        List<Time_Slot__c> timeSlots = [SELECT Id, EC_Order__c,Start_Time__c, Status__c, EC_Email__r.Subject__c, Delivery_Date__c
        FROM Time_Slot__c
        WHERE Delivery_Date__c = YESTERDAY
        AND Status__c = 'Sent'];

        System.debug('TimeSlots == ' + timeSlots);
        If(!timeSlots.isEmpty()) {
            for(Time_Slot__c ts : timeSlots) {
                SendGridActivityController.downloadEmailActivity(ts.Delivery_Date__c, ts.Start_Time__c, ts.EC_Email__r.Subject__c, ts.EC_Order__c);
            }

        }
    }

}