/**
 * @author          :  CRM Science, Inc.
 * @date            :  10/7/2020
 * @description     :  This class uses methods in the MembershipCodeGenerator class to insert batches of OfferMemberships
 */
public without sharing class MembershipCodeGeneratorBatch implements Database.Batchable<sObject>, Database.Stateful {

    // Integers to track records processed
    public Integer rowCount = 0;
    public Integer successCount = 0;
    public Integer errorCount = 0;

    // Constructor Variables
    public Id offerVersionId;
    public String query;
    public OfferVersion__c ov;
    
    // Base link to be used in Email
    public String sfdcURL = URL.getSalesforceBaseUrl().toExternalForm() + '/'; 

    /**
     * @description     :  The constructor for the batch class
     * @param           :  offerVersionId - Id of the OfferVersion being used
     */
    public MembershipCodeGeneratorBatch(Id offerVersionId) {
        this.offerVersionId = offerVersionId;
        this.ov = [SELECT Id, Name, SOQLQuery__c, Offer__c, Offer__r.Name FROM OfferVersion__c WHERE Id = :offerVersionId];
        this.query = this.ov.SOQLQuery__c;
    }

    /**
     * @description     :  The start method of the batch that retrieves the Users we are using and passes it to the execute
     * @param           :  BC - Database.BatchableContext variable
     */
    public Database.QueryLocator start(Database.BatchableContext BC){

        // Return result of OfferVersion SOQLQuery field and pass to execute
        return Database.getQueryLocator(query);
    }

    /**
     * @description     :  The execute method of the batch that creates the OfferMembership records based on the start query
     * @param           :  BC - Database.BatchableContext variable
     * @param           :  usersRetrieved - The list of Users retrieved in the start method
     */
    public void execute(Database.BatchableContext BC, List<User> usersRetrieved){

        // Set row count to increase with query rows
        rowCount += usersRetrieved.size();

        // Set to store contact Ids retrieved by User query
        Set<Id> conIds = new Set<Id>();

        // Populate Contact Id set
        for (User u : usersRetrieved) {
            if (u.ContactId != null) {
                conIds.add(u.ContactId);
            }
        }

        // Call createFromContactIds to populate success and error count and create Offer Memberships
        Map<String, Integer> results = MembershipCodeGenerator.createFromContactIds(offerVersionId, conIds);
        successCount += results.get('success');
        errorCount += results.get('error');

    }

    /**
     * @description     :  The finish method of the batch that sends the email to the user running the batch class
     * @param           :  BC - Database.BatchableContext variable
     */
    public void finish(Database.BatchableContext BC){

        // queue emails for manual batch processing
        MembershipCodeGenerator.queueNotificationEmail('Offer Membership Generation Completed',
                'Offer: ' + '<a href="' + sfdcURL + this.ov.Offer__c + '">' + this.ov.Offer__r.Name + '</a> <br/>' +
                'Offer Version: ' + '<a href="' + sfdcURL + this.ov.Id + '">' + this.ov.Name + '</a> <br/>' + 
                'Batch Job: ' + bc.getJobId() + ' <br/>' +
                'Batch Processing has finished.<br/>Total Rows Processed: ' + this.rowCount + '<br/>' +
                'Total Successful: ' + this.successCount +'<br/>' +
                'Total Errors: ' + this.errorCount +'<br/->'
        );

        // send all queued emails
        MembershipCodeGenerator.sendEmails();
    }
}