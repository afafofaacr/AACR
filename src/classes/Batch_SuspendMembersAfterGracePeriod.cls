/**
 * Created by lauren.lezberg on 1/21/2020.
 */

global class Batch_SuspendMembersAfterGracePeriod implements Database.Batchable<sObject>{

    global Database.QueryLocator start(Database.BatchableContext BC){
        String query = 'SELECT Id, Member_Type__c, Membership_Status__c, RecordTypeId, (SELECT Id, OrderApi__Is_Expired__c, OrderApi__Item__r.Managed__c, OrderApi__Item__r.Name, OrderApi__Paid_Through_Date__c, OrderApi__Grace_Period_End_Date__c FROM OrderApi__Subscriptions__r WHERE OrderApi__Item_Class__r.Name=\'Individual Memberships\' ORDER BY OrderApi__Paid_Through_Date__c DESC, CreatedDate DESC LIMIT 1) FROM Contact WHERE RecordType.Name = \'Member\' AND Membership_Status__c = \'Current\'';
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<Contact> scope){

        Id priorMemberId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Prior Member').getRecordTypeId();
        List<Contact> toUpdate = new List<Contact>();

        //iterate through contacts
        for(Contact con : scope){
            System.debug('subs: ' + con.OrderApi__Subscriptions__r);
            //if contacts have a valid most recent membership subscription
            if(!con.OrderApi__Subscriptions__r.isEmpty()){
                //if subscription is expired and item matches contact membership type and paid through date year is one less than the grace period end date year
                if(con.OrderApi__Subscriptions__r[0].OrderApi__Is_Expired__c
                        && con.OrderApi__Subscriptions__r[0].OrderApi__Item__r.Name == con.Member_Type__c + 'ship'
                        && con.OrderApi__Subscriptions__r[0].OrderApi__Paid_Through_Date__c.year() == (System.now().year()-1)){
                    //flip contact to suspended prior member & add to list
                    con.RecordTypeId = priorMemberId;
                    //set membership status for managed memberships
                    if(con.OrderApi__Subscriptions__r[0].OrderApi__Item__r.Managed__c) {
                        con.Membership_Status__c = 'Suspended';
                    }
                    toUpdate.add(con);
                }
            }
        }

        //expire badges
        List<OrderApi__Badge__c> badges = [SELECT Id, OrderApi__Is_Active__c FROM OrderApi__Badge__c WHERE OrderApi__Contact__c IN: toUpdate AND OrderApi__Badge_Type__r.Name = 'Directory Access'];
        BadgeUtils.expireDirectoryBadges(badges);

        update toUpdate;
    }

    global void finish(Database.BatchableContext BC){
    }
}