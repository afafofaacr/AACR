/**
 * Created by lauren.lezberg on 11/19/2020.
 */

public without sharing class JP_ContainerController {

    /**
     * @purpose Apply offer to sales order and update used mode on offer membership
     * Last accessed step is deleted so user starts from beginning every time
     * @param sourceCodeId
     * @param salesOrderId
     * @param offerMembershipId
     * @param usedMode
     * @param joinId
     *
     * @return salesOrderId
     */
    @AuraEnabled
    public static ContainerInfo applyOffer(String sourceCodeId, String salesOrderId, String offerMembershipId, String usedMode, String joinId){
        System.debug('applyOffer was called with sourceCodeId: ' + sourceCodeId + ' and salesOrderId: ' + salesOrderId + ' and offerMembershipId: ' + offerMembershipId);
        OrderApi__Sales_Order__c so;
        if(salesOrderId!=null) {
            so = [SELECT Id, OrderApi__Source_Code__c FROM OrderApi__Sales_Order__c WHERE Id = :salesOrderId];
            so.OrderApi__Source_Code__c = sourceCodeId;
            so.Offer_Membership__c = offerMembershipId;
        } else {
            Contact con = ECRMUtils.getCurrentLoginContact();
            so = new OrderApi__Sales_Order__c(OrderApi__Contact__c = con.Id,
                    OrderApi__Account__c = con.AccountId,
                    OrderApi__Entity__c = 'Contact',
                    OrderApi__Source_Code__c=sourceCodeId,
                    Offer_Membership__c = offerMembershipId);
        }

        Boolean refresh = false;
        try{
            upsert so;

            OfferMembership__c om = [SELECT Id, Used__c, UsedDate__c, UsedMode__c FROM OfferMembership__c WHERE Id = :offerMembershipId];
            if(om.UsedMode__c!=usedMode) {
                om.UsedMode__c = usedMode;
                update om;
            }

            //if user was already on checkout screen and exited process - reset their last accessed step to zero
            Decimal lastStep = JP_Helper.getLastAccessedStepOrder(joinId);
            if(lastStep!=1) {
                JP_Helper.deleteContactLastAccessedStep(joinId);
                refresh = true;
            }

        }catch(Exception e){
            System.debug('error applying offer.');
            new AACRCustomException(salesOrderId, e.getMessage(), e.getStackTraceString(), 'Apply Offer');
        }

        return new ContainerInfo(so.Id, refresh);
    }

    /**
     * @purpose Start order without offer
     * @param joinId
     *
     * @return new sales order id
     */
    @AuraEnabled
    public static ContainerInfo startOrder(String joinId){
        Contact con = ECRMUtils.getCurrentLoginContact();
        OrderApi__Sales_Order__c so = new OrderApi__Sales_Order__c(OrderApi__Contact__c = con.Id,
                OrderApi__Account__c = con.AccountId,
                OrderApi__Entity__c = 'Contact');

        Boolean refresh = false;
        try {
            insert so;

            //if user was already on checkout screen and exited process - reset their last accessed step to zero
            Decimal lastStep = JP_Helper.getLastAccessedStepOrder(joinId);
            System.debug('lastStep: ' + lastStep);
            if (lastStep != 1) {
                JP_Helper.deleteContactLastAccessedStep(joinId);
                refresh = true;
            }
        } catch(Exception e){
            System.debug('Exception starting order: ' + e.getMessage());
            new AACRCustomException(con.Id, e.getMessage(), e.getStackTraceString(), 'Start Order');
        }

        return new ContainerInfo(so.Id, refresh);
    }

    public class ContainerInfo{
        @AuraEnabled
        public String salesOrderId;

        @AuraEnabled
        public Boolean refresh;

        public ContainerInfo(String soId, Boolean ref){
            this.salesOrderId = soId;
            this.refresh = ref;
        }
    }



}