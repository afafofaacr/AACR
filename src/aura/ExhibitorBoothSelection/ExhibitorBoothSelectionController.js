/**
 * Created by lauren.lezberg on 2/26/2021.
 */

({

    doInit: function(cmp, event, helper){
        var action = cmp.get("c.getBoothItems");
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var data = response.getReturnValue();
                //console.log('data: ' + JSON.stringify(data));
                cmp.set("v.boothItems", data);
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


    onStepChange : function(cmp, event, helper){
        var stepId = event.getParam("stepId");
        var cmpName = event.getParam("cmpName");

        var navEvt = $A.get("e.c:JP_NavigateEvt");

        navEvt.setParams({"stepId": stepId});
        navEvt.setParams({"cmpName": cmpName});
        navEvt.fire();
    }
});