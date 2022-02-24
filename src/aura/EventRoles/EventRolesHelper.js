/**
 * Created by lauren.lezberg on 6/23/2020.
 */
({

    initialize : function(cmp, event){
        var action = cmp.get("c.getRoles");
        action.setParams({
            "eventId": cmp.get("v.recordId")
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var data = response.getReturnValue();
                console.log('roles data: ' + JSON.stringify(data));
                cmp.set("v.roles", data);

            } else if (state === "INCOMPLETE") {
                // do something

            } else if (state === "ERROR") {
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