/**
 * Created by lauren.lezberg on 4/13/2021.
 */

public with sharing class AACR_InvoiceTriggerHandler {

    public void setAppStatusFromInvoice(Id invId){
        System.debug('setAPpStatusFromInvoice....');
        OrderApi__Invoice__c inv = [SELECT OrderApi__Sales_Order__c, OrderApi__Contact__c FROM OrderApi__Invoice__c WHERE Id=: invId];
        Contact updatecontact= [select id, Member_Type__c, Membership_Status__c, Application_Status__c, RecordType.Name from Contact where id = :inv.OrderApi__Contact__c];
        List<OrderApi__Sales_Order_Line__c> soLinesWithMembership = [SELECT Id, OrderApi__Item__r.Name FROM OrderApi__Sales_Order_Line__c WHERE OrderApi__Item_Class__r.Name = 'Individual Memberships' AND OrderApi__Sales_Order__c=: inv.OrderApi__Sales_Order__c];
        System.debug('contact....' + updatecontact);
        System.debug('soLinesWithMembership: ' + soLinesWithMembership);
        if(soLinesWithMembership.size()==1){
            if(updatecontact.RecordType.Name == 'Member' && updatecontact.Membership_Status__c == 'Current'){
                if(soLinesWithMembership[0].OrderApi__Item__r.Name.remove('ship') != updatecontact.Member_Type__c){
                    updatecontact.Application_Status__c = 'Pending Transfer';
                }
                //Reinstatements & reinstate/transfer
            } else if(updatecontact.RecordType.Name == 'Prior Member' && (updatecontact.Membership_Status__c == 'Suspended (Delinquent)' || updatecontact.Membership_Status__c == 'Suspended (Resigned)')){
                if(soLinesWithMembership[0].OrderApi__Item__r.Name.remove('ship') != updatecontact.Member_Type__c){ //Reinstate/transfer
                    updatecontact.Application_Status__c = 'Pending Reinstatement-Transfer';
                } else if(soLinesWithMembership[0].OrderApi__Item__r.Name.remove('ship') == updatecontact.Member_Type__c){ //Reinstate
                    updatecontact.Application_Status__c = 'Pending Reinstatement';
                }
            }

            System.debug('updating contact....' + updatecontact);
            update updatecontact;
        }
    }



}