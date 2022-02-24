/**
 * Created by lauren.lezberg on 6/22/2020.
 */
({

    doInit : function(cmp, event, helper){
        var recordId = cmp.get("v.recordId");
        console.log('recordId: ' + recordId);
        var action = cmp.get("c.getShowCmp");
        // set param to method
        action.setParams({
            'attId' : recordId
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var storeResponse = response.getReturnValue();
                cmp.set("v.showCmp", storeResponse);
            }  else if (state === "INCOMPLETE") {
                console.log('Could not get cmp visibility: Incomplete Callout');
            } else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Could not get cmp visibility - Error message: " +
                            errors[0].message);
                    }
                } else {
                    console.log("Could not get cmp visibility: Unknown error");
                }
            }

        });
        // enqueue the Action
        $A.enqueueAction(action);
    },

    sendToFreeman : function(cmp, event, helper){
        var recordId = cmp.get("v.recordId");
        console.log('recordId: ' + recordId);
        var action = cmp.get("c.resendAttendee");
        // set param to method
        action.setParams({
            'attId' : recordId
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var storeResponse = response.getReturnValue();

                if(storeResponse){
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Success!",
                        "type" : "success",
                        "message": "An email will be send to platformalerts@aacr.org if the callout failed. "
                    });
                    toastEvent.fire();
                } else {
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Failed!",
                        "type" : "error",
                        "message": "Unable to send record to freeman."
                    });
                    toastEvent.fire();
                }
            }else if (state === "INCOMPLETE") {
                console.log('Could not send to freeman: Incomplete Callout');
            } else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Could not send to freeman - Error message: " +
                            errors[0].message);
                    }
                } else {
                    console.log("Could not send to freeman: Unknown error");
                }
            }

        });
        // enqueue the Action
        $A.enqueueAction(action);
    }
})