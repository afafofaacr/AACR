trigger UpdateSSOEmail on User (before insert) {
    for(User u : Trigger.New) {
        u.SSO_Email__c   = u.Username;
    } 
}