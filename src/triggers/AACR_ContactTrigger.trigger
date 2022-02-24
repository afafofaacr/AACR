/**
 * Created by afaf.awad on 11/13/2020.
 */

trigger AACR_ContactTrigger on Contact (before insert, before update) {

    System.debug('AACRContactTrigger...');
    Set<Id> accountIds = new Set<Id>();
    List<Contact> updateIncomeLevel = new List<Contact>();
    List<Contact> updateEventSegment = new List<Contact>();
    for (Contact con : Trigger.new) {
        accountIds.add(con.AccountId);
        if (!con.Manual_Segment_Override__c) {
            updateIncomeLevel.add(con);
        }else{
            updateEventSegment.add(con);
//                    EventSegmentHelper.buildSegmentCode(con); //skip auto update of Income Level. Just set the Event Segment.
        }
    }
    Map<Id, Account> accMap = new Map<Id,Account>([SELECT Id, Institution_Type__c, NPO__c FROM Account WHERE Id IN: accountIds]);

    if (!updateIncomeLevel.isEmpty()) {
        WorldBankIntegration.updateIncomeLevelOnContact(updateIncomeLevel, accMap);
    }

    if(!updateEventSegment.isEmpty()){
        for(Contact con : updateEventSegment){
            con.Event_Segment__c = EventSegmentHelper.buildSegmentCode(con, accMap);
        }
    }
    

    /** EMAIL VALIDATION **/
//    if (Trigger.new.size() == 1) {
//        try {
//            Boolean validWorkEmail = BriteVerifyHelper.verifyEmail(Trigger.new[0].OrderApi__Work_Email__c);
//            if(!validWorkEmail){
//                Trigger.new[0].addError('Work email is not valid.');
//            }
//        } catch (Exception e) {
//            Trigger.new[0].addError(e.getMessage());
//        }
//
//
//    }
}