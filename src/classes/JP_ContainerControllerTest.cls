/**
 * Created by lauren.lezberg on 12/17/2020.
 */

@IsTest
private class JP_ContainerControllerTest {
    public static String AccountName = 'Test Account';
    public static String SourceCodeName = 'BOGO';
    public static String OfferVersionName = SourceCodeName + ' ' + System.today().month() + System.today().year() + '.' + (Math.random() * 10000);
    public static String OVSOQLString = 'SELECT Id, ContactId FROM User WHERE IsActive = true AND ContactId IN (SELECT Id FROM Contact WHERE Member_Type__c=\'Active Member\' AND Membership_Status__c=\'Current\') LIMIT 10';
    public static String OfferMembersipName = OfferVersionName + '.' + (Math.random() * 10000);

    @TestSetup
    public static void setup(){
        Account acc = TestDataFactory.buildAccount('Test Account');
        insert acc;

        Contact con = TestDataFactory.buildContact(acc.Id);
        insert con;

        User u = TestDataFactory.buildUser(con.Id);
        insert u;

    }

    @IsTest
    static void test_applyOffer() {
        Contact con = [SELECT Id FROM Contact WHERE Account.Name = 'Test Account'];
        User u = [SELECT Id FROM User WHERE ContactId=:con.Id];

        OrderApi__Source_Code__c sourceCode = TestDataFactory.buildSourceCode('TEST');
        insert sourceCode;

        Offer__c o = new Offer__c(
                SourceCode__c = sourceCode.Id,
                Prefix__c = 'BOGO'
        );
        insert o;

        OfferVersion__c ov = new OfferVersion__c(
                StartDate__c = Date.today(),
                EndDate__c = Date.today().addDays(7),
                Offer__c = o.Id,
                Publish__c = true,
                Override__c = false,
                SOQLQuery__c = OVSOQLString
        );
        insert ov;

        OfferMembership__c om = new OfferMembership__c(
                Contact__c = con.Id,
                Offer__c = o.Id,
                OfferVersion__c = ov.Id,
                Used__c = false
        );
        insert om;

        Join_Process__mdt jp = [SELECT Id FROM Join_Process__mdt LIMIT 1];
        contact_last_accessed_step__c las = new contact_last_accessed_step__c(Step_Order__c = 1, JoinId__c = jp.Id, Contact__c = con.Id);
        insert las;

        SYstem.runAs(u) {
            Test.startTest();

            JP_ContainerController.ContainerInfo cInfo = JP_ContainerController.applyOffer(sourceCode.Id, null, om.Id, 'URL', jp.Id);
            System.assertEquals(false, cInfo.refresh);
            System.assertNotEquals(null, cInfo.salesOrderId);

            las.Step_Order__c = 2;
            update las;

            cInfo = JP_ContainerController.applyOffer(sourceCode.Id, cInfo.salesOrderId, om.Id, 'URL', jp.Id);
            System.assertEquals(true, cInfo.refresh);
            System.assertNotEquals(null, cInfo.salesOrderId);

        }

    }


    @IsTest
    static void test_startOrder() {
        Contact con = [SELECT Id FROM Contact WHERE Account.Name = 'Test Account'];
        User u = [SELECT Id FROM User WHERE ContactId=:con.Id];

        Join_Process__mdt jp = [SELECT Id FROM Join_Process__mdt LIMIT 1];

        contact_last_accessed_step__c las = new contact_last_accessed_step__c(Step_Order__c = 1, JoinId__c = jp.Id, Contact__c = con.Id);
        insert las;

        SYstem.runAs(u) {
            Test.startTest();

            JP_ContainerController.ContainerInfo cInfo = JP_ContainerController.startOrder(jp.Id);
            System.assertEquals(false, cInfo.refresh);
            System.assertNotEquals(null, cInfo.salesOrderId);

            las.Step_Order__c = 2;
            update las;

            cInfo = JP_ContainerController.startOrder(jp.Id);
            System.assertEquals(true, cInfo.refresh);
            System.assertNotEquals(null, cInfo.salesOrderId);

            Test.stopTest();
        }
    }
}