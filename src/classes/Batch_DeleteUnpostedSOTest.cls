@isTest
public class Batch_DeleteUnpostedSOTest {
    
    @isTest public static void testDeleteWithNoRecords(){
        List<OrderApi__Sales_Order__c> SOToDelete = [SELECT Id FROM OrderApi__Sales_Order__c WHERE OrderApi__Posting_Status__c != 'Posted' AND (OrderApi__Status__c = 'Cancelled' OR OrderApi__Status__c = 'Open') AND CreatedDate < LAST_N_DAYS:90];
        System.assert(SOToDelete.size()==0, 'There should be no sales orders marked for deletion');
        
        Test.startTest();
        Batch_DeleteUnpostedSO obj = new Batch_DeleteUnpostedSO();
        DataBase.executeBatch(obj);    
        Test.stopTest();
        
        SOToDelete = [SELECT Id FROM OrderApi__Sales_Order__c WHERE OrderApi__Posting_Status__c != 'Posted' AND (OrderApi__Status__c = 'Cancelled' OR OrderApi__Status__c = 'Open') AND CreatedDate < LAST_N_DAYS:90];
        System.assert(SOToDelete.size()==0, 'There should still be no sales orders marked for deletion.');
        
    }
    
    @isTest public static void testBatchDeleteOpen(){
        TestDataFactory dataFactory = new TestDataFactory();
        List<OrderApi__Sales_Order__c> lstSO = dataFactory.createOpenUnpostedSalesOrders(200);
        
        Integer i=0;
        //set half creation dates to 90 days ago
        for(OrderApi__Sales_Order__c s: lstSO){
            if(math.mod(i, 2) == 0){
                Test.setCreatedDate(s.Id, Date.today().addDays(-90));
            }
            i++;
        }


        
        List<OrderApi__Sales_Order__c> SOToDelete = [SELECT Id FROM OrderApi__Sales_Order__c WHERE OrderApi__Posting_Status__c != 'Posted' AND (OrderApi__Status__c = 'Cancelled' OR OrderApi__Status__c = 'Open') AND CreatedDate < LAST_N_DAYS:90];
        System.assertEquals(100, SOToDelete.size(), '100 Sales Orders should be marked for deletion');
        
        Test.startTest();
        Batch_DeleteUnpostedSO obj = new Batch_DeleteUnpostedSO();
        DataBase.executeBatch(obj);    
        Test.stopTest();
        
        SOToDelete = [SELECT Id FROM OrderApi__Sales_Order__c WHERE OrderApi__Posting_Status__c != 'Posted' AND (OrderApi__Status__c = 'Cancelled' OR OrderApi__Status__c = 'Open') AND CreatedDate < LAST_N_DAYS:90];
        System.assert(SOToDelete.size()==0, 'No more sales orders should be marked for deletion');
    }

    @isTest public static void testBatchDeleteCancelled(){
        TestDataFactory dataFactory = new TestDataFactory();
        List<OrderApi__Sales_Order__c> lstSO = dataFactory.createCancelledUnpostedSalesOrders(200);

        Integer i=0;
        //set half creation dates to 90 days ago
        for(OrderApi__Sales_Order__c s: lstSO){
            if(math.mod(i, 2) == 0){
                Test.setCreatedDate(s.Id, Date.today().addDays(-91));
            }
            i++;
        }

        List<OrderApi__Sales_Order__c> SOToDelete = [SELECT Id FROM OrderApi__Sales_Order__c WHERE OrderApi__Posting_Status__c != 'Posted' AND (OrderApi__Status__c = 'Cancelled' OR OrderApi__Status__c = 'Open') AND CreatedDate < LAST_N_DAYS:90];
        System.assertEquals(100, SOToDelete.size(), '100 Sales Orders should be marked for deletion');

        Test.startTest();
        Batch_DeleteUnpostedSO obj = new Batch_DeleteUnpostedSO();
        DataBase.executeBatch(obj);
        Test.stopTest();

        SOToDelete = [SELECT Id FROM OrderApi__Sales_Order__c WHERE OrderApi__Posting_Status__c != 'Posted' AND (OrderApi__Status__c = 'Cancelled' OR OrderApi__Status__c = 'Open') AND CreatedDate < LAST_N_DAYS:90];
        System.assert(SOToDelete.size()==0, 'No more sales orders should be marked for deletion');
    }
}