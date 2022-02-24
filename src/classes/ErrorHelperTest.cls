/**
 * Created by lauren.lezberg on 9/3/2019.
 */
@isTest
private with sharing class ErrorHelperTest {

    @testSetup static void setup() {
        Account acc = TestDataFactory.buildAccount('Test Account');
        insert acc;

        Contact con = TestDataFactory.buildContact(acc.Id);
        con.Member_Type__c = 'Active Member';
        insert con;

        AACR_Error_Log__c userReq = TestDataFactory.buildErrorRequest(con.Id);
        insert userReq;


       Profile profileRecord = [SELECT Id
        FROM Profile
        WHERE Name =: 'Standard User'
                LIMIT 1];

        // Create users record
        User pAlert = new User(alias = 'test',
                ProfileId = profileRecord.Id,
                email = Label.Platform_Alert_Email,
                emailencodingkey = 'UTF-8',
                lastname = 'Test User2',
                languagelocalekey = 'en_US',
                localesidkey = 'en_US',
                timezonesidkey = 'America/Los_Angeles',
                username = System.now().millisecond() + 'test@testorg2.com');
        insert pAlert;

    }

    @isTest
    public static void sendExceptionEmails(){
        Contact con = [SELECT Id, Name, OrderApi__Preferred_Email__c, OrderApi__Preferred_Phone__c, AccountId FROM Contact LIMIT 1];
        User usr = [Select id from User where Id = :UserInfo.getUserId()];

        System.runAs(usr) {
            Test.startTest();

            AACR_Error_Log__c eLog = ErrorHelper.buildErrorLog(con, '12346374653543', 'TEST ISSUE', 'TEST DESCRIPTION');
            insert eLog;

            String categoryStr = 'TEST CATEGORY';
            String errorMsg = 'TEST ERROR MESSAGE';
            String stackTrace = 'TEST STACK TRACE';

            ErrorHelper.sendExceptionEmail(categoryStr, errorMsg, stackTrace );

            ErrorHelper.sendExceptionEmail(eLog.Id, categoryStr, errorMsg, stackTrace);

            ErrorHelper.sendExceptionEmail(con.Id, eLog.Id, categoryStr, errorMsg, stackTrace);


            Test.stopTest();

        }
    }

    @isTest
    public static void test_buildErrorLog(){
        Contact con = [SELECT Id, Name, OrderApi__Preferred_Email__c, OrderApi__Preferred_Phone__c, AccountId FROM Contact LIMIT 1];
        User usr = [Select id from User where Id = :UserInfo.getUserId()];

        System.runAs(usr) {
            Test.startTest();

            AACR_Error_Log__c eLog = ErrorHelper.buildErrorLog(con, '12346374653543', 'TEST ISSUE', 'TEST DESCRIPTION');
            System.assertNotEquals(null, eLog);

            Test.stopTest();


        }
    }

    @isTest
    public static void test_buildErrorExceptionLog(){
//        Contact con = [SELECT Id, Name, OrderApi__Preferred_Email__c, OrderApi__Preferred_Phone__c, AccountId FROM Contact LIMIT 1];
        User usr = [Select id from User where Id = :UserInfo.getUserId()];

        System.runAs(usr) {
            Test.startTest();

            AACR_Error_Log__c eLog = ErrorHelper.buildErrorExceptionLog('TEST Error Message', 'Test Stack Trace');
            System.assertNotEquals(null, eLog);

            Test.stopTest();


        }
    }

    @isTest
    public static void test_sendExceptionEmail(){
        Contact con = [SELECT Id FROM Contact LIMIT 1];
        User usr = [Select id from User where Id = :UserInfo.getUserId()];

        System.runAs(usr) {
            Test.startTest();

            ErrorHelper.sendExceptionEmail('TEST', 'TEST ERROR MSG', 'TEST STACK TRACE');

            Test.stopTest();

        }
    }

    @isTest
    public static void test_sendServiceNowEmail(){
        Contact con = [SELECT Id FROM Contact LIMIT 1];
        User usr = [Select id from User where Id = :UserInfo.getUserId()];

        System.runAs(usr) {

            EmailTemplate et = new EmailTemplate(Name='ServiceNow_Request_HTML', IsActive=true, DeveloperName='ServiceNow_Request_HTML', TemplateType= 'Text', FolderId=userInfo.getUserId(), Body='THIS IS A TEST');
            insert et;

            AACR_Error_Log__c log = [SELECT Id FROM AACR_Error_Log__c WHERE Contact__c = :con.Id LIMIT 1];
            Test.setCreatedDate(log.Id, System.now());

            Test.startTest();
            ErrorHelper.sendSNEmail(con.Id, log.Id, null, new List<String>{'test@yopmail.com'}, et.Id);
            ErrorHelper.sendSNEmail(con.Id, log.Id, null, new List<String>{'test@yopmail.com'}, et.Id, 'Test Subject');
            Test.stopTest();

        }
    }


    @isTest
    public static void test_sendSNRequestEmail() {


        Contact con = [SELECT Id FROM Contact LIMIT 1];
        User usr = [Select id from User where Id = :UserInfo.getUserId()];

        System.runAs(usr) {

            EmailTemplate et = new EmailTemplate(Name='ServiceNow_Request_HTML', IsActive=true, DeveloperName='ServiceNow_Request_HTML', TemplateType= 'Text', FolderId=userInfo.getUserId(), Body='THIS IS A TEST');
            insert et;

            AACR_Error_Log__c log = [SELECT Id FROM AACR_Error_Log__c WHERE Contact__c = :con.Id LIMIT 1];
            Test.setCreatedDate(log.Id, System.now());

            Test.startTest();
            ErrorHelper.sendServiceNowRequestEmail(con.Id, log.Id, null);
            ErrorHelper.sendServiceNowRequestEmail(con.Id, log.Id, null, 'Test Subject');
            Test.stopTest();

        }
    }

    //    @isTest
//    public static void test_createErrorLog() {
//        Contact con = [SELECT Id FROM Contact LIMIT 1];
//
//        Test.startTest();
//        ErrorHelper.createServiceNowError(con.Id, 'Test Message', 'TEST STACK TRACE');
//        Test.stopTest();
//
//        AACR_Error_Log__c log = [SELECT Id FROM AACR_Error_Log__c WHERE Contact__c = :con.Id LIMIT 1];
//        System.assertNotEquals(null, log);
//
//    }
}