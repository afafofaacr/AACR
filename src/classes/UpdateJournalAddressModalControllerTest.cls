/**
 * Created by lauren.lezberg on 9/18/2020.
 */

@IsTest
private class UpdateJournalAddressModalControllerTest {

    @TestSetup
    public static void setup(){
        Account acc = TestDataFactory.buildAccount('Test Account');
        insert acc;

        Contact con = TestDataFactory.buildContact(acc.Id);
        insert con;

    }


    @IsTest
    static void test_getAndSaveJournalAddress() {
        Contact con = [SELECT Id FROM Contact WHERE Account.Name='Test Account'];

        OrderApi__Known_Address__c ka = new OrderApi__Known_Address__c(
                Type__c= 'Business',
                Bad_Address__c = false,
                OrderApi__Is_Default__c = true,
                OrderApi__Contact__c = con.Id,
                OrderApi__Street__c = '43 Coolidge Ave',
                OrderApi__City__c = 'Needham',
                OrderApi__Country__c = 'United States',
                OrderApi__Province__c = 'Massachusetts',
                OrderApi__Postal_Code__c = '02492'
        );
        insert ka;

        Test.startTest();

        //run code to copy primary into journal
        UpdateJournalAddressModalController.JournalAddressInfo jAddress = UpdateJournalAddressModalController.getJournalAddress(con.Id);
        System.assertEquals(jAddress.journalAddress.OrderApi__Street__c, ka.OrderApi__Street__c);

        jAddress.journalAddress.OrderApi__Street__c = '123 Main St';
        jAddress.journalAddress.OrderApi__City__c = 'Test';
        UpdateJournalAddressModalController.saveJournalAddress(jAddress.journalAddress);
        jAddress.journalAddress = [SELECT Id, OrderApi__Street__c, OrderApi__City__c FROM OrderApi__Known_Address__c WHERE OrderApi__Contact__c =: con.Id AND Type__c = 'Journal'];
        System.assertEquals('123 Main St', jAddress.journalAddress.OrderApi__Street__c );
        System.assertEquals('Test', jAddress.journalAddress.OrderApi__City__c);

        //run code with journal address
        jAddress = UpdateJournalAddressModalController.getJournalAddress(con.Id);
        System.assertEquals(jAddress.journalAddress.OrderApi__Street__c, '123 Main St');



        Test.stopTest();
    }
    
}