@IsTest
public class ContactApplicationStatusTriggerTest {
    @IsTest static void TestApplicationStatus(){
         Id nonmember = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Nonmember').getRecordTypeId();
 		Id member = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Member').getRecordTypeId();
        List<Contact> conList = new List<Contact>();
         Contact contact1 = new Contact();
        contact1.LastName = 'Test 1';
        contact1.MailingCountry = 'United States';
        contact1.MailingCity = 'Boston';
        contact1.MailingPostalCode = '12121';
        contact1.MailingStreet = 'abc Test';
        contact1.recordtypeid = nonmember;
     	conList.add(contact1);
        insert conList;
        test.startTest();
        Contact contact = [Select id from Contact Limit 1];
        contact_last_accessed_step__c contactlast = new contact_last_accessed_step__c();
        contactlast.Contact__c = contact.id;
        contactlast.Step_Order__c = 3;
        insert contactlast;
        contact_last_accessed_step__c contactstep = [select id,Step_Order__c from contact_last_accessed_step__c limit 1];
        contactstep.Step_Order__c = 6;
        update contactstep;
        
        test.stopTest();
       
    }
}