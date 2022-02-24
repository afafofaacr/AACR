public class CopyContactToClipboardCtrl {
    @AuraEnabled
    public static String getContactData(String contactId) {
        String contactCopyData = '';
        List<Contact> contactList = [
                SELECT Id,
                        Salutation,
                        Name,
                        Nickname__c,
                        Account_Name__c,
                        Title,
                        OrderApi__Work_Phone__c,
                        HomePhone,
                        MobilePhone,
                        OrderApi__Preferred_Email__c,
                        Preferred_Address__c,
                        MailingStreet,
                        MailingCountry,
                        MailingCity,
                        MailingState,
                        MailingStateCode,
                        MailingPostalCode,
                        OtherStreet,
                        OtherCountry,
                        OtherCity,
                        OtherState,
                        OtherStateCode,
                        OtherPostalCode,
                        Journal_Street__c,
                        Journal_City__c,
                        Journal_State_Province__c,
                        Journal_Country__c,
                        Journal_Zip_Postal_Code__c
                FROM Contact
                WHERE Id = :contactId
        ];

        List<OrderApi__Known_Address__c> defaultAddresses = [SELECT Type__c FROM OrderApi__Known_Address__c WHERE OrderApi__Is_Default__c = true AND OrderApi__Contact__c=:contactId];

        List<npe4__Relationship__c> assistants = [
                SELECT npe4__RelatedContact__r.Salutation,
                        npe4__RelatedContact__r.Name,
                        npe4__RelatedContact__r.OrderApi__Work_Phone__c,
                        npe4__RelatedContact__r.HomePhone,
                        npe4__RelatedContact__r.MobilePhone,
                        npe4__RelatedContact__r.OrderApi__Preferred_Email__c
                FROM npe4__Relationship__c
                WHERE npe4__Type__c = 'Assistant'
                AND npe4__Status__c = 'Current'
                AND npe4__Contact__c = :contactId
        ];

        for (Contact contact : contactList) {
            if ( contact.Salutation != null ) {
                contactCopyData = contact.Salutation + ' ';
            }
            if ( contact.Name != null ) {
                contactCopyData += contact.Name + '\n';
            }
            if ( contact.Title != null ) {
                contactCopyData += contact.Title + '\n';
            }
            if ( contact.Account_Name__c != null ) {
                contactCopyData += contact.Account_Name__c + '\n';
            }
            if ( contact.OrderApi__Work_Phone__c != null ) {
                contactCopyData += 'W-' + contact.OrderApi__Work_Phone__c + '\n';
            }
            if ( contact.HomePhone != null ) {
                contactCopyData += 'H-' + contact.HomePhone + '\n';
            }
            if ( contact.MobilePhone != null ) {
                contactCopyData += 'M-' + contact.MobilePhone + '\n';
            }
            if ( contact.OrderApi__Preferred_Email__c != null ) {
                contactCopyData += contact.OrderApi__Preferred_Email__c + '\n';
            }
            if ( contact.Nickname__c != null ) {
                contactCopyData += contact.Nickname__c + '\n';
            }
            if ( !defaultAddresses.isEmpty() ) {
                contactCopyData += 'Primary Address: ' + defaultAddresses[0].Type__c + '\n';
            }
            if ( contact.MailingStreet != null ) {
                contactCopyData += '\nPrimary Address:' + '\n' + contact.MailingStreet + '\n';
            }
            if ( contact.MailingCity != null ) {
                contactCopyData += contact.MailingCity;
            }
            if ( contact.MailingState != null ) {
                contactCopyData += ', ' + contact.MailingStateCode;
            }
            if ( contact.MailingPostalCode != null ) {
                contactCopyData += ' ' + contact.MailingPostalCode + '\n';
            }
            if ( contact.MailingCountry != null ) {
                contactCopyData += contact.MailingCountry + '\n';
            }
            if ( contact.OtherStreet != null ) {
                contactCopyData += '\nHome Address:' + '\n' + contact.OtherStreet + '\n';
            }
            if ( contact.OtherCity != null ) {
                contactCopyData += contact.OtherCity;
            }
            if ( contact.OtherState != null ) {
                contactCopyData += ', ' + contact.OtherStateCode;
            }
            if ( contact.OtherPostalCode != null ) {
                contactCopyData += ' ' + contact.OtherPostalCode + '\n';
            }
            if ( contact.OtherCountry != null ) {
                contactCopyData += contact.OtherCountry + '\n';
            }
            if ( contact.Journal_Street__c != null ) {
                contactCopyData += '\nJournal Address:' + '\n' + contact.Journal_Street__c + '\n';
            }
            if ( contact.Journal_City__c != null ) {
                contactCopyData += contact.Journal_City__c;
            }
            if ( contact.Journal_State_Province__c != null ) {
                contactCopyData += ', ' + contact.Journal_State_Province__c;
            }
            if ( contact.Journal_Zip_Postal_Code__c != null ) {
                contactCopyData += ' ' + contact.Journal_Zip_Postal_Code__c + '\n';
            }
            if ( contact.Journal_Country__c != null ) {
                contactCopyData += contact.Journal_Country__c + '\n';
            }

            if ( !assistants.isEmpty() ) {

                for (npe4__Relationship__c assistant : assistants) {
                    contactCopyData += '\n\nAssistant:\n';

                    if ( assistant.npe4__RelatedContact__r.Salutation != null ) {
                        contactCopyData += assistant.npe4__RelatedContact__r.Salutation + ' ';
                    }
                    if ( assistant.npe4__RelatedContact__r.Name != null ) {
                        contactCopyData += assistant.npe4__RelatedContact__r.Name + '\n';
                    }
                    if ( assistant.npe4__RelatedContact__r.OrderApi__Work_Phone__c != null ) {
                        contactCopyData += 'W-' + assistant.npe4__RelatedContact__r.OrderApi__Work_Phone__c + '\n';
                    }
                    if ( assistant.npe4__RelatedContact__r.HomePhone != null ) {
                        contactCopyData += 'H-' + assistant.npe4__RelatedContact__r.HomePhone + '\n';
                    }
                    if ( assistant.npe4__RelatedContact__r.MobilePhone != null ) {
                        contactCopyData += 'M-' + assistant.npe4__RelatedContact__r.MobilePhone + '\n';
                    }
                    if ( assistant.npe4__RelatedContact__r.OrderApi__Preferred_Email__c != null ) {
                        contactCopyData += assistant.npe4__RelatedContact__r.OrderApi__Preferred_Email__c ;
                    }
                }
            }
        }
        System.Debug('Copy Contact : ' + contactCopyData);
        return contactCopyData;
    }
}