trigger CMETrigger on CME__c (before insert, before update, before delete,
                                   after insert, after update, after delete) {
    Framework.Dispatcher.dispatchTrigger();
}