/**
 * Created by afaf.awad on 10/27/2020.
 */

public without sharing class BadAddressController {


    @AuraEnabled
    public static ContactWrapper getContactInfo(String contactId) {

        List<Contact> contacts = [SELECT Id, Name, FirstName, LastName FROM Contact WHERE Id = :contactId];

        ContactWrapper conWrap = new ContactWrapper();
        conWrap.duplicate = false;
        conWrap.contact = contacts[0];
        conWrap.reasonList = ECRMUtils.getPicklistValues('Bad_Address_Audit__c','Return_Sender_Reason__c');
        conWrap.knownAddresses = [SELECT OrderApi__Street__c, OrderApi__City__c, OrderApi__Province__c, OrderApi__Country__c, OrderApi__Postal_Code__c,
                                            Type__c, Bad_Address__c, Id
                                    FROM OrderApi__Known_Address__c WHERE OrderApi__Contact__c =: contacts[0].Id];

        List<Datacloud.FindDuplicatesResult> results = Datacloud.FindDuplicates.findDuplicates(contacts);

        for (Datacloud.FindDuplicatesResult dupeResult : results) {
            for (Datacloud.DuplicateResult dupeRes : dupeResult.getDuplicateResults()) {
                for (Datacloud.MatchResult matchRes : dupeRes.getMatchResults()) {
                    for (Datacloud.MatchRecord matchRec : matchRes.getMatchRecords()) {
                        System.debug('matchRecord: ' + (string) matchRec.getRecord().get('id'));
                        conWrap.duplicate = true;
                    }
                }
            }
        }
        return conWrap;
    }

    @AuraEnabled
    public static Boolean saveBadAddress(String[] auditString, String kaIdString) {
        List<Bad_Address_Audit__c> auditList = new List<Bad_Address_Audit__c>();
            for (String audit : auditString) {
                Bad_Address_Audit__c a = (Bad_Address_Audit__c) JSON.deserialize(audit, Bad_Address_Audit__c.class);
                auditList.add(a);
            }

            //insert bad address audit
            Database.DMLOptions dmlAudit = new Database.DMLOptions();
            List<Database.SaveResult> insertResults = Database.insert(auditList, dmlAudit);
            for (Database.SaveResult sr : insertResults) {
                if ( !sr.isSuccess() ) {
                    for (Database.Error error : sr.getErrors()) {
                        System.debug('Error saving Bad Addresses:: ' + error.message);
                        return false;
                    }
                }
            }
        
        try {
            //update known addresses
            List<String> kaIds = (List<String>) JSON.deserialize(kaIdString, List<String>.class);
            List<OrderApi__Known_Address__c> knownAddresses = new List<OrderApi__Known_Address__c>();
            for(String kaId: kaIds){
                OrderApi__Known_Address__c ka = new OrderApi__Known_Address__c(Id = kaId, Bad_Address__c = true);
                knownAddresses.add(ka);
            }

            System.debug('Known Addresses to Update : ' + knownAddresses);

                update knownAddresses;
                return true;
            }catch(Exception e){
                System.debug('Cannot update Known Address: ' + e.getMessage());
                return false;
            }
    }

    public class ContactWrapper{
        @AuraEnabled
        public Contact contact;
        @AuraEnabled
        public Boolean duplicate;
        @AuraEnabled
        public List<String> reasonList;
        @AuraEnabled
        public List<OrderApi__Known_Address__c> knownAddresses;
    }
}