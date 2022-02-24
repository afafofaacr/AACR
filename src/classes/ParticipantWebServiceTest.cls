/**
 * Created by lauren.lezberg on 8/19/2020.
 */

@IsTest
private class ParticipantWebServiceTest {

    @TestSetup
    public static void setup(){
        BR_Event__c evt = LiveTestDataFactory.buildEvent('Test Event', true, false);
        insert evt;

        Account acc = TestDataFactory.buildAccount('Test Account');
        insert acc;

        Contact testContact = new Contact();
        testContact.FirstName = 'Atlas';
        testContact.MiddleName = 'Web';
        testContact.LastName = 'Service Test';
        testContact.Title = 'Test Contact';
        testContact.AccountId = acc.Id;
        testContact.MailingStreet = '123 Main St';
        testContact.MailingCity = 'Philadelphia';
        testContact.MailingState = 'Pennsylvania';
        testContact.MailingPostalCode = '19106';
        testContact.MailingCountry = 'United States';
        testContact.MailingCountryCode = 'US';
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

        List<OrgWideEmailAddress> owas = [SELECT Id FROM OrgWideEmailAddress LIMIT 1];
        System.assertEquals(owas.size(), 1);

        insert new BrEvents_Settings__c(Name='org wide email id', Label__c = 'org wide email id', Value__c = owas[0].Id);

        BR_Participation__c participation = new BR_Participation__c(User__c=u.Id, Contact__c=testContact.Id, Participate__c='Yes', BR_Event__c=evt.Id);
        insert participation;
    } 

    @IsTest
    static void testGet() {
        BR_Event__c evt = [SELECT Id FROM BR_Event__c WHERE Name='Test Event'];

        Contact con = [SELECT Id FROM Contact WHERE Account.Name = 'Test Account'];

        Test.startTest();


//        Testing AACRID
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();

        request.requestUri ='https://aacr--UAT.my.salesforce.com/services/apexrest/Participant/' + con.Id;
        request.httpMethod = 'GET';

        RestContext.request = request;
        RestContext.response = response;


        ParticipantWebService.getParticipant();


        Test.stopTest();
    }
}