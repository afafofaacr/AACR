/**
 * Created by afaf.awad on 8/11/2021.
 */

({
    doInit : function(cmp, event, helper) {
        let action = cmp.get("c.getLoginURL");
        action.setParams({
            'contactId' : cmp.get('v.recordId')
        });
        action.setCallback(this, function (response) {
            let state = response.getState();
            if (state === "SUCCESS") {
                let url = response.getReturnValue();
                $A.get("e.force:closeQuickAction").fire();
                window.open(url, '_blank');

            } else if (state === "INCOMPLETE") {
                console.log('Incomplete Callout: - login');
            } else if (state === "ERROR") {
                let errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message - login:::: " +
                            errors[0].message);
                    }
                } else {
                    console.log("Unknown error: login");
                }
            }
        });
        $A.enqueueAction(action);

    }
});