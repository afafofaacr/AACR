/**
 * Created by afaf.awad on 7/10/2020.
 */

public without sharing class CompanyLookupController {

    public static String dunToken;
    public static DunBradstreet__c db = DunBradstreet__c.getOrgDefaults();
    public static String testResponse = '{"transactionDetail":{"transactionID":"rrt-0cde86a015a8f3483-c-wo-31040-48052832-34","transactionTimestamp":"2021-01-19T20:58:54.872Z","inLanguage":"en-US","serviceVersion":"1"},"inquiryDetail":{"searchTerm":"Alphabet%City"},"candidatesReturnedQuantity":10,"candidatesMatchedQuantity":78,"searchCandidates":[{"displaySequence":1,"organization":{"duns":"219241986","dunsControlStatus":{"isOutOfBusiness":false},"primaryName":"ALPHABET CITY DAY NURSERY LTD","primaryAddress":{"addressCountry":{"isoAlpha2Code":"GB"},"streetAddress":{"line1":"Highfield"},"addressLocality":{"name":"BASINGSTOKE"},"postalCode":"RG21 5TG"},"corporateLinkage":{"isBranch":false},"financials":[{"yearlyRevenue":[{"value":1267474.0,"currency":"USD"}]}],"primaryIndustryCodes":[{"usSicV4":"8211","usSicV4Description":"Elementary/secondary school"}]}},{"displaySequence":2,"organization":{"duns":"692194709","dunsControlStatus":{"isOutOfBusiness":false},"primaryName":"ALPHABET CITY CO., LTD.","primaryAddress":{"addressCountry":{"isoAlpha2Code":"JP"},"streetAddress":{"line1":"1-3, SARUGAKUCHO"},"addressLocality":{"name":"SHIBUYA-KU"},"addressRegion":{"name":"TOKYO"},"postalCode":"150-0033"},"corporateLinkage":{"isBranch":false,"globalUltimate":{"duns":"692194709","primaryName":"ALPHABET CITY CO., LTD."}},"financials":[{"yearlyRevenue":[{"value":912800.0,"currency":"USD"}]}],"primaryIndustryCodes":[{"usSicV4":"5411","usSicV4Description":"Ret groceries"}]}},{"displaySequence":3,"organization":{"duns":"780015939","dunsControlStatus":{"isOutOfBusiness":false},"primaryName":"Alphabet City","primaryAddress":{"addressCountry":{"isoAlpha2Code":"US"},"streetAddress":{"line1":"2807 Oregon Ct Ste F1"},"addressLocality":{"name":"Torrance"},"addressRegion":{"name":"California"},"postalCode":"90503-2635"},"corporateLinkage":{"isBranch":false},"financials":[{"yearlyRevenue":[{"value":850000.0,"currency":"USD"}]}],"tradeStyleNames":[{"name":"ALPHABET CITY IMAGING CENTER","priority":1}],"primaryIndustryCodes":[{"usSicV4":"2759","usSicV4Description":"Commercial printing"}]}},{"displaySequence":4,"organization":{"duns":"720434554","dunsControlStatus":{"isOutOfBusiness":false},"primaryName":"ALPHABET CITY CORP.","primaryAddress":{"addressCountry":{"isoAlpha2Code":"PH"},"streetAddress":{"line1":"E Rodriguez Sr Avenue"},"addressLocality":{"name":"Manila"},"addressRegion":{"name":"Manila"}},"corporateLinkage":{"isBranch":false},"financials":[{"yearlyRevenue":[{"value":772408.0,"currency":"USD"}]}],"primaryIndustryCodes":[{"usSicV4":"7389","usSicV4Description":"Business services"}]}},{"displaySequence":5,"organization":{"duns":"019107860","dunsControlStatus":{"isOutOfBusiness":false},"primaryName":"East Village Wine Corp","primaryAddress":{"addressCountry":{"isoAlpha2Code":"US"},"streetAddress":{"line1":"100 Avenue C"},"addressLocality":{"name":"New York"},"addressRegion":{"name":"New York"},"postalCode":"10009-6902"},"corporateLinkage":{"isBranch":false},"financials":[{"yearlyRevenue":[{"value":592217.0,"currency":"USD"}]}],"tradeStyleNames":[{"name":"ALPHABET CITY WINE CO","priority":1}],"primaryIndustryCodes":[{"usSicV4":"5921","usSicV4Description":"Ret alcoholic beverages"}]}},{"displaySequence":6,"organization":{"duns":"505851840","dunsControlStatus":{"isOutOfBusiness":false},"primaryName":"ALPHABET CITY LIMITED","primaryAddress":{"addressCountry":{"isoAlpha2Code":"GB"},"streetAddress":{"line1":"49 West India Dock Road"},"addressLocality":{"name":"LONDON"},"postalCode":"E14 8HN"},"corporateLinkage":{"isBranch":false},"financials":[{"yearlyRevenue":[{"value":409629.0,"currency":"USD"}]}],"primaryIndustryCodes":[{"usSicV4":"6531","usSicV4Description":"Real estate agent/manager"}]}},{"displaySequence":7,"organization":{"duns":"690479110","dunsControlStatus":{"isOutOfBusiness":false},"primaryName":"Alphabet City English PROFESSIONAL Institute","primaryAddress":{"addressCountry":{"isoAlpha2Code":"KR"},"streetAddress":{"line1":"16-5 Jungang-ro 2-gil Yeongdong-eup"},"addressLocality":{"name":"Yeongdong"},"addressRegion":{"name":"Chungbuk"},"postalCode":"29145"},"corporateLinkage":{"isBranch":false},"financials":[{"yearlyRevenue":[{"value":373630.0,"currency":"USD"}]}],"primaryIndustryCodes":[{"usSicV4":"8299","usSicV4Description":"School/educational services"}]}},{"displaySequence":8,"organization":{"duns":"004093389","dunsControlStatus":{"isOutOfBusiness":false},"primaryName":"Alphabet City Childcare Service","primaryAddress":{"addressCountry":{"isoAlpha2Code":"US"},"streetAddress":{"line1":"702 Topsail Dr"},"addressLocality":{"name":"Browns Summit"},"addressRegion":{"name":"North Carolina"},"postalCode":"27214-9062"},"corporateLinkage":{"isBranch":false},"financials":[{"yearlyRevenue":[{"value":310000.0,"currency":"USD"}]}],"primaryIndustryCodes":[{"usSicV4":"8351","usSicV4Description":"Child day care services"}]}},{"displaySequence":9,"organization":{"duns":"784103330","dunsControlStatus":{"isOutOfBusiness":false},"primaryName":"Alphabet City Childcare S","primaryAddress":{"addressCountry":{"isoAlpha2Code":"US"},"streetAddress":{"line1":"2115 Fairbrother St"},"addressLocality":{"name":"Greensboro"},"addressRegion":{"name":"North Carolina"},"postalCode":"27405-6007"},"corporateLinkage":{"isBranch":false},"financials":[{"yearlyRevenue":[{"value":280000.0,"currency":"USD"}]}],"primaryIndustryCodes":[{"usSicV4":"8351","usSicV4Description":"Child day care services"}]}},{"displaySequence":10,"organization":{"duns":"043205109","dunsControlStatus":{"isOutOfBusiness":false},"primaryName":"Alphabet City Beer Co LLC","primaryAddress":{"addressCountry":{"isoAlpha2Code":"US"},"streetAddress":{"line1":"96 Avenue C Frnt 4"},"addressLocality":{"name":"New York"},"addressRegion":{"name":"New York"},"postalCode":"10009-7055"},"corporateLinkage":{"isBranch":false},"financials":[{"yearlyRevenue":[{"value":248740.0,"currency":"USD"}]}],"primaryIndustryCodes":[{"usSicV4":"8641","usSicV4Description":"Civic/social association"}]}}]}';


    /**
 * @purpose Retrieves records based on search keyword from specific object type
 *
 * @param searchKeyWord
 * @param ObjectName
 *
 * @return List of records matching the search keyword
 */
    @AuraEnabled
    public static List<AccountResults> fetchLookUpValues(String searchKeyWord, String token) {

//        List<RecordType> recordTypes = [SELECT Id FROM RecordType WHERE Name= 'Active Account' AND SobjectType= 'Account'];
        List<Account> accounts = searchForAccounts(searchKeyWord);
        System.debug('Accounts ==' + accounts);

        List<AccountResults> results = new List<AccountResults>();
        String searchString = searchKeyWord.replace(' ','%');

        If ( accounts.isEmpty() ) {
//            String testResponse = '{"transactionDetail":{"transactionID":"rrt-0cde86a015a8f3483-c-wo-31040-48052832-34","transactionTimestamp":"2021-01-19T20:58:54.872Z","inLanguage":"en-US","serviceVersion":"1"},"inquiryDetail":{"searchTerm":"Alphabet%City"},"candidatesReturnedQuantity":10,"candidatesMatchedQuantity":78,"searchCandidates":[{"displaySequence":1,"organization":{"duns":"219241986","dunsControlStatus":{"isOutOfBusiness":false},"primaryName":"ALPHABET CITY DAY NURSERY LTD","primaryAddress":{"addressCountry":{"isoAlpha2Code":"GB"},"streetAddress":{"line1":"Highfield"},"addressLocality":{"name":"BASINGSTOKE"},"postalCode":"RG21 5TG"},"corporateLinkage":{"isBranch":false},"financials":[{"yearlyRevenue":[{"value":1267474.0,"currency":"USD"}]}],"primaryIndustryCodes":[{"usSicV4":"8211","usSicV4Description":"Elementary/secondary school"}]}},{"displaySequence":2,"organization":{"duns":"692194709","dunsControlStatus":{"isOutOfBusiness":false},"primaryName":"ALPHABET CITY CO., LTD.","primaryAddress":{"addressCountry":{"isoAlpha2Code":"JP"},"streetAddress":{"line1":"1-3, SARUGAKUCHO"},"addressLocality":{"name":"SHIBUYA-KU"},"addressRegion":{"name":"TOKYO"},"postalCode":"150-0033"},"corporateLinkage":{"isBranch":false,"globalUltimate":{"duns":"692194709","primaryName":"ALPHABET CITY CO., LTD."}},"financials":[{"yearlyRevenue":[{"value":912800.0,"currency":"USD"}]}],"primaryIndustryCodes":[{"usSicV4":"5411","usSicV4Description":"Ret groceries"}]}},{"displaySequence":3,"organization":{"duns":"780015939","dunsControlStatus":{"isOutOfBusiness":false},"primaryName":"Alphabet City","primaryAddress":{"addressCountry":{"isoAlpha2Code":"US"},"streetAddress":{"line1":"2807 Oregon Ct Ste F1"},"addressLocality":{"name":"Torrance"},"addressRegion":{"name":"California"},"postalCode":"90503-2635"},"corporateLinkage":{"isBranch":false},"financials":[{"yearlyRevenue":[{"value":850000.0,"currency":"USD"}]}],"tradeStyleNames":[{"name":"ALPHABET CITY IMAGING CENTER","priority":1}],"primaryIndustryCodes":[{"usSicV4":"2759","usSicV4Description":"Commercial printing"}]}},{"displaySequence":4,"organization":{"duns":"720434554","dunsControlStatus":{"isOutOfBusiness":false},"primaryName":"ALPHABET CITY CORP.","primaryAddress":{"addressCountry":{"isoAlpha2Code":"PH"},"streetAddress":{"line1":"E Rodriguez Sr Avenue"},"addressLocality":{"name":"Manila"},"addressRegion":{"name":"Manila"}},"corporateLinkage":{"isBranch":false},"financials":[{"yearlyRevenue":[{"value":772408.0,"currency":"USD"}]}],"primaryIndustryCodes":[{"usSicV4":"7389","usSicV4Description":"Business services"}]}},{"displaySequence":5,"organization":{"duns":"019107860","dunsControlStatus":{"isOutOfBusiness":false},"primaryName":"East Village Wine Corp","primaryAddress":{"addressCountry":{"isoAlpha2Code":"US"},"streetAddress":{"line1":"100 Avenue C"},"addressLocality":{"name":"New York"},"addressRegion":{"name":"New York"},"postalCode":"10009-6902"},"corporateLinkage":{"isBranch":false},"financials":[{"yearlyRevenue":[{"value":592217.0,"currency":"USD"}]}],"tradeStyleNames":[{"name":"ALPHABET CITY WINE CO","priority":1}],"primaryIndustryCodes":[{"usSicV4":"5921","usSicV4Description":"Ret alcoholic beverages"}]}},{"displaySequence":6,"organization":{"duns":"505851840","dunsControlStatus":{"isOutOfBusiness":false},"primaryName":"ALPHABET CITY LIMITED","primaryAddress":{"addressCountry":{"isoAlpha2Code":"GB"},"streetAddress":{"line1":"49 West India Dock Road"},"addressLocality":{"name":"LONDON"},"postalCode":"E14 8HN"},"corporateLinkage":{"isBranch":false},"financials":[{"yearlyRevenue":[{"value":409629.0,"currency":"USD"}]}],"primaryIndustryCodes":[{"usSicV4":"6531","usSicV4Description":"Real estate agent/manager"}]}},{"displaySequence":7,"organization":{"duns":"690479110","dunsControlStatus":{"isOutOfBusiness":false},"primaryName":"Alphabet City English PROFESSIONAL Institute","primaryAddress":{"addressCountry":{"isoAlpha2Code":"KR"},"streetAddress":{"line1":"16-5 Jungang-ro 2-gil Yeongdong-eup"},"addressLocality":{"name":"Yeongdong"},"addressRegion":{"name":"Chungbuk"},"postalCode":"29145"},"corporateLinkage":{"isBranch":false},"financials":[{"yearlyRevenue":[{"value":373630.0,"currency":"USD"}]}],"primaryIndustryCodes":[{"usSicV4":"8299","usSicV4Description":"School/educational services"}]}},{"displaySequence":8,"organization":{"duns":"004093389","dunsControlStatus":{"isOutOfBusiness":false},"primaryName":"Alphabet City Childcare Service","primaryAddress":{"addressCountry":{"isoAlpha2Code":"US"},"streetAddress":{"line1":"702 Topsail Dr"},"addressLocality":{"name":"Browns Summit"},"addressRegion":{"name":"North Carolina"},"postalCode":"27214-9062"},"corporateLinkage":{"isBranch":false},"financials":[{"yearlyRevenue":[{"value":310000.0,"currency":"USD"}]}],"primaryIndustryCodes":[{"usSicV4":"8351","usSicV4Description":"Child day care services"}]}},{"displaySequence":9,"organization":{"duns":"784103330","dunsControlStatus":{"isOutOfBusiness":false},"primaryName":"Alphabet City Childcare S","primaryAddress":{"addressCountry":{"isoAlpha2Code":"US"},"streetAddress":{"line1":"2115 Fairbrother St"},"addressLocality":{"name":"Greensboro"},"addressRegion":{"name":"North Carolina"},"postalCode":"27405-6007"},"corporateLinkage":{"isBranch":false},"financials":[{"yearlyRevenue":[{"value":280000.0,"currency":"USD"}]}],"primaryIndustryCodes":[{"usSicV4":"8351","usSicV4Description":"Child day care services"}]}},{"displaySequence":10,"organization":{"duns":"043205109","dunsControlStatus":{"isOutOfBusiness":false},"primaryName":"Alphabet City Beer Co LLC","primaryAddress":{"addressCountry":{"isoAlpha2Code":"US"},"streetAddress":{"line1":"96 Avenue C Frnt 4"},"addressLocality":{"name":"New York"},"addressRegion":{"name":"New York"},"postalCode":"10009-7055"},"corporateLinkage":{"isBranch":false},"financials":[{"yearlyRevenue":[{"value":248740.0,"currency":"USD"}]}],"primaryIndustryCodes":[{"usSicV4":"8641","usSicV4Description":"Civic/social association"}]}}]}';
            String dbResults = Test.isRunningTest() ? testResponse : typeAheadSearch(searchString, token) ;
            if ( dbResults != null ) {
                DunJSON2Apex response = DunJSON2Apex.parse(dbResults);
                System.debug('SearchCandidates:::' + response.searchCandidates);

                if ( response.searchCandidates != null ) {
                    results.clear();
                    Integer i = 0;
                    Integer listsize = response.searchCandidates.size() > 5 ? 5 : response.searchCandidates.size();
                    while (i < listsize) {
                        AccountResults ar = new AccountResults(response.searchCandidates[i].organization.duns, response.searchCandidates[i].organization.primaryName, false);
                        results.add(ar);
                        i++;
                    }

                } else {
                    results.clear();
                    AccountResults ar = getSuggestedCompany(searchString, token);
                    results.add(ar);
                }
            }
        }else {
            for (Account a : accounts) {
//                System.debug('account item= ' + a.get('Name').toString());
                AccountResults ar = new AccountResults(a.Id, a.get('Name').toString(), false);
                results.add(ar);
            }
        }

        System.debug('results' + results);
        return results;
    }

    @AuraEnabled
    public static List<Account> searchForAccounts(String searchText) {
        System.debug('searchForAccount searchText = ' + searchText);

        List<RecordType> recordTypes = [SELECT Id FROM RecordType WHERE Name= 'Active Account' AND SobjectType= 'Account'];
        List<List<SObject>> results = [FIND :searchText IN NAME FIELDS
                RETURNING Account(Id,Name WHERE RecordTypeId =: recordTypes[0].Id AND (NOT Name LIKE '%Household') AND ( NOT Name LIKE '%AACR%') AND ( NOT Name LIKE '%(Individual)'))
                LIMIT 5];

        List<Account> accResults = new List<Account>();
        for (Account a : (Account[])results[0]) {
                Account acc = new Account();
                acc.Id = a.Id;
                acc.Name = a.Name;
                accResults.add(acc);
        }
        System.debug('Accounts SOSL::: ' + accResults);
        return accResults;
    }

    @AuraEnabled
    public static AccountResults getSuggestedCompany(String searchKeyWord, String token) {
        DunJSON2Apex response = new DunJSON2Apex();

        if ( Test.isRunningTest() ) {
            response.searchCandidates = null;
        } else {
            response = DunJSON2Apex.parse(typeAheadSearch(searchKeyWord, token));
        }

        while (response.searchCandidates == null) {
            searchKeyWord = searchKeyWord.left(searchKeyWord.length() - 1);
            System.debug('searchKeyword = ' + searchKeyWord);
            String dbResults = Test.isRunningTest() ? testResponse : typeAheadSearch(searchKeyWord, token) ;
            response = DunJSON2Apex.parse(dbResults);

        }

        System.debug('suggestedCandidates = ' + response.searchCandidates[0].organization.primaryName);

        return new AccountResults(response.searchCandidates[0].organization.duns, response.searchCandidates[0].organization.primaryName, true);
    }

    @AuraEnabled
    public static AccountResults getAccountInfo(String contactId){
        Account a = [SELECT Id, Name FROM Account WHERE Id IN (SELECT AccountId FROM Contact WHERE Id =: contactId)];
        return new AccountResults(a.Id, a.get('Name').toString(), false);

    }

//    @AuraEnabled
//    public static AccountResults getTestAccount() {
//        Account a = [SELECT Name, Id FROM Account WHERE Name = 'AACR Test Accounts'];
//
//       return new AccountResults(a.Id, a.get('Name').toString(), false);
//    }

    @AuraEnabled
    public static AccountResults createPersonAccount(String contactId) {

        Contact con = [SELECT Id, FirstName,LastName, Email FROM Contact WHERE Id=: contactId];
        Account acc = ECRMUtils.createOrFindIndividualAccount(con.FirstName, con.LastName,con.Email, contactId);

        return new AccountResults(acc.Id, acc.Name, false);

//        List<Account> acc = [SELECT Id, Name FROM Account WHERE OrderApi__Primary_Contact__c =: contactId LIMIT 1];

//        If(acc.isEmpty()) {
//            List<RecordType> recordTypes = [SELECT Id FROM RecordType WHERE Name = 'Active Account' AND SobjectType = 'Account' AND IsActive = TRUE];
//            Account newAcc = new Account();
//            newAcc.Name = recordName;
//            newAcc.RecordTypeId = recordTypes[0].Id;
//            newAcc.Institution_Type__c = 'Individual';
//            List<siteSettings__c> siteSetting = [SELECT ownerId__c FROM siteSettings__c LIMIT 1];
//            if ( siteSetting.size() == 1 ) {
//                newAcc.OwnerId = siteSetting[0].ownerId__c;
//            }
//            try {
//                insert newAcc;
//                System.debug('Person Account Id = ' + newAcc.Id);
//
//                return new AccountResults(newAcc.Id, newAcc.Name, false);
//            } catch (Exception e) {
//                System.debug('Could not create Person Account:: ' + e.getMessage());
//                return null;
//            }
//        }else{
//            return new AccountResults(acc[0].Id, acc[0].Name, false);
//        }

    }

    @AuraEnabled
    public static AccountResults createNewAccount(String accountName, String duns){
        List<Account> checkAcc = [SELECT Id, Name FROM Account WHERE DNBoptimizer__DNB_D_U_N_S_Number__c =: duns];
        If(checkAcc.isEmpty()) {
            List<RecordType> recordTypes = [SELECT Id FROM RecordType WHERE Name = 'Active Account' AND SobjectType = 'Account'];
            Account acc = new Account();
            acc.RecordTypeId = recordTypes[0].Id;
            acc.Name = accountName;
            acc.DNBoptimizer__DNB_D_U_N_S_Number__c = duns;
          //  acc.LD_USE_DnB_Optimize__c = true;
            List<siteSettings__c> siteSetting = [SELECT ownerId__c FROM siteSettings__c LIMIT 1];
            if ( siteSetting.size() == 1 ) {
                acc.OwnerId = siteSetting[0].ownerId__c;
            }
            try {
                insert acc;
                return new AccountResults(acc.Id, acc.Name, false);
            } catch (Exception e) {
                System.debug('Could not create account: ' + e.getMessage());
                return null;
            }
        }else{
            return new AccountResults(checkAcc[0].Id, checkAcc[0].Name, false);
        }
    }

    /**
     * @purpose Gets specific record based on object type and recordId
     *
     * @param ObjectName
     * @param recordId
     *
     * @return specified record or null
     */
//    @AuraEnabled
//    public static sObject getInitialValue(String ObjectName, String recordId) {
//        String sQuery = 'select id, Name from ' + ObjectName + ' where Id =\'' + recordId + '\'';
//        List < sObject > lstOfRecords = Database.query(sQuery);
//        if ( lstOfRecords.size() == 1 ) {
//            return lstOfRecords[0];
//        }
//        return null;
//    }

    public static String typeAheadSearch(String searchTerm, String token) {

        HttpRequest reqAuth = new HttpRequest();
        reqAuth.setEndpoint(db.Endpoint__c + '/v1/search/typeahead?searchTerm=' + searchTerm.replace(' ', '%20'));
        reqAuth.setMethod('GET');
        reqAuth.setHeader('Content-Type', 'application/json');
        reqAuth.setHeader('Authorization', 'Bearer ' + token);

        try {
            Http http = new Http();
            HTTPResponse res = http.send(reqAuth);
            System.debug('response::::' + res.getBody());
            System.debug('Status = ' + res.getStatus());

            return res.getBody();
//            if ( res.getStatus() == 'OK' ) {
//                return res.getBody();
//            } else {
//                return null;
//            }
        }catch (Exception e){
            System.debug('Could not complete D&B callout: ' + e.getMessage());
            return null;
        }

    }

    @AuraEnabled
    public static String dunAuthentication() {
        HttpRequest reqAuth = new HttpRequest();
        reqAuth.setEndpoint(db.Endpoint__c + '/v2/token');
        reqAuth.setMethod('POST');
        reqAuth.setHeader('Content-Type', 'application/json');
        reqAuth.setHeader('Authorization', 'Basic ' + EncodingUtil.base64Encode(Blob.valueOf(db.Key__c + ':' + db.Secret__c)));
        reqAuth.setBody('{"grant_type" : "client_credentials"}');

        Http http = new Http();
        HTTPResponse res = http.send(reqAuth);
        System.debug(res.getBody());

        Map<String, Object> response = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());

        String tokenId = response.get('access_token').toString();

        System.debug('tokenId = ' + tokenId);

        dunToken = tokenId;
        return tokenId;
    }

    @AuraEnabled
    public static String updateContact(String accountId, String contactId){
        System.debug('accountId =' + accountId + '::: and contactId = ' + contactId);
        Contact con = new Contact();
        con.Id = contactId;
        con.AccountId = accountId;

        try{
            update con;
        }catch(Exception e){
            System.debug('Could not update contact: ' + e.getMessage());
        }

        return con.AccountId;
    }

    @AuraEnabled
    public static String getContactAccount(String accountId){
        return [SELECT Name FROM Account WHERE Id=: accountId].Name;
    }

    public class AccountResults {
        @AuraEnabled
        public String accountId;
        @AuraEnabled
        public String accountName;
        @AuraEnabled
        public Boolean isSuggested;

        public AccountResults(String companyId, String companyName, Boolean suggested) {
            accountId = companyId;
            accountName = companyName;
            isSuggested = suggested;
        }
    }
}