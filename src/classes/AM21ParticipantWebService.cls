/**
 * Created by lauren.lezberg on 4/5/2021.
 */
@RestResource(urlMapping='/AM21Participant/*')
global with sharing class AM21ParticipantWebService {

    @HttpGet
    global static AM21Participation getParticipant() {
        RestRequest req = RestContext.request;

        String keyId = req.requestURI.substring(req.requestURI.lastIndexOf('/') + 1);
        String contactId;

        System.debug('keyId = ' + keyId.substring(0, 3));

        If ( keyId.substring(0, 3) == '005' ) {
            contactId = [SELECT ContactId FROM User WHERE Id = :keyId].ContactId;
        } else {
            contactId = keyId;
        }

        AM21Participation participant = new AM21Participation();


        try{
            Contact con = [
                    SELECT Salutation,
                            FirstName,
                            MiddleName,
                            LastName,
                            Suffix_Text__c,
                            Name,
                            Title,
                            Department,
                            AccountId,
                            Account.Name,
                            Account.Institution_Type__c,
                            MailingStreet,
                            MailingCity,
                            MailingState,
                            MailingPostalCode,
                            MailingCountry,
                            Email,
                            Phone,
                            Race__c,
                            Gender__c,
                            Birthdate,
                            Primary_Research_Area_of_Expertise__c,
                            Major_Focus__c,
                            AACR_ID__c,
                            Membership_Status__c,
                            Member_Type__c,
                            Paid_thru_date__c,
                            Degrees_Held__c,
                            Current_Education_Status__c,
                            Organ_Sites__c,
                            Advocate__c,
                            Survivor__c,
                            RecordType.Name,
                            Id
                    FROM Contact
                    WHERE AACR_ID__c = :contactId OR Id = :contactId];

            participant.contact = con;
            List<BR_Participation__c> participations = [SELECT Id FROM BR_Participation__c WHERE BR_Event__r.Name = 'AACR Annual Meeting 2021' AND Contact__c=:con.Id AND Participate__c = 'Yes'];

            if(!participations.isEmpty()){
                participant.isRegistered = true;
                participant.registrationId = participations[0].Id;
            }

        } catch(Exception e){

        }

        return participant;
    }

    global class AM21Participation{
        public Boolean isRegistered = false;
        public String registrationId = null;
        public Contact contact;
    }
}