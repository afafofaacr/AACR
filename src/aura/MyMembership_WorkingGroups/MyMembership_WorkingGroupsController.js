/**
 * Created by lauren.lezberg on 4/21/2021.
 */

({
    doInit: function(cmp,event, helper){
        console.log('MyMembership_WorkingGroups init...');

        var action = cmp.get("c.getWorkingGroups");
        action.setParams({
            "contactId" : cmp.get('v.contactId')
        })
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var data = response.getReturnValue();

                cmp.set("v.workingGroups", data);
                cmp.set("v.isLoading", false);
            }
            else if (state === "INCOMPLETE") {
                console.log('Could not retrieve subscription data: Incomplete Callout');
                cmp.set("v.isLoading", false);
            }
            else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Could not retrieve subscription data - Error message: " +
                            errors[0].message);
                    }
                } else {
                    console.log("Could not retrieve subscription data: Unknown error");
                }
                cmp.set("v.isLoading", false);
            }

        });
        $A.enqueueAction(action);
    }
});