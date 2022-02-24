/**
 * Created by lauren.lezberg on 5/7/2021.
 * Job is to be run annually on 12/31 to flip ineligible associates & students
 */

global class Batch_EndOfYearEligibilityJob implements Database.Batchable<sObject>{


    global Database.QueryLocator start(Database.BatchableContext BC){
        String query = 'SELECT Id, Expected_Completion_Date__c, Member_Type__c, Membership_Status__c, RecordTypeId, ' +
                '(SELECT Id, OrderApi__Item__r.Managed__c, OrderApi__Is_Expired__c, OrderApi__Item__r.Name, ' +
                'OrderApi__Paid_Through_Date__c, OrderApi__Item_Class__r.Name, OrderApi__Current_Term_End_Date__c, OrderApi__Grace_Period_End_Date__c,' +
                ' OrderApi__Subscription_Plan__c FROM OrderApi__Subscriptions__r WHERE ' +
                'OrderApi__Is_Active__c=true ORDER BY OrderApi__Paid_Through_Date__c ' +
                'DESC, CreatedDate DESC) FROM Contact WHERE (Member_Type__c=\'Student Member\' OR Member_Type__c=\'Associate Member\') AND RecordType.Name = \'Member\' AND ' +
                'Membership_Status__c = \'Current\'';
        System.debug('query: ' + query);
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<Contact> scope){
        System.debug('contacts: ' + scope.size());
        Id priorMemberId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Prior Member').getRecordTypeId();
        List<Contact> toUpdate = new List<Contact>();
        List<OrderApi__Subscription__c> subs = new List<OrderApi__Subscription__c>();
        List<OrderApi__Renewal__c> terms = new List<OrderApi__Renewal__c>();

        //iterate through contacts
        for(Contact con : scope){
            System.debug('contact: ' + con);
            SYstem.debug('subscriptions: ' + con.OrderApi__Subscriptions__r);
            //if contacts have a valid most recent membership subscription
            if(!con.OrderApi__Subscriptions__r.isEmpty()){
                for(OrderApi__Subscription__c sub : con.OrderApi__Subscriptions__r){
                    System.debug('subscription: ' + sub);
                    //PTD == Current Year
                    if(sub.OrderApi__Paid_Through_Date__c.year() == System.now().year()) {
                        //ASSOCIATES
                        if(con.Member_Type__c.contains('Associate')){
                            System.debug('ASSOCIATE');
                            if(sub.OrderApi__Item_Class__r.Name == 'Individual Memberships'){
                                //flip contact to ineligible prior member & add to list
                                con.RecordTypeId = priorMemberId;
                                con.Membership_Status__c = 'Ineligible';
                                toUpdate.add(con);
                            }

                        //STUDENTS
                        } else if(con.Member_Type__c.contains('Student')){
                            System.debug('STUDENT');
                            //STUDENTS GRADUATING NEXT YEAR
                            if(con.Expected_Completion_Date__c.year() == System.now().year()+1){
                                System.debug('Graduating Next Year...flip member' );
                                if(sub.OrderApi__Item_Class__r.Name == 'Individual Memberships') {
                                    //flip contact to ineligible prior member & add to list
                                    con.RecordTypeId = priorMemberId;
                                    con.Membership_Status__c = 'Ineligible';
                                    toUpdate.add(con);
                                }
                            //STUDENTS GRADUATING FUTURE
                            } else {
                                System.debug('Future graduation date...renew subscriptions');
                                //renew student subscription --> add term & push date of sub
                                OrderApi__Renewal__c ren = new OrderApi__Renewal__c(
                                        OrderApi__Subscription__c=sub.Id,
                                        OrderApi__Term_Start_Date__c = Date.newInstance(System.now().year() + 1, 1, 1),
                                        OrderApi__Term_End_Date__c = Date.newInstance(System.now().year() + 1, 8, 31),
                                        OrderApi__Subscription_Plan__c = sub.OrderApi__Subscription_Plan__c
                                );
                                terms.add(ren);
                                sub.OrderApi__Paid_Through_Date__c = Date.newInstance(System.now().year() + 1, 8, 31);
                                sub.OrderApi__Current_Term_End_Date__c = Date.newInstance(System.now().year() + 1, 8, 31);
                                subs.add(sub);
                            }
                        }
                    }
                }
            }
        }

        try{
            insert terms;
            update subs;
            update toUpdate;

        }catch(Exception e){
            System.debug('exception: ' + e.getMessage());
        }

        //expire badges
        List<OrderApi__Badge__c> badges = [SELECT Id, OrderApi__Is_Active__c FROM OrderApi__Badge__c WHERE OrderApi__Contact__c IN: toUpdate AND OrderApi__Badge_Type__r.Name = 'Directory Access'];
        BadgeUtils.expireDirectoryBadges(badges);
    }

    global void finish(Database.BatchableContext BC){
    }
}