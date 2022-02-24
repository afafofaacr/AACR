@RestResource(urlMapping='/Contact/*')

global with sharing class AtlasWebService {
    @Httpget
    global static Contact fetchContact(){
        RestRequest req = RestContext.request;
        RestResponse res = Restcontext.response;

        String keyId = req.requestURI.substring(req.requestURI.lastIndexOf('/') + 1);
        String contactId;

        System.debug('keyId = ' + keyId.substring(0, 3));

        If ( keyId.substring(0, 3) == '005' ) {
            contactId = [SELECT ContactId FROM User WHERE Id = :keyId].ContactId;
        } else if(keyId.contains('@') ){
            contactId = [SELECT ContactId FROM User WHERE Email = :keyId].ContactId;
        } else {
            contactId = keyId;
        }

        Contact result = new Contact();

        try {
            result = [
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
                            OrderApi__Preferred_Phone__c,
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
//                    ,(SELECT Id FROM OrderApi__Badges__r)
                    FROM Contact
                    WHERE AACR_ID__c = :contactId OR Id = :contactId
            ];

            if(result.Account.Name.contains('Household') || result.Account.Name.contains('(Individual)')){
                result.Account.Name = null;
            }

        } catch (DmlException e) {
            System.debug('Id ' + contactId + ' returned no result');
        }

        return result;
    }
}