/**
 * Created by lauren.lezberg on 7/23/2021.
 */

({
    getJointData : function(cmp){
        var action = cmp.get("c.getJointInstitutionName");
        action.setParams({
            "participantId": cmp.get("v.participantId")
        })
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var resp = response.getReturnValue();
                // console.log('resp: ' + resp);
                cmp.set("v.institutionName", resp);
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