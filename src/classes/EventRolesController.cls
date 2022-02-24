/**
 * Created by lauren.lezberg on 6/17/2020.
 */

public with sharing class EventRolesController {

    @AuraEnabled
    public static List<Meeting_Role__c> getRoles(String eventId){
        return [SELECT Id, Role__c, User__c, User__r.Name, Primary__c FROM Meeting_Role__c WHERE AC_Event__c=: eventId ORDER BY Role__c DESC, Primary__c DESC];
    }

    @AuraEnabled
    public static Boolean deleteRole(String roleId){
        try{
            Database.delete(roleId);

            return true;
        } catch(Exception e){
            new AACRCustomException(roleId, e.getMessage(), e.getStackTraceString(), 'Event Roles');
            return false;
        }
    }
}