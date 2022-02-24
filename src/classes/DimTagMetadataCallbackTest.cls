/**
 * Created by afaf.awad on 7/7/2021.
 */

@IsTest
private class DimTagMetadataCallbackTest {
    @IsTest
    static void testDimTagCallback() {

        Account acc = TestDataFactory.buildAccount('Test Account');
        insert acc;

        // Instantiate the callback.
        Metadata.DeployCallback callback = new DimTagMetadataCallback();

        // Create test result and context objects.
        Metadata.DeployResult result = new Metadata.DeployResult();
        result.numberComponentErrors = 1;
        Metadata.DeployCallbackContext context = new TestingDeployCallbackContext();

        // Invoke the callback's handleResult method.
        callback.handleResult(result, context);
    }

    // DeployCallbackContext subclass for testing that returns myJobId.
    public class TestingDeployCallbackContext extends Metadata.DeployCallbackContext {
        private Id myJobId = '7074F00000TFipCQAT'; // Set to a fixed ID you can use for testing.
        public override Id getCallbackJobId() {
            return myJobId;
        }
    }
    
}