/**
 * Created by lauren.lezberg on 12/2/2020.
 */

({


    startPartialRefund : function(cmp){
        var action = cmp.get("c.processPartialRefund");
        action.setParams({
            "receiptId": cmp.get("v.recordId"),
            "recLinesJSON" : JSON.stringify(cmp.get("v.receiptLines"))
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var data = response.getReturnValue();
                console.log('data: ' + JSON.stringify(data));

                if(data.success) {
                    window.location.href = data.redirectURL;
                } else {
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "type": 'error',
                        "title": "Error",
                        "message": "Refund failed. " + data.errorMsg
                    });
                    toastEvent.fire();
                    var dismissActionPanel = $A.get("e.force:closeQuickAction");
                    dismissActionPanel.fire();
                }

            } else if (state === "INCOMPLETE") {
                // do something
                console.log('INCOMPLETE');
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

    startRefund : function(cmp){
        console.log('start refund...');
        var action = cmp.get("c.processRefund");
        action.setParams({
            "receiptId": cmp.get("v.recordId")
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var data = response.getReturnValue();
                console.log('data: ' + JSON.stringify(data));

                if(data.success) {
                    window.location.href = data.redirectURL;
                } else {
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "type": 'error',
                        "title": "Error",
                        "message": "Refund failed. " + data.errorMsg
                    });
                    toastEvent.fire();
                    var dismissActionPanel = $A.get("e.force:closeQuickAction");
                    dismissActionPanel.fire();
                }

            } else if (state === "INCOMPLETE") {
                // do something
                console.log('INCOMPLETE');
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
    }
});