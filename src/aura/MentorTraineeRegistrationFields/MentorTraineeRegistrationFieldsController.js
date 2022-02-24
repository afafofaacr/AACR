/**
 * Created by lauren.lezberg on 4/28/2021.
 */

({
    getParticipantId : function(cmp, event, helper){
        console.log('getParticipantID from Mentor/Trainee cmp');
        var action = cmp.get("c.getParticipantFromSO");
        action.setParams({
            "salesOrderId": cmp.get("v.salesOrderId")
        })
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var resp = response.getReturnValue();
                console.log('resp: ' + resp);
                cmp.set("v.participantId", resp);
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
    }


});