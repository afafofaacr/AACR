/**
 * Created by lauren.lezberg on 9/6/2019.
 */
({
    saveRenewalSetting : function(cmp, event){
        var action = cmp.get("c.saveRenewalSettings");
        action.setParams({
            "record" : cmp.get("v.processSetting")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var data = response.getReturnValue();
                $A.get('e.force:refreshView').fire();
            }
            else if (state === "INCOMPLETE") {
                // do something
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