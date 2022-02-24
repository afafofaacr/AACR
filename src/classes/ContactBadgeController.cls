public class ContactBadgeController {
   //set up the extension
    public Contact con;
    public ContactBadgeController(ApexPages.StandardController stdController) {
        this.con = (Contact)stdController.getRecord();
    }
    
    //get list of active badges for contacts
    public List<Badge_Setting__c> getBadges() {
         Badge_Setting__c[] conbadges = [SELECT Id, Object__c, Criteria__c, Sort_Order__c, Image__c, Description__c
                                     FROM Badge_Setting__c
                                     WHERE Active__c = TRUE AND Object__c = 'Contact' ORDER BY Sort_Order__c ASC ];
    
    //set up list for badges for this contact
    List<Badge_Setting__c> activebadges = new List<Badge_Setting__c>();    
    
    //loop through badges list to query contacts that meet criteria and assign them to a list
    for(Badge_Setting__c b : conbadges) {
        string contactid = con.id;
        string query = 'SELECT Id FROM Contact WHERE Id = :contactid AND ' + b.Criteria__c;
        System.debug('>>>>>>>>> Query: ' + query);
        List<sObject> conlist = Database.query(query);
        
    //check if current contact is included in list of contacts meeting the criteria for badge     
        for(sObject thiscontact : conlist) {
            if(thiscontact.id == con.id){
                activebadges.add(b);
            } 
        }   

            }
    return activebadges;
    }
}