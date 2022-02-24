/**
 * Created by lauren.lezberg on 3/21/2019.
 */

public with sharing class setContactAppStatusTriggerHandler {

    public static void setAppStatus(Id receiptId){
        OrderApi__Receipt__c receipt = [SELECT OrderApi__Sales_Order__c, OrderApi__Sales_Order__r.OrderApi__Description__c, OrderApi__Contact__c FROM OrderApi__Receipt__c WHERE Id=: receiptId];
        Contact updatecontact= [select id, Member_Type__c, Membership_Status__c, Application_Status__c, RecordType.Name from Contact where id = :receipt.OrderApi__Contact__c];
        List<OrderApi__Sales_Order_Line__c> soLinesWithMembership = [SELECT Id FROM OrderApi__Sales_Order_Line__c WHERE OrderApi__Item_Class__r.Name = 'Individual Memberships' AND OrderApi__Sales_Order__c=: receipt.OrderApi__Sales_Order__c];
        if(updatecontact.RecordType.Name == 'Nonmember' && soLinesWithMembership.size()>0) {
            updatecontact.Application_Status__c = 'Pending Approval';
        } else if(receipt.OrderApi__Sales_Order__r.OrderApi__Description__c == 'Transfer Application') {
            updatecontact.Application_Status__c = null;
        }
        update updatecontact;
    }

}