trigger EducationTrigger on Education__c (before insert, before update, before delete,
                                   after insert, after update, after delete) {
    Framework.Dispatcher.dispatchTrigger();
}