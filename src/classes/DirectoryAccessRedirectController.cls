/**
 * Created by lauren.lezberg on 5/7/2019.
 */

public with sharing class DirectoryAccessRedirectController {
    //public String directoryURL{get;set;}
    public Boolean priorMember {get;set;}
    public Boolean nonMember {get;set;}
    public Boolean member{get;set;}

    public PageReference checkDirectoryAccess(){
        System.debug('checking directory access');
        Contact currentContact = DW_ECRMUtils.getCurrentLoginContact();
        priorMember = false;
        nonMember = false;

        if(currentContact.RecordType.Name == 'Prior Member'){
            priorMember = true;
        } else if(currentContact.RecordType.Name == 'Nonmember'){
            nonMember = true;
        } else {
            member = true;
        }
        //Id currentContactId = DW_ECRMUtils.getCurrentLoginUserContactId();
        OrderApi__Badge__c directoryBadge = BadgeUtils.getDirectoryBadge(currentContact.Id);
        if(directoryBadge!=null){
            System.debug('directory badge found: ' + directoryBadge);
            if(directoryBadge.OrderApi__Is_Active__c){
                String directoryURL = [SELECT Directory_URL__c FROM DRCTS__Directories__c WHERE Name='American Association for Cancer Research Member Directory' LIMIT 1].Directory_URL__c;
                PageReference pageRef = new PageReference(directoryURL);
                pageRef.setRedirect(true);
                return pageRef;
            }
        }
        return null;
    }

    public PageReference returnToProfile(){
        return new PageReference('/apex/DW_Custom_Profile');
    }

}