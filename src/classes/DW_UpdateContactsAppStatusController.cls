/**
 *@Purpose      : Update contacts application status when sales order gets created or updated and its posting status is pending
 *@Created Date : 11-10-2018
 *@Modified Date: 11-10-2018
 */
public class DW_UpdateContactsAppStatusController {

    /**
     *@purpose : update contact's application status after update
     *@param   : newSalesOrderList, oldSalesOrderMap
     *@return  : 
     */
    public static void onafterUpdateSO(List<OrderApi__Sales_Order__c> newSalesOrderList, Map<Id,OrderApi__Sales_Order__c> oldSalesOrderMap){
        OrderApi__Sales_Order__c oldSalesOrder;
        List<OrderApi__Sales_Order__c> salesOderToUpdateList = new List<OrderApi__Sales_Order__c>();
        
        for(OrderApi__Sales_Order__c newSalesOrder : newSalesOrderList){
            oldSalesOrder = oldSalesOrderMap.get(newSalesOrder.Id);
            
            // check if previous sales order posting status not equals to new updated status
            if(newSalesOrder.OrderApi__Posting_Status__c != oldSalesOrder.OrderApi__Posting_Status__c ||
               newSalesOrder.OrderApi__Contact__c != oldSalesOrder.OrderApi__Contact__c){
                salesOderToUpdateList.add(newSalesOrder);                                                   
            }
        }
        if(! salesOderToUpdateList.isEmpty()){
            // update contact
            updateContactsAppStatus(salesOderToUpdateList);
        }
    }
    
    /**
     *@purpose : update contact's application status 
     *@param   : newSalesOrderList
     *@return  : 
     */
    public static void updateContactsAppStatus(List<OrderApi__Sales_Order__c> newSalesOrderList){
        List<Contact> contactToUpdateList = new List<Contact>();
        
        for(OrderApi__Sales_Order__c salesOrder : [SELECT Id, OrderApi__Posting_Status__c, OrderApi__Contact__c,
                                                          OrderApi__Contact__r.RecordType.Name,
                                                          OrderApi__Contact__r.Application_Status__c
                                                   FROM OrderApi__Sales_Order__c
                                                   WHERE Id IN : newSalesOrderList AND
                                                         OrderApi__Contact__r.RecordType.Name !=: Label.Contact_Non_Member_Record_Type]){
                                                             
          if(salesOrder.OrderApi__Posting_Status__c == Label.DW_SO_Posting_Status){
                // update contact application status
                salesOrder.OrderApi__Contact__r.Application_Status__c = Label.DW_Contact_App_Status;
                contactToUpdateList.add(salesOrder.OrderApi__Contact__r);
                System.debug('contactToUpdateList==>'+contactToUpdateList);
          }                                                 
       }
       if(! contactToUpdateList.isEmpty()){
          // Update contactToUpdateList 
          update contactToUpdateList;
       } 
    }
}