/**
 * Created by lauren.lezberg on 2/21/2020.
 */
@isTest
private with sharing class FS_SelectorControllerTest {

    @isTest
    public static void test_getFieldSets(){

        Test.startTest();

        Map<String, String> fSets = FS_SelectorController.getFieldSets('BR_Participation__c');

        Test.stopTest();

        System.assertNotEquals(null, fSets);
    }

    @isTest
    public static void test_getFieldsInFieldset(){

        Test.startTest();
        Map<String, String> fSets = FS_SelectorController.getFieldSets('BR_Participation__c');

        for(String key : fSets.keySet()){
            List<String> fieldList = FS_SelectorController.getFieldsInFieldset('BR_Participation__c', fSets.get(key));
            System.assertNotEquals(null, fieldList);
        }

        Test.stopTest();

    }
}