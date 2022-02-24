/**
 * Created by afaf.awad on 11/4/2020.
 */

@IsTest
private class BadAddressControllerTest {

    @TestSetup
    public static void setup() {

        Account acc = TestDataFactory.buildAccount('Test Account');
        insert acc;

        Contact con = TestDataFactory.buildContact(acc.Id);
        con.FirstName = 'Zono';
        insert con;

        OrderApi__Known_Address__c  ka = new OrderApi__Known_Address__c();
        ka.OrderApi__Street__c = '742 Evergreen Terrace';
        ka.OrderApi__City__c = 'Springfield';
        ka.OrderApi__Province__c = 'Ohio';
        ka.OrderApi__Country__c ='United States';
        ka.Type__c = 'Other';
        ka.OrderApi__Contact__c = con.Id;
        insert ka;

//        //Insert duplicate Account
//        Database.DMLOptions dml = new Database.DMLOptions();
//        dml.DuplicateRuleHeader.allowSave = true;
//        Contact conDup = TestDataFactory.buildContact(acc.Id);
//        conDup.email = 'testEmail2@yopmail.com';
//        insert conDup;

    }
    @IsTest
    static void test_getContactInfo() {

        String con = [SELECT Id FROM Contact LIMIT 1].Id;
        Test.startTest();
        BadAddressController.ContactWrapper conWrap = BadAddressController.getContactInfo(con);
        Test.stopTest();
        System.assertEquals(false, conWrap.duplicate);
    }

    @IsTest
    static void test_saveBadAddress(){
        Contact con = [SELECT Id, Bad_Other_Address__c, Bad_Journal_Address__c, Bad_Mailing_Address__c FROM Contact LIMIT 1];

        List<String> kaIds = new List<String>();
        List<OrderApi__Known_Address__c> knownAddresses = [SELECT Id FROM OrderApi__Known_Address__c WHERE OrderApi__Contact__c =: con.Id];
        for(OrderApi__Known_Address__c ka : knownAddresses){
            kaIds.add(ka.Id);
        }

        String[] auditList = new List<String>();
        Bad_Address_Audit__c audit = new Bad_Address_Audit__c(Contact__c = con.Id,
                                                                Return_Sender_Reason__c = 'Other (please enter into Other Return)',
                                                                Other_Reason__c = 'Testing reason',
                                                                Address_Type__c = 'Other',
                                                                Known_Address__c = knownAddresses[0].Id);
        System.debug('audit: ' + audit);
        auditList.add(JSON.serialize(audit));


        Test.startTest();
        BadAddressController.saveBadAddress(auditList, JSON.serialize(kaIds));
        Test.stopTest();

        List<Bad_Address_Audit__c> auditPostTest = [SELECT Id FROM Bad_Address_Audit__c];

        System.assertEquals(1, auditPostTest.size());
    }

    @IsTest
    static void test_saveBadAddress_Error(){
        Contact con = [SELECT Id, Bad_Other_Address__c, Bad_Journal_Address__c, Bad_Mailing_Address__c FROM Contact LIMIT 1];

        List<String> kaIds = new List<String>();
        List<OrderApi__Known_Address__c> knownAddresses = [SELECT Id FROM OrderApi__Known_Address__c WHERE OrderApi__Contact__c =: con.Id];
        for(OrderApi__Known_Address__c ka : knownAddresses){
            kaIds.add(ka.Id);
        }

        String[] auditList = new List<String>();
        Bad_Address_Audit__c audit = new Bad_Address_Audit__c(
                Return_Sender_Reason__c = 'Other (please enter into Other Return)',
                Other_Reason__c = 'Testing reason',
                Address_Type__c = 'Other',
                Known_Address__c = knownAddresses[0].Id);
        System.debug('audit: ' + audit);
        auditList.add(JSON.serialize(audit));


        Test.startTest();
        Boolean isSuccess = BadAddressController.saveBadAddress(auditList, JSON.serialize(kaIds));
        Test.stopTest();

        //System.assertEquals(false, isSuccess);
    }

}