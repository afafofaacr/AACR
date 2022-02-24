/**
 * Created by lauren.lezberg on 7/22/2021.
 */

({
    doInit : function(cmp, event, helper){
        console.log('sales order: ' + cmp.get('v.salesOrderId'));
        console.log('event: ' + cmp.get('v.eventId'));
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
                helper.getJointData(cmp);
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


    getParticipantId : function(cmp, event, helper){
        console.log('get participant id')
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