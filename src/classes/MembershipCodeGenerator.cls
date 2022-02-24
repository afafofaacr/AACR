/**
 * @author          :  CRM Science, Inc.
 * @date            :  10/7/2020
 * @description     :  This class holds the methods to generate OfferMemberships based on data sent in from the membershipCodeGenerator LWC
 */
public with sharing class MembershipCodeGenerator {

    /**
     * @description     :  @AuraEnabled method that retrieves all of the Offer records in Salesforce
     */
    @AuraEnabled(cacheable=true)
    public static List<Offer__c> getOffers() {
        return [SELECT Id, Name, SourceCode__c FROM Offer__c];
    }

    /**
     * @description     :  @AuraEnabled method that generates Offer Versions and calls batch class to generate Offer Memberships with parameters passed in from LWC inputs
     * @param           :  offerId - Id of the offer being used
     * @param           :  startDate - Date to be used in creating an OfferVersion
     * @param           :  endDate - Date to be used in creating an OfferVersion
     * @param           :  oRide - Boolean that sets the Override field on OfferVersion
     * @param           :  publish - Boolean that sets the Publish field on OfferVersion
     * @param           :  soqlString - String that stores the SOQL query used to create the Offer Memberships
     * @param           :  description - String that sets the Description field on OfferVersion
     * @param           :  versionCode - String that sets the Version Code field on OfferVersion
     */
    @AuraEnabled
    public static String generateMemberships(Id offerId, Date startDate, Date endDate, Boolean oRide, Boolean publish, String soqlString, String description, String versionCode) {

        // Success string to be built out and returned
        String successMessage = 'Offer Version saved.  Offer Membership creation pending. Please check your email for results.';

        // Query to retrieve Offer based on given offerId
        Offer__c offerRetrieved = [SELECT Id, Name, SourceCode__r.Name FROM Offer__c WHERE Id = :offerId AND SourceCode__c <> null];

        // Timestamp used for the name of version
        String timeStamp = Datetime.now().format('ddMMyyHHmmss');

        // Create and Insert Offer Version
        OfferVersion__c ovToInsert = new OfferVersion__c(
            Name = offerRetrieved.Name + '.' + timeStamp,
            Offer__c = offerId,
            StartDate__c = startDate,
            EndDate__c = endDate,
            Override__c = oRide,
            Publish__c = publish,
            Description__c = description,
            SOQLQuery__c = soqlString,
            VersionCode__c = versionCode
        );
        insert ovToInsert;

        // Call batch class and do in batches of 4000
        Database.executeBatch(new MembershipCodeGeneratorBatch(ovToInsert.Id), 4000);

        // Return successMessage to LWC
        return successMessage;
    }

    /**
     * @description     :  Method that is called from batch class to create OfferMemberships
     * @param           :  offerVersionId - Id of the OfferVersion to create OfferMemberships from
     * @param           :  conIds - Set of Contact Ids to create OfferMemberships from
     */ 
    public static Map<String, Integer> createFromContactIds(Id offerVersionId, Set<Id> conIds) {

        // Integers to be incremented and returned to batch class
        Integer successInserts = 0;
        Integer errorInserts = 0;

        // Map to store success and error numbers
        Map<String, Integer> results = new Map<String, Integer>();

        // List of OfferMemberships to be inserted
        List<OfferMembership__c> membershipsToInsert = new List<OfferMembership__c>();

        // Retrieve OfferVersion based on Id passed in
        OfferVersion__c ov = [SELECT Id, Name, Offer__c, Description__c FROM OfferVersion__c WHERE Id = :offerVersionId];

        // Create an Offer Membership for each Contact Id
        for (Id cId : conIds) {
            membershipsToInsert.add(new OfferMembership__c(
                Name = ov.Name,
                Offer__c = ov.Offer__c,
                OfferVersion__c = ov.Id,
                Contact__c = cId,
                Description__c = ov.Description__c
            ));
        }

        // If there are Offer Memberships, insert them
        if (!membershipsToInsert.isEmpty()) {
            Database.SaveResult[] srList = Database.insert(membershipsToInsert, false);

            for (Database.SaveResult sr : srList) {
                if (sr.isSuccess()) {
                    // Operation was successful, so get the ID of the record that was processed
                    System.debug('Successfully inserted Offer Membership. Offer Membership ID: ' + sr.getId());

                    // Increment success count
                    successInserts++;
                }
                else {
                    // Operation failed, so get all errors                
                    for(Database.Error err : sr.getErrors()) {
                        System.debug('The following error has occurred.');                    
                        System.debug(err.getStatusCode() + ': ' + err.getMessage());
                        System.debug('Offer Membership fields that affected this error: ' + err.getFields());

                        // Increment error count
                        errorInserts++;
                    }
                }
            }
        }

        // Add successes and errors to map for batch class
        results.put('success', successInserts);
        results.put('error', errorInserts);
        System.debug('results map: ' + results);

        // Return results map to batch class
        return results;
    }

    // Variable to store emails to be sent
    public static List<Messaging.SingleEmailMessage> queuedEmails = new List<Messaging.SingleEmailMessage>();

    /**
     * @description     :  Method that is called from batch class to create emails to be sent
     * @param           :  subject - The subject of the email being sent
     * @param           :  details - The body of the email being sent
     */ 
    public static void queueNotificationEmail(String subject, String details) {

        // Retrieve organization Id for email
        String orgId = UserInfo.getOrganizationId();

        // Best practice send to IDs anytime you can vs email address to cut back on SF limits
        Id userIdToEmail = UserInfo.getUserId();

        // Instantiate and build out recipients of email
        List<String> sendTo = new List<String>();
        sendTo.add(userIdToEmail);

        if (!sendTo.isEmpty()) {
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setToAddresses(sendTo);

            // Email Content
            String body = 'Note: Your request to Generate Offer Memberships has completed.  Please review the outcome of the process below. <br/> <br/>' + 
                    'Salesforce Organization Id: ' + orgId + ' <br/>' +
                    'Date/Time: ' + Datetime.Now().format('yyyy.MM.dd \'at\' HH:mm:ss:SSS z') + ' <br/>' +
                    'Details:<br/><br/>' + details;

            // If the details string is too long, truncate it
            String truncatedBody = body;
            if(!String.isEmpty(body) && (body.length() > 31000))
                truncatedBody = body.substring(0,31000) + '<br/><br/><br/><br/>----- Truncated, maximum email size -----';
            
            // Set email subject and body
            mail.setSubject(subject);
            mail.setHtmlBody(truncatedBody);

            // Add to email list to be sent
            queuedEmails.add(mail);
        }
    }

    /**
     * @description     :  Method that is called from batch class to send emails
     */
    public static void sendEmails() {
        try {
            if(!queuedEmails.isEmpty()) Messaging.sendEmail(queuedEmails);
        } catch (exception e){
            system.debug('catching error: ' + 'Line: ' + e.getLineNumber() + ' Message: ' + e.getMessage());
        }

        // Reset the queue
        queuedEmails = new List<Messaging.SingleEmailMessage>();
    }
}