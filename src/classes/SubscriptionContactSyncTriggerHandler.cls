/**
 * Created by lauren.lezberg on 10/2/2019.
 */

public with sharing class SubscriptionContactSyncTriggerHandler {


    public static void updateContactFromSubscription(List<OrderApi__Subscription__c> subs, Boolean isUpdate){
        System.debug('updateContactFromSubscription...' + isUpdate);
        Set<Id> contactIds = new Set<Id>();

        for (OrderApi__Subscription__c sub : subs) {
            contactIds.add(sub.OrderApi__Contact__c);
        }


        Map<Id, Contact> contactMap = new Map<Id, Contact>([
                select id, Member_Type__c, Membership_Status__c, Paid_thru_date__c, Application_Status__c, RecordTypeId
                from Contact
                where Id IN:contactIds
        ]);

        List<Contact> toUpdate = new List<Contact>();

        Id memberRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Member').getRecordTypeId();

        Set<Id> contactDirectoryUpdate = new Set<Id>();

        /* for each subscription */
        for (OrderApi__Subscription__c sub :subs) {
            //get contact
            Contact con = contactMap.get(sub.OrderApi__Contact__c);

            //get most recent membership subscription
//            List<OrderApi__Subscription__c> memSubs = RenewalUtils.getIndividualMembershipSubscription(con.Id);
            Map<Id, OrderApi__Subscription__c> memSubsMap = RenewalUtils.getContactMembershipMap(contactIds);
            System.debug('memSubsMap: ' + memSubsMap);

            if(memSubsMap.keySet().contains(con.Id)) {
                //if subscription is the most recent membership subscription and subscription is active and isUpdate OR is NOT update
                if ((sub.Id == memSubsMap.get(con.Id).Id && sub.OrderApi__Is_Active__c && isUpdate) || !isUpdate) {
                    System.debug('update contact from subscription...');
                    //set member type on contact record if contact member type is null or doesnt match item
                    if (sub.OrderApi__Item__r.Name.remove('ship') != con.Member_Type__c || con.Member_Type__c == null) {
                        con.Member_Type__c = sub.OrderApi__Item__r.Name.remove('ship');
                    }
                    //set paid through date on contact record if contact paid through date is null or doesnt match subscription
                    if (sub.OrderApi__Current_Term_End_Date__c != con.Paid_thru_date__c || con.Paid_thru_date__c == null) {
                        con.Paid_thru_date__c = sub.OrderApi__Current_Term_End_Date__c;
                    }

                    //if its not a new application, change record type and status to Member and Current
                    if (con.Application_Status__c == null || con.Application_Status__c == 'Awaiting Payment') {
                        System.debug('Renewal or Awaiting Payment');
                        if (con.RecordTypeId != memberRecordTypeId) {
                            con.RecordTypeId = memberRecordTypeId;
                        }
                        if (con.Membership_Status__c != 'Current') {
                            con.Membership_Status__c = 'Current';
                        }

                        if(con.Application_Status__c == 'Awaiting Payment'){
                            con.Application_Status__c = null;
                        }

                        //get contacts to enable directory badges for
                        contactDirectoryUpdate.add(con.Id);
                    }
                    toUpdate.add(con);
                }
            }
        }

        
        try {
            update toUpdate;

            if(!Test.isRunningTest()) {
                BadgeUtils.enableDirectoryAccess(contactDirectoryUpdate);
            }
        }catch(Exception e){
            System.debug('Could not update contact: ' + e.getMessage());
        }
    }
}