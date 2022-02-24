/**
 * Created by lauren.lezberg on 4/8/2020.
 */
({

    doInit : function(cmp, event, helper){
        var action = cmp.get("c.getContent");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var data = response.getReturnValue();
                 // console.log('data: ' + JSON.stringify(data));
                cmp.set("v.events", data);
                cmp.set("v.isLoading", false);
            }
            else if (state === "INCOMPLETE") {
                console.log('Could not retrieve cart item data: Incomplete Callout');
            }
            else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Could not retrieve cart item data - Error message: " +
                            errors[0].message);
                    }
                } else {
                    console.log("Could not retrieve cart item data: Unknown error");
                }
            }
        });
        $A.enqueueAction(action);
    }
})