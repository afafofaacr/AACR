/**
 * Test class for brRecaptchaCtrl class
 */
@IsTest
private class BrRecaptchaCtrlTest {
    /**
     * Test method gets domain
     */
    @IsTest
    static void testGetDomain() {
        Test.startTest();

        String domain = BrRecaptchaCtrl.getDomain();
        System.assertEquals(false, String.isBlank(domain), 'wrong domain');

        Test.stopTest();
    }

    /**
     * Test method gets site key for recaptcha
     */
    @IsTest
    static void testGetSiteKey() {
        BrEvents_Settings__c brSetting = new BrEvents_Settings__c(Name='recaptcha_key', Value__c='1234567890');
        insert brSetting;

        Test.startTest();

        String key = BrRecaptchaCtrl.getSiteKey();

        Test.stopTest();

        System.assertEquals('1234', key, 'wrong recaptcha site key');
    }
}