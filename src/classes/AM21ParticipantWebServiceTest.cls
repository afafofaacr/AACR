/**
 * Created by lauren.lezberg on 4/5/2021.
 */

@IsTest
private class AM21ParticipantWebServiceTest {

    @IsTest
    static void testRequest() {

        BR_Event__c AM21 = LiveTestDataFactory.buildEvent('AACR Annual Meeting 2021', false, false);
        insert AM21;


        Account a = new Account();
        a.Name = 'Test Household';
        insert a;

        Contact testContact = new Contact();
        testContact.FirstName                    = 'AM21 Participant ';
        testContact.MiddleName                   = 'Web';
        testContact.LastName                     = 'Service Test';
        testContact.Title                        = 'Test Contact';
        testContact.AccountId                    = a.Id;
        testContact.MailingStreet                = '123 Main St';
        testContact.MailingCity                  = 'Philadelphia';
        testContact.MailingState                 = 'Pennsylvania';
        testContact.MailingPostalCode            = '19106';
        testContact.MailingCountry               = 'United States';
        testContact.Email                        = 'atlaswebservicetest@yopmail.com';
        testContact.Phone                        = '215-555-5555';
        testContact.Gender__c                    = 'Female';
        testContact.Birthdate                    = Date.newInstance(1990,1,1);
        testContact.Membership_Status__c         = 'Current';
        testContact.Member_Type__c               = 'Student Member';
        testContact.Degrees_Held__c              = 'PhD';
        testContact.Current_Education_Status__c  = 'Graduate Student';
        testContact.Organ_Sites__c               = 'Breast;Other Female Genital System;Uterine Cervix;Uterine Corpus';
        testContact.Paid_thru_date__c            = Date.newInstance(2019,12,31);
        testContact.Advocate__c                  = false;
        insert testContact;

        User u = TestDataFactory.buildUser(testContact.Id);
        insert u;

        Contact conTest = [Select AACR_ID__c from Contact where id=: testContact.id];

        List<OrgWideEmailAddress> owas = [SELECT Id FROM OrgWideEmailAddress LIMIT 1];
        System.assertEquals(owas.size(), 1);

        insert new BrEvents_Settings__c(Name='org wide email id', Label__c = 'org wide email id', Value__c = owas[0].Id);

        BR_Participation__c participation = new BR_Participation__c(Contact__c=conTest.Id, BR_Event__c=AM21.Id, Participate__c = 'Yes');
        insert participation;

        Test.startTest();


//        Testing AACRID
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();

        request.requestUri ='https://aacr--UAT.my.salesforce.com/services/apexrest/AM21Participant/' + conTest.Id;
        request.httpMethod = 'GET';

        RestContext.request = request;
        RestContext.response = response;

        AM21ParticipantWebService.getParticipant();


        System.assertNotEquals(null, conTest);


    }
}