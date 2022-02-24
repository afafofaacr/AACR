/**
 * Created by afaf.awad on 11/19/2020.
 */

({
    executeBatch : function (cmp){
        var action = cmp.get("c.findNewIncomeLevels");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var jobId = response.getReturnValue();
                if (jobId) {
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "type": "success",
                        "title": "Success!",
                        "message": "World Bank process successfully initiated."
                    });
                    toastEvent.fire();

                    if (state === "SUCCESS") {
                        var interval = setInterval($A.getCallback(function () {
                            var jobStatus = cmp.get("c.getWB_BatchJobStatus");
                            if (jobStatus != null) {
                                jobStatus.setParams({
                                    jobId: response.getReturnValue()
                                });
                                jobStatus.setCallback(this, function (jobStatusResponse) {
                                    var state = jobStatus.getState();
                                    if (state === "SUCCESS") {
                                        var job = jobStatusResponse.getReturnValue();
                                        cmp.set('v.apexJob', job);
                                        var processedPercent = 0;
                                        if (job.JobItemsProcessed != 0) {
                                            processedPercent = (job.JobItemsProcessed / job.TotalJobItems) * 100;
                                        }
                                        var progress = cmp.get('v.progress');
                                        cmp.set('v.progress', processedPercent);

                                        // cmp.set('v.progress', progress === 100 ? clearInterval(interval) : processedPercent);
                                    }
                                });
                                $A.enqueueAction(jobStatus);
                            }
                        }), 2000);
                    }
                }else{
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "type": "info",
                        "title": "Finished!",
                        "message": "No new income levels to update."
                    });
                    toastEvent.fire();
                }
            }
            else if (state === "ERROR") {
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "type": "error",
                    "title": "Error!",
                    "message": "An Error has occurred. Please try again or contact System Administrator."
                });
                toastEvent.fire();
            }
        });
        $A.enqueueAction(action);

    }
});