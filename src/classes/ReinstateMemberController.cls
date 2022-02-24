/**
 * Created by lauren.lezberg on 2/6/2020.
 */

public with sharing class ReinstateMemberController {

    @AuraEnabled
    public static Boolean getShowReinstate(String contactId){
        if(FeatureManagement.checkPermission('Reinstatements')) {
            Contact con = [SELECT Membership_Status__c FROM Contact WHERE Id=: contactId LIMIT 1];

//            List<OrderApi__Subscription__c> memberships = RenewalUtils.getIndividualMembershipSubscription(contactId);
            List<OrderApi__Subscription__c> memberships = [SELECT Id, OrderApi__Paid_Through_Date__c
                                                            FROM OrderApi__Subscription__c
                                                            WHERE OrderApi__Item_Class__r.Name='Individual Memberships' AND OrderApi__Contact__c=: contactId
                                                            ORDER BY OrderApi__Paid_Through_Date__c DESC, CreatedDate DESC];
            if(!memberships.isEmpty()){
                if (System.now().year() - memberships[0].OrderApi__Paid_Through_Date__c.year() >= 3 || con.Membership_Status__c=='Suspended (Resigned)' || con.Membership_Status__c == 'Ineligible'){
                    return true;
                }
            }
        }
        return false;
    }

    /**
     * @purpose Create an empty sales order and retrieve new application join process id
     *
     * @param contactId
     *
     * @return sales order id and join process id for url construction
     */
    @AuraEnabled
    public static NewApplicationController.NewApplicationInfo createReinstatementSO(String contactId){
       return NewApplicationController.createBackOfficeSO(contactId);
    }

}