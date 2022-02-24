/**
 * Created by lauren.lezberg on 2/21/2020.
 */
@isTest
private with sharing class SpeakerFormControllerTest {

    @testSetup public static void setup(){
        Account acc = LiveTestDataFactory.buildAccount('Test Account');
        insert acc;

        Contact con = LiveTestDataFactory.buildContact(acc.Id);
        insert con;

    }

    @isTest
    public static void test_getAssistants(){
        Contact con = [SELECT Id, AccountId FROM Contact WHERE Email='testEmail@yopmail.com'];

        Test.startTest();
        List<npe4__Relationship__c> assistants = SpeakerFormController.getAssistants(con.Id);
        System.assertEquals(null, assistants);

        Contact assistant = LiveTestDataFactory.buildAssistant(con.AccountId);
        insert assistant;

        npe4__Relationship__c assistRelationship = LiveTestDataFactory.buildAssistantRelationship(con.Id, assistant.Id);
        insert assistRelationship;

        assistants = SpeakerFormController.getAssistants(con.Id);
        System.assertEquals(1, assistants.size());
        System.assertEquals(assistRelationship.Id, assistants[0].Id);

        Test.stopTest();
    }
}