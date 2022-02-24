/**
 * @author          :  CRM Science, Inc.
 * @date            :  10/7/2020
 * @description     :  This class tests the methods in the MembershipCodeGenerator class
 */
@isTest
private without sharing class MembershipCodeGeneratorTest {

    public static String AccountName = 'Test Account';
    public static String SourceCodeName = 'BOGO';
    public static String OfferVersionName = SourceCodeName + ' ' + System.today().month() + System.today().year() + '.' + (Math.random() * 10000);
    public static String OVSOQLString = 'SELECT Id, ContactId FROM User WHERE IsActive = true AND ContactId <> null LIMIT 1';
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
    }

    /**
     * @description     :  Test Method that tests MembershipCodeGenerator.getOffers() and MembershipCodeGenerator.generateMemberships() methods
     */
    @isTest
    private static void testMembershipCodeGenerator() {

        // Retrieve Source Code that will be used to retrieve offers
        OrderApi__Source_Code__c sc = [SELECT Id, Name FROM OrderApi__Source_Code__c WHERE Name = :SourceCodeName];

        // Call getOffers() to retrieve all offers
        List<Offer__c> offers = MembershipCodeGenerator.getOffers();

        // Assert that the getOffers() method retrieved offers
        System.assert(!offers.isEmpty());

        // Offer to be populated below
        Offer__c retrievedOffer;

        // Variables to be passed to generateMemberships() method
        Date startDate = Date.today();
        Date endDate = Date.today().addDays(7);
        Boolean oRide = false;
        Boolean publish = true;
        String description = 'Test Description';
        String versionCode = '1234';

        // Populate retrievedOffer
        for (Offer__c o : offers) {
            if (o.SourceCode__c == sc.Id) {
                retrievedOffer = o;
            }
        }

        Test.startTest();

        // Call generateMemberships(), which calls the batch and createFromContactIds()
        String successMessage = MembershipCodeGenerator.generateMemberships(retrievedOffer.Id, startDate, endDate, oRide, publish, OVSOQLString, description, versionCode);
        
        Test.stopTest();

        // Retrieve Offer Version and Offer Membership to be asserted
        List<OfferVersion__c> ov = [SELECT Id, Offer__c FROM OfferVersion__c WHERE Offer__c = :retrievedOffer.Id];
        List<OfferMembership__c> om = [SELECT Id, Offer__c FROM OfferMembership__c WHERE Offer__c = :retrievedOffer.Id];

        // Assert that Offer Version was inserted
        System.assertEquals(1, ov.size());

        // Assert that Offer Membership was inserted
        System.assertEquals(1, om.size());
    }
}