/**
 * Created by afaf.awad on 3/25/2021.
 */

public with sharing class CommunityPermissionsCtrl {

    public String contactId {get;set;}
    public Boolean ecAccess {get;set;}

    public CommunityPermissionsCtrl(){
        contactId = ECRMUtils.getCurrentLoginUserContactId();
        checkPermissions();
    }

    public void checkPermissions(){
        System.debug('contactId = ' + contactId);
        List<Community_Permission__c> cp = [SELECT Id FROM Community_Permission__c WHERE Contact__c =: contactId];
        System.debug('commPerm = ' + cp);
        if(!cp.isEmpty()) {
            ecAccess = true;
        }else{
            ecAccess = false;
        }
        System.debug('ec access = ' + ecAccess);

    }

}