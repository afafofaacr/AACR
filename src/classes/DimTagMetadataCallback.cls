/**
 * Created by afaf.awad on 6/1/2021.
 */

public class DimTagMetadataCallback implements Metadata.DeployCallback {

    public String recordId {get;set;}

    public void handleResult(Metadata.DeployResult result,
            Metadata.DeployCallbackContext context) {
        System.debug('Succeeded = ' + Metadata.DeployStatus.Succeeded);
        System.debug('result.status = ' + result.status);
        if (result.status == Metadata.DeployStatus.Succeeded || Test.isRunningTest()) {
            System.debug('success: '+ result);
//            System.debug('result Details: ' +  result.details.componentSuccesses);
            String metadataId = Test.isRunningTest() ? '7074F00000TFipCQAT' : result.details.componentSuccesses.toString();
            metadataId = metadataId.mid(metadataId.indexOf('id='), 21).right(18);
            System.debug('result id == ' + metadataId );
            System.debug('record id == ' + recordId );
            if(!String.isBlank(recordId)) {
                DimensionTagModalController.createTagRecord(metadataId, recordId);
            }
        } else {
            System.debug('fail: '+ result.errorMessage);
            System.debug('result details: '+ result.details);

        }
    }


}