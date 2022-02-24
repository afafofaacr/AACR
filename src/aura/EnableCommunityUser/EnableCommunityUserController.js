/**
 * Created by afaf.awad on 8/4/2021.
 */

({
    doInit : function(cmp, event, helper) {
        let action = cmp.get("c.activateUser");
        action.setParams({
            'contactId' : cmp.get('v.recordId')
        });
        action.setCallback(this, function (response) {
            let state = response.getState();
            if (state === "SUCCESS") {
                console.log('user enabled successfully');
                $A.get("e.force:closeQuickAction").fire();
                location.reload();

            } else if (state === "INCOMPLETE") {
                console.log('Incomplete Callout: - doInit');
            } else if (state === "ERROR") {
                let errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message - doInit:::: " +
                            errors[0].message);
                    }
                } else {
                    console.log("Unknown error: doInit");
                }
            }
        });
        $A.enqueueAction(action);

    }

});