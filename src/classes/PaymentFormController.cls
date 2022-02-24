/**
 * Created by lauren.lezberg on 2/5/2020.
 */

public with sharing class PaymentFormController {


    /**
     * @purpose For a sales order with a total of $0, set status to closed, set posting entity to receipt, set to posted
     *
     * @param salesOrderId
     *
     * @return Receipt ID
     */
    @AuraEnabled
    public static void processZeroDollarPayment(String salesOrderId, String stepId) {
        System.debug('ProcessZeroDollarPayment being called with salesOrderId: ' + salesOrderId);
//        Id receiptId;
        OrderApi__Sales_Order__c so = [SELECT Id FROM OrderApi__Sales_Order__c WHERE Id=: salesOrderId];
        so.OrderApi__Posting_Entity__c = 'Receipt';
        so.OrderApi__Is_Posted__c = true;
        so.OrderApi__Status__c = 'Closed';

        update so;

        //clear last accessed step
        List<Process_Steps__mdt> currentStep = [SELECT Process__c FROM Process_Steps__mdt WHERE Id =: stepId LIMIT 1];
        if (currentStep.size() == 1) {
            JP_Helper.deleteContactLastAccessedStep(currentStep[0].Process__c);
        }

    }

    /**
     * @purpose Closes sales order for check processing
     *
     * @param salesOrderId
     *
     * @return salesOrderId
     */
    @AuraEnabled
    public static String closeSalesOrder(String salesOrderId){
        OrderApi__Sales_Order__c so = [SELECT Id FROM OrderApi__Sales_Order__c WHERE Id=: salesOrderId];
        so.OrderApi__Posting_Entity__c = 'Receipt';
        so.OrderApi__Status__c = 'Closed';

        try {
            update so;
            return so.Id;
        } catch(Exception e){
            System.debug('Could not close sales order: ' + e.getMessage());
        }

        return null;
    }

    /**
     * @purpose Prepare sales order for payment processing by clearing last accessed step and closing sales order
     *
     * @param salesOrderId
     * @param stepId
     */
    @AuraEnabled
    public static void payNow(Id salesOrderId, Id stepId){
        System.debug('payNow was just called with salesOrderId: ' + salesOrderId + ' from step ' + stepId);
        try{
            //clear last accessed step
            List<Process_Steps__mdt> currentStep = [SELECT Process__c FROM Process_Steps__mdt WHERE Id =: stepId LIMIT 1];
            if (currentStep.size() == 1) {
                JP_Helper.deleteContactLastAccessedStep(currentStep[0].Process__c);
            }
            //close sales order
            OrderApi__Sales_Order__c so = [SELECT Id, OrderApi__Status__c FROM OrderApi__Sales_Order__c WHERE Id=: salesOrderId];
            so.OrderApi__Status__c = 'Closed';
            update so;
        }catch(Exception e){
            System.debug('Could not delete contact last step record and update so: ' + e.getMessage());
        }
    }

    /**
     * @purpose Delete sales order and delete last accessed step
     *
     * @param salesOrderId
     * @param stepId
     */
    @AuraEnabled
    public static String deleteSalesOrder(String salesOrderId,Id stepId){ 
        System.debug('Deleting sales order: ' + salesOrderId + ' at step ' + stepId);
        List<Process_Steps__mdt> currentStep = [SELECT Process__c FROM Process_Steps__mdt WHERE Id =: stepId LIMIT 1];
        if (currentStep.size() == 1) {
            JP_Helper.deleteContactLastAccessedStep(currentStep[0].Process__c);
        }
        OrderApi__Sales_Order__c so = [SELECT Id FROM OrderApi__Sales_Order__c WHERE Id=: salesOrderId];
        try {
            delete so;
        } catch(Exception e){
            System.debug('Could not delete sales order: ' + e.getMessage());
        }

        Process_Steps__mdt pStep = [SELECT Process__r.Cancel_URL__c FROM Process_Steps__mdt WHERE Id=: stepId];
        if(pStep!=null){
            return pStep.Process__r.Cancel_URL__c;
        }

        return null;
    }

    /**
     * @purpose Determines if user is in community or in salesforce
     *
     * @return True or False
     */
    @AuraEnabled
    public static boolean isCommunity(){
        Id siteId = Site.getSiteId(); // take a look at the apex class Site, you may find more useful method concerning site/community
        if (siteId != null) {
            return true;
        }
        return false;
    }

    @AuraEnabled
    public static PayNowData getPayNowData(String salesOrderId, String joinId){
        String redirectURL;

            if(isCommunity()){
                if(joinId!=null) {
                    Join_Process__mdt jp = [SELECT Redirect_URL__c fROM Join_Process__mdt WHERE Id = :joinId];
                    if (jp.Redirect_URL__c != null) {
                        redirectURL = jp.Redirect_URL__c + '?salesorder=' + salesOrderId;
                    } else {
                        redirectURL = '/orderapi__checkout?salesorder=' + salesOrderId;
                    }
                } else {
                    redirectURL = '/orderapi__checkout?salesorder=' + salesOrderId;
                }
            } else {
                redirectURL = '/' + salesOrderId;
            }

        return new PayNowData(salesOrderId, redirectURL);
    }


    public class PayNowData{
        @AuraEnabled
        public OrderApi__Store__c store;

        @AuraEnabled
        public String environmentKey;

        @AuraEnabled
        public String redirectURL;

        @AuraEnabled
        public List<OrderApi__Custom_Payment_Type__c> paymentTypes;

        public PayNowData(String salesOrderId, String url){
            OrderApi.PaymentConfigPreferences paymentPrefs = new OrderApi.PaymentConfigPreferences();
            environmentKey = paymentPrefs.getKey();
            redirectURL = url;
            store = [SELECT Id, OrderApi__Enable_Proforma_Invoice_Payment_Option__c, OrderApi__Enable_Invoice_Payment_Option__c FROM OrderApi__Store__c WHERE Name='AACR eStore'];
            paymentTypes = [SELECT Id, Name FROM OrderApi__Custom_Payment_Type__c WHERE OrderApi__Is_Enabled__c = true AND OrderApi__Store__c =: store.Id];
        }
    }
}