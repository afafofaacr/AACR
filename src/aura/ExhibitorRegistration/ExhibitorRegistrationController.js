/**
 * Created by lauren.lezberg on 2/26/2021.
 */

({
    doInit: function (cmp, event, helper) {
        console.log('exhibitor register init');
        // console.log('eventId: ' + eventId);

        var action = cmp.get("c.getContact");
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var data = response.getReturnValue();
                //console.log('data: ' + JSON.stringify(data));
                cmp.set("v.contactId", data);
            } else if (state === "INCOMPLETE") {
                console.log('Incomplete Callout:doInit');
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
    },

    onStepChange: function (cmp, event, helper) {
        console.log('onStepChange...');
        var stepId = event.getParam("stepId");
        var cmpName = event.getParam("cmpName");


        var nextStep = {};
        nextStep.stepId = stepId;
        nextStep.cmpName = cmpName;

        cmp.set("v.nextStep", nextStep);


        cmp.find('fSet').save();

    },

    goToNextStep: function (cmp, event, helper) {
        console.log('goToNextStep...');

        if (cmp.find("fSet").get("v.isValid")){

            var navEvt = $A.get("e.c:JP_NavigateEvt");

            navEvt.setParams({"stepId": cmp.get("v.nextStep").stepId});
            navEvt.setParams({"cmpName": cmp.get("v.nextStep").cmpName});
            navEvt.fire();

        } else {
            var navEvt = $A.get("e.c:JP_NavigateEvt");

            navEvt.setParams({"stepId": cmp.get("v.stepId")});
            navEvt.setParams({"cmpName": null});
            navEvt.fire();
        }

    }
});