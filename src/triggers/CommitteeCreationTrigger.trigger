/**
 * Created by lauren.lezberg on 7/22/2019.
 */

trigger CommitteeCreationTrigger on OrderApi__Receipt__c (after insert) {

    if(Trigger.isAfter && Trigger.isInsert){
        CommitteeCreationHandler.createWGCommittees(Trigger.new);

        CreateOpportunitiesHandler.createDonationOpp(Trigger.new);
    }


//    System.debug('committeeCreationTrigger....');
//    List<OrderApi__Receipt__c> receipts = [SELECT OrderApi__Sales_Order__c, OrderApi__Contact__c FROM OrderApi__Receipt__c WHERE Id IN: Trigger.new];
//    if(receipts.size()==1 ) {
//        if(receipts[0].OrderApi__Sales_Order__c != null) {
//            System.debug('receipt sales order Id: ' + receipts[0].OrderApi__Sales_Order__c);
//            CommitteeCreationTriggerHandler.createCommittees(receipts[0].OrderApi__Sales_Order__c, receipts[0].OrderApi__Contact__c);
//        }
//    }
}