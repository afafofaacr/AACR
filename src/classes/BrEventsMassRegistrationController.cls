/**
 * Created by afaf.awad on 1/20/2021.
 */

public with sharing class BrEventsMassRegistrationController {

    @AuraEnabled
    public static Boolean validateData(String fileData, List<String> fields, String emailField) {
        Boolean validated = true;
        List<String> emailStrings = new List<String>();
        try {
            String[] fileLines = new String[]{
            };
            fileLines = fileData.unescapeCsv().split('\n');
            for (Integer i = 1, j = fileLines.size(); i < j; i++) {
                if ( validated == true ) {
                    String[] inputvalues = new String[]{
                    };
                    inputvalues = fileLines[i].unescapeCsv().split(',');
                        System.debug('inputvalues ::: ' + inputvalues);
                    integer rowsize = inputvalues.size();
                    for (integer m = 0; m < rowsize; m++) {
                        if ( fields.get(m) == emailField ) {
                            if ( String.isNotBlank(inputvalues[m]) ) {
                                    System.debug('Validate Email: ' + inputvalues[m] );
                                String email = inputvalues[m];
                                emailStrings.add(email.deleteWhitespace());
                            }else {
                                validated = false;
                            }
                        }
                    }
                }else {
                    break;
                }
            }
        } catch (Exception e) {
            System.debug('exception' + e);
            throw new AACRCustomException(e.getMessage(), e.getStackTraceString(), 'BrEventsMassRegistrationController');
        }
        System.debug('validated = ' + validated);
        return validated;
    }


    @AuraEnabled
    public static ContactLookups processData(String fileData, List<String> fields, String emailField, String eventId) {

        System.debug('fields:::' + fields);
        System.debug('emailField:::' + emailField);
        System.debug('fileData:::' + fileData);

        //PROCESS FILE************************************//
//        List<String> emailStrings = new List<String>();
        Map<String, String> emailMap = new Map<String,String>();
        try {
            if ( fileData != null ) {
                String[] fileLines = new String[]{
                };
                fileLines = fileData.unescapeCsv().split('\n');
                for (Integer i = 1, j = fileLines.size(); i < j; i++) {
                    String[] inputvalues = new String[]{
                    };
                    inputvalues = fileLines[i].unescapeCsv().split(',(?=(?:[^\"]*\"[^\"]*\")*[^\"]*$)');
                    System.debug('inputvalues ::: ' + inputvalues);
                    integer rowsize = inputvalues.size();
                    System.debug('rowsize::'+rowsize);

//                    if(!String.isBlank(compCodeField)){
//                    for (integer l = 0; l < rowsize ; l++) {
//                        if ( fields.get(l) == emailField ) {
//                            if ( String.isNotBlank(inputvalues[l]) ) {
//                                for (integer m = 0; m < rowsize; m++) {
//                                    if ( fields.get(m) == compCodeField ) {
//                                        //Map is set to find any mismatched between AACRID and Email
//                                        emailMap.put(inputvalues[l].deleteWhitespace().toLowerCase(), inputvalues[m].deleteWhitespace());
//                                    }
//                                }
//                            }
//                        }
//                    }
//                    }else {
                        for (integer m = 0; m < rowsize; m++) {
                            if ( fields.get(m) == emailField ) {
                                if ( String.isNotBlank(inputvalues[m]) ) {
                                    emailMap.put(inputvalues[m].deleteWhitespace().toLowerCase(), '');
                                }
                            }
                        }
//                    }
                }
            }

        } catch (Exception e) {
            System.debug('exception' + e);
            throw new AACRCustomException(e.getMessage(),  e.getStackTraceString() , 'BrEventsMassRegistrationController');
        }

//        //VALIDATE EMAILS************************************//


        //get Email Map and put into list of Email Strings
        List<String> emailStrings = new List<String>();
//        List<String> compStrings = new List<String>();
        for(String e : emailMap.keySet() ){
            emailStrings.add(e);
//            compStrings.add(emailMap.get(e));
        }

        //Check for existing participants - These contacts are good and notify user they are created already
        List<BR_Participation__c> participants = getExistingParticipants(emailStrings, eventId);


        //put ContactIds into a list to exclude from future query validations.
        List<String> existingPartContacts = new List<String>();
        for(BR_Participation__c part: participants){
            existingPartContacts.add(part.Contact__c);
        }

        //List of contacts that don't exist - notify User
        List<String> emailsThatDontExist = queryContactsByEmail(emailStrings);

        //Get list of valid source codes
//        List<OrderApi__Source_Code__c> sourceCodes = getSouceCodes(compStrings);
//        System.debug('sourceCodes returned: ' + sourceCodes);
//        Map<Id, String> sourceCodeMap = new Map<Id, String>();

//        List<String> validSourceCodes = new List<String>();
//        for(OrderApi__Source_Code__c sc: sourceCodes){
//            validSourceCodes.add(sc.name);
//            sourceCodeMap.put(sc.name, sc.Id);
//        }

        //Go through original list of Email and Code Maps. Create a new list filtering out anyone mapped with an invalid code
        List<String> emailStringsWithCode = new List<String>();
        List<EmailInvalidCode> emailNoCode = new List<EmailInvalidCode>();
        for(String e: emailStrings){
            if(!existingPartContacts.contains(e) && !emailsThatDontExist.contains(e)) {
//                if ( validSourceCodes.contains(emailMap.get(e)) || String.isBlank(emailMap.get(e))) {
                    emailStringsWithCode.add(e);
//                } else {
                    EmailInvalidCode eic = new EmailInvalidCode();
                    eic.Email = e;
                    eic.Code = emailMap.get(e);
                    emailNoCode.add(eic);
//                }
            }
        }

        List<Contact> dupContactsList = getDupUsersByEmail(emailStringsWithCode, existingPartContacts); //To display to the user
        Map<String, String> dupContactsMap = new Map<String,String>(); //To track duplicate contact and matching source code

        List<String> dupContactIds = new List<String>();
        for(Contact dc : dupContactsList){
            dupContactIds.add(dc.Id);
            dupContactsMap.put(dc.AACR_ID__c, emailMap.get(dc.Email));
        }

        List<Contact> existingCons = [ SELECT Id FROM Contact
        WHERE Email IN: emailStrings
        OR OrderApi__Work_Email__c IN: emailStrings
        OR OrderApi__Personal_Email__c IN: emailStrings];

        List<String> existingConIds = new List<String>();
        for(Contact c : existingCons){
            existingConIds.add(c.Id);
        }

        System.debug('dupContactsMap = ' + dupContactsMap);
        //Get list of contacts that do not have Participant record, but has valid contact and user record. These users will need a Participant record.
        List<User> contactsWithUser = getExistingUsers(emailStrings, existingConIds, existingPartContacts, dupContactIds);

        //Create list of AACRIDs, to be returned, of validated contacts that are ready to create Participant records
        List<String> aacrIds = new List<String>();
//        Map<String,String> aacrIdCompMap = new Map<String,String>();
        //Create list of contactIds that exist without a user record and no participant record; We also want to exclude those with participant records
        List<String> contactIdsWithUser = new List<String>(existingPartContacts);
        for(User u: contactsWithUser){
            contactIdsWithUser.add(u.ContactId);
            aacrIds.add(u.AACR_ID__c);
//            aacrIdCompMap.put(u.AACR_ID__c, emailMap.get(u.Email));
        }

//        System.debug('aacrIDCompMap ==' + aacrIdCompMap);

        //This list will not create participants - notify User
        List<Contact> contactsNoUser = getContactsNoUser(emailStringsWithCode, contactIdsWithUser, dupContactIds);

        return new ContactLookups(dupContactsList,
                                    dupContactsMap,
                                    contactsNoUser,
                                    emailsThatDontExist,
                                    aacrIds,
                                    participants);


    }

    @AuraEnabled
    public static List<String> queryContactsByEmail(List<String> emailStrings){
        List<Contact> contacts = [ SELECT Id, AACR_ID__c, Email, Name, Membership_Status__c, Member_Type__c, RecordType.Name FROM Contact
        WHERE Email IN: emailStrings
        OR OrderApi__Work_Email__c IN: emailStrings
        OR OrderApi__Personal_Email__c IN: emailStrings];

        List<String> conEmailStrings = new List<String>();
        for (Contact con : contacts) {
            conEmailStrings.add(con.Email.toLowerCase());
        }

        List<String> emailDoesNotExist = new List<String>();
        for(String email : emailStrings){
            If(!conEmailStrings.contains(email.toLowerCase())) {
                System.debug('Email does not exist: ' + email);
                emailDoesNotExist.add(email);
            }
        }

        return emailDoesNotExist;

    }

    @AuraEnabled
    public static List<Contact> getDupUsersByEmail(List<String> emailStrings, List<String> contactIdsWithParts ){
        //EMAILS THAT HAVE DUPLICATES
        List<AggregateResult> dupContactsAgg = [SELECT Count(Id), Email FROM User
        WHERE Email IN: emailStrings
        AND ContactId !=NULL
        AND ContactId NOT IN: contactIdsWithParts
        GROUP BY Email
        HAVING COUNT(Id) > 1];

//        Create a list of emails for dup contacts
        List<String> dupContactEmails = new List<String>();
        for(AggregateResult dc : dupContactsAgg){
            dupContactEmails.add( String.valueOf(dc.get('Email')));
        }

//        Return list of Contacts that are duplicates to display to user
         return [SELECT Id, AACR_ID__c, Name, RecordType.Name, Member_Type__c, Membership_Status__c, Email
                FROM Contact
                WHERE Id IN (SELECT ContactId FROM User WHERE Email IN: dupContactEmails)];
    }


    @AuraEnabled
    public static List<Contact> getContactsNoUser(List<String> emailStrings, List<String> contactIdsWithUser, List<String> dupContactIds) {

        return [
                SELECT Id, AACR_ID__c, Name, RecordType.Name, Member_Type__c, Membership_Status__c, Email
                FROM Contact
                WHERE Email IN:emailStrings
                AND Id NOT IN:contactIdsWithUser
                AND Id NOT IN:dupContactIds
        ];
    }

    @AuraEnabled
    public static List<User> getExistingUsers(List<String> emailStrings, List<String> contactIds, List<String> contactsWithParts, List<String> dupContactIds) {

        return [
                SELECT Id, Email, ContactId, AACR_ID__c
                FROM User
                WHERE (Email IN: emailStrings OR ContactId IN: contactIds)
                AND ContactId NOT IN:contactsWithParts
                AND ContactId NOT IN:dupContactIds
        ];
    }


    @AuraEnabled
    public static List<BR_Participation__c> getExistingParticipants(List<String> emailStrings, String eventId){

        List<BR_Participation__c> participants =  [SELECT Id, Contact__c, Contact__r.AACR_ID__c , Registration_Date__c,
                                                    Contact__r.FirstName, Contact__r.LastName , Contact__r.Email
                                                    FROM BR_Participation__c
                                                    WHERE BR_Event__c =: eventId
                                                    AND Participate__c = 'Yes'
                                                    AND User__c IN (SELECT Id FROM User WHERE Email IN: emailStrings)];
        return participants;
    }

//    @AuraEnabled
//    public static List<OrderApi__Source_Code__c>  getSouceCodes(List<String> compCodes){
//        return [SELECT Id, Name FROM OrderApi__Source_Code__c WHERE OrderApi__Active__c = TRUE AND Name IN: compCodes];
//    }

    @AuraEnabled
    public static List<Contact> queryContactsByAACRID(List<String> aacrIds){
        return [ SELECT Id, AACR_ID__c, Name, RecordType.Name, Member_Type__c, Membership_Status__c, Email
        FROM Contact
        WHERE AACR_ID__c IN: aacrIds];
    }

    @AuraEnabled
    public static Id createParticipants(List<Contact> contacts, String eventId, Boolean bypassEmail, String compMapString){

        List<EmailCodeObject> deserializedList = (List<EmailCodeObject>) JSON.deserialize(compMapString, List<EmailCodeObject>.class);

//        Map<String, String> compMap = new Map<String, String>();
//        for(EmailCodeObject eco: deserializedList){
//            compMap.put(eco.key, eco.value);
//        }
//
//        System.debug('Comp MAP == ' + compMap);

        //Get list of Contacts that already have a participation record for this event
        List<BR_Participation__c> existingParts = [SELECT Id, Contact__c, Participate__c, Contact__r.AACR_ID__c FROM BR_Participation__c
                                                    WHERE BR_Event__c =: eventId
                                                    AND Contact__c IN: contacts];

//        List<String> codeStrings = new List<String>();
//        for(String code : compMap.values()){
//            codeStrings.add(code);
//        }
//
        Map<String, String> sourceCodeMap = new Map<String, String>();
//        if(!codeStrings.isEmpty()) {
//            List<OrderApi__Source_Code__c> sourceCodes = getSouceCodes(codeStrings);
//            for (String id : compMap.keySet()) {
//                for (OrderApi__Source_Code__c code : sourceCodes) {
//                    if ( compMap.get(id) == code.Name ) {
//                        sourceCodeMap.put(id, code.Id);
//                    }
//                }
//            }
//        }else{
//            sourceCodeMap = compMap;
//        }

//        System.debug('SourceCodeMap == ' + sourceCodeMap);

        //Create String list of Ids to compare against full list of contacts
        List<String> partContacts = new List<String>();
        List<BR_Participation__c> updateParticipations = new List<BR_Participation__c>();
        for(BR_Participation__c p: existingParts){
            partContacts.add(p.Contact__c);

            if(p.Participate__c != 'Yes'){
              updateParticipations.add(new BR_Participation__c(Id = p.Id, Participate__c = 'Yes', Via_Mass_Reg__c = true));
//                updateParticipations.add(new BR_Participation__c(Id = p.Id, Participate__c = 'Yes', Source_Code__c = sourceCodeMap.get(p.Contact__r.AACR_ID__c)));

            }
        }

        //Compare contacts list with existingParts list and only create participation records for those not in existingParts list
        List<String> newContacts = new List<String>();
        for(Contact con: contacts){
            if(!partContacts.contains(con.Id)) {
                newContacts.add(con.Id);
            }
        }


        if(!updateParticipations.isEmpty()) {
            update updateParticipations;
        }

        System.debug('Contacts to create Participant records = ' + newContacts.size());
            Batch_ProcessMassRegistration batch = new Batch_ProcessMassRegistration(eventId, newContacts, sourceCodeMap, bypassEmail);
            Id batchId = Database.executeBatch(batch, 100);

        return batchId;

    }

    @AuraEnabled
    public static AsyncApexJob getMassReg_BatchJobStatus(Id jobId){

        try {
            return [SELECT Status, NumberOfErrors,JobItemsProcessed,TotalJobItems FROM AsyncApexJob WHERE Id = :jobId];
        }catch(Exception e) {
            System.debug('exception' + e);
            return null;
        }

    }

    public static void sendRecordErrors_Contacts(List<User> users, Integer numProcessed, Id jobId){
        Messaging.EmailFileAttachment attachment = new Messaging.EmailFileAttachment();
        AsyncApexJob job = getMassReg_BatchJobStatus(jobId);
        Integer errorNum = Test.isRunningTest() ? 5 : job.NumberOfErrors;
        String body = 'Mass Registration completed with ' + errorNum + ' errors. ';

        if(errorNum > 0){
            body += 'Check PlatformAlert for error details. ';
        }

        if(!users.isEmpty()) {
            body += '\nSee attached file for Contacts that did register.';

            String contentCSV = '';
            for(User u : users){
                contentCSV += u.ContactId + ',' + u.Contact.AACR_ID__c + ',' + u.Contact.FirstName + ',' + u.Contact.LastName + ',' + u.Contact.Email + '\n';
            }
            String content = 'ContactId, AACRID, FirstName, LastName, Email\n' + contentCSV;

            attachment.setContentType('text/csv');
            attachment.setFileName( 'MassRegistration-DidNotRegister_' + Datetime.now().format('YYYYMMDD') + '.csv' );
            attachment.setBody( Blob.valueOf( content ) );
        }

        String subject = 'Mass Registration Completed: ' + numProcessed + ' records processed. ';
//        emailBatchCompleteStatus(subject,body,attachment);

        System.debug('attachment = ' + attachment);
        try {
            List<Messaging.SingleEmailMessage> messages = new List<Messaging.SingleEmailMessage>();
            Messaging.SingleEmailMessage msg = new Messaging.SingleEmailMessage();

            msg.setSubject(subject);
            msg.setHtmlBody(body);
//            msg.setToAddresses(new List<String>{ 'platformalert@yopmail.com' });
            msg.setTargetObjectId(UserInfo.getUserId());
            msg.setTreatTargetObjectAsRecipient(true);
            msg.setSaveAsActivity(false);
            if(attachment.getBody() != null) {
                msg.setFileAttachments(new Messaging.EmailFileAttachment[]{
                        attachment
                });
            }

            messages.add(msg);
            Messaging.sendEmail(messages);

        } catch (AACRCustomException e) {
            System.debug('Exception sending email :::' + e.getMessage() + '\t' + e.getStackTraceString());
            throw new AACRCustomException(e.getMessage(), e.getStackTraceString(), 'Email not sent');
        }
    }


    public class ContactLookups {
        @AuraEnabled
        public List<Contact> duplicateContactsList;
        @AuraEnabled
        public Map<String,String> duplicateContactsMap;
        @AuraEnabled
        public List<Contact> contactsNoUser;
        @AuraEnabled
        public List<String> emailDoesNotExist;
        @AuraEnabled
        public List<String> aacrIDs;
        @AuraEnabled
        public List<Object> participations;
//        @AuraEnabled
//        public Map<String,String> compMap;
//        @AuraEnabled
//        public List<EmailInvalidCode> emailInvalidCode;


        public ContactLookups(List<Contact> duplicateContactsList, Map<String,String> duplicateContactsMap,
                            List<Contact> contactsNoUser, List<String> emailDoesNotExist, List<String> aacrIDs,
                            List<BR_Participation__c> parts) {
            this.duplicateContactsList = duplicateContactsList;
            this.duplicateContactsMap = duplicateContactsMap;
            this.contactsNoUser = contactsNoUser;
            this.emailDoesNotExist = emailDoesNotExist;
            this.aacrIDs = aacrIDs;
            this.participations = parts;
//            this.compMap = compMap;
//            this.emailInvalidCode = emailInvalidCode;
        }
    }

    public class EmailInvalidCode {
        @AuraEnabled
        public String Email;
        @AuraEnabled
        public String Code;
    }

    public class EmailCodeObject {
        public String key;
        public String value;
    }

//    public class EmailLookups{
//        public List<String> emails;
//        public List<String> aacrIds;
//        public List<Contact> mismatchedContacts;
//
//        public EmailLookups(List<String> emails, List<String> aacrIds, List<Contact> mismatchedContacts){
//            this.emails = emails;
//            this.aacrIds = aacrIds;
//            this.mismatchedContacts = mismatchedContacts;
//        }
//    }
}