/**
    @ PURPOSE : 1. Update Member Type of Contact as per Subscription 
    @ AUTHER  : (Nilesh K.)
*/
global class ContactSubscriptionBatch implements Database.Batchable<sObject>{
    
    /**
     *@purpose   : Build the query and reurns record to execute function.
     *@param     : -
     *@return    : -
     */
    global Database.QueryLocator start(Database.BatchableContext BC){
        
        String query = 'Select id, Member_Type__c, '+ 
                            '(SELECT OrderApi__Item__r.Name '+ 
                            'FROM OrderApi__Subscriptions__r '+ 
                            'WHERE OrderApi__Item_Class__r.Name IN (\'Individual Memberships\', \'Legacy Membership\' , \'Lifetime Membership\') '+
                            'ORDER BY CreatedDate DESC NULLS LAST) '+ 
                        'FROM Contact '+
                        'WHERE (Member_Type__c = null '+ 
                            'AND RecordType.Name = \'Member\' )';
        System.debug('Query ::: '+query);
        return Database.getQueryLocator(query);
    }
    
    /**
     *@purpose   : Get Records and Update Member type of Contact.
     *@param     : -
     *@return    : -
     */
    global void execute(Database.BatchableContext BC, List<Contact> scope){
        
        List<Contact> contactTobeUpdate = new List<Contact>();
        // Fetch All contacts
        for(Contact contact : scope){
            System.debug('contact ::: '+contact);
            
            // Check Subscription is present in Contact record.
            if(contact.OrderApi__Subscriptions__r != null ){
                System.debug('Subscriptions not Null ::: '+Contact.OrderApi__Subscriptions__r);
                
                // Fetch All Subscription
                for(OrderApi__Subscription__c subsription : contact.OrderApi__Subscriptions__r){

                    // Set Member Type to C
                    String memberType = subsription.OrderApi__Item__r.Name.replace('Membership','Member');
                    memberType = memberType.replace('(REN)','');
                    if(String.isBlank(contact.Member_Type__c)){
                        System.debug('memberType ::: '+memberType.trim());        
                        contact.Member_Type__c = memberType;
                        contactTobeUpdate.add(contact);
                    }

                    break;
                }
            }
        }
        
        // Check if List is not empty
        System.debug('contactTobeUpdate ::: '+contactTobeUpdate);
        if(!contactTobeUpdate.isEmpty()){
            
            // Upsert Contact.
            Database.SaveResult[] updateSRList = Database.update(contactTobeUpdate, false);
            System.debug('updateSRList ::: '+updateSRList);
            Set<String> contactIdSet = new Set<String>();
            
            // Fetch Failed Contact and add To list 
            for (integer i=0;i < contactTobeUpdate.size();i++) {
                Database.SaveResult result = updateSRList[i];
                if (!result.isSuccess()) {
                   contactIdSet.add(contactTobeUpdate[i].Id+' :: '+result.errors);
                 
                }
            }
           
            // Make doccument of Id - Errors.
            if(!contactIdSet.isEmpty() || Test.isRunningTest()){
                List<String> contactIdList = new List<String>();
                contactIdList.addAll(contactIdSet);
                System.debug('contactIdList ::: '+contactIdList);
                Folder folder = [select id from Folder where name ='Failed to Update Contact' LIMIT 1];
                
                Document doc = new Document(); 
                doc.Name = 'Batch v2 ::: '+DateTime.now(); 
                doc.Body = Blob.valueOf(string.join(contactIdList,','));
                doc.folderId = folder.Id;
                doc.ContentType = 'text/plain';
                doc.Type = 'txt';
                insert doc;
                System.debug('doc ::: '+doc);
            }
        }
    }
    

    global void finish(Database.BatchableContext BC){
    }
}