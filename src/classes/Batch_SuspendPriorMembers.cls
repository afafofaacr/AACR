/**
 * Created by afaf.awad on 12/14/2020.
 */

public class Batch_SuspendPriorMembers implements Database.Batchable<sObject>, Database.Stateful {

    List<Contact> contactsDidNotUpdate = new List<Contact>();
    Set<String> aacrIds = new Set<String>();
    Date ptd;
    Integer recordsProcessed = 0;


    public Batch_SuspendPriorMembers(Set<String> aIds, Date paidThruDate) {
        this.aacrIds = aIds;
        this.ptd = paidThruDate;
    }

    public Database.QueryLocator start(Database.BatchableContext BC) {
        //Query Contacts from list of AACR IDs
        String query = 'SELECT Id, FirstName, LastName, AACR_ID__c, Paid_thru_date__c, Membership_Status__c FROM Contact WHERE RecordType.Name = \'Prior Member\' AND AACR_ID__c IN: aacrIds';
        System.debug('Query: ' + query);
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext BC, List<Contact> scope) {

        List<Contact> updateContacts = new List<Contact>();

        try {
            for(Contact con : scope){
                if(con.Paid_thru_date__c == ptd.addYears(-1)){
                    updateContacts.add(new Contact(Id = con.Id,
                            Membership_Status__c = 'Suspended'));
                }else if(con.Paid_thru_date__c == ptd.addYears(-2)){
                    updateContacts.add(new Contact(Id = con.Id,
                            Membership_Status__c = 'Suspended (Delinquent)'));
                }else{
                    contactsDidNotUpdate.add(con);
                }
            }

            update updateContacts;


        } catch (Exception e) {
            contactsDidNotUpdate.addAll(scope);
            System.debug('Exception occurred while updating Prior Members :::' + e.getMessage() + '\t' + e.getStackTraceString());
            throw new AACRCustomException(e.getMessage(), e.getStackTraceString(), 'Batch Job: Batch_SuspendPriorMembers');
        }

    }

    public void finish(Database.BatchableContext BC) {
        System.debug('finishing Batch_SuspendPriorMembers...');
        System.debug('record Processed ::: ' + recordsProcessed);

        BatchUpdateMembershipHelper.sendRecordErrors_Contacts(contactsDidNotUpdate, recordsProcessed, bc.getJobId());
    }
}