/**
 * Created by afaf.awad on 9/8/2021.
 */
@IsTest
public with sharing class CSI_Reg_ApiTest {
    @testSetup
    public static void setup() {

        Account a = TestDataFactory.buildAccount('Test Account');
        insert a;

        Contact testContact = new Contact();
        testContact.FirstName = 'Atlas';
        testContact.MiddleName = 'Web';
        testContact.LastName = 'Service Test';
        testContact.Title = 'Test Contact';
        testContact.AccountId = a.Id;
        testContact.MailingStreet = '123 Main St';
        testContact.MailingCity = 'Philadelphia';
        testContact.MailingState = 'Pennsylvania';
        testContact.MailingPostalCode = '19106';
        testContact.MailingCountry = 'United States';
        testContact.Email = 'atlaswebservicetest@yopmail.com';
        testContact.Phone = '215-555-5555';
        testContact.Gender__c = 'Female';
        testContact.Birthdate = Date.newInstance(1990, 1, 1);
        testContact.Membership_Status__c = 'Current';
        testContact.Member_Type__c = 'Nonmember';
        testContact.Degrees_Held__c = 'PhD';
        testContact.Current_Education_Status__c = 'Graduate Student';
        testContact.Organ_Sites__c = 'Breast;Other Female Genital System;Uterine Cervix;Uterine Corpus';
        testContact.Paid_thru_date__c = Date.newInstance(2019, 12, 31);
        testContact.Advocate__c = false;
        testContact.Pre_Post_Doc__c = false;
        insert testContact;

        User u = TestDataFactory.buildUser(testContact.Id);
        insert u;
    }

    @IsTest
    public static void testContactId() {

        Contact conTest = [Select AACR_ID__c from Contact LIMIT 1];
        Test.startTest();
        createREST(conTest.AACR_ID__c);
        CSI_Reg_Api.fetchContact();
        Test.stopTest();
    }

    @IsTest
    public static void testUserId() {

        Contact con = [Select Id from Contact LIMIT 1];
        User testUser = [SELECT Id from User WHERE ContactId =: con.Id];
        Test.startTest();
        createREST(testUser.Id);
        CSI_Reg_Api.fetchContact();
        Test.stopTest();

    }

    @IsTest
    public static void testUserEmail() {

        Contact con = [Select Id from Contact LIMIT 1];
        User userEmail = [SELECT email from User WHERE ContactId =: con.Id];
        Test.startTest();
        createREST(userEmail.email);
        CSI_Reg_Api.fetchContact();
        Test.stopTest();


    }

    public static void createREST(String key){
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestUri ='https://aacr--UAT.my.salesforce.com/services/apexrest/Con_CSI/' + key;
        request.httpMethod = 'GET';

        RestContext.request = request;
        RestContext.response = response;
    }

}