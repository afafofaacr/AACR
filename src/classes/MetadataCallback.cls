/**
 * Created by lauren.lezberg on 9/6/2019.
 */

public class MetadataCallback implements Metadata.DeployCallback {

    public void handleResult(Metadata.DeployResult result,
            Metadata.DeployCallbackContext context) {
        if (result.status == Metadata.DeployStatus.Succeeded) {
            System.debug('success: '+ result);
        } else {
            System.debug('fail: '+ result.details);
            System.debug('Message: '+ result.errorMessage);
        }
    }

}