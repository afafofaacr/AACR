@isTest
private class UpateSSOEmailTest {
    static Boolean isInstalled = false;
    
    private static void install() {
        Fon_PackageScripts.testInstall();  
    }
    
    @isTest
    private static void updateEmail(){
        install();
        
        User thisUser = [select Id from User where Id = :UserInfo.getUserId() ];
        
        System.runAs(thisUser) {
            
            Account acc = new Account(Name='Test Account');
            insert acc;
            
           Contact con = new Contact(
            AccountId = acc.Id,
            LastName = 'Contact',
            FirstName = 'Test'
            );
 
            insert con;
            System.debug('Contact created id=' + con.Id);
           
            Profile[] prf = [select Id from Profile where Name = 'Fonteva Customer Community Login User'];
            
            User usr = new User(Alias = 'testusr', Email='testcontact@mailinator.com', 
                                EmailEncodingKey='UTF-8', FirstName='Test', LastName='Contact', LanguageLocaleKey='en_US', 
                                LocaleSidKey='en_US', ProfileId = prf[0].Id, 
                                TimeZoneSidKey='America/New_York ', UserName='testcontact@mailinator.com',ContactId = con.Id);
            insert usr;
            System.debug('User created id=' + usr.Id + 'Contact Id = ' + usr.ContactId);

           
            //Check user data
            User checkUsr = [SELECT SSO_Email__c FROM USER WHERE username= 'testcontact@mailinator.com' LIMIT 1];
            system.assertEquals(checkUsr.SSO_Email__c, 'testcontact@mailinator.com');
            
        }
        
    }
}