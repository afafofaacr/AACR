/**
 * Created by lauren.lezberg on 3/28/2019.
 */
@isTest
private with sharing class CustomLookupControllerTest {
 

    @isTest
    static void testFetchLookupValues(){
        Account a = TestDataFactory.buildAccount('Test Account');
        insert a;

        Test.startTest();
        List<sObject> accts = CustomLookupController.fetchLookUpValues('Test', 'Account',null);
        Test.stopTest();

        System.assertEquals(1, accts.size());
    }


    @isTest
    static void testGetInitialValue(){
        Account a = TestDataFactory.buildAccount('Test Account');
        insert a;

        Test.startTest();
        sObject initialAcct = CustomLookupController.getInitialValue('Account', a.Id);
        Test.stopTest();

        System.assertNotEquals(null, initialAcct);

    }

    @isTest
    static void testCreateNewRecord(){

        Test.startTest();
        String newRec = CustomLookupController.createNewRecord('Account', 'Test Account', 'Unapproved Account');
        Test.stopTest();

        System.assertNotEquals('', newRec);
        System.assertNotEquals(null, newRec);
    }
}