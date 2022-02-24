/**
 * Created by lauren.lezberg on 12/15/2020.
 */

@IsTest
private class PaymentBillingAddressControllerTest {

    @TestSetup
    public static void setup(){
        Account acc = TestDataFactory.buildAccount('Test Account');
        insert acc;
        Contact testContact = TestDataFactory.buildContactMemberCurrent(acc.Id);
        insert testContact;
        User u = TestDataFactory.buildUser(testContact.Id);
        insert u;
    }


    @IsTest
    static void test_getBillingAddressInfo() {
        COntact con = [SELECT Id FROM Contact WHERE Account.Name='Test Account'];

        Test.startTest();

        PaymentBillingAddressController.BillingAddressInfo bai = PaymentBillingAddressController.getBillingAddressInfo(con.Id);
        System.assertEquals(null, bai.billingAddress);
        System.assert(bai.countryList.keySet().size()>0, 'Country map should not be empty');

        OrderApi__Known_Address__c billingAddress = new OrderApi__Known_Address__c(Type__c='Billing', OrderApi__Contact__c=con.Id, OrderApi__Street__c='123 Main St', OrderApi__City__c='TEST', OrderApi__Province__c='PA', OrderApi__Country__c='United States');
        insert billingAddress;

        bai = PaymentBillingAddressController.getBillingAddressInfo(con.Id);
        System.assertNotEquals(null, bai.billingAddress);
        System.assert(bai.countryList.keySet().size()>0, 'Country map should not be empty');
        
        Test.stopTest();
    }
}