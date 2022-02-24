/**
 * Created by lauren.lezberg on 3/30/2021.
 */
@RestResource(urlMapping='/Membership/*')

global with sharing class MembershipWebService {

    @Httpget
    global static Boolean getMembership(){
        RestRequest req = RestContext.request;
        RestResponse res = Restcontext.response;

        String orcid = req.params.get('orcid');
        System.debug('orcid: ' + orcid);
        String aacrid = req.params.get('aacrid');
        System.debug('aacrid: ' + aacrid);

        Boolean hasValidMembership = false;

        if(aacrid!=null){
            List<Contact> contacts = [SELECT Id, RecordType.Name, Membership_Status__c FROM Contact WHERE AACR_ID__c =: aacrid];
            if(!contacts.isEmpty()){
                hasValidMembership = contacts[0].RecordType.Name == 'Member' && contacts[0].Membership_Status__c == 'Current';
                if(orcid!=null){
                    List<User> users = [SELECT ORCID__c FROM User WHERE ContactId =: contacts[0].Id AND IsActive=true];
                    if(!users.isEmpty()){
                        if(users[0].ORCID__c==null){
                            users[0].ORCID__c = orcid;
                            update users[0];
                        }
                    }
                }
            }
        } else if(orcid!=null) {
            List<User> users = [SELECT ORCID__c, ContactId FROM User WHERE ORCID__c =:orcid];
            if(!users.isEmpty()){
                List<Contact> contacts = [SELECT Id, RecordType.Name, Membership_Status__c FROM Contact WHERE Id=: users[0].ContactId];
                if(!contacts.isEmpty()){
                    hasValidMembership = contacts[0].RecordType.Name == 'Member' && contacts[0].Membership_Status__c == 'Current';
                }
            }
        }


        return hasValidMembership;

    }

}