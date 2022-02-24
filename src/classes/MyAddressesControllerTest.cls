/**
 * Created by lauren.lezberg on 9/18/2020.
 */
@IsTest
private with sharing class MyAddressesControllerTest {

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
    public static void test_constructor(){
        Contact con = [SELECT Id FROM Contact WHERE Account.Name = 'Test Account'];
        User u = [SELECT Id FROM User WHERE ContactId=:con.Id];

        System.runAs(u){
            Test.startTest();

            MyAddressesController ctrl = new MyAddressesController();

            Test.stopTest();

            System.assertEquals(con.Id, ctrl.contactId);

        }
    }

    @IsTest
    public static void test_updateBusinessAddress(){
        Contact con = [SELECT Id FROM Contact WHERE Account.Name = 'Test Account'];

        OrderApi__Known_Address__c ka = new OrderApi__Known_Address__c(
                Type__c= 'Business',
                Bad_Address__c = false,
                OrderApi__Is_Default__c = true,
                OrderApi__Contact__c = con.Id,
                OrderApi__Street__c = '123 Main St',
                OrderApi__City__c = 'Test',
                OrderApi__Country__c = 'United States',
                OrderApi__Province__c = 'California',
                OrderApi__Postal_Code__c = '12345'
        );
        insert ka;

        Account householdAcc = TestDataFactory.buildAccount('Test Household');
        insert householdAcc;

        Account validAcc = TestDataFactory.buildAccount('Test Valid Acc');
        validAcc.BillingStreet = '43 Coolidge Ave';
        validAcc.BillingCity = 'Needham';
        validAcc.BillingState = 'Massachusetts';
        validAcc.BillingCountry = 'United States';
        validAcc.BillingPostalCode = '02492';
        insert validAcc;

        Test.startTest();
        Boolean resp = MyAddressesController.updateBusinessAddress(con.Id, householdAcc.Id);
        ka = [SELECT OrderApi__Street__c, OrderApi__City__c, OrderApi__Province__c, OrderApi__Postal_Code__c FROM OrderApi__Known_Address__c WHERE Id=:ka.Id];

        System.assertEquals(false, resp);
        System.assertEquals(ka.OrderApi__Street__c, '123 Main St');
        System.assertEquals(ka.OrderApi__City__c, 'Test');
        System.assertEquals(ka.OrderApi__Province__c, 'California');
        System.assertEquals(ka.OrderApi__Postal_Code__c, '12345');


        resp = MyAddressesController.updateBusinessAddress(con.Id, validAcc.Id);
        ka = [SELECT OrderApi__Street__c, OrderApi__City__c, OrderApi__Province__c, OrderApi__Postal_Code__c FROM OrderApi__Known_Address__c WHERE Id=:ka.Id];

        System.assertEquals(true, resp);
        System.assertEquals(ka.OrderApi__Street__c, '43 Coolidge Ave');
        System.assertEquals(ka.OrderApi__City__c, 'Needham');
        System.assertEquals(ka.OrderApi__Province__c, 'Massachusetts');
        System.assertEquals(ka.OrderApi__Postal_Code__c, '02492');

        Test.stopTest();
    }

    @IsTest
    public static void test_getAddresses(){
        Account acc = [SELECT Id FROM Account WHERE NAme='Test Account'];
        acc.BillingStreet = '43 Coolidge Ave';
        acc.BillingCity = 'Needham';
        acc.BillingState = 'Massachusetts';
        acc.BillingCountry = 'United States';
        acc.BillingPostalCode = '02492';
        update acc;

        Contact con = [SELECT Id FROM Contact WHERE AccountId=:acc.Id];

        Test.startTest();

        MyAddressesController.MyAddressesDTO addresses = MyAddressesController.getAddresses(con.Id, acc.Id);
        List<OrderApi__Known_Address__c> ka = [SELECT Id FROM OrderApi__Known_Address__c WHERE OrderApi__Contact__c=:con.Id];
        System.assertEquals(addresses.addresses.size(), ka.size());

        addresses = MyAddressesController.getAddresses(con.Id, acc.Id);
        ka = [SELECT Id FROM OrderApi__Known_Address__c WHERE OrderApi__Contact__c=:con.Id];
        System.assertEquals(addresses.addresses.size(), ka.size());

        Test.stopTest();


    }

    @IsTest
    public static void test_getPlaceId(){
        Contact con = [SELECT Id FROM Contact WHERE Account.Name = 'Test Account'];

        OrderApi__Known_Address__c ka = new OrderApi__Known_Address__c(
                Type__c= 'Personal',
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

        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());

        String placeId = MyAddressesController.getPlaceId(ka.Id);
        System.assertNotEquals(null, placeId);

        Test.stopTest();
    }

    @IsTest
    public static void test_getAddress(){
        Contact con = [SELECT Id FROM Contact WHERE Account.Name = 'Test Account'];

        OrderApi__Known_Address__c ka = new OrderApi__Known_Address__c(
                Type__c= 'Personal',
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

        OrderApi__Known_Address__c address = MyAddressesController.getAddress(ka.Id);
        System.assertEquals(address.Id, ka.Id);

        OrderApi__Known_Address__c ka2 = new OrderApi__Known_Address__c(
                Type__c= 'Business',
                Bad_Address__c = false,
                OrderApi__Is_Default__c = false,
                OrderApi__Contact__c = con.Id,
                OrderApi__Street__c = '123 Main St',
                OrderApi__City__c = 'Test',
                OrderApi__Country__c = 'United States',
                OrderApi__Province__c = 'Massachusetts',
                OrderApi__Postal_Code__c = '12345'
        );
        insert ka2;

        MyAddressesController.updateDefault(ka2.Id, con.Id);
        ka2 = [SELECT OrderApi__Is_Default__c FROM OrderApi__Known_Address__c WHERE Id=:ka2.Id];
        System.assertEquals(true, ka2.OrderApi__Is_Default__c);

        MyAddressesController.deleteKnownAddress(ka.Id);
        List<OrderApi__Known_Address__c> kas = [SELECT OrderApi__Street__c, OrderApi__City__c, OrderApi__Province__c, OrderApi__Postal_Code__c FROM OrderApi__Known_Address__c WHERE Id=:ka.Id];
        System.assertEquals(true, kas.isEmpty());

        Test.stopTest();
    }

    @IsTest
    public static void test_getStates(){
        Contact con = [SELECT Id FROM Contact WHERE Account.Name = 'Test Account'];
        User u = [SELECT Id FROM User WHERE ContactId=:con.Id];

        Map<String, String> stateMap = new Map<String, String>();

        System.runAs(u) {
            Test.startTest();

            stateMap = MyAddressesController.getStates('US');
            System.assertEquals(false, stateMap.isEmpty());

            Test.stopTest();
        }
    }

    public class MockHTTPResponseGenerator implements HttpCalloutMock{
        public HTTPResponse respond(HTTPRequest req) {
            if(req.getEndpoint().contains('https://maps.googleapis.com/maps/api/place/findplacefromtext')){
                HttpResponse res = new HttpResponse();
                res.setHeader('Content-Type', 'application/json');
                res.setBody('{"placeId":"123456"}');
                res.setStatusCode(200);
                return res;
            }

            return null;
        }
    }

}