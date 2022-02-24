/**
 *@Purpose      : Test class for DW_UpdateTransactionWebService
 *@Created Date : 03-10-2018
 *@Modified Date: 03-10-2018
 */
@isTest
public class DW_UpdateTransactionWebServiceTest {
	/**
     *@purpose   : build test data.
     */
    @testSetup
    private static void buildTestData(){
        OrderApi__Transaction__c transactionRecord = buildTransaction();
        insert transactionRecord;
    }
    
    /**
     *@purpose   : build Transaction record
     *@param     : 
     *@return    : Transaction record
     */
    static OrderApi__Transaction__c buildTransaction(){
        return new OrderApi__Transaction__c(GP_Batch_Number__c = '',
                                            OrderApi__Type__c = 'Adjustment');
    }
    
    /**
     *@Purpose : test updateTransaction() positively 
     */
    static testMethod void posTestUpdateTransaction(){
        
        String transactionJSON = '[{"transctionNumber":"a1R0U0000006ffg", "GPBatchId": "123456789"}]';
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        
        req.requestURI = '/services/apexrest/Transaction/';
        req.httpMethod = 'PATCH';
        req.requestBody = Blob.valueof(transactionJSON);
        
        RestContext.request = req;
        RestContext.response= res;
        
        OrderApi__Transaction__c transactionRecord = [SELECT Id, GP_Batch_Number__c, Name
                                                      FROM OrderApi__Transaction__c 
                                                      WHERE  OrderApi__Type__c = 'Adjustment'];
        
        Test.startTest();
        
        DW_UpdateTransactionWebService.ResponseObject positiveResponse = DW_UpdateTransactionWebService.updateTransaction(transactionRecord.Name, '123456');
        // Fetching updated transaction
        OrderApi__Transaction__c updatedTransaction = [SELECT Id, GP_Batch_Number__c 
                                                       FROM OrderApi__Transaction__c 
                                                       WHERE  OrderApi__Type__c = 'Adjustment'];
        
        System.assertEquals('123456', updatedTransaction.GP_Batch_Number__c);
        System.assertEquals(true, positiveResponse.isSuccess);
        System.assertEquals('Transaction record updated successfully',positiveResponse.message);
     
        Test.stopTest();
    }
    
    /**
     *@Purpose : test updateTransaction() negatively 
     */
    static testMethod void negTestUpdateTransaction(){
        String transactionJSON = '[{"transctionNumber":"88888", "GPBatchId": "123456789"}]';
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        
        req.requestURI = '/services/apexrest/Transaction/';
        req.httpMethod = 'PATCH';
        req.requestBody = Blob.valueof(transactionJSON);
        
        RestContext.request = req;
        RestContext.response= res;
        
        Test.startTest();  
        
        DW_UpdateTransactionWebService.ResponseObject negativeResponse1 = DW_UpdateTransactionWebService.updateTransaction('88888', '123456');
        System.assertEquals(false, negativeResponse1.isSuccess);
        System.assertEquals('TransactionId does not exist',negativeResponse1.message);
        
        DW_UpdateTransactionWebService.ResponseObject negativeResponse2 = DW_UpdateTransactionWebService.updateTransaction('', '');
       
        Test.stopTest();
    }
}