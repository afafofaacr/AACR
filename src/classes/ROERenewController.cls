/**
 * Created by lauren.lezberg on 8/26/2019.
 */

public with sharing class ROERenewController {

    /**
     * @purpose Retrieves renewal information for the given contact including the process id for back office renewals
     *
     * @param contactId
     *
     * @return Renewal Information
     */
    @AuraEnabled
    public static RenewInfo getRenewalInfo(Id contactId){ 
        List<Join_Process__mdt> joinProcesses = [SELECT Id FROM Join_Process__mdt WHERE DeveloperName = 'Back_Office_Order' LIMIT 1];
        return new RenewInfo(RenewalUtils.canPerformROERenew(contactId), joinProcesses[0].Id);
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

    public class RenewInfo{
        @AuraEnabled
        public Boolean showRenewButton;

        @AuraEnabled
        public String joinId;

        public RenewInfo(Boolean showButton, String jId){
            this.showRenewButton = showButton;
            this.joinId = jId;
        }

    }
}