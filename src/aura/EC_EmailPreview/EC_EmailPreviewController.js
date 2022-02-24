/**
 * Created by afaf.awad on 2/15/2021.
 */

({
    getTemplatePreview : function(cmp,event, helper){
        console.log('getting email preview...');
        var action = cmp.get("c.getEmailPreview");
        action.setParams({
            "emailId": cmp.get("v.emailId")
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var data = response.getReturnValue();
                // console.log('preview template body: ' + data);
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
    
});