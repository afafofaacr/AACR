public class AccountBadgeController {
    
    //set up the extension
    public Account acct;
    public AccountBadgeController(ApexPages.StandardController stdController) {
        this.acct = (Account)stdController.getRecord();  
       
    }
    
    
    //get list of active badges for accounts
    public List<Badge_Setting__c> getBadges() {
         Badge_Setting__c[] acctbadges = [SELECT Id, Object__c, Criteria__c, Sort_Order__c, Image__c, Description__c
                                     FROM Badge_Setting__c
                                     WHERE Active__c = TRUE AND Object__c = 'Account' ORDER BY Sort_Order__c ASC ];
    
    //set up list for badges for this account
    List<Badge_Setting__c> activebadges = new List<Badge_Setting__c>();    
    
    //loop through badges list to query accounts that meet criteria and assign them to a list
    for(Badge_Setting__c b : acctbadges) {
        string accountid = acct.id;
        string query = 'SELECT Id FROM Account WHERE Id = :accountid AND ' + b.Criteria__c;
        System.debug('>>>>>>>>> Query: ' + query);
        List<sObject> acctlist = Database.query(query);
        
    //check if current account is included in list of accounts meeting the criteria for badge 
        for(sObject thisaccount : acctlist) {
            if(thisaccount.id == acct.id){
                activebadges.add(b);
            } 
        }   

            }
            return activebadges;
        }

    }