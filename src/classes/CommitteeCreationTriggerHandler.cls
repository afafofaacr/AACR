/**
 * Created by lauren.lezberg on 7/22/2019.
 */

public without sharing class CommitteeCreationTriggerHandler {

    public static void createCommittees(Id salesOrderId, Id contactId){
        System.debug('createCommittees just called with salesOrderId: ' + salesOrderId + ' and contactId: ' + contactId);

        List<OrderApi__Sales_Order_Line__c> lines = [
                SELECT Id, OrderApi__Sales_Order__r.OrderApi__Contact__c, OrderApi__Sales_Order__c, OrderApi__Item_Class__r.Name, OrderApi__Item__r.Name
                FROM OrderApi__Sales_Order_Line__c
                WHERE OrderApi__Sales_Order__c = :salesOrderId AND OrderApi__Item_Class__r.Name = 'Working Groups'
                ORDER BY OrderApi__Sales_Order__c
        ];

        if(lines.size()>0) {

            //get all committee records for contact
            List<Committee_Member__c> committeeMembers = [SELECT Id, End_Date__c, Committee_Name__r.Name FROM Committee_Member__c WHERE Committee_Member__c = :contactId AND (End_Date__c = null OR End_Date__c > TODAY)];
            System.debug('committee member records: ' + committeeMembers);
            if (committeeMembers.size() > 0) {

                Set<String> oldCommitteeNames = new Set<String>();
                for (Committee_Member__c com : committeeMembers) {
                    oldCommitteeNames.add(com.Committee_Name__r.Name);
                }
                System.debug('oldCommmitteeNames: ' + oldCommitteeNames);

                List<String> committeesToAdd = new List<String>();
                for(OrderApi__Sales_Order_Line__c line : lines){
                    if(!oldCommitteeNames.contains(line.OrderApi__Item__r.Name)){
                        committeesToAdd.add(line.OrderApi__Item__r.Name);
                    }
                }
                System.debug('committeesToAdd: ' + committeesToAdd);

            //if there are committee records to add
            List<Committee_Member__c> membershipsToAdd = new List<Committee_Member__c>();
                if(committeesToAdd.size()>0) {
                    List<Committee__c> committees = [SELECT Id, Type__c FROM Committee__c WHERE Name IN:committeesToAdd];
                    System.debug('found committees: ' + committees);

                    if (committees.size() > 0) {
                        for (Committee__c committee : committees) {
                            Committee_Member__c member = new Committee_Member__c();
                            member.Committee_Name__c = committee.Id;
                            member.Committee_Type__c = committee.Type__c;
                            member.Committee_Member__c = contactId;
                            member.Member_Role__c = 'Member';
                            member.Start_Date__c = Date.today();
                            membershipsToAdd.add(member);
                        }
                    }
                }
                System.debug('membershipsToAdd: ' + membershipsToAdd);

                //deselected committee member record update
                Set<String> newCommitteeNames = new Set<String>();
                for (OrderApi__Sales_Order_Line__c line : lines) {
                    newCommitteeNames.add(line.OrderApi__Item__r.Name);
                }
                System.debug('newCommitteeNames: ' + newCommitteeNames);

            List<Committee_Member__c> recordsToUpdate = new List<Committee_Member__c>();
                if(newCommitteeNames.size()>0) {
                    for (Committee_Member__c mem : committeeMembers) {
                        if (!newCommitteeNames.contains(mem.Committee_Name__r.Name)) {
                            //update end date of committee member record
                            mem.End_Date__c = Date.today();
                            recordsToUpdate.add(mem);
                        }
                    }
                }
                System.debug('recordsToUpdate: ' + recordsToUpdate);

                insert membershipsToAdd;
                update recordsToUpdate;

            } else {
                System.debug('no committee member records found...adding committee member records...');
                List<String> committeesToAdd = new List<String>();
                for(OrderApi__Sales_Order_Line__c line : lines){
                    committeesToAdd.add(line.OrderApi__Item__r.Name);
                }

                List<Committee_Member__c> membershipsToAdd = new List<Committee_Member__c>();
                if(committeesToAdd.size()>0) {
                    List<Committee__c> committees = [SELECT Id, Type__c FROM Committee__c WHERE Name IN:committeesToAdd];
                    System.debug('found committees: ' + committees);

                    if (committees.size() > 0) {
                        for (Committee__c committee : committees) {
                            Committee_Member__c member = new Committee_Member__c();
                            member.Committee_Name__c = committee.Id;
                            member.Committee_Type__c = committee.Type__c;
                            member.Committee_Member__c = contactId;
                            member.Member_Role__c = 'Member';
                            member.Start_Date__c = Date.today();
                            membershipsToAdd.add(member);
                        }
                    }
                }

                System.debug('membershipsToAdd: ' + membershipsToAdd);
                insert membershipsToAdd;
            }
        }
    }

}