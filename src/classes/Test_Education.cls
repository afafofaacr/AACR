@isTest
private class Test_Education {
   @isTest static void TestInsertEducation() {
        // Test data setup
        // Create an education record
        Contact con = new Contact(FirstName='Test', LastName='Contact');
        insert con;
        
        Education__c edu = new Education__c(Name='Test',Education_Related_to_Contact__c=con.Id);
        // Perform test
        Test.startTest();
        Database.SaveResult result = Database.insert(edu, false);
        Test.stopTest();
        // Verify 
        System.assert(result.isSuccess());
        System.assert(result.getErrors().size() == 0);
    }
    
 	@isTest static void TestEducation() {
        List<Education__c> eduList = new List<Education__c>();
        Education eduClass = new Education(eduList);
    }
  
	@isTest static void TestFramework() {
        List<Education__c> eduList = new List<Education__c>();
               
    	Education.Constructor cons = new Education.Constructor();
        cons.construct(eduList);
    }
    
}