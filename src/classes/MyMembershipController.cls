/**
 * Created by lauren.lezberg on 4/21/2021.
 */

public with sharing class MyMembershipController {

    @AuraEnabled
    public static List<OrderApi__Subscription__c> getJournals(String contactId){
        List<OrderApi__Subscription__c> journals = new List<OrderApi__Subscription__c>();
        OrderApi__Subscription__c memSub;

        List<OrderApi__Subscription__c> memSubs = RenewalUtils.getIndividualMembershipSubscription(contactId);
        if(!memSubs.isEmpty()){
            memSub = memSubs[0];

            List<String> classNames = new List<String>{'Journal Subscriptions', 'Complimentary Journals'};
            List<OrderApi__Subscription__c> subs = new List<OrderApi__Subscription__c>();

//            if(memSub.OrderApi__Item__r.Name=='Emeritus Membership' || memSub.OrderApi__Item__r.Name=='Honorary Membership'){
                subs = [SELECT OrderApi__Item__r.Portal_Label__c, OrderApi__Item__r.Name, Id, OrderApi__Item__r.Association_Journals_Type__c, OrderApi__Current_Term_End_Date__c, OrderApi__Days_To_Lapse__c, OrderApi__Item_Class__r.Name
                FROM OrderApi__Subscription__c
                WHERE OrderApi__Item_Class__r.Name IN:classNames
//                AND OrderApi__Paid_Through_Date__c >= :Date.today()
                AND OrderApi__Is_Active__c = true
                AND OrderApi__Contact__c = :contactId
                AND OrderApi__Is_Cancelled__c = false];
//            } else {
//                subs = [SELECT OrderApi__Item__r.Portal_Label__c, OrderApi__Item__r.Name, Id, OrderApi__Item__r.Association_Journals_Type__c, OrderApi__Current_Term_End_Date__c, OrderApi__Days_To_Lapse__c, OrderApi__Item_Class__r.Name
//                FROM OrderApi__Subscription__c
//                WHERE OrderApi__Item_Class__r.Name IN:classNames
//                AND OrderApi__Paid_Through_Date__c = :memSub.OrderApi__Paid_Through_Date__c
//                AND OrderApi__Contact__c = :contactId
//                AND OrderApi__Is_Cancelled__c = false];
//            }


            for (OrderApi__Subscription__c sub : subs) {
                if (sub.OrderApi__Item_Class__r.Name == 'Journal Subscriptions' || sub.OrderApi__Item_Class__r.Name == 'Complimentary Journals') {
                    journals.add(sub);
                }
            }
        }

        return journals;
    }

    @AuraEnabled
    public static List<OrderApi__Subscription__c> getWorkingGroups(String contactId){
        List<OrderApi__Subscription__c> workingGroups = new List<OrderApi__Subscription__c>();
        OrderApi__Subscription__c memSub;

        List<OrderApi__Subscription__c> memSubs = RenewalUtils.getIndividualMembershipSubscription(contactId);
        if(!memSubs.isEmpty()){
            memSub = memSubs[0];

            List<String> classNames = new List<String>{'Working Groups'};
            List<OrderApi__Subscription__c> subs = new List<OrderApi__Subscription__c>();

//            if(memSub.OrderApi__Item__r.Name=='Emeritus Membership' || memSub.OrderApi__Item__r.Name=='Honorary Membership'){
                subs = [SELECT OrderApi__Item__r.Portal_Label__c, OrderApi__Item__r.Name, Id, OrderApi__Item__r.Association_Journals_Type__c, OrderApi__Current_Term_End_Date__c, OrderApi__Days_To_Lapse__c, OrderApi__Item_Class__r.Name
                FROM OrderApi__Subscription__c
                WHERE OrderApi__Item_Class__r.Name IN:classNames
//                AND OrderApi__Paid_Through_Date__c >= :Date.today()
                AND OrderApi__Is_Active__c = true
                AND OrderApi__Contact__c = :contactId
                AND OrderApi__Is_Cancelled__c = false];
//            } else {
//                subs = [SELECT OrderApi__Item__r.Portal_Label__c, OrderApi__Item__r.Name, Id, OrderApi__Item__r.Association_Journals_Type__c, OrderApi__Current_Term_End_Date__c, OrderApi__Days_To_Lapse__c, OrderApi__Item_Class__r.Name
//                FROM OrderApi__Subscription__c
//                WHERE OrderApi__Item_Class__r.Name IN:classNames
//                AND OrderApi__Paid_Through_Date__c = :memSub.OrderApi__Paid_Through_Date__c
//                AND OrderApi__Contact__c = :contactId
//                AND OrderApi__Is_Cancelled__c = false];
//            }


            for (OrderApi__Subscription__c sub : subs) {
//                if (sub.OrderApi__Item_Class__r.Name == 'Working Groups') {
                    workingGroups.add(sub);
//                }
            }
        }

        return workingGroups;
    }

}