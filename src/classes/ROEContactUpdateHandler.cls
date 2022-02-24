/**
 * Created by lauren.lezberg on 12/13/2018.
 */

public with sharing class ROEContactUpdateHandler {

    public static void updateContactToMember(Id contactId, Date paidThruDate){
        List<Contact> toUpdate = [SELECT Id, Paid_thru_date__c, RecordTypeId, Membership_Status__c, RecordType.Name, Prior_Member_Status__c FROM Contact WHERE Id =: contactId];
        List<RecordType> rType = [SELECT Id FROM RecordType WHERE SobjectType = 'Contact' AND Name='Member'];

        for(Contact c: toUpdate){
            if(c.RecordType.Name == 'Prior Member') {
                System.debug('contact is prior member');
                c.RecordTypeId = rType[0].Id;
                if(paidThruDate==null){
                    //if member only catches up to current year with dues only purchase
                    if(c.Membership_Status__c == '1-YR Suspended'){
                        c.Paid_thru_date__c = c.Paid_thru_date__c.addYears(1);
                    }
                    if(c.Membership_Status__c == '2-YR Suspended'){
                        c.Paid_thru_date__c = c.Paid_thru_date__c.addYears(2);
                    }
                } else {
                    c.Paid_thru_date__c = paidThruDate;
                }
                c.Prior_Member_Status__c = c.Membership_Status__c;
                c.Membership_Status__c = 'Current';
            } else {
                c.Paid_thru_date__c = paidThruDate;
                c.Prior_Member_Status__c = c.Membership_Status__c;
                c.Membership_Status__c = 'Current';
            }
        }
        System.debug('contact: ' + toUpdate);
        try {
            update toUpdate;
        } catch(Exception e){
            System.debug('cannot update contacts '+ e.getMessage());
        }
    }


//    public static void updateContactToMember(Id contactId, Boolean setPaidThruDate){
//        List<Contact> toUpdate = [SELECT Id, Paid_thru_date__c, RecordTypeId, Membership_Status__c, RecordType.Name, Prior_Member_Status__c FROM Contact WHERE Id =: contactId];
//        List<RecordType> rType = [SELECT Id FROM RecordType WHERE SobjectType = 'Contact' AND Name='Member'];
//
//        for(Contact c: toUpdate){
//            if(c.RecordType.Name == 'Prior Member') {
//                System.debug('contact is prior member');
//                c.RecordTypeId = rType[0].Id;
//                if(setPaidThruDate){
//                    if(c.Membership_Status__c == '1-YR Suspended'){
//                        c.Paid_thru_date__c = c.Paid_thru_date__c.addYears(1);
//                    }
//                    if(c.Membership_Status__c == '2-YR Suspended'){
//                        c.Paid_thru_date__c = c.Paid_thru_date__c.addYears(2);
//                    }
//                }
//                c.Prior_Member_Status__c = c.Membership_Status__c;
//                c.Membership_Status__c = 'Current';
//            }
//        }
//        System.debug('contact: ' + toUpdate);
//        try {
//            update toUpdate;
//        } catch(Exception e){
//            System.debug('cannot update contacts '+ e.getMessage());
//        }
//    }

}