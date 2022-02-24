/**
 *@Purpose      : Web service to update salesforce transaction records.
 *@Created date : 26-09-2018
 */
@RestResource(urlMapping='/Transaction/')
Global with sharing class DW_UpdateTransactionWebService {

    @HttpPatch
    Global Static ResponseObject updateTransaction(String transactionNumber, String GPBatchId){

        if(String.isNotBlank(transactionNumber) && String.isNotBlank(GPBatchId)){
            OrderApi__Transaction__c sfTransaction;

            try{
                sfTransaction = [SELECT Id, GP_Batch_Number__c
                FROM OrderApi__Transaction__c
                WHERE Name =: transactionNumber] ;
            }
            catch(Exception exp){
                return new responseObject(false, 'TransactionId does not exist');
            }

            // Check if record is NULL or not
            if(sfTransaction != NULL){
                sfTransaction.GP_Batch_Number__c = GPBatchId;
                try{
                    // Updating transaction
                    update sfTransaction;

                    return new responseObject(true, 'Transaction record updated successfully');
                }
                catch(Exception exp){

                    return new responseObject(true, exp.getMessage());
                }
            }
        } else {
            return new responseObject(false, 'Missing parameters');
        }
        return new ResponseObject(false, 'Provide TransactionId and BatchId to get access to web service');
    }

    /**
     *@Purpose : Wrapper class for result
     */
    global class ResponseObject{
        public Boolean isSuccess;
        public String message;

        public ResponseObject( Boolean isSuccess, String message ) {
            this.isSuccess = isSuccess;
            this.message = message;
        }
    }
}