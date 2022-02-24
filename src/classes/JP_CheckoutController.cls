/**
 * Created by lauren.lezberg on 2/15/2019.
 */

public without sharing class JP_CheckoutController {
//    public Id salesOrderId{get;set;}
//    public OrderApi__Store__c store {get;set;}
//    public String redirectURL {get;set;}


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
    public static void submitApplication(String salesOrderId, String stepId){
        Contact con = ECRMUtils.getCurrentLoginContact();
        if(con.Id!=null) {

            Process_Steps__mdt ps = [SELECT Process__c FROM Process_Steps__mdt WHERE Id = :stepId];
            JP_Helper.deleteContactLastAccessedStep(ps.Process__c);

            OrderApi__Sales_Order__c so = [SELECT Id, Is_Transfer__c, Is_Reinstatement__c FROM OrderApi__Sales_Order__c WHERE Id=: salesOrderId];

            if(so.Is_Transfer__c && !so.Is_Reinstatement__c) {
                con.Application_Status__c = 'Pending Transfer';
            } else if(so.Is_Reinstatement__c && !so.Is_Transfer__c){
                con.Application_Status__c = 'Pending Reinstatement';
            } else if(so.Is_Reinstatement__c && so.Is_Transfer__c){
                con.Application_Status__c = 'Pending Reinstatement-Transfer';
            }
            //update application status
            update con;
        }
//        OrderApi__Sales_Order__c so = [SELECT Id, OrderApi__Total__c FROM OrderApi__Sales_Order__c WHERE Id=: salesOrderId];
////        so.OrderApi__Posting_Entity__c = 'Receipt';
//
//        so.OrderApi__Status__c = 'Closed';
//        so.OrderApi__Posting_Status__c = 'Pending';
//        try {
//            update so;
//        } catch (Exception e) {
//            System.debug('Could not close sales order: ' + e.getMessage());
//        }
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
        OrderApi__Sales_Order__c so = [SELECT Id, OrderApi__Total__c FROM OrderApi__Sales_Order__c WHERE Id=: salesOrderId];
//        so.OrderApi__Posting_Entity__c = 'Receipt';
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
     * @purpose Retrieve all item information from the given sales order and upsert last accessed step
     *
     * @param salesOrderId
     * @param stepId
     *
     * @return CartData object instance
     */
    @AuraEnabled
    public static CartData getCartItems(String salesOrderId, Id stepId){
        if(stepId!=null) {
            JP_Helper.upsertLastAccessedStep(stepId);
        }
        return new CartData(salesOrderId, stepId);
    }




    /**
     * @purpose Delete sales order line from sales order. If item is a comp journal, delete and add decline journal item
     *
     * @param salesOrderLineId
     */
    @AuraEnabled
    public static void deleteCartItem(Id salesOrderLineId){
        System.debug('Deleting sales order line: ' + salesOrderLineId);
        OrderApi__Sales_Order_Line__c sol = [SELECT Id, OrderApi__Sales_Order__c, OrderApi__GL_Account__c, OrderApi__Item_Class__r.Name, OrderApi__Item__r.Future_Income_Account__c, OrderApi__Item__r.OrderApi__Income_Account__c FROM OrderApi__Sales_Order_Line__c WHERE Id=: salesOrderLineId LIMIT 1];
        if(sol.OrderApi__Item_Class__r.Name == 'Complimentary Journals'){
            OrderApi__Sales_Order_Line__c newLine = new OrderApi__Sales_Order_Line__c(OrderApi__Sales_Order__c = sol.OrderApi__Sales_Order__c);
            OrderApi__Item__c declineJournal = [SELECT Id, OrderApi__Income_Account__c, Future_Income_Account__c FROM OrderApi__Item__c WHERE OrderApi__Item_Class__r.Name = 'ZDecline of the Journals'];
            if(sol.OrderApi__GL_Account__c == sol.OrderApi__Item__r.Future_Income_Account__c){
                newLine.OrderApi__GL_Account__c = declineJournal.Future_Income_Account__c;
            } else {
                newLine.OrderApi__GL_Account__c = declineJournal.OrderApi__Income_Account__c;
            }
            newLine.OrderApi__Item__c = declineJournal.Id;
            insert newLine;
        }
            try {
                delete sol;
            } catch (Exception e) {
                System.debug('Could not remove item from cart: ' + e.getMessage());
            }

    }

    /**
     * @purpose Add discount code to sales order
     *
     * @param code
     * @param salesOrderId
     *
     * @return True or False
     */
    @AuraEnabled
    public static Boolean applyDiscountCode(String code, String salesOrderId){
        System.debug('Apply ' + code + ' to sales order ' + salesOrderId);
        OrderApi__Source_Code__c sCode = [SELECT Id, Name FROM OrderApi__Source_Code__c WHERE Name=: code LIMIT 1];

        OrderApi__Sales_Order__c so = [SELECT Id, OrderApi__Source_Code__c FROM OrderApi__Sales_Order__c WHERE Id=: salesOrderId];
        so.OrderApi__Source_Code__c = sCode.Id;

        List<OrderApi__Sales_Order_Line__c> lines = [SELECT Id FROM OrderApi__Sales_Order_Line__c WHERE OrderApi__Sales_Order__c=: salesOrderId AND OrderApi__Item_Class__r.Name='Live Event Tickets'];
        for(OrderApi__Sales_Order_Line__c line : lines){
            line.OrderApi__Price_Override__c = false;  
        }

        try{
            update so;
            update lines;
            return true;
        } catch (Exception e){
            System.debug('Could not apply discount code: ' + e.getMessage());
            return false;
        }
    }

    private static String getVFHostName(){
        if(isCommunity()){
            Network myNetwork = [SELECT Id FROM Network WHERE Name ='AACR Community' ];
            ConnectApi.Community  myCommunity = ConnectApi.Communities.getCommunity(myNetwork.Id);
            System.debug('MyDebug : ' + myCommunity.siteUrl);
            return myCommunity.siteURL;
        } else {
            String hostname = Url.getSalesforceBaseUrl().getHost();
            // will support prod and sandboxes
            // e.g. https://mydomain--sandbox.lightning.force.com
            // and https://mydomain.lightning.force.com
            String myDomain = hostname.split('\\.')[0];
//            String namespace = ProxyController.class.getName().split('\\.')[0];
            String pod = [SELECT InstanceName FROM Organization].InstanceName.toLowerCase();

            return 'https://' + myDomain + '--c.visualforce.com';

        }
    }

    /* CartData class provides item list, sales order and other data required for OrderApi:PayNow component */
    public class CartData{
        @AuraEnabled
        public OrderApi__Sales_Order__c SO;

        @AuraEnabled
        public List<OrderApi__Sales_Order_Line__c> items;

        @AuraEnabled
        public String vfHostName;


        public CartData(String salesOrderId, Id stepId){
            vfHostName = getVFHostName();
            SO = [SELECT Id, OrderApi__Status__c,OrderApi__Contact__c, OrderApi__Account__c, OrderApi__Payment_Terms__c,OrderApi__Total__c, OrderApi__Entity__c, OrderApi__Schedule_Type__c, OrderApi__Shipping_Country__c, OrderApi__Posting_Status__c, OrderApi__Posting_Entity__c, OrderApi__Business_Group__c FROM OrderApi__Sales_Order__c WHERE Id=: salesOrderId];
            items = [SELECT OrderApi__Sales_Order__r.OrderApi__Source_Code__r.Name, OrderApi__Sales_Order__r.OrderApi__Source_Code__c, OrderApi__Sales_Order__r.OrderApi__Total__c, OrderApi__Item_Class__r.Name, OrderApi__Item__r.Portal_Label__c, OrderApi__Item__r.Name, OrderApi__Sale_Price__c, OrderApi__Quantity__c, OrderApi__Item__r.OrderApi__Image_Path__c, AC_User_Segment__r.Name FROM OrderApi__Sales_Order_Line__c WHERE OrderApi__Sales_Order__c=: salesOrderId ORDER BY OrderApi__Item_Class__r.Name];
        }
    }



}