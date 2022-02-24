/**
 * Created by lauren.lezberg on 5/3/2019.
 */

public with sharing class ContactDirectoryAccessController { 

    public class DirectoryBadgeInfo {
        @AuraEnabled
        public Boolean canEdit;

        @AuraEnabled
        public OrderApi__Badge__c dirBadge; 

        public DirectoryBadgeInfo(OrderApi__Badge__c badge, Boolean editPermission){
            this.canEdit =  editPermission;
            this.dirBadge = badge;
        }
    }

    @AuraEnabled
    public static DirectoryBadgeInfo getDirectoryAccessBadge(Id contactId){
        Boolean canEditBadge = FeatureManagement.checkPermission('Directory_Badge_Access') || (Schema.sObjectType.OrderApi__Badge__c.isCreateable() && Schema.sObjectType.OrderApi__Badge__c.isUpdateable()); 
        return new DirectoryBadgeInfo(BadgeUtils.getDirectoryBadge(contactId), canEditBadge);
    }

    @AuraEnabled
    public static Boolean enableDirectoryForContact(Id contactId){
        return BadgeUtils.enableDirectoryAccess(contactId);
    }

    @AuraEnabled
    public static Boolean revokeDirectoryForContact(Id contactId){
        return BadgeUtils.revokeDirectoryAccess(contactId); 
    }

}