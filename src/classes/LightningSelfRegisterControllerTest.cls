@IsTest(SeeAllData = true)
public with sharing class LightningSelfRegisterControllerTest {

 /* Verifies that IsValidPassword method with various password combinations. */
 @IsTest
 static void testIsValidPassword() {
  System.assert(LightningSelfRegisterController.isValidPassword('password?@12334', 'password?@12334') == true);
  System.assert(LightningSelfRegisterController.isValidPassword('password?@12334', 'dummyPassword') == false);
  System.assert(LightningSelfRegisterController.isValidPassword('password?@12334', null) == false);
  System.assert(LightningSelfRegisterController.isValidPassword(null, 'fakePwd') == false);
 }

 /* Verifies the default value of siteAsContainerEnabled method. */
// @IsTest
// static void testSiteAsContainerEnabled() {
//  String networkId = Network.getNetworkId();
//
//  System.assertNotEquals( null, LightningSelfRegisterController.siteAsContainerEnabled(networkId));
//
// }

//    @isTest
//    static void testValidatePassword(){
//        Account a = TestDataFactory.buildAccount('Test Account');
//        insert a;
//        Contact c = TestDataFactory.buildContact(a.Id);
//        insert c;
//        User u = TestDataFactory.buildUser(c.Id);
//        insert u;
//
//        LightningSelfRegisterController.validatePassword(u, 'password?@1234', 'password?@1234');
//    }

     /* Verifies the selfRegistration method flow with various invalid inputs */
     @IsTest
     static void testSelfRegistrationLastNameRequired() {

         Test.startTest();
         Test.setMock(HttpCalloutMock.class, new SuccessMockHttpResponseGenerator());
         Map < String, String > paramsMap = initializeParams();
         System.assertNotEquals(null, paramsMap);
         System.assertEquals(Label.Site.lastname_is_required, LightningSelfRegisterController.selfRegister(paramsMap.get('firstName'), '', paramsMap.get('email'), paramsMap.get('password'), paramsMap.get('confirmPasswordCorrect'), null, paramsMap.get('regConfirmUrl'), null, paramsMap.get('startUrl'), true));
        Test.stopTest();
     }

    @IsTest
    static void testSelfRegistrationEmailRequired1() {

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new SuccessMockHttpResponseGenerator());
        Map < String, String > paramsMap = initializeParams();
        System.assertNotEquals(null, paramsMap);
         System.assertEquals(Label.Site.email_is_required, LightningSelfRegisterController.selfRegister(paramsMap.get('firstName'), paramsMap.get('lastName'), '', paramsMap.get('password'), paramsMap.get('confirmPasswordCorrect'), null, paramsMap.get('regConfirmUrl'), null, paramsMap.get('startUrl'), true));
        Test.stopTest();
    }

    @IsTest
    static void testSelfRegistrationEmailRequired2() {

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new SuccessMockHttpResponseGenerator());
        Map < String, String > paramsMap = initializeParams();
        System.assertNotEquals(null, paramsMap);
         System.assertEquals(Label.Site.email_is_required, LightningSelfRegisterController.selfRegister(null, paramsMap.get('lastName'), '', null, paramsMap.get('confirmPasswordCorrect'), null, paramsMap.get('regConfirmUrl'), null, paramsMap.get('startUrl'), true));
        Test.stopTest();
    }

    @IsTest
    static void testSelfRegistrationPasswordMismatch() {

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new SuccessMockHttpResponseGenerator());
        Map < String, String > paramsMap = initializeParams();
        System.assertNotEquals(null, paramsMap);
         System.assertEquals(Label.site.passwords_dont_match, LightningSelfRegisterController.selfRegister(paramsMap.get('firstName'), paramsMap.get('lastName'), paramsMap.get('email'), paramsMap.get('password'), paramsMap.get('confirmPasswordWrong'), null, paramsMap.get('regConfirmUrl'), null, paramsMap.get('startUrl'), true));
        Test.stopTest();
    }

    @IsTest
    static void testSelfRegistrationSuccess() {

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new SuccessMockHttpResponseGenerator());
        Map < String, String > paramsMap = initializeParams();
        System.assertNotEquals(null, paramsMap);
         System.assertNotEquals(null, LightningSelfRegisterController.selfRegister(paramsMap.get('firstName'), paramsMap.get('lastName'), '', paramsMap.get('password'), paramsMap.get('confirmPasswordCorrect'), null, paramsMap.get('regConfirmUrl'), null, paramsMap.get('startUrl'), false));
        Test.stopTest();
    }


    @IsTest
    static void testSelfRegistrationDupeContacts() {
        Account acc = TestDataFactory.buildAccount('Test Account');
        insert acc;

        Contact con = TestDataFactory.buildContact(acc.Id);
        con.Email = 'testUser@salesforce.com';
        insert con;

        Contact con2 = TestDataFactory.buildContact(acc.Id);
        con2.Email = 'testUser@salesforce.com';
        insert con2;

        List<Contact> contacts = [SELECT id FROM Contact WHERE Email='testUser@salesforce.com'];
        System.assertEquals(2, contacts.size());

        User u = TestDataFactory.buildUser(con.Id);
        insert u;

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new SuccessMockHttpResponseGenerator());
        System.runAs(u) {
            Map < String, String > paramsMap = initializeParams();
            System.assertNotEquals(null, paramsMap);
            System.assertNotEquals(null, LightningSelfRegisterController.selfRegister(paramsMap.get('firstName'), paramsMap.get('lastName'), paramsMap.get('email'), paramsMap.get('password'), paramsMap.get('confirmPasswordCorrect'), null, paramsMap.get('regConfirmUrl'), null, paramsMap.get('startUrl'), false));
        }
        Test.stopTest();
    }


    /* Verifies the selfRegistration flow for valid inputs */
     @IsTest
     static void testSelfRegisterWithProperCredentials() {
         Test.setMock(HttpCalloutMock.class, new SuccessMockHttpResponseGenerator());
         Map < String, String > paramsMap = initializeParams();
//         Account a = TestDataFactory.buildAccount('Test Account');
//         insert a;
//         Contact c = TestDataFactory.buildContact(a.Id);
//         insert c;
//         User u = TestDataFactory.buildUser(c.Id);
//         insert u;
         System.assertEquals(null, LightningSelfRegisterController.selfRegister(paramsMap.get('firstName'), paramsMap.get('lastName'), paramsMap.get('email'), paramsMap.get('password'), paramsMap.get('confirmPasswordCorrect'), null, paramsMap.get('regConfirmUrl'), null, paramsMap.get('startUrl'), true));
     }

    
 /* Verifies SelfRegistration flow with an accounId that is created within the test */
 @IsTest
 static void testSelfRegisterWithCreatedAccount() {
//     Account acc = new Account(name = 'test acc');
//     insert acc;


     Test.setMock(HttpCalloutMock.class, new SuccessMockHttpResponseGenerator());

//     List < Account > accounts = [SELECT Id FROM Account LIMIT 1];
//
//     System.assert(!accounts.isEmpty(), 'There must be at least one account in this environment!');
//     String accountId = accounts[0].Id;
     Map < String, String > paramsMap = initializeParams();
     String resp = LightningSelfRegisterController.selfRegister(paramsMap.get('firstName'), paramsMap.get('lastName'), paramsMap.get('email'), paramsMap.get('password'), paramsMap.get('confirmPasswordCorrect'), null, paramsMap.get('regConfirmUrl'), null, paramsMap.get('startUrl'), false);
     System.assertEquals(null, resp);

//     COntact con = new Contact();
//     con.AccountId = acc.Id;
//     con.FirstName = paramsMap.get('firstName');
//     con.LastName = paramsMap.get('lastName');
//     con.Email = paramsMap.get('email');
//     insert con;
//
//     resp = LightningSelfRegisterController.selfRegister(paramsMap.get('firstName'), paramsMap.get('lastName'), paramsMap.get('email'), paramsMap.get('password'), paramsMap.get('confirmPasswordCorrect'), accountId, paramsMap.get('regConfirmUrl'), null, paramsMap.get('startUrl'), false);
//     System.assertNotEquals(null, resp);

 }

    
 /* Verifies SelfRegistration flow with an accounId that is created within the test without a last name  */
 /*@IsTest
 static void testSelfRegisterWithCreatedAccountNoPassword() {
  Account acc = new Account(name = 'test acc');
  insert acc;
  List < Account > accounts = [SELECT Id FROM Account LIMIT 1];
  System.assert(!accounts.isEmpty(), 'There must be at least one account in this environment!');
  String accountId = accounts[0].Id;
  Map < String, String > paramsMap = initializeParams();
  System.assertEquals(null, LightningSelfRegisterController.selfRegister(paramsMap.get('firstName'), paramsMap.get('lastName'), paramsMap.get('email'), '', '', accountId, paramsMap.get('regConfirmUrl'), null, paramsMap.get('startUrl'), false));
 }*/

// @IsTest
//  static void testGetNullExtraFields() {
//  System.assertEquals(new List < Map < String, Object >> (), LightningSelfRegisterController.getExtraFields(null));
// }
//
// @IsTest
// static void testGetNonEmptyExtraFields() {
//  System.assertEquals(new List < Map < String, Object >> (), LightningSelfRegisterController.getExtraFields('field1'));
// }
//
// /* Verifies validation of extraFields within the Self Registration flow */
// @IsTest
// static void testGetExtraFieldsInSelfRegistration() {
//  List < Map < String, Object >> fieldlist = new List < Map < String, Object >> ();
//  Map < String, String > paramsMap = initializeParams();
//  Map < String, Object > fieldMap = new Map < String, Object > ();
//  fieldMap.put('description', 'new field');
//  fieldMap.put('fieldPath', 'dummyPath');
//  fieldlist.add(fieldMap);
//  String extraFields = JSON.serialize(fieldlist);
//  System.assertNotEquals(null, LightningSelfRegisterController.selfRegister(paramsMap.get('firstName'), paramsMap.get('lastName'), paramsMap.get('email'), paramsMap.get('password'), paramsMap.get('confirmPasswordCorrect'), null, paramsMap.get('regConfirmUrl'), extraFields, paramsMap.get('startUrl'), true));
// }

 @IsTest
 static void LightningSelfRegisterControllerInstantiation() {
  LightningSelfRegisterController controller = new LightningSelfRegisterController();
  System.assertNotEquals(controller, null);
 }

 /* Helper method to initialize the parameters required for SelfRegistration. */
 private static Map < String, String > initializeParams() {
  Map < String, String > paramsMap = new Map < String, String > ();
  String firstName = 'test';
  String lastName = 'User';
  String email = 'testUser@salesforce.com';
  String password = 'testuser@123';
  String confirmPasswordCorrect = 'testuser@123';
  String confirmPasswordWrong = 'wrongpassword';
  String accountId = 'testuser123';
  String regConfirmUrl = 'http://registration-confirm.com';
  String startUrl = 'http://my.company.salesforce.com';
  paramsMap.put('firstName', firstName);
  paramsMap.put('lastName', lastName);
  paramsMap.put('email', email);
  paramsMap.put('password', password);
  paramsMap.put('confirmPasswordCorrect', confirmPasswordCorrect);
  paramsMap.put('confirmPasswordWrong', confirmPasswordWrong);
  paramsMap.put('accountId', accountId);
  paramsMap.put('regConfirmUrl', regConfirmUrl);
  paramsMap.put('startUrl', startUrl);
  return paramsMap;
 }


    public class SuccessMockHTTPResponseGenerator implements HttpCalloutMock{
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/x-www-form-urlencoded');
            res.setBody('{"email" : {"status": "valid"}}');
            res.setStatusCode(200);
            return res;
        }
    }


    public class FailureMockHTTPResponseGenerator implements HttpCalloutMock{
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/x-www-form-urlencoded');
            res.setBody('{"email" : {"status": "invalid"}}');
            res.setStatusCode(402);
            return res;
        }
    }
}