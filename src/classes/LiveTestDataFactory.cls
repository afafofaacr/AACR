/**
 * Created by lauren.lezberg on 2/20/2020.
 */
@isTest
public with sharing class LiveTestDataFactory {

    public static AC_Event_User_Segment__c buildEventUserSegment(Id eventId, Id userSegmentId, String eventPreferenceFieldSet){
        AC_Event_User_Segment__c eus = new AC_Event_User_Segment__c();
        eus.AC_User_Segment__c = userSegmentId;
        eus.Event_Preferences_Form_Fieldset__c = eventPreferenceFieldSet;
        eus.AC_Event__c = eventId;

        return eus;
    }

    public static AC_User_Segment__c buildUserSegment(String name){
        AC_User_Segment__c us = new AC_User_Segment__c();
        us.Name= name;
        us.Active__c = true;
        us.Description__c = 'Test User Segment';

        return us;
    }

    public static BR_Events_Zone__c buildZone(String zoneName, Boolean isDefault){
        BR_Events_Zone__c zone = new BR_Events_Zone__c();
        zone.Name=zoneName;
        zone.Is_Default__c = isDefault;

        return zone;
    }

    public static Venue__c buildVenue(String venueName){
        Venue__c ven = new Venue__c(Name=venueName);
        ven.Street_1__c = '123 Main St';
        ven.City__c = 'Test';
        ven.State__c = 'TEST';
        ven.Country__c = 'USA';
        ven.Zip__c = '12345';

        return ven;
    }

    public static BR_Event__c buildEvent(String eventName, Boolean draft, Boolean isPrivate, Id zoneId){
        BR_Event__c evnt = new BR_Event__c();
        evnt.Start_Date__c = System.today();
        evnt.End_Date__c = Datetime.newInstance(System.now().year(), System.now().month(), System.now().day() + 1);
        evnt.Name = eventName;
        evnt.Draft__c = draft;
        evnt.BR_Events_Zone__c = zoneId;
        if(isPrivate) {
            evnt.Unlisted_Event__c = true;
        } else {
            evnt.Publicly_available__c = true;
        }

        return evnt;
    }

    public static BR_Event__c buildEvent(String eventName, Boolean draft, Boolean isPrivate){
        BR_Event__c evnt = new BR_Event__c();
        evnt.Start_Date__c = System.today();
        evnt.End_Date__c = Datetime.newInstance(System.now().year(), System.now().month(), System.now().day() + 1);
        evnt.Name = eventName;
        evnt.Draft__c = draft;
        if(isPrivate) {
            evnt.Unlisted_Event__c = true;
        } else {
            evnt.Publicly_available__c = true;
        }
        evnt.Registration_Confirmation_Message__c = 'Test Message';

        return evnt;
    }


    public static AACR_Session__c buildSession(Id eventId, String sessionName, Date sessionDate, Time startTime, Time endTime){
        AACR_Session__c session = new AACR_Session__c();
        session.Event__c = eventId;
        session.Name = sessionName;
        session.Start_Time__c = startTime;
        session.End_Time__c = endTime;
        session.Date__c = sessionDate;
        return session;
    }

    public static Session_Speaker__c buildSessionSpeaker(Id sessionId, String presentationName, Id contactId){
        Session_Speaker__c speaker = new Session_Speaker__c();
        speaker.Speaker__c = contactId;
        speaker.Name = presentationName;
        speaker.Session__c = sessionId;
        speaker.Roles__c = 'Speaker';

        return speaker;
    }

    /**
    *@purpose   : build Account record
    *@param     : accountName
    *@return    : Account record
    */
    public static Account buildAccount(String accountName){

        return new Account(Name = accountName);
    }

    /**
     *@purpose   : Build Contact record for non-member
     *@param     : accountId
     *@return    : Contact record
     */
    public static Contact buildContact(Id accountId){
        // Creating Contact record
        return new Contact(LastName = 'Test contact',
                AccountId = accountId,
                Phone ='9878986789',
                Fax = 'fax',
                Email = 'testEmail@yopmail.com');
    }

    public static Contact buildAssistant(Id accountId){
        Contact assist = new Contact(LastName = 'Test Assistant',
                AccountId = accountId,
                Phone ='9878986789',
                Fax = 'fax',
                Email = 'testAssistantEmail@yopmail.com');
        return  assist;

    }

    public static npe4__Relationship__c buildAssistantRelationship(Id contactId, Id assistantId){
        npe4__Relationship__c relationship = new npe4__Relationship__c(npe4__Type__c='Assistant', npe4__Status__c = 'Current', npe4__RelatedContact__c=assistantId, npe4__Contact__c=contactId);

        return relationship;
    }


    /**
     *@purpose   : Build User record
     *@param     : contactId
     *@return    : User Record
     */
    public static User buildStandardUser(Id contactId){
        // Fetching profile record
        Profile profileRecord = [SELECT Id
        FROM Profile
        WHERE Name =: 'Standard User'
        LIMIT 1];

        // Create users record
        User userRecord = new User(alias = 'test',
                ProfileId = profileRecord.Id,
                email = 'test@testorg.com',
                emailencodingkey = 'UTF-8',
                lastname = 'Test User2',
                CommunityNickname = contactId,
                languagelocalekey = 'en_US',
                localesidkey = 'en_US',
                timezonesidkey = 'America/Los_Angeles',
                username = System.now().millisecond() + 'test@testorg2.com');
        return userRecord;
    }
}