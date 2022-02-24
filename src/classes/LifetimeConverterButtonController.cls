/**
 * Created by lauren.lezberg on 5/18/2021.
 */

public with sharing class LifetimeConverterButtonController {

    @AuraEnabled
    public static Boolean getVisibility(String contactId){
        Boolean showBtn = false;
        List<OrderApi__Subscription__c> subscriptions = RenewalUtils.getIndividualMembershipSubscription(contactId);
        if(!subscriptions.isEmpty()){
            if(subscriptions[0].OrderApi__Is_Active__c && subscriptions[0].OrderApi__Item__r.Name=='Active Membership' && subscriptions[0].OrderApi__Subscription_Plan__r.Name!='Lifetime'){
                showBtn = true;
            }
        }

        showBtn = showBtn && FeatureManagement.checkPermission('Lifetime_Conversion');

        return showBtn;
    }

    @AuraEnabled
    public static void doConversion(String contactId){

        List<OrderApi__Subscription__c> subscriptions = RenewalUtils.getIndividualMembershipSubscription(contactId);
        if(!subscriptions.isEmpty()){
            OrderApi__Subscription__c memSub = subscriptions[0];
            List<OrderApi__Renewal__c> terms = [SELECT Id, OrderApi__Term_End_Date__c, OrderApi__Grace_Period_End_Date__c, OrderApi__Subscription_Plan__c FROM OrderApi__Renewal__c WHERE OrderApi__Subscription__c=:memSub.Id ORDER BY OrderApi__Term_End_Date__c DESC];
            List<OrderApi__Subscription_Plan__c> lifeTimePlans = [SELECT Id FROM OrderApi__Subscription_Plan__c WHERE Name='Lifetime'];
            memSub.OrderApi__Subscription_Plan__c = lifeTimePlans[0].Id;
            memSub.OrderApi__Current_Term_End_Date__c = memSub.OrderApi__Current_Term_End_Date__c.addYears(100);
            memSub.OrderApi__Grace_Period_End_Date__c = null;

            terms[0].OrderApi__Term_End_Date__c = terms[0].OrderApi__Term_End_Date__c.addYears(100);
            terms[0].OrderApi__Grace_Period_End_Date__c = null;
            terms[0].OrderApi__Subscription_Plan__c = lifeTimePlans[0].Id;

            try{
                update memSub;
                update terms[0];
            } catch(Exception e){
                System.debug('could not convert member to lifetime: ' + e.getMessage());
                new AACRCustomException(contactId, e.getMessage(), e.getStackTraceString(), 'Lifetime Conversion');
            }


        }
    }
}