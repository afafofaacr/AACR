/**
 * Created by lauren.lezberg on 5/12/2021.
 */

public with sharing class BackOfficeRecertifyController {
    /**
         * @purpose Retrieves renewal information for the given contact including the process id for back office renewals
         *
         * @param contactId
         *
         * @return Renewal Information
         */
    @AuraEnabled
    public static RecertInfo getRecertifyInfo(Id contactId){
        List<Join_Process__mdt> joinProcesses = [SELECT Id FROM Join_Process__mdt WHERE DeveloperName = 'Back_Office_Order' LIMIT 1];
        Contact con = [SELECT Application_Status__c FROM Contact WHERE Id=:contactId];
        List<OrderApi__Subscription__c> membershipSubs = RenewalUtils.getIndividualMembershipSubscription(contactId);
        Boolean canRecert = false;
        if(!membershipSubs.isEmpty()){
            OrderApi__Subscription__c membership = membershipSubs[0];
            if(membership.OrderApi__Paid_Through_Date__c.year() == Date.today().year()){
                if (!membership.OrderApi__Item__r.Managed__c && (membership.OrderApi__Item__r.Name.contains('Student') || membership.OrderApi__Item__r.Name.contains('Associate'))) {
                    if(con.Application_Status__c==null){
                        canRecert = true;
                    }
                }
            }
        }

        canRecert = canRecert && FeatureManagement.checkPermission('Recertifications');
        return new RecertInfo(canRecert, joinProcesses[0].Id);
    }


    /**
     * @purpose Process the renewal for contact record by finding the most recent membership subscription and making a sales order that
     * contains all subscription items as sales order lines.
     *
     * @param contactId
     *
     * @return
     */
    @AuraEnabled
    public static JP_Helper.JPResponse processROERenew(Id contactId){
        return RenewalUtils.processROERenew(contactId);
    }

    public class RecertInfo{
        @AuraEnabled
        public Boolean showRecertButton;

        @AuraEnabled
        public String joinId;

        public RecertInfo(Boolean showButton, String jId){
            this.showRecertButton = showButton;
            this.joinId = jId;
        }

    }
}