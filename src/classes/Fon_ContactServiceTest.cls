@isTest
public class Fon_ContactServiceTest {

    static testMethod void saveKnownAddressTest() {
        
        List<Contact> conList = new List<Contact>();
        Contact contact1 = new Contact();
        contact1.LastName = 'Test 1';
        contact1.MailingCountry = 'Austria';
        contact1.MailingCity = 'test';
        contact1.MailingPostalCode = '12121';
        contact1.MailingStreet = 'abc Test';
        contact1.Preferred_Address__c = 'Business';
        conList.add(contact1);
        
//        Contact contact2 = new Contact();
//        contact2.LastName = 'Test 2';
//        contact2.MailingCountry = 'United States';
//        contact2.MailingCity = 'SF';
//        contact2.MailingPostalCode = '12121';
//        contact2.MailingStreet = 'abc Test';
//        contact2.Preferred_Address__c = 'Business';
//        conList.add(contact2);

//        Contact contact3 = new Contact();
//        contact3.LastName = 'Test 3';
//        contact3.OtherCountry = 'United States';
//        contact3.OtherState ='California';
//        contact3.OtherCity = 'SF';
//        contact3.OtherPostalCode = '12121';
//        contact3.OtherStreet = 'abc Test';
//        contact3.Preferred_Address__c = 'Home';
//        conList.add(contact3);
//
//        Contact contact4 = new Contact();
//        contact4.LastName = 'Test 4';
//        contact4.OtherCountry = 'United States';
//        contact4.OtherCity = 'SF';
//        contact4.OtherPostalCode = '12121';
//        contact4.OtherStreet = 'abc Test';
//        contact4.Preferred_Address__c = 'Home';
//        conList.add(contact4);

        insert conList;
        Fon_contactTrigger conTrigger = new Fon_contactTrigger(conList);
        conTrigger.afterInsert();
        conTrigger.beforeInsert();
        Fon_ContactService.runOnce();
        Fon_ContactService.saveKnownAddress(conList);
    }
    static testMethod void updateKnownAddressTest() {
        
        List<Contact> conList = new List<Contact>();
        List<Contact> conUpdateList = new List<Contact>();
        Contact contact1 = new Contact();
        contact1.LastName = 'Test 1';
        contact1.MailingCountry = 'Canada';
        contact1.MailingCity = '';
        contact1.MailingState = 'Quebec';
        contact1.MailingPostalCode = '12121';
        contact1.MailingStreet = 'abc Test';
        contact1.Preferred_Address__c = 'Business';
        conList.add(contact1);
        insert conList;
         OrderApi__Known_Address__c knownAddress = new OrderApi__Known_Address__c();
        knownAddress.OrderApi__Contact__c = contact1.id;
        knownAddress.OrderApi__Name__c = contact1.LastName;
        knownAddress.OrderApi__Is_Default__c = true;
        knownAddress.OrderApi__Country__c = contact1.MailingCountry;
        knownAddress.OrderApi__City__c = contact1.MailingCity;
        knownAddress.OrderApi__Postal_Code__c = contact1.MailingPostalCode;
        knownAddress.OrderApi__Street__c = contact1.MailingStreet;
        insert knownAddress;
        Map<Id,Contact> conMap = new Map<Id,Contact>([Select Id,LastName, MailingCountry, MailingCity, MailingPostalCode, MailingStreet from Contact where Id In: conList]);
        Contact c = [Select Id,LastName, MailingCountry, MailingCity, MailingPostalCode, MailingStreet from Contact limit 1];
        c.MailingPostalCode = '324223';
        contact1.MailingCountry = 'United States';
        contact1.MailingState = 'California';
        conUpdateList.add(c);
        update conUpdateList;
        Fon_contactTrigger conTrigger = new Fon_contactTrigger(conList);
        conTrigger.afterUpdate(conMap);
        conTrigger.beforeUpdate(conMap);
        Fon_ContactService.updateKnownAddress(conUpdateList, conMap);
    }
     static testMethod void updateKnownAddressTest1() {
        
        List<Contact> conList = new List<Contact>();
        List<Contact> conUpdateList = new List<Contact>();
        Contact contact1 = new Contact();
        contact1.LastName = 'Test 1';
        contact1.OtherCountry = 'India';
        contact1.OtherCity = 'test';
        contact1.OtherPostalCode = '12121';
        contact1.OtherStreet = 'abc Test';
         contact1.Preferred_Address__c = 'Home';
        conList.add(contact1);
        insert conList;
         OrderApi__Known_Address__c knownAddress = new OrderApi__Known_Address__c();
        knownAddress.OrderApi__Contact__c = contact1.id;
        knownAddress.OrderApi__Name__c = contact1.LastName;
        knownAddress.OrderApi__Is_Default__c = true;
        knownAddress.OrderApi__Country__c = contact1.OtherCountry;
        knownAddress.OrderApi__City__c = contact1.OtherCity;
        knownAddress.OrderApi__Postal_Code__c = contact1.OtherPostalCode;
        knownAddress.OrderApi__Street__c = contact1.OtherStreet;
        insert knownAddress;
        Map<Id,Contact> conMap = new Map<Id,Contact>([Select Id,LastName, OtherCountry, OtherCity, OtherPostalCode, OtherStreet from Contact where Id In: conList]);
        Contact c = [Select Id,LastName, OtherCountry, OtherCity, OtherPostalCode, OtherStreet from Contact limit 1];
        c.OtherPostalCode = '324223';
         contact1.OtherCountry = 'Austria';
        conUpdateList.add(c);
        update conUpdateList;
        Fon_contactTrigger conTrigger = new Fon_contactTrigger(conList);
        conTrigger.afterUpdate(conMap);
        conTrigger.beforeUpdate(conMap);
        Fon_ContactService.updateKnownAddress(conUpdateList, conMap);
    }
    static testMethod void updateKnownAddressTest2() {
        
        List<Contact> conList = new List<Contact>();
        List<Contact> conUpdateList = new List<Contact>();
        Contact contact1 = new Contact();
        contact1.LastName = 'Test 1';
        contact1.MailingCountry = 'India';
        contact1.MailingCity = 'test';
        contact1.MailingPostalCode = '12121';
        contact1.MailingStreet = 'abc Test';
        contact1.Preferred_Address__c = 'Business';
        conList.add(contact1);
        insert conList;
         OrderApi__Known_Address__c knownAddress = new OrderApi__Known_Address__c();
        knownAddress.OrderApi__Contact__c = contact1.id;
        knownAddress.OrderApi__Name__c = contact1.LastName;
        knownAddress.OrderApi__Is_Default__c = true;
        knownAddress.OrderApi__Country__c = contact1.MailingCountry;
        knownAddress.OrderApi__City__c = contact1.MailingCity;
        knownAddress.OrderApi__Postal_Code__c = contact1.MailingPostalCode;
        knownAddress.OrderApi__Street__c = contact1.MailingStreet;
        insert knownAddress;
        Map<Id,Contact> conMap = new Map<Id,Contact>([Select Id,LastName, MailingCountry, MailingCity, MailingPostalCode, MailingStreet from Contact where Id In: conList]);
        Contact c = [Select Id,LastName, MailingCountry, MailingCity, MailingPostalCode, MailingStreet from Contact limit 1];
        c.MailingPostalCode = '324223';
         contact1.MailingCountry = 'Austria';
        conUpdateList.add(c);
        update conUpdateList;
        Fon_contactTrigger conTrigger = new Fon_contactTrigger(conList);
        conTrigger.afterUpdate(conMap);
        conTrigger.beforeUpdate(conMap);
        Fon_ContactService.updateKnownAddress(conUpdateList, conMap);
    }
    static testMethod void updateKnownAddressTest3() {

        List<Contact> conList = new List<Contact>();
        List<Contact> conUpdateList = new List<Contact>();
        Contact contact1 = new Contact();
        contact1.LastName = 'Test 1';
        contact1.OtherCountry = 'United States';
        contact1.OtherState='Pennsylvania';
        contact1.OtherCity = 'test';
        contact1.OtherPostalCode = '12121';
        contact1.OtherStreet = 'abc Test';
        contact1.Preferred_Address__c = 'Home';
        conList.add(contact1);
        insert conList;
        OrderApi__Known_Address__c knownAddress = new OrderApi__Known_Address__c();
        knownAddress.OrderApi__Contact__c = contact1.id;
        knownAddress.OrderApi__Name__c = contact1.LastName;
        knownAddress.OrderApi__Is_Default__c = true;
        knownAddress.OrderApi__Country__c = contact1.OtherCountry;
        knownAddress.OrderApi__City__c = contact1.OtherCity;
        knownAddress.OrderApi__Postal_Code__c = contact1.OtherPostalCode;
        knownAddress.OrderApi__Street__c = contact1.OtherStreet;
        insert knownAddress;
        Map<Id,Contact> conMap = new Map<Id,Contact>([Select Id,LastName, OtherCountry, OtherCity, OtherPostalCode, OtherStreet from Contact where Id In: conList]);
        Contact c = [Select Id,LastName, OtherCountry, OtherCity, OtherPostalCode, OtherStreet from Contact limit 1];
        c.OtherPostalCode = '324223';
        contact1.OtherState = 'California';
        conUpdateList.add(c);
        update conUpdateList;
        Fon_contactTrigger conTrigger = new Fon_contactTrigger(conList);
        conTrigger.afterUpdate(conMap);
        conTrigger.beforeUpdate(conMap);
        Fon_ContactService.updateKnownAddress(conUpdateList, conMap);
    }
    static testMethod void updateKnownAddressTest4() {

        List<Contact> conList = new List<Contact>();
        List<Contact> conUpdateList = new List<Contact>();
        Contact contact1 = new Contact();
        contact1.LastName = 'Test 1';
        contact1.MailingCountry = 'United States';
        contact1.MailingCity = 'Boston';
        contact1.MailingState = 'Massachusetts';
        contact1.MailingPostalCode = '12121';
        contact1.MailingStreet = 'abc Test';
        contact1.Preferred_Address__c = 'Business';
        conList.add(contact1);
        insert conList;
        OrderApi__Known_Address__c knownAddress = new OrderApi__Known_Address__c();
        knownAddress.OrderApi__Contact__c = contact1.id;
        knownAddress.OrderApi__Name__c = contact1.LastName;
        knownAddress.OrderApi__Is_Default__c = true;
        knownAddress.OrderApi__Country__c = contact1.MailingCountry;
        knownAddress.OrderApi__City__c = contact1.MailingCity;
        knownAddress.OrderApi__Postal_Code__c = contact1.MailingPostalCode;
        knownAddress.OrderApi__Street__c = contact1.MailingStreet;
        insert knownAddress;
        Map<Id,Contact> conMap = new Map<Id,Contact>([Select Id,LastName, MailingCountry, MailingCity, MailingPostalCode, MailingStreet from Contact where Id In: conList]);
        Contact c = [Select Id,LastName, MailingCountry, MailingCity, MailingPostalCode, MailingStreet from Contact limit 1];
        c.MailingPostalCode = '324223';
        contact1.MailingState = 'California';
        conUpdateList.add(c);
        update conUpdateList;
        Fon_contactTrigger conTrigger = new Fon_contactTrigger(conList);
        conTrigger.afterUpdate(conMap);
        conTrigger.beforeUpdate(conMap);
        Fon_ContactService.updateKnownAddress(conUpdateList, conMap);
    }
}