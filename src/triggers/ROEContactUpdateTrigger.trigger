/**
 * Created by lauren.lezberg on 12/13/2018.
 */

trigger ROEContactUpdateTrigger on OrderApi__Sales_Order__c (after update) {

//    if(Trigger.new.size() == 1 && Trigger.new[0].OrderApi__Posting_Status__c == 'Posted'){
//        List<OrderApi__Sales_Order_Line__c> lines = [SELECT Id, OrderApi__Sales_Order__r.OrderApi__Contact__c, OrderApi__Sales_Order__c, OrderApi__Item_Class__r.Name
//        FROM OrderApi__Sales_Order_Line__c
//        WHERE OrderApi__Sales_Order__c =: Trigger.new[0].Id AND (OrderApi__Item_Class__r.Name = 'Prior Year Dues' OR OrderApi__Item_Class__r.Name = 'Individual Memberships')
//        ORDER BY OrderApi__Sales_Order__c];
//
//        if(lines.size()==1 && lines[0].OrderApi__Item_Class__r.Name == 'Prior Year Dues'){
//            ROEContactUpdateHandler.updateContactToMember(Trigger.new[0].OrderApi__Contact__c, true);
//        } else if(lines.size()==2){
//            if(lines[0].OrderApi__Item_Class__r.Name=='Individual Memberships' || lines[1].OrderApi__Item_Class__r.Name=='Individual Memberships'){
//                ROEContactUpdateHandler.updateContactToMember(Trigger.new[0].OrderApi__Contact__c, false);
//            }
//        } else if(lines.size()==1 && lines[0].OrderApi__Item_Class__r.Name == 'Individual Memberships'){
//            ROEContactUpdateHandler.updateContactToMember(Trigger.new[0].OrderApi__Contact__c, false);
//        }
//    }

}