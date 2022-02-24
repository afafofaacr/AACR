@isTest
public class UpateUserEmailAndUsernameTest {
    static Boolean isInstalled = false;
    
    private static void install() {
        Fon_PackageScripts.testInstall();  
    }
    
    @isTest
    public static void updateContactEmail(){
        install();
        
        User thisUser = [select Id from User where Id = :UserInfo.getUserId() ];
        
        System.runAs(thisUser) {
            
            Account acc = new Account(Name='Test Account');
            insert acc;
            
           Contact con = new Contact(
            AccountId = acc.Id,
            LastName = 'Duck',
            FirstName = 'Daisy',
            Salutation = 'Ms.',
            MiddleName = 'The',
            
            OtherCity = 'Arlington',
            OtherState = 'Alaska',
            OtherPostalCode = '22203',
            OtherCountry = 'United States',
            OtherStateCode = 'AK',
            OtherCountryCode = 'US',
            
            MailingCity = 'city',
            
            Email = 'daisy11@mailinator.com',
            Title = 'Queen Duck',
            Department = 'Aquatics',
            Birthdate = Date.newInstance(2000,02,15),      
            HasOptedOutOfEmail = false,
            HasOptedOutOfFax = false,
            DoNotCall = false,
            OrderApi__Assistant_Do_Not_Call__c = false,
            OrderApi__Assistant_Email_Opt_Out__c = false,
            OrderApi__Home_Do_Not_Call__c = false,
            OrderApi__Mobile_Do_Not_Call__c = false,
            OrderApi__Other_Do_Not_Call__c = false,
            OrderApi__Other_Email_Opt_Out__c = false,
            OrderApi__Personal_Email_Opt_Out__c = false,
            OrderApi__Personal_Email__c = 'daisy11@mailinator.com',
            OrderApi__Preferred_Email_Type__c = 'Personal',
            OrderApi__Preferred_Phone_Type__c = 'Work',
            OrderApi__Sync_Address_Billing__c = false,
            OrderApi__Sync_Address_Shipping__c = false,
            OrderApi__Sync_Email__c = false,
            OrderApi__Sync_Phone__c = false,
            OrderApi__Work_Do_Not_Call__c = false,
            OrderApi__Work_Email_Opt_Out__c = false,
            OrderApi__Work_Email__c = 'daisywork@mailinator.com',
            OrderApi__Work_Phone__c = '5559990987',
            DonorApi__Active_Recurring_Gift__c = false,
            DonorApi__Auto_Calculate_Contact_Greetings__c = false,
            DonorApi__Auto_Calculate_Current_Ask_Amount__c = false,
            DonorApi__Deceased__c = false,
            DonorApi__Default_Greeting_Type__c = 'Personal Greeting',
            DonorApi__Direct_Mail_Opt_Out__c = false,
            DonorApi__Do_Not_Solicit__c = false,
            DonorApi__Gift_Opportunities__c = 0.0,
            DonorApi__Gifts_Outstanding__c = 0.0,
            DonorApi__Gifts_Received__c = 0.0,
            DonorApi__Include_in_Household_Greetings__c = false,
            DonorApi__Last_Gift_Amount__c = 0.0,
            DonorApi__Primary__c = false,
            DonorApi__Suffix__c = 'II'
            );
        
           
           /* Contact con = new Contact(FirstName = 'John', LastName = 'Smith', Email='test@fusionspan.com',
                                      OrderApi__Personal_Email__c =  'test@fusionspan.com', OrderApi__Preferred_Email_Type__c = 'Personal',
                                      AccountID=acc.Id
                                     );
            */
            insert con;
            System.debug('1. Con pe is:'+ con.OrderApi__Preferred_Email__c);
            
            Profile[] prf = [select Id from Profile where Name = 'Fonteva Customer Community Login User'];
            
            User usr = new User(Alias = 'testfs', Email='daisy11@mailinator.com', 
                                EmailEncodingKey='UTF-8', FirstName='Test', LastName='User', LanguageLocaleKey='en_US', 
                                LocaleSidKey='en_US', ProfileId = prf[0].Id, 
                                TimeZoneSidKey='America/New_York ', UserName='daisy11@mailinator.com',ContactId = con.Id);
            insert usr;

            con.OrderApi__Personal_Email__c = 'newtestemail@fusionspan.com';
            System.Test.startTest();
            update con;
            System.debug('2. Con pe is:'+ con.OrderApi__Preferred_Email__c);
            System.Test.stopTest();
            
            //usr = [select Email, Username from User where Id = :usr.Id];
           
        }
        
    }
}