/**
 * Created by lauren.lezberg on 3/18/2020.
 */
({
    getTemplatePreview : function(cmp,event, helper){
        var action = cmp.get("c.getEmailTemplateBody");
        action.setParams({
            "eventId": cmp.get("v.eventId")
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var data = response.getReturnValue();
                // console.log('data: ' + data);
                cmp.set("v.templateBody", data);
            } else if (state === "INCOMPLETE") {
                console.log("Error: Incomplete callout.");
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