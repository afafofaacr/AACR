/**
 * Created by lauren.lezberg on 9/17/2020.
 */
@IsTest
private with sharing class UpdateContactMailingAddressTriggerTest {


    @TestSetup
    public static void setup(){
        Account acc = TestDataFactory.buildAccount('Test Account');
        insert acc;

        Contact con = TestDataFactory.buildContact(acc.Id);
        insert con;

    }

    @IsTest
    public static void test_updateBillingAddress(){
        Contact con = [SELECT Id, MailingStreet, MailingState, MailingCountry, MailingCity, MailingPostalCode FROM Contact WHERE Account.Name = 'Test Account'];

        OrderApi__Known_Address__c ka = new OrderApi__Known_Address__c(
                OrderApi__Name__c = 'TEST',
                Type__c= 'Business',
                OrderApi__Is_Default__c = true,
                OrderApi__Contact__c = con.Id,
                OrderApi__Street__c = '123 Main St',
                OrderApi__City__c = 'Test',
                OrderApi__Country__c = 'United States',
                OrderApi__Province__c = 'California',
                OrderApi__Postal_Code__c = '12345'
        );

        Test.startTest();

        insert ka;

        Test.stopTest();

        ka = [SELECT OrderApi__Name__c, Type__c FROM OrderApi__Known_Address__c WHERE Id=:ka.Id];

        System.assertEquals('Other', ka.Type__c);
        System.assertEquals('Billing Address', ka.OrderApi__Name__c);
    }

    @IsTest
    public static void test_nonDefaultKnownAddress(){
        Contact con = [SELECT Id, MailingStreet, MailingState, MailingCountry, MailingCity, MailingPostalCode FROM Contact WHERE Account.Name = 'Test Account'];
        List<OrderApi__Known_Address__c> kas = new List<OrderApi__Known_Address__c>();
        Test.startTest();

        OrderApi__Known_Address__c ka = new OrderApi__Known_Address__c(
                Type__c= 'Business',
                OrderApi__Is_Default__c = true,
                OrderApi__Contact__c = con.Id,
                OrderApi__Street__c = '123 Main St',
                OrderApi__City__c = 'Test',
                OrderApi__Country__c = 'United States',
                OrderApi__Province__c = 'California',
                OrderApi__Postal_Code__c = '12345'
        );
        kas.add(ka);

        OrderApi__Known_Address__c ka2 = new OrderApi__Known_Address__c(
                Type__c= 'Personal',
                OrderApi__Is_Default__c = false,
                OrderApi__Contact__c = con.Id,
                OrderApi__Street__c = '456 Main St',
                OrderApi__City__c = 'Test2',
                OrderApi__Country__c = 'Canada',
                OrderApi__Province__c = 'Quebec',
                OrderApi__Postal_Code__c = '67890'
        );
        kas.add(ka2);

        insert kas;

        Test.stopTest();

        con = [SELECT Id, MailingStreet, MailingState, MailingCountry, MailingCity, MailingPostalCode FROM Contact WHERE Id=:con.Id];

        System.assertEquals(ka.OrderApi__Street__c, con.MailingStreet);
        System.assertEquals(ka.OrderApi__City__c, con.MailingCity);
        System.assertEquals(ka.OrderApi__Province__c, con.MailingState);
        System.assertEquals(ka.OrderApi__Country__c, con.MailingCountry);
        System.assertEquals(ka.OrderApi__Postal_Code__c, con.MailingPostalCode);

        System.assertNotEquals(ka2.OrderApi__Street__c, con.MailingStreet);
        System.assertNotEquals(ka2.OrderApi__City__c, con.MailingCity);
        System.assertNotEquals(ka2.OrderApi__Province__c, con.MailingState);
        System.assertNotEquals(ka2.OrderApi__Country__c, con.MailingCountry);
        System.assertNotEquals(ka2.OrderApi__Postal_Code__c, con.MailingPostalCode);

    }

    @IsTest
    public static void test_newKnownAddress(){
        Contact con = [SELECT Id, MailingStreet, MailingState, MailingCountry, MailingCity, MailingPostalCode FROM Contact WHERE Account.Name = 'Test Account'];

        OrderApi__Known_Address__c ka = new OrderApi__Known_Address__c(
                Type__c= 'Business',
                OrderApi__Is_Default__c = true,
                OrderApi__Contact__c = con.Id,
                OrderApi__Street__c = '123 Main St',
                OrderApi__City__c = 'Test',
                OrderApi__Country__c = 'United States',
                OrderApi__Province__c = 'California',
                OrderApi__Postal_Code__c = '12345'
        );

        Test.startTest();

        insert ka;

        Test.stopTest();

        con = [SELECT Id, MailingStreet, MailingState, MailingCountry, MailingCity, MailingPostalCode FROM Contact WHERE Id=:con.Id];

        System.assertEquals(ka.OrderApi__Street__c, con.MailingStreet);
        System.assertEquals(ka.OrderApi__City__c, con.MailingCity);
        System.assertEquals(ka.OrderApi__Province__c, con.MailingState);
        System.assertEquals(ka.OrderApi__Country__c, con.MailingCountry);
        System.assertEquals(ka.OrderApi__Postal_Code__c, con.MailingPostalCode);

    }

    @IsTest
    public static void test_newJournalAddress(){
        Contact con = [SELECT Id, Journal_Street__c, Journal_City__c, Journal_State_Province__c, Journal_Country__c, Journal_Zip_Postal_Code__c FROM Contact WHERE Account.Name = 'Test Account'];

        OrderApi__Known_Address__c ka = new OrderApi__Known_Address__c(
                Type__c= 'Journal',
                OrderApi__Is_Default__c = false,
                OrderApi__Contact__c = con.Id,
                OrderApi__Street__c = '123 Main St',
                OrderApi__City__c = 'Test',
                OrderApi__Country__c = 'United States',
                OrderApi__Province__c = 'California',
                OrderApi__Postal_Code__c = '12345'
        );

        Test.startTest();

        insert ka;

        Test.stopTest();

        con = [SELECT Id, Journal_Street__c, Journal_City__c, Journal_State_Province__c, Journal_Country__c, Journal_Zip_Postal_Code__c FROM Contact WHERE Id=:con.Id];

        System.assertEquals(ka.OrderApi__Street__c, con.Journal_Street__c);
        System.assertEquals(ka.OrderApi__City__c, con.Journal_City__c);
        System.assertEquals(ka.OrderApi__Province__c, con.Journal_State_Province__c);
        System.assertEquals(ka.OrderApi__Country__c, con.Journal_Country__c);
        System.assertEquals(ka.OrderApi__Postal_Code__c, con.Journal_Zip_Postal_Code__c);

    }

    @IsTest
    public static void test_updateReturnedAddress(){
        Contact con = [SELECT Id, MailingStreet, MailingState, MailingCountry, MailingCity, MailingPostalCode FROM Contact WHERE Account.Name = 'Test Account'];

        OrderApi__Known_Address__c ka = new OrderApi__Known_Address__c(
                OrderApi__Name__c = 'TEST',
                Type__c= 'Business',
                OrderApi__Is_Default__c = true,
                OrderApi__Contact__c = con.Id,
                OrderApi__Street__c = '123 Main St',
                OrderApi__City__c = 'Test',
                OrderApi__Country__c = 'United States',
                OrderApi__Province__c = 'California',
                OrderApi__Postal_Code__c = '12345',
                Bad_Address__c = True
        );
        insert ka;
        Test.startTest();

        ka.OrderApi__Street__c = '456 New Main Street';
        update ka;

        Test.stopTest();

        ka = [SELECT OrderApi__Name__c, Bad_Address__c FROM OrderApi__Known_Address__c WHERE Id=:ka.Id];

        System.assertEquals(false, ka.Bad_Address__c);
    }

}