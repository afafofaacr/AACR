/**
 * Created by lauren.lezberg on 9/3/2019.
 */

@isTest
private with sharing class SN_HelpFormControllerTest {

    @testSetup static void setup(){
        Account acc = TestDataFactory.buildAccount('Test Account');
        insert acc;

        Contact con = TestDataFactory.buildContact(acc.Id);
        insert con;

        User u = TestDataFactory.buildUser(con.Id);
        insert u;

    }

    @isTest
    public static void test_saveChunk(){
        Contact con = [SELECT Id FROM Contact LIMIT 1];

        String before = 'Testing base 64 encode';
        String after = 'Testing add on base 64 encode';
        Blob beforeblob = Blob.valueOf(before);
        Blob afterblob = Blob.valueOf(after);

        String paramvalue = EncodingUtil.base64Encode(beforeblob);


            Test.startTest();

            List<ServiceNow_Incident_Type__mdt> incidentTypes = [SELECT Id, Type__c FROM ServiceNow_Incident_Type__mdt WHERE Is_Active__c = true];
            AACR_Error_Log__c log = new AACR_Error_Log__c(Incident_Id__c=incidentTypes[0].Id,Contact__c = con.Id, Issue_Type__c = 'Other', Error_Message__c='TEST ERROR MESSAGE', Stack_Trace__c='TEST STACK TRACE' );
            insert log;

            Id fileId = SN_HelpFormController.saveChunk(log.Id, 'TEST FILE', paramvalue, 'text/plain', '', 'TEST');

            System.assertNotEquals(null, fileId);

            paramvalue = EncodingUtil.base64Encode(afterblob);
            fileId = SN_HelpFormController.saveChunk(log.Id, 'TEST FILE', paramvalue, 'text/plain', fileId, 'TEST');

            System.assertNotEquals(null, fileId);

            Test.stopTest();
    }

    @isTest
    public static void test_saveAttachment(){
        Contact con = [SELECT Id FROM Contact LIMIT 1];

        String before = 'Testing base 64 encode';
        Blob beforeblob = Blob.valueOf(before);

        String paramvalue = EncodingUtil.base64Encode(beforeblob);

        Test.startTest();

        List<ServiceNow_Incident_Type__mdt> incidentTypes = [SELECT Id, Type__c FROM ServiceNow_Incident_Type__mdt WHERE Is_Active__c = true];
        AACR_Error_Log__c log = new AACR_Error_Log__c(Incident_Id__c=incidentTypes[0].Id,Contact__c = con.Id, Issue_Type__c = 'Other', Error_Message__c='TEST ERROR MESSAGE', Stack_Trace__c='TEST STACK TRACE' );
        insert log;

        Id attachId = SN_HelpFormController.saveTheAttachment(log.Id, 'TEST FILE', paramvalue, 'text/plain', 'TEST');

        System.assertNotEquals(null, attachId);


        Test.stopTest();
    }




    @isTest
    public static void test_getHelpFormData(){
        Test.startTest();
        Contact con = [SELECT Id, Name, Email FROM Contact LIMIT 1];
        Contact matchCon = SN_HelpFormController.findContact(con.Name, con.Email);
        System.assertEquals(con.Name, matchCon.Name);

        user u = [SELECT Id FROM User WHERE ContactId =: con.Id];
        System.runAs(u){
            SN_HelpFormController.HelpFormData data = SN_HelpFormController.getInitialHelpFormData();
            System.assertNotEquals(null, data);
        }
        Test.stopTest();

    }

    @isTest
    public static void test_sendInfoEmail(){
        Test.startTest();
        Contact con = [SELECT Id FROM Contact LIMIT 1];
        List<ServiceNow_Incident_Type__mdt> incidentTypes = [SELECT Id, Type__c FROM ServiceNow_Incident_Type__mdt WHERE Is_Active__c = true];
        AACR_Error_Log__c log = new AACR_Error_Log__c(Incident_Id__c=incidentTypes[0].Id,Contact__c = con.Id, Issue_Type__c = 'Other', Error_Message__c='TEST ERROR MESSAGE', Stack_Trace__c='TEST STACK TRACE' );
        insert log;

        SN_HelpFormController.sendInfoEmail(con.Id, log.Id, null);
        Test.stopTest();
    }

    @IsTest
    public static void test_saveErrorLog(){
        Contact con = [SELECT Id FROM Contact LIMIT 1];
        List<ServiceNow_Incident_Type__mdt> incidentTypes = [SELECT Id, Type__c FROM ServiceNow_Incident_Type__mdt WHERE Is_Active__c = true];
        AACR_Error_Log__c log = new AACR_Error_Log__c(Incident_Id__c=incidentTypes[0].Id,Contact__c = con.Id, Issue_Type__c = 'Other', Error_Message__c='TEST ERROR MESSAGE', Stack_Trace__c='TEST STACK TRACE' );
        String logString = JSON.serialize(log);

        Test.startTest();

        SN_HelpFormController.saveNewErrorLog(logString);

        Test.stopTest();

        List<AACR_Error_Log__c> logs = [SELECT Id FROM AACR_Error_Log__c];
        System.assertEquals(1, logs.size());
    }

}