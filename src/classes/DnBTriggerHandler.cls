/**
 * Created by afaf.awad on 6/10/2021.
 */

public without sharing class DnBTriggerHandler {

    public static void updateInstitutionType(List<Account> accounts){

        List<String> dnbIds = new List<String>();
        for(Account acc : accounts){
            dnbIds.add(acc.DNBoptimizer__DnBCompanyRecord__c);
        }

        List<DNBoptimizer__DnBCompanyRecord__c> dnBCompanyRecords = [SELECT Id, Name,  DNBoptimizer__MinorityOwnedIndicator__c, DNBoptimizer__SIC4Code1__c, DNBoptimizer__DUNSNumber__c
                                                                        FROM DNBoptimizer__DnBCompanyRecord__c
                                                                        WHERE Id IN: dnbIds];

        System.debug('accountToDnb = ' + dnBCompanyRecords);

        List<SIC_Code__mdt> sicCodesMtd = [SELECT Id, Label, Industry_Group__c, Major_Group__c, Specific_Code__c FROM SIC_Code__mdt];
        Map<String,String> majorGroup = new Map<String,String>();
        Map<String,String> industryGroup = new Map<String,String>();
        Map<String,String> specificGroup = new Map<String,String>();
        List<Account> accounts2Update = new List<Account>();

        for(SIC_Code__mdt code: sicCodesMtd){
            majorGroup.put(code.Major_Group__c, code.Label);
            industryGroup.put(code.Industry_Group__c, code.Label);
            specificGroup.put(code.Specific_Code__c, code.Label);
        }

        for(Account acc : accounts) {
            for (DNBoptimizer__DnBCompanyRecord__c dnb : dnBCompanyRecords) {
                if(acc.DNBoptimizer__DnBCompanyRecord__c == dnb.Name) {
                    String sicCode = dnb.DNBoptimizer__SIC4Code1__c;
                    System.debug('sicCode == ' + sicCode);
                    if(String.isNotBlank(sicCode)) {
                        if (getListOfSicCodeMatches(sicCode.left(2), majorGroup) != null) {
                            acc.Institution_Type__c = getListOfSicCodeMatches(sicCode.left(2), majorGroup);
                        } else if (getListOfSicCodeMatches(sicCode.left(3), industryGroup) != null) {
                            acc.Institution_Type__c = getListOfSicCodeMatches(sicCode.left(3), industryGroup);
                        } else if (getListOfSicCodeMatches(sicCode.left(4), specificGroup) != null){
                            acc.Institution_Type__c = getListOfSicCodeMatches(sicCode.left(4), specificGroup);
                        }else{
                            acc.Institution_Type__c = 'Other';
                        }
                    }else{
                        acc.Institution_Type__c = 'Other';
                    }
                    acc.Minority_Institution__c = dnb.DNBoptimizer__MinorityOwnedIndicator__c == 'true' ? true : false;
                    accounts2Update.add(acc);
                }
            }
        }

        try{
            if(!accounts2Update.isEmpty()) {
                update accounts2Update;
            }
        }catch(Exception e){
            System.debug('Error updating Institution types from DNB: ' + e.getMessage());
        }
    }

    public static String getListOfSicCodeMatches(String sicCode, Map<String, String> groupMap) {

        List<String> groupList = new List<String>();
        for (String key : groupMap.keySet()) {
            if ( groupMap.containsKey(sicCode) ) {
                groupList.add(groupMap.get(sicCode));
            }
        }

        if ( groupList.size() > 1 ) {
            System.debug('groupMap == ' + groupMap.get(sicCode));
            return groupMap.get(sicCode);
        } else {
            return null;
        }
    }

}