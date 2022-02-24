/**
 * Created by afaf.awad on 7/14/2021.
 */

({
    getBatchJobStatus : function(cmp, batchId){
        var interval = setInterval($A.getCallback(function () {
            var jobStatus = cmp.get("c.getBatchJobStatus");
            if (jobStatus != null) {
                jobStatus.setParams({
                    jobId: batchId
                });
                jobStatus.setCallback(this, function (jobStatusResponse) {
                    var state = jobStatus.getState();
                    if (state === "SUCCESS") {
                        var job = jobStatusResponse.getReturnValue();
                        cmp.set('v.apexJob', job);
                        var processedPercent = 0;
                        if(job.Status == 'Completed' && job.JobItemsProcessed == 0 ){
                            processedPercent = 100;
                        }else if (job.JobItemsProcessed != 0) {
                            processedPercent = (job.JobItemsProcessed / job.TotalJobItems) * 100;
                        }
                        var progress = cmp.get('v.progress');
                        // cmp.set('v.progress', progress === 100 ? clearInterval(interval) : processedPercent);
                        cmp.set('v.progress', processedPercent);
                    }
                });
                $A.enqueueAction(jobStatus);
            }
        }), 2000);

    },

});