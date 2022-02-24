/**
 * Created by lauren.lezberg on 12/13/2018.
 */
@isTest
private class AuraHelperTest {

    @isTest (seeAllData=true)
    private static void test_getRecordTypes(){
        Test.startTest();
        List<RecordType> types = AuraHelper.getRecordTypes('Contact');
        Test.stopTest();

        System.assert(types.size()>1, 'Should be at least one record type');
    }



//    @isTest (seeAllData=true)
//    private static void test_getSiteConfigs(){
//        Test.startTest();
//        List<Maintenance_Mode_Config__mdt> configs = AuraHelper.getSiteConfigs();
//        Test.stopTest();
//
//        System.assert(configs.size()>1, 'Should be at least one configuration');
//    }
//
//    @isTest
//    private static void test_saveMdtConfig(){
//        Maintenance_Mode_Config__mdt record = new Maintenance_Mode_Config__mdt();
//        record.Label = 'Test Config';
//        record.Maintenance_Message__c = 'Test Message';
//        record.Page_API_Name__c = 'Test_Page';
//        record.Description__c = 'Test DESCRIPTION';
//
//        Test.startTest();
//        AuraHelper.saveMdtConfig(record);
//        Test.stopTest();
//
//    }
}