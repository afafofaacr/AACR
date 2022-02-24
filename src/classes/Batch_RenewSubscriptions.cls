/**
 * Created by afaf.awad on 12/7/2020.
 */

public class Batch_RenewSubscriptions implements Database.Batchable<sObject>, Database.Stateful{

    List<OrderApi__Subscription__c> subsDidNotUpdate = new List<OrderApi__Subscription__c>();
    Set<String> aacrIds = new Set<String>();
    Date ptd;
    Id itemClass;
    Id subPlanId;
    Integer recordsProcessed = 0;


        public Batch_RenewSubscriptions(Set<String> aIds , Date paidThruDate, Id subscriptionPlanId, Id itemClassId){
            this.aacrIds = aIds;
            this.ptd = paidThruDate;
            this.subPlanId = subscriptionPlanId;
            this.itemClass = itemClassId;
        }

        public Database.QueryLocator start(Database.BatchableContext BC){
            //Query Contacts from list of AACR IDs
            String query = 'SELECT Id, OrderApi__Contact__c, OrderApi__Contact__r.FirstName, OrderApi__Contact__r.LastName, OrderApi__Contact__r.AACR_ID__c, OrderApi__Current_Term_End_Date__c, OrderApi__Subscription_Plan__r.Name, OrderApi__Account__c, OrderApi__Item_Class__c, OrderApi__Item__r.Future_Income_Account__c, OrderApi__Item__r.OrderApi__Income_Account__c, OrderApi__Business_Group__c,OrderApi__Item__c, OrderApi__Entity__c, OrderApi__Item__r.Name, OrderApi__Item_Class__r.Name, OrderApi__Is_Active__c, OrderApi__Subscription_Plan__c, OrderApi__Enable_Auto_Renew__c \n' +
                    'FROM OrderApi__Subscription__c \n' +
                    'WHERE OrderApi__Contact__r.AACR_ID__c IN: aacrIds ' +
                    'AND OrderApi__Paid_Through_Date__c =: ptd ' +
                    'AND OrderApi__Item__r.OrderApi__Is_Active__c = true \n' +
                    'AND OrderApi__Subscription_Plan__r.OrderApi__Is_Active__c = true \n' +
                    'AND OrderApi__Is_Cancelled__c = false ' +
                    'AND OrderApi__Item_Class__r.Name NOT IN (\'Journal Subscriptions\', \'Complimentary Journals\')';
            System.debug('Query: ' + query);
            return Database.getQueryLocator(query);
        }

        public void execute(Database.BatchableContext BC, List<OrderApi__Subscription__c> scope){

            List<OrderApi__Subscription__c> subscriptions = new List<OrderApi__Subscription__c>();
            List<OrderApi__Renewal__c> terms = new List<OrderApi__Renewal__c>();

            try {

            for(OrderApi__Subscription__c sub : scope) {

                OrderApi__Renewal__c term = new OrderApi__Renewal__c(OrderApi__Term_Start_Date__c = ptd.addDays(1),
                OrderApi__Term_End_Date__c = ptd.addYears(1),
                        OrderApi__Subscription__c = sub.Id,
                        OrderApi__Subscription_Plan__c = sub.OrderApi__Subscription_Plan__c
                );
                terms.add(term);

                OrderApi__Subscription__c newSub = new OrderApi__Subscription__c(
                        Id = sub.Id,
                        OrderApi__Current_Term_End_Date__c = ptd.addYears(1),
                        OrderApi__Paid_Through_Date__c = ptd.addYears(1)
                        );

                        subscriptions.add(newSub);
            }

            System.debug('subscriptions to update = ' + subscriptions.size());
                insert terms;
                update subscriptions;

                recordsProcessed = recordsProcessed + subscriptions.size();
                System.debug('Number of records processed so far: ' + recordsProcessed);

            } catch (Exception e) {
                subsDidNotUpdate.addAll(scope);
                System.debug('Exception occurred while updating Subscriptions :::' + e.getMessage() + '\t' + e.getStackTraceString());
                throw new AACRCustomException(e.getMessage(),  e.getStackTraceString() , 'Batch Job: Batch_RenewSubscriptions');
            }
        }

        public void finish(Database.BatchableContext BC){
            System.debug('finishing Batch_RenewSubscriptions...');
            System.debug('record Processed ::: ' + recordsProcessed);

            BatchUpdateMembershipHelper.sendRecordErrors_Subscriptions(subsDidNotUpdate, recordsProcessed, bc.getJobId());
        }


}