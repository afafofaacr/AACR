/**
 * Created by lauren.lezberg on 7/1/2020.
 */
@isTest
private with sharing class AACRCustomExceptionTest {

    @isTest
    public static void testException(){
        Account acc = TestDataFactory.buildAccount('Test Account');
        insert acc;

        String testCategory = 'TEST CATEGORY';
        String errorMsg = 'TEST ERROR';
        String details = 'TEST DETAILS';


        Test.startTest();

        AACRCustomException e = new AACRCustomException(acc.Id, errorMsg, details, testCategory);

        e = new AACRCustomException(errorMsg, details, testCategory);

        System.assertEquals(2, [SELECT COUNT() FROM AACR_Error_Log__c]);

        Test.stopTest();
    }

}