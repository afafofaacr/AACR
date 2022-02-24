/**
 * Created by afaf.awad on 6/5/2020.
 */

({
    doInit: function (cmp, event, helper) {
        var action = cmp.get("c.isEligibleEvent");
        action.setParams({
            eventId: cmp.get('v.recordId')
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var response = response.getReturnValue();
                cmp.set('v.isEligible', response);
            } else if (state === "INCOMPLETE") {
                console.log('State = ' + state);
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
                cmp.set("v.processing", false);
            }
        });
        $A.enqueueAction(action);

    },

    gotoMassReg: function (cmp, event, helper) {
        cmp.set("v.processing", true);
        console.log('calling Mass reg service...');
        var pageReference = {
            type: 'standard__component',
            attributes: {
                componentName: 'c__BrEventsMassRegistration',
            },
            state: {
                "c__eventId": cmp.get("v.recordId")
            }
        };

        cmp.set("v.processing", false);
        var navService = cmp.find("navService");
        navService.navigate(pageReference);
    }
});