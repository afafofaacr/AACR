/**
 * Created by afaf.awad on 6/5/2020.
 */

public with sharing class MassRegistrationController {

    @AuraEnabled
    public static Boolean isEligibleEvent(String eventId){

        EventApi__Event__c event = [SELECT Is_Eligible_Mass_Registration__c FROM EventApi__Event__c where Id =: eventId];

        return event.Is_Eligible_Mass_Registration__c;

    }

    @AuraEnabled
    public static Boolean validateData(String fileData, List<String> fields, String aacrField, String emailField) {

        System.debug('fields:::' + fields);
        System.debug('aacrField:::' + aacrField);
        System.debug('emailField:::' + emailField);

        Boolean validated = true;
        List<String> emailStrings = new List<String>();
        try {
                String[] fileLines = new String[]{
                };
                fileLines = fileData.split('\n');
                for (Integer i = 1, j = fileLines.size(); i < j; i++) {
                    if ( validated == true ) {
                        String[] inputvalues = new String[]{
                        };
                        inputvalues = fileLines[i].split(',');
//                        System.debug('inputvalues ::: ' + inputvalues);
                        integer rowsize = inputvalues.size();
                        for (integer m = 0; m < rowsize; m++) {
                            if ( fields.get(m) == emailField ) {
                                if ( String.isNotBlank(inputvalues[m]) ) {
//                                    System.debug('Validate Email: ' + inputvalues[m] );
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
//            throw new AACRCustomException(e.getMessage(), e.getStackTraceString(), 'Mass Registration');
        }
        System.debug('validated = ' + validated);
        return validated;
    }


    @AuraEnabled
    public static ContactLookups processData(String fileData, List<String> fields, String aacrField, String emailField, String eventId) {

        System.debug('fields:::' + fields);
        System.debug('aacrField:::' + aacrField);
        System.debug('emailField:::' + emailField);

        List<String> emailStrings = new List<String>();
        Map<String, String> emailNIdMap = new Map<String,String>();
        try {
            if ( fileData != null ) {
                String[] fileLines = new String[]{
                };
                fileLines = fileData.split('\n');
                for (Integer i = 1, j = fileLines.size(); i < j; i++) {
                    String[] inputvalues = new String[]{
                    };
                    inputvalues = fileLines[i].split(',');
//                    System.debug('inputvalues ::: ' + inputvalues);
                    integer rowsize = inputvalues.size();
//                    System.debug('rowsize::'+rowsize);

                    for (integer l = 0; l < rowsize ; l++) {
                        if ( fields.get(l) == aacrField ) {
                            if ( String.isNotBlank(inputvalues[l]) ) {
                                for (integer m = 0; m < rowsize; m++) {
                                    if ( fields.get(m) == emailField ) {
                                        //Map is set to find any mismatched between AACRID and Email
                                        emailNIdMap.put(inputvalues[l].deleteWhitespace(), inputvalues[m].deleteWhitespace());
                                    }
                                }
                            }
                        }
                    }

                    for (integer m = 0; m < rowsize; m++) {
                        if ( fields.get(m) == emailField ) {
                            if ( String.isNotBlank(inputvalues[m]) ) {
                                emailStrings.add(inputvalues[m].deleteWhitespace());
                            }
                        }
                    }
                }
            }

        } catch (Exception e) {
            System.debug('exception' + e);
//            throw new AACRCustomException(e.getMessage(),  e.getStackTraceString() , 'Mass Registration');
        }

        EmailLookups lookups = queryContactsByEmail(emailStrings, emailNIdMap);
        List<Contact> dupContacts = queryDupContactsByEmail(emailStrings);

        List<String> dupStrings = new List<String>();
        List<String> aacrIds = new List<String>();

        //Create list of AACRIDs for Dup Contacts to compare against AACRID Set
        for(Contact con : dupContacts){
            dupStrings.add(con.AACR_ID__c);
        }
        //Compare dups list with ACCRID set. If it exists, remove from list
//        for(String s: dupStrings){
//            if(aacrIdSet.contains(s)){
//                aacrIdSet.remove(s);
//            }
//        }
        //Compare list of Emails queried. If they are not in the dups list, add to AACRID Set
        for(String a : lookups.aacrIds){
            if(!dupStrings.contains(a)){
                aacrIds.add(a);
            }
        }
//        List<String> aacrIds = new List<String>();
//        aacrIds.addAll(aacrIdSet);

        System.debug('AACRID String = ' + aacrIds);
        System.debug('Email String = ' + emailStrings);

        List<EventApi__Attendee__c> attendees = getExistingAttendees(aacrIds, emailStrings, eventId);

        //Remove existing Attendees from Dups List and AACRID List
        for (EventApi__Attendee__c a : attendees) {
            for (Integer i = (dupContacts.size() - 1); i >= 0; i--) {
                if(dupContacts[i].Email == a.EventApi__Email__c){
                    dupContacts.remove(i);
                }
            }
            for (Integer i = (aacrIds.size() - 1); i >= 0; i--) {
                if(aacrIds[i] == a.EventApi__Contact__r.AACR_ID__c){
                    aacrIds.remove(i);
                }
            }
        }

        //Remove dups from misMatched list
        for (Contact c : dupContacts ) {
            for (Integer i = (lookups.mismatchedContacts.size() - 1); i >= 0; i--) {
                if ( lookups.mismatchedContacts[i].Email == c.Email ) {
                    lookups.mismatchedContacts.remove(i);
                }
            }
        }

        System.debug('Final result of aacrids= ' + aacrIds);

        return new ContactLookups(dupContacts, lookups.emails, aacrIds, attendees, lookups.mismatchedContacts);
    }

    @AuraEnabled
    public static EmailLookups queryContactsByEmail(List<String> emailStrings, Map<String,String> idEmailMap){
        List<Contact> contacts = [ SELECT Id, AACR_ID__c, Email, Name, Membership_Status__c, Member_Type__c, RecordType.Name FROM Contact
                                    WHERE Email IN: emailStrings
                                    OR OrderApi__Work_Email__c IN: emailStrings
                                    OR OrderApi__Personal_Email__c IN: emailStrings];

        List<String> conEmailStrings = new List<String>();
        List<String> aacrIds = new List<String>();
        List<Contact> mismatchContacts = new List<Contact>();
        List<String> mismatchAACR = new List<String>();

        for (String k : idEmailMap.keySet()) {
            for (Contact con : contacts) {
//                conEmailStrings.add(con.Email);
                if ( con.Email.toLowerCase() == idEmailMap.get(k).toLowerCase() ) {
                    if ( con.AACR_ID__c != k ) {
                        System.debug('mismatched Contact : ' + con);
                        mismatchContacts.add(con);
                        mismatchAACR.add(con.AACR_ID__c);
                    }
                }
            }
        }

        for(Contact con: contacts){
            if(!mismatchAACR.contains(con.AACR_ID__c)){
                aacrIds.add(con.AACR_ID__c);
            }
        }

        for (Contact con : contacts) {
            conEmailStrings.add(con.Email.toLowerCase());
        }

        System.debug('contactsBYEmail: ' + conEmailStrings);

        List<String> emailDoesNotExist = new List<String>();
        for(String email : emailStrings){
            If(!conEmailStrings.contains(email.toLowerCase())) {
                System.debug('Email does not exist: ' + email);
                emailDoesNotExist.add(email);
            }
        }

        return new EmailLookups(emailDoesNotExist, aacrIds, mismatchContacts);
    }

    @AuraEnabled
    public static List<Contact> queryDupContactsByEmail(List<String> emailStrings){
        //EMAILS THAT HAVE DUPLICATES
        List<AggregateResult> dupContactsAgg = [SELECT Count(Id), Email FROM Contact
                                                WHERE Email IN: emailStrings
                                              //  OR OrderApi__Work_Email__c IN: emailStrings
                                              //  OR OrderApi__Personal_Email__c IN: emailStrings
                                                GROUP BY Email
                                                HAVING COUNT(Id) > 1];

        List<String> dupContactEmails = new List<String>();

        for(AggregateResult dc : dupContactsAgg){
            dupContactEmails.add( String.valueOf(dc.get('Email')));
        }

        List<Contact> dupContacts = [SELECT Id, AACR_ID__c, Name, RecordType.Name, Member_Type__c, Membership_Status__c, Email
                                        FROM Contact
                                        WHERE Email IN: dupContactEmails
                                        OR OrderApi__Work_Email__c IN: dupContactEmails
                                        OR OrderApi__Personal_Email__c IN: dupContactEmails];
        return dupContacts;
    }

    @AuraEnabled
    public static List<EventApi__Attendee__c> getExistingAttendees(List<String> aacrIds, List<String> emailStrings, String eventId){
        return [SELECT Id, EventApi__Contact__c, EventApi__Contact__r.AACR_ID__c , EventApi__Registration_Date__c, EventApi__Full_Name__c, EventApi__Email__c
                FROM EventApi__Attendee__c
                WHERE EventApi__Event__c =: eventId
                AND EventApi__Contact__c IN (SELECT Id FROM Contact WHERE AACR_ID__c IN: aacrIds
                                                OR Email IN: emailStrings
                                                OR OrderApi__Work_Email__c IN: emailStrings
                                                OR OrderApi__Personal_Email__c IN: emailStrings)];
    }

    @AuraEnabled
    public static List<Contact> queryContactsByAACRID(List<String> aacrIds){
        return [ SELECT Id, AACR_ID__c, Name, RecordType.Name, Member_Type__c, Membership_Status__c, Email
        FROM Contact
        WHERE AACR_ID__c IN: aacrIds];
    }

    @AuraEnabled
    public static void createAttendees(List<Contact> contacts, String eventId){
        String freemanEvent;

        try {
            freemanEvent = [SELECT Freeman_Event_Id__c FROM Virtual_Meeting_Links__mdt WHERE Event_Id__c = :eventId].Freeman_Event_Id__c;
        }catch (Exception e){
            freemanEvent = '';
        }

        List<EventApi__Attendee__c> attendees = new List<EventApi__Attendee__c>();

        List<EventApi__Attendee__c> existingAttendees = [SELECT Id, EventApi__Contact__c
                                                            FROM EventApi__Attendee__c
                                                            WHERE EventApi__Event__c =: eventId
                                                            AND EventApi__Contact__c IN: contacts];

        List<String> contactIds = new List<String>();
        for(EventApi__Attendee__c a: existingAttendees){
            contactIds.add(a.EventApi__Contact__c);
        }

        List<Id> fmContacts = new List<Id>();

        for(Contact con: contacts){
            if(!contactIds.contains(con.Id)) {
                EventApi__Attendee__c att = new EventApi__Attendee__c();
                att.EventApi__Contact__c = con.Id;
                att.EventApi__Event__c = eventId;
                att.EventApi__Status__c = 'Registered';
                att.EventApi__Registration_Date__c = Date.today();
                attendees.add(att);
                fmContacts.add(con.Id);
            }
        }

        try{

            System.debug('# of Contacts to send to Freeman: ' + fmContacts.size());
            System.debug('serialized list = ' + JSON.serialize(fmContacts));
            Batch_CallFreeman bcn = new Batch_CallFreeman(eventId, false, JSON.serialize(fmContacts), freemanEvent, true);
            Id batchproccessId = Database.executeBatch(bcn, 50);

        }catch(DmlException e){
            System.debug('exception' + e);
//           throw new AACRCustomException(e.getMessage(),  e.getStackTraceString() , 'Mass Registration');
        }

    }


    public class ContactLookups {
        @AuraEnabled
        public List<Contact> duplicateContacts;
        @AuraEnabled
        public List<String> emailDoesNotExist;
        @AuraEnabled
        public List<String> aacrIDs;
        @AuraEnabled
        public List<EventApi__Attendee__c> attendees;
        @AuraEnabled
        public List<Contact> mismatchedContacts;

        public ContactLookups(List<Contact> duplicateContacts, List<String> emailDoesNotExist, List<String> aacrIDs, List<EventApi__Attendee__c> attendees, List<Contact> mismatchedContacts) {
            this.duplicateContacts = duplicateContacts;
            this.emailDoesNotExist = emailDoesNotExist;
            this.aacrIDs = aacrIDs;
            this.attendees = attendees;
            this.mismatchedContacts = mismatchedContacts;
        }
    }

    public class EmailLookups{
        public List<String> emails;
        public List<String> aacrIds;
        public List<Contact> mismatchedContacts;

        public EmailLookups(List<String> emails, List<String> aacrIds, List<Contact> mismatchedContacts){
            this.emails = emails;
            this.aacrIds = aacrIds;
            this.mismatchedContacts = mismatchedContacts;
        }
    }
}