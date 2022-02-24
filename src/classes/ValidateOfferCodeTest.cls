/**
 * @author          :  CRM Science, Inc.
 * @date            :  10/7/2020
 * @description     :  This class tests the methods in the ValidateOfferCode class
 */
@isTest
private without sharing class ValidateOfferCodeTest {

    public static String AccountName = 'Test Account';
    public static String SourceCodeName = 'BOGO';
    public static String OfferVersionName = SourceCodeName + ' ' + System.today().month() + System.today().year() + '.' + (Math.random() * 10000);
    public static String OVSOQLString = 'SELECT Id, ContactId FROM User WHERE IsActive = true AND ContactId IN (SELECT Id FROM Contact WHERE Member_Type__c=\'Active Member\' AND Membership_Status__c=\'Current\') LIMIT 10';
    public static String OfferMembersipName = OfferVersionName + '.' + (Math.random() * 10000);

    /**
     * @description     :  @testSetup method that inserts the necessary testing data
     */
    @testSetup
    private static void setup(){


        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        User sa = TestDataFactory.buildTestUser(p.Id, 'admin', 'user');
        insert sa;

        OrderApi__GL_Account__c glAcct = TestDataFactory.buildGLAccount();
        insert glAcct;

        Account a = TestDataFactory.buildAccount(AccountName);
        insert a;

        Contact c = TestDataFactory.buildContact(a.Id);
        insert c;

        User u = TestDataFactory.buildUser(c.Id);
        insert u;

        OrderApi__Source_Code__c sc = TestDataFactory.buildSourceCode(SourceCodeName);
        insert sc;

        Offer__c o = new Offer__c(
            OwnerId = sa.Id,
            SourceCode__c = sc.Id,
            Prefix__c = 'BOGO'
        );
        insert o;

        OfferVersion__c ov = new OfferVersion__c(
            StartDate__c = Date.today(),
            EndDate__c = Date.today().addDays(7),
            Offer__c = o.Id,
            Name = OfferVersionName,
            Publish__c = true,
            Override__c = false,
            SOQLQuery__c = OVSOQLString
        );
        insert ov;

        OfferMembership__c om = new OfferMembership__c(
            Contact__c = c.Id,
            Offer__c = o.Id,
            Name = OfferMembersipName,
            OfferVersion__c = ov.Id,
            Used__c = false
        );
        insert om;
    }


    @IsTest
    private static void testUseOffers(){
        OfferMembership__c om = [SELECT Id, Name, MembershipCode__c, SourceCode__c, Contact__c, Status__c, Offer__r.SourceCode__c, Used__c, Description__c FROM OfferMembership__c WHERE SourceCode__c LIKE '%BOGO%' LIMIT 1];
        System.debug('Offer Membership: ' + om);
        List<Id> offerIds = new List<Id>{om.Id};
        Test.startTest();

        ValidateOfferCode.useOffers(offerIds);

        Test.stopTest();

        om = [SELECT Id, Name, MembershipCode__c, SourceCode__c, Contact__c, Status__c, Offer__r.SourceCode__c, Used__c, Description__c FROM OfferMembership__c WHERE SourceCode__c LIKE '%BOGO%' LIMIT 1];
        System.assertEquals(true, om.Used__c);
    }


    /**
     * @description     :  Test Method that tests ValidateOfferCode.codeConfirm() method
     */
    @isTest
    private static void testCodeConfirm() {

        // Retrieve test contact
        Contact testCon = [SELECT Id, Name, AccountId FROM Contact WHERE Name LIKE 'Test contact'];
        System.debug('Test Contact: ' + testCon);

        //create sales order
        OrderApi__Sales_Order__c so = TestDataFactory.buildOpenSalesOrder(testCon.AccountId, testCon.Id);
        insert so;

        // Retrieve Source Code
        OrderApi__Source_Code__c sc = [SELECT Id, Name FROM OrderApi__Source_Code__c WHERE Name = :SourceCodeName];

        OfferMembership__c om = [SELECT Id, Name, MembershipCode__c, SourceCode__c, Contact__c, Status__c, Offer__r.SourceCode__c, Used__c, Description__c FROM OfferMembership__c WHERE SourceCode__c LIKE '%BOGO%' LIMIT 1];
        System.debug('Offer Membership: ' + om);

        Offer__c o = [SELECT Id, Name, SourceCode__r.Name FROM Offer__c];
        System.debug('Offer: ' + o);
        System.debug('Offer Source Code Name: ' + o.SourceCode__r.Name);

        OfferVersion__c ov = [SELECT Id, Name, StartDate__c, EndDate__c FROM OfferVersion__c WHERE Offer__c=:o.Id];


        // String to hold response from codeConfirm() method
        ValidateOfferCode.OfferCodeResponse response = new ValidateOfferCode.OfferCodeResponse();
        ValidateOfferCode.OfferCodeResponse responseError = new ValidateOfferCode.OfferCodeResponse();


        Test.startTest();

        om.Description__c = 'Test Description';
        update om;

        //test success without sales order
        response = ValidateOfferCode.codeConfirm(om.MembershipCode__c, testCon.Id, 'Manual', null);
        System.assertEquals(false, response.HasError);
        //test success with sales order
        response = ValidateOfferCode.codeConfirm(om.MembershipCode__c, testCon.Id, 'Manual', so.Id);
        System.assertEquals(false, response.HasError);

        String offerCode = ValidateOfferCode.getOfferCode(so.Id);
        System.assertEquals(om.MembershipCode__c, offerCode);

        om.Used__c = true;
        om.UsedDate__c = Date.today();
        update om;

        //test already used code
        response = ValidateOfferCode.codeConfirm(om.MembershipCode__c, testCon.Id, 'Manual', null);
        System.assertEquals(true, response.HasError);

        om.Used__c = false;
        om.UsedDate__c = null;
        update om;

        ov.StartDate__c = Date.today().addDays(-3);
        ov.EndDate__c = Date.today().addDays(-2);
        ov.Publish__c = false;
        update ov;

        //test expired code
        response = ValidateOfferCode.codeConfirm(om.MembershipCode__c, testCon.Id, 'Manual', null);
        System.assertEquals(true, response.HasError);

        //test general error
        responseError = ValidateOfferCode.codeConfirm(null, null,null, null);
        System.assertEquals('Error: Invalid offer.', responseError.ErrorMsg);

        Test.stopTest();

        List<OfferMembership__c> omToCheck = [SELECT Id FROM OfferMembership__c WHERE Id = :om.Id];
        System.assertEquals(1, omToCheck.size());

    }

    /**
     * @description     :  Test Method that tests ValidateOfferCode.setCodeUsed() method
     */
    @isTest
    private static void testSetCodeUsed() {

        // Retrieve test contact
        Contact testCon = [SELECT Id FROM Contact WHERE Name LIKE 'Test contact'];

        // Retrieve test offer
        Offer__c o = [SELECT Id FROM Offer__c];

        // Retrieve test offer version
        OfferVersion__c ov = [SELECT Id FROM OfferVersion__c];

        // Retrieve OfferMembership to set to used
        OfferMembership__c om = [SELECT Id, SourceCode__c FROM OfferMembership__c WHERE SourceCode__c LIKE '%BOGO%' LIMIT 1];

        // Insert Used OfferMembership
        OfferMembership__c omUsed = new OfferMembership__c(
            Contact__c = testCon.Id,
            Offer__c = o.Id,
//            Name = SourceCodeName,
            OfferVersion__c = ov.Id,
            Used__c = true,
            UsedDate__c = Date.today(),
            UsedMode__c = 'Manual'
        );
        insert omUsed;

        // Strings to hold responses from setCodeUsed()
        String response;
        String responseError;

        Test.startTest();

        response = ValidateOfferCode.setCodeUsed(om.Id, 'Manual');
        responseError = ValidateOfferCode.setCodeUsed(omUsed.Id, 'Manual');

        Test.stopTest();

        // OfferMemberships to be tested
        OfferMembership__c omUnusedToCheck;
        OfferMembership__c omUsedToCheck;

        // Retieve same OfferMembership with updated values
        List<OfferMembership__c> omsToTest = [SELECT Id, SourceCode__c, Used__c, UsedDate__c, UsedMode__c FROM OfferMembership__c WHERE SourceCode__c LIKE '%BOGO%'];

        // Populate OfferMemberships to assert
        for (OfferMembership__c omToTest : omsToTest) {
            if(omToTest.Id == omUsed.Id) {
                omUsedToCheck = omToTest;
            } else if (omToTest.Id == om.Id) {
                omUnusedToCheck = omToTest;
            }
        }

        // Assert that necessary values were updated
        System.assertEquals(omUnusedToCheck.Used__c, true);
        System.assertEquals(omUnusedToCheck.UsedDate__c, Date.today());
        System.assertEquals(omUnusedToCheck.UsedMode__c, 'Manual');

        // Assert that Error returned
        System.assertEquals('Error: Code Already Used', responseError);
    }
}