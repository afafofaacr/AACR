/**
 * Created by lauren.lezberg on 9/6/2019.
 */
({
    save : function(cmp, event, record){
        var action = cmp.get("c.saveSiteConfigs");
        action.setParams({
            "record": record
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "message": "Your request has been sent. You can check the status of this job from Setup > Deployment Status ",
                    "type" : "success"
                });
                toastEvent.fire();
                setTimeout(function(){ $A.get('e.force:refreshView').fire(); }, 5000);

            }
            else if (state === "INCOMPLETE") {
                console.log('Incomplete Callout');
            }
            else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " +
                            errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
        });
        $A.enqueueAction(action);

    }
})