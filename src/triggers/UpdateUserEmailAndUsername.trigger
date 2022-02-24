trigger UpdateUserEmailAndUsername on Contact (after update) {
    static boolean first=true;
    /*System.Debug('$$$ From Contact 1: '+ userSynchUtil.SynchStart);
    if(userSynchUtil.SynchStart==null){
        userSynchUtil.SynchStart = 'From Contact';
        System.Debug('$$$ From Contact 2: '+ userSynchUtil.SynchStart);*/
        Map<Id, Contact> contactsUpdated = new Map<Id,Contact>();
        List<Id> contactIds = new List<Id>();
        List<String> contactEmails = new List<String>();
        Map<Id, Contact> conflictingContact = new Map<Id,Contact>();
        
        for(Contact currContact : Trigger.New) {
            if(Trigger.oldMap.get(currContact.Id) == null || Trigger.oldMap.get(currContact.Id).OrderApi__Preferred_Email__c == null) {
                continue;
            }
          if(! (Trigger.oldMap.get(currContact.Id).OrderApi__Preferred_Email__c.equals(currContact.OrderApi__Preferred_Email__c)) ) {
            contactIds.add(currContact.Id);
            contactsUpdated.put(currContact.Id, currContact);
            contactEmails.add(currContact.OrderApi__Preferred_Email__c);
          }
        }
        
        if(contactIds.size() == 0) {
            return; //there are not contacts with changed emails
        }
        
        List<User> userConflicts = [select Id, ContactId, Email, UserName from User where ((Email in :contactEmails  and isActive = true) or UserName in :contactEmails)];
        Set<String> conflictingEmailsContacts = new Set<String>();
        Set<String> conflictingUserNamesContacts = new Set<String>();
        
        for(User conflictingUser : userConflicts) {
            conflictingEmailsContacts.add(conflictingUser.Email);
            conflictingUserNamesContacts.add(conflictingUser.Email);
        }
        
        for(Contact currContact : contactsUpdated.values()) {
            if(conflictingEmailsContacts.contains(currContact.OrderApi__Preferred_Email__c)
                || conflictingUserNamesContacts.contains(currContact.OrderApi__Preferred_Email__c)){
                conflictingContact.put(currContact.Id,currContact);
            }
        }
        
        //update users now
        List<User> usersToUpdate = [select Id, Email, Username, ContactId, Bad_Email_Address__c from User where ContactId In :contactIds];
        
        for(User currUser : usersToUpdate) {
            Contact toTest = contactsUpdated.get(currUser.ContactId);
            if( toTest == null) {
                continue;
            }
            String newEmail = toTest.OrderApi__Preferred_Email__c;
            String newUN = '';
            if (conflictingContact.containsKey(toTest.Id)) {
                newUN = toTest.OrderApi__Preferred_Email__c + '.myaacr';
            } else {
                newUN = toTest.OrderApi__Preferred_Email__c;
            }
            if(newEmail == null) {
                continue;
            }
            
          currUser.Email = newEmail;
            if(currUser.Bad_Email_Address__c){
                currUser.Bad_Email_Address__c = false;
            }
          currUser.Username = newUN;
        }
        if(usersToUpdate.size() > 0) {
          System.enqueueJob(new UpateUserEmailAndUsernameQueueable(usersToUpdate));
        }
        first=false;
        
    //}
    
}