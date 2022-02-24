/**
 * Created by afaf.awad on 10/28/2021.
 */

({
    executeBatch : function (cmp){
        var action = cmp.get("c.executeMassContactUpdate");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var jobId = response.getReturnValue();
                if (jobId) {
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        type: "success",
                        title: "BOOP successfully initiated!",
                        message: "Email will be sent to you when job is completed.",
                        mode : "sticky"
                    });
                    toastEvent.fire();

                    // if (state === "SUCCESS") {
                    //     cmp.set('v.processing', true);
                        // var interval = setInterval($A.getCallback(function () {
                        //     var jobStatus = cmp.get("c.getBatchJobStatus");
                        //     if (jobStatus != null) {
                        //         jobStatus.setParams({
                        //             jobId: response.getReturnValue()
                        //         });
                        //         jobStatus.setCallback(this, function (jobStatusResponse) {
                        //             var state = jobStatus.getState();
                        //             if (state === "SUCCESS") {
                        //                 var job = jobStatusResponse.getReturnValue();
                        //                 cmp.set('v.apexJob', job);
                        //                 var processedPercent = 0;
                        //                 if (job.JobItemsProcessed != 0) {
                        //                     processedPercent = (job.JobItemsProcessed / job.TotalJobItems) * 100;
                        //                 }
                        //                 var progress = cmp.get('v.progress');
                        //                 cmp.set('v.progress', processedPercent);
                        //
                        //                 // cmp.set('v.progress', progress === 100 ? clearInterval(interval) : processedPercent);
                        //             }
                        //         });
                        //         $A.enqueueAction(jobStatus);
                        //     }
                        // }), 2000);
                    // }
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