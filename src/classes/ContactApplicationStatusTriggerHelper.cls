public class ContactApplicationStatusTriggerHelper {

    public static void setContactApplicationStatus(List<contact_last_accessed_step__c> contactLastAccessedList){
        contact_last_accessed_step__c contact=contactLastAccessedList[0];
		Contact updatecontact= [select id, Application_Status__c from Contact where id = :contact.Contact__c];
         if(contact.Step_Order__c  > 1 && contact.Step_Order__c  < =6){
            updatecontact.Application_Status__c = 'Incomplete Application';
        	}
        update updatecontact;
    }
}