/**
 * Created by lauren.lezberg on 7/15/2021.
 */

({
    getAdvocateData : function(cmp){
        var action = cmp.get("c.getAdvocateInfo");
        action.setParams({
            "contactId": cmp.get("v.recordId")
        })
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var data = response.getReturnValue();
                console.log('data: ' + JSON.stringify(data));
                cmp.set("v.contactRecord", data.con);
                cmp.set("v.pendingTickets", data.tickets);

            } else if (state === "INCOMPLETE") {
                console.log('Could not get button visibility: Incomplete Callout');
            } else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Could not get button visibility - Error message: " +
                            errors[0].message);
                    }
                } else {
                    console.log("Could not get button visibility: Unknown error");
                }
            }
        });
        $A.enqueueAction(action);
    }
});