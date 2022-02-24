/**
 * Created by lauren.lezberg on 11/15/2019.
 */

public with sharing class TransferMemberController {

    /**
      * @purpose Determines whether to show the transfer button
      * Criteria: Does current user have custom permission & does contact have current PTD
      *
      * @param contactId
      *
      * @return True or False
      */
    @AuraEnabled
    public static Boolean showTransferButton(String contactId){
        Boolean toReturn = false;
        if(FeatureManagement.checkPermission('Transfers')) {
            Contact con = [SELECT Id, Paid_thru_date__c FROM Contact WHERE Id=: contactId];
            if(con.Paid_thru_date__c!=null) {
                if (con.Paid_thru_date__c.year() == System.now().year()) {
                    toReturn = true;
                } else if(con.Paid_thru_date__c.year() == System.now().year() + 1){ //if paid through next year
                    //get most recent membership subscription
                    List<OrderApi__Subscription__c> memSubs = [
                            SELECT Id,OrderApi__Paid_Through_Date__c, OrderApi__Subscription_Plan__c, OrderApi__Contact__c, OrderApi__Current_Term_End_Date__c, OrderApi__Days_To_Lapse__c,
                                    OrderApi__Item__c, OrderApi__Item__r.Name, OrderApi__Item__r.Fon_Association_Journal_Type__c, OrderApi__Grace_Period_End_Date__c,
                                    OrderApi__Item_Class__r.Name, Join_Date__c, OrderApi__Account__c,OrderApi__Is_Active__c, OrderApi__Is_Expired__c, OrderApi__Current_Term_Start_Date__c, Days_Left__c,
                                    OrderApi__Business_Group__c, OrderApi__Entity__c, OrderApi__Enable_Auto_Renew__c,Delinquency__c, OrderApi__Item__r.OrderApi__Image_Path__c, OrderApi__Item__r.Managed__c
                            FROM OrderApi__Subscription__c
                            WHERE OrderApi__Contact__c = :contactId AND
                            OrderApi__Item_Class__r.Name= 'Individual Memberships'
                            ORDER BY OrderApi__Paid_Through_Date__c DESC, CreatedDate DESC
                    ];
                    if(!memSubs.isEmpty()){
                        if(memSubs[0].OrderApi__Item__r.Managed__c) {
                            OrderApi__Subscription_Plan__c subPlan = [SELECT OrderApi__Advanced_Calendar_Days__c FROM OrderApi__Subscription_Plan__c WHERE Id = :memSubs[0].OrderApi__Subscription_Plan__c];
                            //check that sub plan is 2YR
                            if (subPlan.OrderApi__Advanced_Calendar_Days__c == 365) {
                                toReturn = true;
                            }
                        } else {
                            toReturn = true; 
                        }
                    }
                }
            }
        }
        return toReturn;
    }

    /**
     * @purpose Creates an empty sales order for back order processing and find correct join process for transfer
     *
     * @param contactId
     *
     * @return Instance of TransferInfo class
     */
    @AuraEnabled
    public static TransferInfo createEmptySO(Id contactId){
        OrderApi__Sales_Order__c SO = new OrderApi__Sales_Order__c(OrderApi__Contact__c=contactId);
        try {

            insert SO;
            List<Join_Process__mdt> joinProcesses = [SELECT Id FROM Join_Process__mdt WHERE DeveloperName = 'Back_Office_Transfer' LIMIT 1];
            return new TransferInfo(SO.Id, joinProcesses[0].Id);
        } catch(Exception e){
            System.debug('Could not create sales order: ' + e.getMessage());
        }
        return null;
    }

    public class TransferInfo{
        @AuraEnabled
        public String salesOrderId;

        @AuraEnabled
        public String joinId;


        public TransferInfo(String soId, String jId){
            this.salesOrderId = soId;
            this.joinId = jId;
        }

    }
}