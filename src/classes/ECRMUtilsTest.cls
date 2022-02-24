/**
 * Created by lauren.lezberg on 4/1/2019.
 */
@isTest
private with sharing class ECRMUtilsTest {

    @testSetup static void setup(){
        Account acc = TestDataFactory.buildAccount('Test Account');
        insert acc;
        Account acc2 = TestDataFactory.buildAccount('Test Account 2');
        insert acc2;
        Contact testContact = TestDataFactory.buildContactMemberCurrent(acc.Id);
        insert testContact;
        Contact testContact2 = TestDataFactory.buildContactMemberCurrent(acc2.Id);
        testContact2.Email='testcontact2@yopmail.com';
        insert testContact2;
        User u = TestDataFactory.buildUser(testContact2.Id);
        insert u;


        OrderApi__Item_Class__c itemClass = TestDataFactory.buildItemClass('Individual Memberships');
        insert itemClass;
        OrderApi__Item__c item = TestDataFactory.buildItem(itemClass.Id, 'Active Membership');
        insert item;
        OrderApi__GL_Account__c glAccount = TestDataFactory.buildGLAccount();
        insert glAccount;
        OrderApi__Item_Class__c nonSubItemClass = TestDataFactory.buildItemClass('Merchandise');
        insert nonSubItemClass;
        OrderApi__Item__c nonSubItem = TestDataFactory.buildItem(nonSubItemClass.Id, 'AACR Member Pin');
        nonSubItem.Future_Income_Account__c = glAccount.Id;
        nonSubItem.OrderApi__Is_Subscription__c = false;
        insert nonSubItem;
        OrderApi__Sales_Order__c so = TestDataFactory.buildOpenSalesOrder(acc.Id, testContact.Id);
        insert so;
        OrderApi__Sales_Order_Line__c soLine = TestDataFactory.buildSOLine(so.Id, item.Id, itemClass.Id);
        insert soLine;
        OrderApi__Sales_Order_Line__c soLine2 = TestDataFactory.buildSOLine(so.Id, nonSubItem.Id, nonSubItemClass.Id);
        insert soLine2;

        OrderApi__Item_Class__c journalsClass = TestDataFactory.buildItemClass('Journal Subscriptions');
        insert journalsClass;
        OrderApi__Item__c bloodCancerJ = TestDataFactory.buildItem(journalsClass.Id, 'Blood Cancer Discovery - Online');
        insert bloodCancerJ;
    }

    @IsTest
    public static void test_markInvoiceAsPaid(){
        Contact con = [SELECT Id FROM Contact WHERE Account.Name='Test Account'];
        OrderApi__Sales_Order__c so = [SELECT Id FROM OrderApi__Sales_Order__c WHERE OrderApi__Contact__c=:con.Id];

        OrderApi__Invoice__c inv = new OrderApi__Invoice__c(OrderApi__Contact__c=con.Id, Stripe_Invoice_Id__c='1234', OrderApi__Sales_Order__c=so.Id);
        insert inv;

        Test.startTest();

        ECRMUtils.markInvoiceAsPaid('1234');

        Test.stopTest();

        inv = [SELECT OrderApi__Status__c FROM OrderApi__Invoice__c WHERE OrderApi__Contact__c=:con.Id];
        System.assertEquals('Posted', inv.OrderApi__Status__c);
    }

    @IsTest
    public static void test_getSalesOrder(){
        Contact con = [SELECT Id FROM Contact WHERE Account.Name='Test Account'];
        OrderApi__Sales_Order__c so = [SELECT Id FROM OrderApi__Sales_Order__c WHERE OrderApi__Contact__c=:con.Id];

        Test.startTest();

        so = ECRMUtils.getSalesOrder(so.Id);
        System.assertNotEquals(null, so);

        Test.stopTest();
    }

    @IsTest
    public static void test_getCountryCodes(){
        Map<String, String> countryMap = new Map<String, String>();
        Test.startTest();

        countryMap = ECRMUtils.getCountryCodes();

        Test.stopTest();

        System.assertEquals(false, countryMap.isEmpty());
    }

    @IsTest
    public static void test_getRecordTypes(){
        Test.startTest();

        List<RecordType> rTypes = ECRMUtils.getRecordTypes('Contact');

        Test.stopTest();

        System.assertEquals(rTypes.size(), [SELECT COUNT() FROM RecordType WHERE SobjectType='Contact' AND IsActive = true]);
    }

    @IsTest
    public static void test_deleteRecord(){
        Contact con = [SELECT Id, Email FROM Contact WHERE Account.Name = 'Test Account'];

        OrderApi__Sales_Order__c so = [SELECT Id FROM OrderApi__Sales_Order__c WHERE OrderApi__Contact__c=:con.Id];

        Test.startTest();

        ECRMUtils.deleteRecord(so.Id);

        Test.stopTest();

        List<OrderApi__Sales_Order__c> sos = [SELECT Id FROM OrderApi__Sales_Order__c WHERE Id=:so.Id];
        SYstem.assertEquals(true, sos.isEmpty());
    }

    @isTest
    public static void test_getVirtualSponsorsHTML(){
        EventApi__Event__c evt = TestDataFactory.buildEvent();

        Virtual_Meeting_Links__mdt vml = [SELECT Id FROM Virtual_Meeting_Links__mdt LIMIT 1];
        vml.Login_Background_Image__c = 'https://s3.us-east-1.amazonaws.com/fonteva-customer-media/undefined/lYVgTwcf_myAACR_4C_Oct22_2018_horiz3_png';
        vml.Login_Header_Image__c = 'https://s3.us-east-1.amazonaws.com/fonteva-customer-media/undefined/lYVgTwcf_myAACR_4C_Oct22_2018_horiz3_png';
        vml.DeveloperName='Virtual_Test_Event';
        vml.Event_Id__c = evt.Id;
        vml.View_Link__c = 'https://www.google.com';
        vml.Event_IsActive__c = true;
        vml.Computer_Check_Link__c = 'https://www.salesforce.com';
        vml.Check_IsActive__c = true;
        vml.Registration_Open__c = false;

        ECRMUtils.virtualMeetings.add(vml);

        Virtual_Meeting_Sponsor__mdt vms = new Virtual_Meeting_Sponsor__mdt();
        vms.Virtual_Meeting__c = vml.Id;
        vms.Sponsor_Type__c = 'Cure Level';
        vms.MasterLabel = 'Test Person1';
        ECRMUtils.virtualSponsors.add(vms);

        vms = new Virtual_Meeting_Sponsor__mdt();
        vms.Virtual_Meeting__c = vml.Id;
        vms.Sponsor_Type__c = 'Cure Level';
        vms.MasterLabel = 'Test Person2';
        ECRMUtils.virtualSponsors.add(vms);

        vms = new Virtual_Meeting_Sponsor__mdt();
        vms.Virtual_Meeting__c = vml.Id;
        vms.Sponsor_Type__c = 'Progress Level';
        vms.MasterLabel = 'Test Person3';
        ECRMUtils.virtualSponsors.add(vms);

         vms = new Virtual_Meeting_Sponsor__mdt();
        vms.Virtual_Meeting__c = vml.Id;
        vms.Sponsor_Type__c = 'Underwriting Sponsor';
        vms.MasterLabel = 'Test Person4';
        ECRMUtils.virtualSponsors.add(vms);

        Test.startTest();

        String html = ECRMUtils.getVirtualSponsorsHTML(evt.Id);

        System.assertNotEquals(null, html);

        Test.stopTest();
    }


    @isTest
    public static void test_getCurrentRelationships(){
        Contact con = [SELECT Id, Email FROM Contact WHERE Account.Name = 'Test Account'];
        Account acc = [SELECT Id FROM Account WHERE Name='Test Account'];

        Contact relatedCon = new Contact(FirstName='Testy', LastName='Testerson', AccountId=acc.Id);
        insert relatedCon;

        npe4__Relationship__c relation = new npe4__Relationship__c(npe4__Type__c='Assistant', npe4__Status__c = 'Current', npe4__Contact__c=con.Id, npe4__RelatedContact__c=relatedCon.Id);
        insert relation;

        Test.startTest();

        List<npe4__Relationship__c> currentRelationships = ECRMUtils.getCurrentRelationships('Assistant', con.Id);

        System.assertEquals(1, currentRelationships.size());

        Test.stopTest();


    }

    @isTest
    public static void test_checkForContactDuplicates(){
        Contact con = [SELECT Id, Email FROM Contact WHERE Account.Name = 'Test Account'];
        Account acc = [SELECT Id FROM Account WHERE Name='Test Account'];
        Test.startTest();

        String updateEmail = 'newworkemail@yopmail.com';
        Boolean hasDupes = ECRMUtils.checkForContactDuplicates(updateEmail);
        System.assertEquals(false, hasDupes);

        Contact dupeContact = new Contact(AccountId=acc.Id, FirstName='Dupe', LastName='Test', Email=con.Email);
        insert dupeContact;

        hasDupes = ECRMUtils.checkForContactDuplicates(con.Email);
        System.assertEquals(true, hasDupes);

        Test.stopTest();
    }

    @isTest
    public static void test_updateContactWorkEmail(){
        Contact con = [SELECT Id FROM Contact WHERE Account.Name = 'Test Account'];
        User u = TestDataFactory.buildUser(con.Id);
        insert u;

        Test.startTest();

        String updateEmail = 'newworkemail@yopmail.com';
        ECRMUtils.updateContactWorkEmail(u.Id, updateEmail);
        con = [SELECT OrderApi__Work_Email__c FROM Contact WHERE Id=: con.Id];
        System.assertEquals(updateEmail, con.OrderApi__Work_Email__c);

        Test.stopTest();
    }

//    @isTest
//    public static void test_deactivatePortalUser(){
//        Contact con = [SELECT Id FROM Contact WHERE Account.Name = 'Test Account 2' AND Email='testcontact2@yopmail.com'];
//
//        Test.startTest();
//
//        ECRMUtils.deactivatePortalUser(con.Id);
//
//        Test.stopTest();
//
//        User u = [SELECT Id, IsActive FROM User WHERE ContactId=:con.Id];
//        System.assertEquals(false, u.IsActive);
//    }

    @isTest
    public static void test_getMembershipSalesOrderLines(){
        Contact con = [SELECT Id FROM Contact WHERE Account.Name = 'Test Account'];
        OrderApi__Sales_Order__c so = [SELECT Id FROM OrderApi__Sales_Order__c WHERE OrderApi__Contact__c=:con.Id];

        Test.startTest();
        List<OrderApi__Sales_Order_Line__c> lines = ECRMUtils.getMembershipSalesOrderLines(so.Id);
        System.assertEquals(1, lines.size());
        Test.stopTest();
    }

    @isTest
    public static void test_getSubscriptionsFromMembership(){
        Contact con = [SELECT Id FROM Contact WHERE Account.Name = 'Test Account'];
        OrderApi__Item__c membership = [SELECT Id, OrderApi__Item_Class__c FROM OrderApi__Item__c WHERE Name='Active Membership'];
        OrderApi__Subscription_Plan__c subPlan = TestDataFactory.buildsubPlan();
        insert subPlan;
        OrderApi__Subscription__c sub = TestDataFactory.buildSubscription(con.Id, subPlan.Id, membership.Id, membership.OrderApi__Item_Class__c);
        insert sub;
        Set<String> itemClasses = new Set<String>();
        itemClasses.add('Individual Memberships');

        List<OrderApi__Subscription__c> memSubs = RenewalUtils.getIndividualMembershipSubscription(con.Id);

        Test.startTest();

        List<OrderApi__Subscription__c> allSubs = ECRMUtils.getSubscriptionsFromMembership(itemClasses, memSubs[0]);

        Test.stopTest();

        System.assertEquals(1, allSubs.size());
    }

    @isTest
    public static void test_fetchLookupValues(){

        Test.startTest();
        List<sObject> accts = ECRMUtils.fetchLookUpValues('Test', 'Account',null);
        Test.stopTest();

        System.assertEquals(2, accts.size());
    }

    @IsTest
    public static void test_startMembershipApplication(){
        Contact con = [SELECT Id FROM Contact WHERE Email = 'testcontact2@yopmail.com'];
        User u = [SELECT Id FROM User WHERE ContactId=:con.Id];

        OrderApi__Item__c membership = [SELECT Id, OrderApi__Item_Class__c FROM OrderApi__Item__c WHERE Name='Active Membership'];


        System.runAs(u){
            Test.startTest();

            String soId = ECRMUtils.startMembershipApplication(membership.Id);

            Test.stopTest();

            System.assertNotEquals(null, soId);
        }
    }

    @IsTest
    public static void test_startTransferApplication(){
        Contact con = [SELECT Id FROM Contact WHERE Email = 'testcontact2@yopmail.com'];
        User u = [SELECT Id FROM User WHERE ContactId=:con.Id];

        OrderApi__Item__c membership = [SELECT Id, OrderApi__Item_Class__c FROM OrderApi__Item__c WHERE Name='Active Membership'];


        System.runAs(u){
            Test.startTest();

            String soId = ECRMUtils.startTransferApplication(membership.Id);

            Test.stopTest();

            System.assertNotEquals(null, soId);
        }
    }

    @IsTest
    public static void test_startReinstatementTransferApplication(){
        Contact con = [SELECT Id FROM Contact WHERE Email = 'testcontact2@yopmail.com'];
        User u = [SELECT Id FROM User WHERE ContactId=:con.Id];

        OrderApi__Item__c membership = [SELECT Id, OrderApi__Item_Class__c FROM OrderApi__Item__c WHERE Name='Active Membership'];


        System.runAs(u){
            Test.startTest();

            String soId = ECRMUtils.startReinstateTransferApplication(membership.Id);

            Test.stopTest();

            System.assertNotEquals(null, soId);
        }
    }


    @IsTest
    public static void test_dupeLogic(){
        Contact con = [SELECT Id, AccountId, Email, LastName, FirstName FROM Contact WHERE Account.Name = 'Test Account'];

        Contact con2 = new Contact();
        con2.AccountId = con.AccountId;
        con2.LastName = con.LastName;
        con2.FirstName = con.FirstName;
        con2.Email = con.Email;
        insert con2;

        Test.startTest();
        List<Contact> contacts = ECRMUtils.getContactDuplicates(con.Email);
        System.assertEquals(2, contacts.size());

        Boolean hasUser = ECRMUtils.checkForUser(con.Email);
        System.assertEquals(false, hasUser);

        ECRMUtils.createDuplicateAlert(con);

        Test.stopTest();
    }

    @isTest
    public static void test_cancelAllSubscriptionsWithBadges(){
        Contact con = [SELECT Id FROM Contact WHERE Account.Name = 'Test Account'];

        OrderApi__Subscription_Plan__c subPlan = TestDataFactory.buildsubPlan();
        insert subPlan;


        OrderApi__Item__c membership = [SELECT Id, OrderApi__Item_Class__c FROM OrderApi__Item__c WHERE Name='Active Membership'];

        OrderApi__Subscription__c membershipSub = TestDataFactory.buildSubscription(con.Id, subPlan.Id, membership.Id, membership.OrderApi__Item_Class__c);
        insert membershipSub;

        Test.startTest();
        ECRMUtils.cancelAllSubscriptionsWithBadges(con.Id, 'Customer Request');

        List<OrderApi__Subscription__c> cancelledSubs = [SELECT Id FROM OrderApi__Subscription__c WHERE OrderApi__Contact__c=:con.Id AND OrderApi__Is_Cancelled__c= true];
        System.assertEquals(1, cancelledSubs.size());
        Test.stopTest();
    }

    @isTest
    public static void test_cancelAllSubscriptions(){
        Contact con = [SELECT Id FROM Contact WHERE Account.Name = 'Test Account'];

        OrderApi__Subscription_Plan__c subPlan = TestDataFactory.buildsubPlan();
        insert subPlan;


        OrderApi__Item__c membership = [SELECT Id, OrderApi__Item_Class__c FROM OrderApi__Item__c WHERE Name='Active Membership'];

        OrderApi__Subscription__c membershipSub = TestDataFactory.buildSubscription(con.Id, subPlan.Id, membership.Id, membership.OrderApi__Item_Class__c);
        insert membershipSub;

        Test.startTest();
        ECRMUtils.cancelAllSubscriptions(con.Id, 'Customer Request');

        List<OrderApi__Subscription__c> cancelledSubs = [SELECT Id FROM OrderApi__Subscription__c WHERE OrderApi__Contact__c=:con.Id AND OrderApi__Is_Cancelled__c= true];
        System.assertEquals(1, cancelledSubs.size());
        Test.stopTest();
    }

    @isTest
    public static void test_changeTerm(){
        Contact con = [SELECT Id FROM Contact WHERE Account.Name = 'Test Account'];
        OrderApi__Sales_Order__c SO = [SELECt Id FROM OrderApi__Sales_Order__c WHERE OrderApi__Contact__c=: con.Id];

        OrderApi__Subscription_Plan__c subPlan = TestDataFactory.buildsubPlan();
        subPlan.Name= '2YR Membership';
        subPlan.OrderApi__Advanced_Calendar_Days__c = 365;
        insert subPlan;

        Test.startTest();

        ECRMUtils.changeSubscriptionTerm(subPlan.Id, SO.Id, '2020');

        OrderApi__Subscription_Plan__c subPlan2 = TestDataFactory.buildsubPlan();
        insert subPlan2;

        ECRMUtils.changeSubscriptionTerm(subPlan2.Id, SO.Id, '2019');

        Test.stopTest();
    }

    @isTest
    public static void testGetDependentPicklistValues(){
        Test.startTest();
        Map<String, String> picklistMap = ECRMUtils.getDependentPicklistValues('Contact', 'MailingCountryCode', 'MailingStateCode', 'US');
        Test.stopTest();

        System.assertNotEquals(picklistMap, null);
    }

    @isTest
    public static void testGetReverseDependentPicklistValues(){
        Test.startTest();
        Map<String, String> picklistMap = ECRMUtils.getDependentPicklistValuesReverse('Contact', 'MailingCountryCode', 'MailingStateCode', 'US');
        Test.stopTest();

        System.assertNotEquals(picklistMap, null);
    }

    @isTest
    public static void testGetCountryPicklistValues(){
        Test.startTest();
        Map<String, String> countryMap = ECRMUtils.getCountryPicklistValues();
        List<String> majorFocus = ECRMUtils.getPicklistValues('Contact', 'Major_Focus__c');

        Test.stopTest();

        System.assert(majorFocus.size()>0, 'Should be more than one option for major focus');
        System.assertNotEquals(countryMap, null);
    }

    @isTest
    public static void testGetReverseCountryPicklistValues(){
        Test.startTest();
        Map<String, String> countryMap = ECRMUtils.getReverseCountryPicklistValues();
        Test.stopTest();

        System.assertNotEquals(countryMap, null);
    }

    @isTest
    public static void testGetStatePicklistValues(){
        Test.startTest();
        Map<String, String> stateMap = ECRMUtils.getStatePicklistValues();

        Test.stopTest();

        System.assertNotEquals(stateMap, null);
        System.assert(!stateMap.isEmpty(), 'Should be more than one state value');
    }

    @isTest
    public static void testGetCurrentContact(){
        Contact testContact = [SELECT Id FROM Contact LIMIT 1];
        User u = TestDataFactory.buildUser(testContact.Id);
        insert u;

        System.runAs(u){
            Id contactId = ECRMUtils.getCurrentLoginUserContactId();
            Contact contact = ECRMUtils.getCurrentLoginContact();

            System.assertEquals(u.ContactId, contactId);
            System.assertEquals(u.ContactId, contact.Id);
        }
    }

    @isTest
    public static void test_getSpecificSalesOrderIndMemLIs(){
        Contact testContact = [SELECT Id FROM Contact LIMIT 1];
        OrderApi__Sales_Order__c so = [SELECT Id FROM OrderApi__Sales_Order__c WHERE OrderApi__Contact__c =: testContact.Id];

        Test.startTest();

        List<OrderApi__Sales_Order_Line__c> SOLines = ECRMUtils.getSpecificSalesOrderIndMemLIs(so.Id);
        System.assertNotEquals(null, SOLines);
        System.assertEquals(1, SOLines.size());

        Test.stopTest();

    }

    @IsTest
    public static void test_cleanStringCase(){

        Test.startTest();

        String testString1 = ECRMUtils.cleanStringCase('l\'ower-case');
        String testString2 = ECRMUtils.cleanStringCase('UPPER C\'ASE');
        String testString3 = ECRMUtils.cleanStringCase('APOS\'TROPHIE');
        String testString4 = ECRMUtils.cleanStringCase('SIMPLENAME');
        System.assertEquals('L\'Ower-Case', testString1);
        System.assertEquals('Upper C\'Ase', testString2);
        System.assertEquals('Apos\'Trophie', testString3);
        System.assertEquals('Simplename', testString4);
        
        Test.stopTest();


    }


}