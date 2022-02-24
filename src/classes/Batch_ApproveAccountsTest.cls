/**
 * Created by afaf.awad on 4/14/2021.
 */
@IsTest
public with sharing class Batch_ApproveAccountsTest {

    @TestSetup
    public static void setup() {

        RecordType recordType = [SELECT Id FROM RecordType WHERE SobjectType = 'Account' AND Name = 'Unfiled'];

        List<Account> accounts = new List<Account>();
        for (Integer i = 0; i < 100; i++) {
            Account acc = LiveTestDataFactory.buildAccount('Test Account' + i);
            acc.DNBoptimizer__DNB_D_U_N_S_Number__c = '123test' + i;
            acc.RecordTypeId = recordType.Id;
            accounts.add(acc);
        }
        insert accounts;

    }


    @isTest
    public static void test_Schedule() {

        System.debug('accounts in test method: ' + [SELECT Id FROM Account WHERE RecordType.Name = 'Unfiled'].size());
        String CRON_EXP = '0 0 0 15 3 ? 2025';

        Test.startTest();
        String jobId = System.schedule('ScheduledApexTest',
                CRON_EXP,
                new Batch_ApproveAccountsScheduler());
        Test.stopTest();


    }

}