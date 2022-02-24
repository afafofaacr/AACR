trigger setContactAppStatus on OrderApi__Receipt__c (after insert, after update) {

    if(trigger.isAfter){
        //add to query --> OrderApi__Sales_Order__r.Offer_Membership__c
        List<OrderApi__Receipt__c > receipt = [SELECT OrderApi__Is_Posted__c, OrderApi__Sales_Order__r.Offer_Membership__c FROM OrderApi__Receipt__c WHERE Id IN: trigger.new];
        if(trigger.isInsert) {
            setContactAppStatusTriggerHandler.setAppStatus(receipt[0].Id);
        }
        else if (trigger.isUpdate){ /** OFFER APP **/
            List<Id> membershipOffers = new List<Id>();
            for(OrderApi__Receipt__c rec : receipt){
                if(Trigger.oldMap.get(rec.Id).OrderApi__Is_Posted__c == false && rec.OrderApi__Is_Posted__c) {
                    if (rec.OrderApi__Sales_Order__r.Offer_Membership__c != null) {
                        membershipOffers.add(rec.OrderApi__Sales_Order__r.Offer_Membership__c);
                    }
                }
            }
            ValidateOfferCode.useOffers(membershipOffers);
        }
    }
}