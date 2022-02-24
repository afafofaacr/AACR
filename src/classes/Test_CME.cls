@isTest
private class Test_CME {
   @isTest static void TestInsertCME() {
        // Test data setup
        // Create an CME record
        Contact con = new Contact(FirstName='Test', LastName='Contact');
        insert con;

        CME__c cme = new CME__c(Name='Test',Contact__c=con.Id, Awarded_Date__c=system.today(), CME_Hours__c=1,CME_Type__c='Physician',RecordtypeId= Schema.SObjectType.CME__c.getRecordTypeInfosByName().get('Manuscript Review').getRecordTypeId());
        // Perform test
        Test.startTest();
        Database.SaveResult result = Database.insert(cme, false);
        Test.stopTest();
        // Verify 
        System.assert(result.isSuccess());
        System.assert(result.getErrors().size() == 0);
    }
    
 	@isTest static void TestEducation() {
        List<CME__c> cmeList = new List<CME__c>();
        CME cmeClass = new CME(cmeList);
    }
  
	@isTest static void TestFramework() {
        List<CME__c> eduList = new List<CME__c>();
               
    	CME.Constructor cons = new CME.Constructor();
        cons.construct(eduList);
    }
    
}