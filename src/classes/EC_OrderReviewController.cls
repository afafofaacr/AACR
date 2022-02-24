/**
 * Created by afaf.awad on 2/24/2021.
 */

public without sharing class EC_OrderReviewController {

    @AuraEnabled
    public static ReviewOrder getReviewOrder(String stepId, String orderId){
        if(stepId != null) {
            JP_Helper.upsertLastAccessedStep(stepId);
        }
        EC_Order__c  order = EC_Helper.getOrderRecord(orderId);
        List<Time_Slot__c> timeSlots = [SELECT Id, Start_Time__c, End_Time__c, Delivery_Date__c FROM Time_Slot__c WHERE EC_Order__c =: orderId];

        if(!timeSlots.isEmpty()){
            return new ReviewOrder(order, timeSlots[0]);
        }else
        {
            return new ReviewOrder(order, null);

        }

    }

    @AuraEnabled
    public static Boolean clearLastStep(String stepId){
        List<Process_Steps__mdt> currentStep = [SELECT Process__c FROM Process_Steps__mdt WHERE Id =: stepId LIMIT 1];
        if (currentStep.size() == 1) {
            JP_Helper.deleteContactLastAccessedStep(currentStep[0].Process__c);
        }

        return true;
    }

    @AuraEnabled
    public static String getPreviousStep(String stepId){
        return EC_Helper.getPreviousStep(stepId, 'New_Exhibitor_Order');
    }

    public class ReviewOrder{
        @AuraEnabled
        public EC_Order__c order;
        @AuraEnabled
        public Time_Slot__c timeSlot;

        public ReviewOrder(EC_Order__c exOrder, Time_Slot__c timeRange){
            this.order = exOrder;
            this.timeSlot = timeRange;
        }
    }

}