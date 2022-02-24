@IsTest
public class CopyContactToClipboardCtrlTest {

      @isTest static void createContactTest()
      {

          Account acc = TestDataFactory.buildAccount('TEST Account');
          insert acc;

          Contact con = TestDataFactory.buildContactMemberPrior(acc.Id);
          con.Salutation = 'Dr.';
          con.FirstName = 'Test';
          con.Nickname__c = 'Testy';
          con.Degrees_Held__c ='BA';
          con.Title = 'testing title';
          con.MailingStreet = '1234 Testing Street';
          con.MailingCity = 'Philadelphia';
          con.MailingCountryCode = 'US';
          con.MailingStateCode = 'PA';
          con.MailingPostalCode = '19106';
          con.OrderApi__Work_Phone__c='0987654321';
          con.HomePhone='9886776676';
          con.MobilePhone= '21213231';
          con.OtherStreet = '1234 Testing Street';
          con.OtherCity = 'Philadelphia';
          con.OtherCountryCode = 'US';
          con.OtherStateCode = 'PA';
          con.OtherPostalCode = '19106';
          con.Journal_Street__c = '1234 Testing Street';
          con.Journal_City__c = 'Philadelphia';
          con.Journal_Country__c = 'United States';
          con.Journal_State_Province__c = 'PA';
          con.Journal_Zip_Postal_Code__c = '19106';
          con.OrderApi__Preferred_Email_Type__c = 'Work';
          insert con;

          Contact assist = TestDataFactory.buildContactMemberPrior(acc.Id);
          assist.Salutation = 'Miss.';
          assist.FirstName = 'Assistant';
          assist.Email = 'assistant.test@yopmail.com';
          assist.HomePhone='9886776676';
          assist.MobilePhone= '21213231';
          assist.OrderApi__Work_Phone__c='0987654321';
          assist.OrderApi__Preferred_Email_Type__c = 'Work';
          insert assist;

          npe4__Relationship__c r = new npe4__Relationship__c();
          r.npe4__RelatedContact__c = con.Id;
          r.npe4__Contact__c = assist.Id;
          r.npe4__Type__c = 'Assistant';
          r.npe4__Status__c = 'Current';
          insert r;

          test.startTest();

          CopyContactToClipboardCtrl.getContactData([SELECT Id from Contact LIMIT 1].Id);

          test.stopTest();
      }

}