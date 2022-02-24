/**
 * Created by afaf.awad on 9/20/2021.
 */

public without sharing class EventSegmentHelper {

    @AuraEnabled
    public static Boolean checkAccess(String contactId){
        return FeatureManagement.checkPermission('Override_Segment');
    }

    @AuraEnabled
    public static Contact getSegmentInfo(String contactId){
        return [SELECT AccountId  FROM Contact WHERE Id =: contactId];
    }

    @AuraEnabled
    public static void saveSegmentOverride(String contactId, String wbilReason, String wbil, String intType, String intTypeReason, String accountId){
        System.debug('Saving event segment...');

        if(String.isNotBlank(wbilReason)) {
            Contact orContact = new Contact(Id = contactId,
                    WBIL_Override_Reason__c = wbilReason,
                    Income_Level__c = wbil,
                    Manual_Segment_Override__c = true,
                    Override_Date__c = System.now(),
                    Override_By__c = UserInfo.getUserId());
            update orContact;
        }

        if(String.isNotBlank(intTypeReason)) {
            Account orAccount = new Account(Id = accountId,
                    Institution_Type__c = intType,
                    Institution_Type_Override__c = true,
                    Institution_Type_Override_Reason__c = intTypeReason);

            update orAccount;
        }

    }

    public static String buildSegmentCode(Contact con, Map<Id, Account> accountMap) {

        String recordtype = Schema.getGlobalDescribe().get('Contact').getDescribe().getRecordTypeInfosById().get(con.RecordTypeId).getName();
        //Init string; Record type segment
        System.debug('recordType = ' + recordtype);
        String segment = recordtype == 'Member' ? 'MB-' : 'NM-';
        System.debug('segment = ' + segment);
        //Institution Type segment
        System.debug('int type = ' + accountMap.get(con.AccountId).NPO__c);
        if(accountMap.get(con.AccountId).NPO__c && (con.Member_Type__c == 'Active Member' || recordtype != 'Member')){
            segment += 'NP';
        }else {
            segment += 'NA';
        }

        segment += '-';

        System.debug('segment = ' + segment);
        //Constituent Type segment
        if (con.Advocate__c) {
            segment = recordtype == 'Member' ? 'MB-NA-PA' : 'NM-NA-PA';
        } else if (con.Pre_Post_Doc__c) {
            segment = 'NA-NA-PP';
        } else {
            if(recordtype == 'Member') {
                switch on con.Member_Type__c {
                    when 'Active Member' {
                        segment += 'AM';
                    }
                    when 'Associate Member' {
                        segment += 'AS';
                    }
                    when 'Affiliate Member' {
                        segment += 'AF';
                    }
                    when 'Emeritus Member' {
                        segment += 'EM';
                    }
                    when 'Student Member' {
                        segment += 'SD';
                    }
                    when else {
                        if (segment.contains('NP')) {
                            segment += 'AM';
                        } else {
                            segment += 'NA';
                        }
                    }
                }
            }else{
                segment += 'NA';
            }
        }

        segment += '-';
        System.debug('segment = ' + segment);
        System.debug('Income Level == ' + con.Income_Level__c);
        //World Bank
        if(String.isBlank(con.Income_Level__c)) {
            segment += 'HHI';
        }else{
            switch on con.Income_Level__c.toLowerCase() {
                when 'upper middle income' {
                    segment += 'UMI';
                }
                when 'lower middle income' {
                    segment += 'LMI';
                }
                when 'low income' {
                    segment += 'LWI';
                }
                when else {
                    segment += 'HHI';
                }
            }
        }
        System.debug('segment = ' + segment);
        return segment;
    }
}