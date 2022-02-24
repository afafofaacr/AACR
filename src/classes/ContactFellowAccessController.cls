/**
 * Created by afaf.awad on 9/2/2020.
 */

public with sharing class ContactFellowAccessController {

    public class FellowBadgeInfo {
        @AuraEnabled
        public Boolean canEdit;

        @AuraEnabled
        public OrderApi__Badge__c dirBadge;

        public FellowBadgeInfo(OrderApi__Badge__c badge, Boolean editPermission){
            this.canEdit =  editPermission;
            this.dirBadge = badge;
        }
    }

    @AuraEnabled
    public static FellowBadgeInfo getFellowAccessBadge(Id contactId){
        Boolean canEditBadge = FeatureManagement.checkPermission('Directory_Badge_Access') || (Schema.sObjectType.OrderApi__Badge__c.isCreateable() && Schema.sObjectType.OrderApi__Badge__c.isUpdateable());

        Contact con = [SELECT Member_Type__c FROM  Contact WHERE Id=: contactId];
        if(con.Member_Type__c.contains('Active') || con.Member_Type__c.contains('Emeritus') || con.Member_Type__c.contains('Honorary')){
            canEditBadge = true;
        }else{
            canEditBadge = false;
        }

        return new FellowBadgeInfo(BadgeUtils.getFellowBadge(contactId), canEditBadge);
    }

    @AuraEnabled
    public static Boolean enableFellowForContact(Id contactId){
        return BadgeUtils.enableFellowAccess(contactId);
    }

    @AuraEnabled
    public static Boolean revokeFellowForContact(Id contactId){
        return BadgeUtils.revokeFellowAccess(contactId);
    }
}