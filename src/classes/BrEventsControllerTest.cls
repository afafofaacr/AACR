@IsTest
private class BrEventsControllerTest {

    @IsTest
    public static void test_constructor(){
        insert new BrEvents_Settings__c(Name='default zone id', Value__c='1234566');

        Test.startTest();

        BrEventsController ctrl = new BrEventsController();
        System.assert(ctrl.zoneId!=null);

        Test.stopTest();
    }

    @isTest
    public static void testGetUserInfo() {
        Map<String, String> uInf = BrEventsController.getUserInfo();

        System.assertEquals(true, String.isNotEmpty(uInf.get('Id')), 'Id property is empty');
        System.assertEquals(true, String.isNotEmpty(uInf.get('Name')), 'Name property is empty');
        System.assertEquals(true, String.isNotEmpty(uInf.get('Username')), 'Username property is empty');
        System.assertEquals(true, String.isNotEmpty(uInf.get('Email')), 'Email property is empty');
        System.assertEquals(true, String.isNotEmpty(uInf.get('Type')), 'Type property is empty');
    }
}