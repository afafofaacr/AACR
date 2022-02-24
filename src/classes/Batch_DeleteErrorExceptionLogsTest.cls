/**
 * Created by lauren.lezberg on 7/1/2020.
 */
@isTest
private with sharing class Batch_DeleteErrorExceptionLogsTest {

    @testSetup
    public static void setup(){
        Account acc = TestDataFactory.buildAccount('Test Account');
        insert acc;

        Contact con = TestDataFactory.buildContact(acc.Id);
        insert con;

        Datetime logCutoffDate = Datetime.newInstance(Date.today().year(), Date.today().month() - 7, Date.today().day());
        List<AACR_Error_Log__c> logs = new List<AACR_Error_Log__c>();

        Id recordTypeId = [SELECT Id FROM RecordType
                WHERE DeveloperName = 'Error_Exception' AND sObjectType = 'AACR_Error_Log__c'].Id;

        for(Integer i = 0; i<200; i++){
            AACR_Error_Log__c log = new AACR_Error_Log__c();
            log.RecordTypeId = recordTypeId;
            log.Contact__c = con.Id;
            log.Incident_Type__c = 'TEST';
            logs.add(log);
        }

        insert logs;

        for(AACR_Error_Log__c log : logs){
            Test.setCreatedDate(log.Id, logCutoffDate);
        }

    }


    @isTest
    public static void test_BatchDelete(){
        Test.startTest();


        database.executeBatch(new Batch_DeleteErrorExceptionLogs());

        Test.stopTest();
    }
}