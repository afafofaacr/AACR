@isTest
private class Test_Committees {
   @isTest static void TestInsertCommittee() {
        // Test data setup
        // Create a committee
        Contact con = new Contact(FirstName='Test', LastName='Contact');
        insert con;
        
        Committees__c comm = new Committees__c(Name='Test Committee',Committees__c=con.Id);
        // Perform test
        Test.startTest();
        Database.SaveResult result = Database.insert(comm, false);
        Test.stopTest();
        // Verify 
        System.assert(result.isSuccess());
        System.assert(result.getErrors().size() == 0);
    }
    
 	@isTest static void TestCommittees() {
        List<Committees__c> commList = new List<Committees__c>();
        Committees comClass = new Committees(commList);
    }
  
	@isTest static void TestFramework() {
        List<Committees__c> commList = new List<Committees__c>();
               
    	Committees.Constructor cons = new Committees.Constructor();
        cons.construct(commList);
    }

}