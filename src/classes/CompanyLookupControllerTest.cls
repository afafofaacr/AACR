/**
 * Created by afaf.awad on 1/19/2021.
 */
@IsTest
private class CompanyLookupControllerTest {

    @TestSetup
    public static void setup(){
        Account acc = TestDataFactory.buildAccount('Test Account');
        insert acc;

        Contact con = TestDataFactory.buildContact(acc.Id);
        insert con;

        insert new siteSettings__c(ownerId__c='0051I000000a2kkQAA');


    }

    @IsTest
    public static void test_dunAuthentication() {


//        SingleRequestMock fakeResponse = new SingleRequestMock(200,
//                'Complete',
//                '{\n' +
//                        '    "access_token": "1O38U1e61j50udqzb47O5mg258i6",\n' +
//                        '    "expiresIn": 86400\n' +
//                        '}',
//                null);
//
//        Map<String, HttpCalloutMock> endpoint2TestResp = new Map<String, HttpCalloutMock>();
//        endpoint2TestResp.put('https://plus.dnb.com/v2/token', fakeResponse);

//        HttpCalloutMock mockPlatformService = new MockHttpResponseGenerator(endpoint2TestResp);


        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new CreateMockHTTPResponseGenerator());

        String result =  CompanyLookupController.dunAuthentication();
        System.assertNotEquals(null, result);
        System.debug(result);

       Test.stopTest();
    }

    @IsTest
    public static void test_typeAheadSearch() {
        String token = '1O38U1e61j50udqzb47O5mg258i6';

        Test.startTest();

        SingleRequestMock fakeResponse = new SingleRequestMock(200,
                'Complete',
                '{"transactionDetail":{"transactionID":"rrt-0cde86a015a8f3483-c-wo-31040-48052832-34","transactionTimestamp":"2021-01-19T20:58:54.872Z","inLanguage":"en-US","serviceVersion":"1"},"inquiryDetail":{"searchTerm":"Alphabet%City"},"candidatesReturnedQuantity":10,"candidatesMatchedQuantity":78,"searchCandidates":[{"displaySequence":1,"organization":{"duns":"219241986","dunsControlStatus":{"isOutOfBusiness":false},"primaryName":"ALPHABET CITY DAY NURSERY LTD","primaryAddress":{"addressCountry":{"isoAlpha2Code":"GB"},"streetAddress":{"line1":"Highfield"},"addressLocality":{"name":"BASINGSTOKE"},"postalCode":"RG21 5TG"},"corporateLinkage":{"isBranch":false},"financials":[{"yearlyRevenue":[{"value":1267474.0,"currency":"USD"}]}],"primaryIndustryCodes":[{"usSicV4":"8211","usSicV4Description":"Elementary/secondary school"}]}},{"displaySequence":2,"organization":{"duns":"692194709","dunsControlStatus":{"isOutOfBusiness":false},"primaryName":"ALPHABET CITY CO., LTD.","primaryAddress":{"addressCountry":{"isoAlpha2Code":"JP"},"streetAddress":{"line1":"1-3, SARUGAKUCHO"},"addressLocality":{"name":"SHIBUYA-KU"},"addressRegion":{"name":"TOKYO"},"postalCode":"150-0033"},"corporateLinkage":{"isBranch":false,"globalUltimate":{"duns":"692194709","primaryName":"ALPHABET CITY CO., LTD."}},"financials":[{"yearlyRevenue":[{"value":912800.0,"currency":"USD"}]}],"primaryIndustryCodes":[{"usSicV4":"5411","usSicV4Description":"Ret groceries"}]}},{"displaySequence":3,"organization":{"duns":"780015939","dunsControlStatus":{"isOutOfBusiness":false},"primaryName":"Alphabet City","primaryAddress":{"addressCountry":{"isoAlpha2Code":"US"},"streetAddress":{"line1":"2807 Oregon Ct Ste F1"},"addressLocality":{"name":"Torrance"},"addressRegion":{"name":"California"},"postalCode":"90503-2635"},"corporateLinkage":{"isBranch":false},"financials":[{"yearlyRevenue":[{"value":850000.0,"currency":"USD"}]}],"tradeStyleNames":[{"name":"ALPHABET CITY IMAGING CENTER","priority":1}],"primaryIndustryCodes":[{"usSicV4":"2759","usSicV4Description":"Commercial printing"}]}},{"displaySequence":4,"organization":{"duns":"720434554","dunsControlStatus":{"isOutOfBusiness":false},"primaryName":"ALPHABET CITY CORP.","primaryAddress":{"addressCountry":{"isoAlpha2Code":"PH"},"streetAddress":{"line1":"E Rodriguez Sr Avenue"},"addressLocality":{"name":"Manila"},"addressRegion":{"name":"Manila"}},"corporateLinkage":{"isBranch":false},"financials":[{"yearlyRevenue":[{"value":772408.0,"currency":"USD"}]}],"primaryIndustryCodes":[{"usSicV4":"7389","usSicV4Description":"Business services"}]}},{"displaySequence":5,"organization":{"duns":"019107860","dunsControlStatus":{"isOutOfBusiness":false},"primaryName":"East Village Wine Corp","primaryAddress":{"addressCountry":{"isoAlpha2Code":"US"},"streetAddress":{"line1":"100 Avenue C"},"addressLocality":{"name":"New York"},"addressRegion":{"name":"New York"},"postalCode":"10009-6902"},"corporateLinkage":{"isBranch":false},"financials":[{"yearlyRevenue":[{"value":592217.0,"currency":"USD"}]}],"tradeStyleNames":[{"name":"ALPHABET CITY WINE CO","priority":1}],"primaryIndustryCodes":[{"usSicV4":"5921","usSicV4Description":"Ret alcoholic beverages"}]}},{"displaySequence":6,"organization":{"duns":"505851840","dunsControlStatus":{"isOutOfBusiness":false},"primaryName":"ALPHABET CITY LIMITED","primaryAddress":{"addressCountry":{"isoAlpha2Code":"GB"},"streetAddress":{"line1":"49 West India Dock Road"},"addressLocality":{"name":"LONDON"},"postalCode":"E14 8HN"},"corporateLinkage":{"isBranch":false},"financials":[{"yearlyRevenue":[{"value":409629.0,"currency":"USD"}]}],"primaryIndustryCodes":[{"usSicV4":"6531","usSicV4Description":"Real estate agent/manager"}]}},{"displaySequence":7,"organization":{"duns":"690479110","dunsControlStatus":{"isOutOfBusiness":false},"primaryName":"Alphabet City English PROFESSIONAL Institute","primaryAddress":{"addressCountry":{"isoAlpha2Code":"KR"},"streetAddress":{"line1":"16-5 Jungang-ro 2-gil Yeongdong-eup"},"addressLocality":{"name":"Yeongdong"},"addressRegion":{"name":"Chungbuk"},"postalCode":"29145"},"corporateLinkage":{"isBranch":false},"financials":[{"yearlyRevenue":[{"value":373630.0,"currency":"USD"}]}],"primaryIndustryCodes":[{"usSicV4":"8299","usSicV4Description":"School/educational services"}]}},{"displaySequence":8,"organization":{"duns":"004093389","dunsControlStatus":{"isOutOfBusiness":false},"primaryName":"Alphabet City Childcare Service","primaryAddress":{"addressCountry":{"isoAlpha2Code":"US"},"streetAddress":{"line1":"702 Topsail Dr"},"addressLocality":{"name":"Browns Summit"},"addressRegion":{"name":"North Carolina"},"postalCode":"27214-9062"},"corporateLinkage":{"isBranch":false},"financials":[{"yearlyRevenue":[{"value":310000.0,"currency":"USD"}]}],"primaryIndustryCodes":[{"usSicV4":"8351","usSicV4Description":"Child day care services"}]}},{"displaySequence":9,"organization":{"duns":"784103330","dunsControlStatus":{"isOutOfBusiness":false},"primaryName":"Alphabet City Childcare S","primaryAddress":{"addressCountry":{"isoAlpha2Code":"US"},"streetAddress":{"line1":"2115 Fairbrother St"},"addressLocality":{"name":"Greensboro"},"addressRegion":{"name":"North Carolina"},"postalCode":"27405-6007"},"corporateLinkage":{"isBranch":false},"financials":[{"yearlyRevenue":[{"value":280000.0,"currency":"USD"}]}],"primaryIndustryCodes":[{"usSicV4":"8351","usSicV4Description":"Child day care services"}]}},{"displaySequence":10,"organization":{"duns":"043205109","dunsControlStatus":{"isOutOfBusiness":false},"primaryName":"Alphabet City Beer Co LLC","primaryAddress":{"addressCountry":{"isoAlpha2Code":"US"},"streetAddress":{"line1":"96 Avenue C Frnt 4"},"addressLocality":{"name":"New York"},"addressRegion":{"name":"New York"},"postalCode":"10009-7055"},"corporateLinkage":{"isBranch":false},"financials":[{"yearlyRevenue":[{"value":248740.0,"currency":"USD"}]}],"primaryIndustryCodes":[{"usSicV4":"8641","usSicV4Description":"Civic/social association"}]}}]}',
                null);

        Map<String, HttpCalloutMock> endpoint2TestResp = new Map<String, HttpCalloutMock>();
        endpoint2TestResp.put('https://plus.dnb.com/v1/search/typeahead?searchTerm=Alphabet', fakeResponse);

        HttpCalloutMock mockPlatformService = new MockHttpResponseGenerator(endpoint2TestResp);

        Test.setMock(HttpCalloutMock.class, mockPlatformService);

        String returnBody = CompanyLookupController.typeAheadSearch('Alphabet', token);

        Test.stopTest();
    }

    @IsTest
    public static void test_getAccountInfo() {

        Account acc = [SELECT Id FROM Account WHERE Name='Test Account'];

        Contact con = [SELECT Id FROM Contact WHERE AccountId=:acc.Id];

        Test.startTest();

        CompanyLookupController.AccountResults accountResults = CompanyLookupController.getAccountInfo(con.Id);

        System.assertEquals(acc.Id, accountResults.accountId);

        Test.stopTest();
    }

    @IsTest
    public static void test_createPersonAccount() {
        Account acc = [SELECT Id FROM Account WHERE Name='Test Account'];

        Contact con = [SELECT Id, FirstName, LastName FROM Contact WHERE AccountId=:acc.Id];

        Test.startTest();

        CompanyLookupController.AccountResults accountResults = CompanyLookupController.createPersonAccount(con.Id);

        System.assertEquals(con.FirstName +' ' + con.LastName + ' (Individual)', accountResults.accountName);

        Test.stopTest();
    }

    @IsTest
    public static void test_createNewAccount() {

        Account acc = [SELECT Id FROM Account WHERE Name='Test Account'];

        Contact con = [SELECT Id FROM Contact WHERE AccountId=:acc.Id];

        Test.startTest();

        //First run to create new Account
        CompanyLookupController.AccountResults accountResults = CompanyLookupController.createNewAccount('New Test Account', '123456');
        Account newAcc = [SELECT Id, Name FROM Account WHERE DNBoptimizer__DNB_D_U_N_S_Number__c = '123456'];
        System.assertEquals(accountResults.accountName, newAcc.Name);

        //Second run to return existing Account
        accountResults = CompanyLookupController.createNewAccount('New Test Account', '123456');
        newAcc = [SELECT Id, Name FROM Account WHERE DNBoptimizer__DNB_D_U_N_S_Number__c = '123456'];
        System.assertEquals(accountResults.accountName, newAcc.Name);

        //Update Contact after creation of new account
        String conAccountId = CompanyLookupController.updateContact(newAcc.Id, con.Id);
        System.assertEquals(conAccountId, newAcc.Id);

        Test.stopTest();
    }

    @IsTest
    public static void test_fetchLookUpValues(){

        Test.startTest();

        String token = '1O38U1e61j50udqzb47O5mg258i6';

        System.debug('test token = ' + token);

       List<CompanyLookupController.AccountResults> accountResults = CompanyLookupController.fetchLookUpValues('Test Account', token);

        RecordType recordType = [SELECT Id FROM RecordType WHERE Name= 'Active Account' AND SobjectType= 'Account' LIMIT 1];
        Account acc = LiveTestDataFactory.buildAccount('Test Account');
        acc.RecordTypeId = recordType.Id;
        insert acc;

        Id[] fixedSearchResults= new Id[1];
        fixedSearchResults[0] = acc.Id;
        Test.setFixedSearchResults(fixedSearchResults);

        List<CompanyLookupController.AccountResults> accountResults2 = CompanyLookupController.fetchLookUpValues('Test', token);

        Test.stopTest();
    }

    @IsTest
    public static void test_getSuggestedCompany(){

        Test.startTest();

        String token = '1O38U1e61j50udqzb47O5mg258i6';

        CompanyLookupController.AccountResults accountResults = CompanyLookupController.getSuggestedCompany('Alphabet City', token);

        Test.stopTest();

    }

    public class CreateMockHTTPResponseGenerator implements HttpCalloutMock{
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"access_token": "1O38U1e61j50udqzb47O5mg258i6"}');
            res.setStatusCode(201);
            return res;
        }
    }


}