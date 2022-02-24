/**
 * Created by lauren.lezberg on 12/11/2019.
 */
@isTest
private with sharing class MetadataCallbackTest {

    @IsTest
    static void testMyCallback() {

        // Instantiate the callback.
        Metadata.DeployCallback callback = new MetadataCallback();

        // Create test result and context objects.
        Metadata.DeployResult result = new Metadata.DeployResult();
        result.numberComponentErrors = 1;
        Metadata.DeployCallbackContext context = new Metadata.DeployCallbackContext();

        // Invoke the callback's handleResult method.
        callback.handleResult(result, context);
    }
    
}